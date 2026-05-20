# Integración Tonel con MCP (Model Context Protocol)

Este documento diseña la integración de Tonel con MCP para que agentes de IA puedan leer y escribir código Smalltalk en formato Tonel directamente desde el filesystem, sin necesitar una imagen Cuis corriendo.

---

## Contexto

**Tonel** es un formato file-per-class para Smalltalk. Cada clase o extensión de clase vive en un archivo `.st` independiente con una sintaxis bien definida. Esto hace que el código Smalltalk sea legible y manipulable desde herramientas externas.

**MCP (Model Context Protocol)** es un protocolo que permite exponer herramientas que un agente de IA puede invocar durante una sesión. El agente describe qué quiere hacer y el servidor MCP ejecuta la operación correspondiente.

**La idea central**: el agente puede leer y escribir código Smalltalk directamente desde el filesystem Tonel, sin imagen Cuis. El servidor MCP vive en el repo `cuis-tonel` y puede ser un script Node.js, Python, o Smalltalk headless.

---

## Arquitectura general

```
Agente de IA
    │
    │  invoca herramientas MCP (JSON-RPC)
    ▼
MCP Server (Node.js / Python)
    │
    │  lee/escribe archivos .st
    ▼
Filesystem Tonel
    │
    │  (opcional, para validación o carga)
    ▼
Imagen Cuis (headless)
```

El flujo principal es: agente → MCP server → filesystem Tonel. La imagen Cuis es opcional y solo entra en juego si se quiere validar sintaxis o ejecutar código.

---

## Herramientas MCP

### `tonel_read_class`

Lee la definición completa de una clase desde un archivo `.st` Tonel y la devuelve como JSON estructurado.

**Parámetros**

| Nombre | Tipo   | Descripción                              |
|--------|--------|------------------------------------------|
| `path` | string | Ruta absoluta o relativa al archivo `.st` |

**Resultado**

JSON con las siguientes claves:

```json
{
  "name": "NombreDeLaClase",
  "superclass": "NombreDelSuperclass",
  "instVars": ["var1", "var2"],
  "classVars": ["Var1"],
  "comment": "Comentario de la clase.",
  "methods": [
    {
      "selector": "nombreDelMetodo",
      "category": "accessing",
      "body": "nombreDelMetodo\n\t^ valor"
    }
  ]
}
```

**Ejemplo de invocación**

```json
{
  "tool": "tonel_read_class",
  "arguments": {
    "path": "src/Collections/OrderedCollection.class.st"
  }
}
```

**Ejemplo de respuesta**

```json
{
  "name": "OrderedCollection",
  "superclass": "SequenceableCollection",
  "instVars": ["firstIndex", "lastIndex"],
  "classVars": [],
  "comment": "I am a collection whose elements are kept in order.",
  "methods": [
    {
      "selector": "add:",
      "category": "adding",
      "body": "add: anObject\n\t^ self addLast: anObject"
    }
  ]
}
```

---

### `tonel_list_package`

Lista todas las clases y extensiones de clase definidas en un directorio Tonel.

**Parámetros**

| Nombre      | Tipo   | Descripción                           |
|-------------|--------|---------------------------------------|
| `directory` | string | Ruta al directorio del paquete Tonel  |

**Resultado**

```json
[
  {
    "file": "OrderedCollection.class.st",
    "name": "OrderedCollection",
    "type": "class"
  },
  {
    "file": "Collection.extension.st",
    "name": "Collection",
    "type": "extension"
  }
]
```

**Ejemplo de invocación**

```json
{
  "tool": "tonel_list_package",
  "arguments": {
    "directory": "src/Collections"
  }
}
```

**Ejemplo de respuesta**

```json
[
  { "file": "OrderedCollection.class.st", "name": "OrderedCollection", "type": "class" },
  { "file": "SortedCollection.class.st",  "name": "SortedCollection",  "type": "class" },
  { "file": "Collection.extension.st",    "name": "Collection",        "type": "extension" }
]
```

---

### `tonel_read_method`

Devuelve el cuerpo de un método específico dentro de un archivo `.st`.

**Parámetros**

| Nombre     | Tipo   | Descripción                                |
|------------|--------|--------------------------------------------|
| `path`     | string | Ruta al archivo `.st`                      |
| `selector` | string | Selector del método (ej: `add:`, `size`)   |

**Resultado**

```json
{
  "selector": "add:",
  "category": "adding",
  "body": "add: anObject\n\t^ self addLast: anObject"
}
```

Si el método no existe, se retorna un error descriptivo (ver sección de errores).

**Ejemplo de invocación**

```json
{
  "tool": "tonel_read_method",
  "arguments": {
    "path": "src/Collections/OrderedCollection.class.st",
    "selector": "add:"
  }
}
```

**Ejemplo de respuesta**

```json
{
  "selector": "add:",
  "category": "adding",
  "body": "add: anObject\n\t^ self addLast: anObject"
}
```

---

### `tonel_write_class`

Escribe o actualiza un archivo `.st` con la definición completa de una clase. La operación es idempotente.

**Parámetros**

| Nombre       | Tipo   | Descripción                                           |
|--------------|--------|-------------------------------------------------------|
| `path`       | string | Ruta donde escribir el archivo `.st`                  |
| `definition` | object | Definición de la clase (mismo formato que `tonel_read_class`) |

**Resultado**

```json
{
  "status": "ok",
  "path": "src/Collections/OrderedCollection.class.st",
  "action": "updated"
}
```

`action` puede ser `"created"` (archivo nuevo) o `"updated"` (archivo existente modificado).

**Ejemplo de invocación**

```json
{
  "tool": "tonel_write_class",
  "arguments": {
    "path": "src/Collections/OrderedCollection.class.st",
    "definition": {
      "name": "OrderedCollection",
      "superclass": "SequenceableCollection",
      "instVars": ["firstIndex", "lastIndex"],
      "classVars": [],
      "comment": "I am a collection whose elements are kept in order.",
      "methods": [
        {
          "selector": "add:",
          "category": "adding",
          "body": "add: anObject\n\t^ self addLast: anObject"
        }
      ]
    }
  }
}
```

**Ejemplo de respuesta**

```json
{
  "status": "ok",
  "path": "src/Collections/OrderedCollection.class.st",
  "action": "updated"
}
```

---

### `tonel_write_method`

Escribe o actualiza un método específico dentro de un archivo `.st`. Si el método ya existe, lo reemplaza. Si no existe, lo agrega.

**Parámetros**

| Nombre      | Tipo   | Descripción                                      |
|-------------|--------|--------------------------------------------------|
| `path`      | string | Ruta al archivo `.st`                            |
| `selector`  | string | Selector del método                              |
| `body`      | string | Cuerpo completo del método (incluyendo selector) |
| `metadata`  | object | Metadatos opcionales: `{ "category": "..." }`   |

**Resultado**

```json
{
  "status": "ok",
  "selector": "add:",
  "action": "updated"
}
```

**Ejemplo de invocación**

```json
{
  "tool": "tonel_write_method",
  "arguments": {
    "path": "src/Collections/OrderedCollection.class.st",
    "selector": "add:",
    "body": "add: anObject\n\t^ self addLast: anObject",
    "metadata": { "category": "adding" }
  }
}
```

**Ejemplo de respuesta**

```json
{
  "status": "ok",
  "selector": "add:",
  "action": "updated"
}
```

---

### `tonel_find_implementors`

Busca en un directorio qué clases implementan un selector dado.

**Parámetros**

| Nombre      | Tipo   | Descripción                          |
|-------------|--------|--------------------------------------|
| `directory` | string | Directorio raíz donde buscar         |
| `selector`  | string | Selector a buscar (ej: `printOn:`)   |

**Resultado**

```json
[
  {
    "class": "OrderedCollection",
    "file": "src/Collections/OrderedCollection.class.st",
    "category": "printing"
  }
]
```

**Ejemplo de invocación**

```json
{
  "tool": "tonel_find_implementors",
  "arguments": {
    "directory": "src",
    "selector": "printOn:"
  }
}
```

**Ejemplo de respuesta**

```json
[
  { "class": "OrderedCollection", "file": "src/Collections/OrderedCollection.class.st", "category": "printing" },
  { "class": "SortedCollection",  "file": "src/Collections/SortedCollection.class.st",  "category": "printing" }
]
```

---

### `tonel_find_senders`

Busca en un directorio qué métodos envían un mensaje con el selector dado.

**Parámetros**

| Nombre      | Tipo   | Descripción                        |
|-------------|--------|------------------------------------|
| `directory` | string | Directorio raíz donde buscar       |
| `selector`  | string | Selector a buscar como envío       |

**Resultado**

```json
[
  {
    "class": "OrderedCollection",
    "method": "addLast:",
    "file": "src/Collections/OrderedCollection.class.st"
  }
]
```

**Ejemplo de invocación**

```json
{
  "tool": "tonel_find_senders",
  "arguments": {
    "directory": "src",
    "selector": "printOn:"
  }
}
```

**Ejemplo de respuesta**

```json
[
  { "class": "Transcript", "method": "show:", "file": "src/System/Transcript.class.st" },
  { "class": "Inspector",  "method": "inspect", "file": "src/Tools/Inspector.class.st" }
]
```

---

## Decisiones de diseño

### Por qué MCP

MCP es el protocolo estándar emergente para exponer herramientas a agentes de IA. Usar MCP significa que cualquier agente compatible (Claude, GPT, Gemini, etc.) puede usar estas herramientas sin adaptación adicional. Alternativas como APIs REST propias o LSP fueron descartadas porque requieren más infraestructura y no están diseñadas para el contexto de agentes.

### Por qué sin imagen para las herramientas de lectura

Las herramientas de lectura (`tonel_read_class`, `tonel_list_package`, `tonel_read_method`, `tonel_find_implementors`, `tonel_find_senders`) trabajan únicamente sobre el filesystem. Esto las hace:

- **Portables**: funcionan en cualquier entorno sin dependencias de imagen Cuis.
- **Rápidas**: no hay overhead de VM ni de carga de imagen.
- **Predecibles**: el resultado depende solo del contenido del archivo, no del estado de la imagen.

Las herramientas de escritura también trabajan sobre el filesystem, pero en el futuro podrían opcionalmente sincronizar con una imagen corriendo.

### Sin estado de imagen

Todas las operaciones son stateless respecto a la imagen Cuis. El servidor MCP no mantiene una imagen cargada entre llamadas. Si se necesita validar sintaxis o ejecutar código, eso es una operación separada y explícita.

### JSON como formato de intercambio

JSON es el formato natural para MCP. La estructura elegida para `tonel_read_class` mapea directamente a los conceptos Tonel: metadata de clase + lista de métodos. Cada método tiene `selector`, `category` y `body` como campos de primer nivel.

### Idempotencia de las escrituras

`tonel_write_class` y `tonel_write_method` son idempotentes: llamarlos varias veces con los mismos datos produce el mismo resultado. Esto es importante para workflows de agentes donde una misma herramienta puede invocarse múltiples veces por reintentos o por diseño.

### Logs y errores descriptivos

Cada operación:
- Loguea a stderr: qué herramienta se invocó, con qué argumentos, y qué resultado produjo.
- En caso de error, retorna un objeto con `"status": "error"` y un campo `"message"` que describe exactamente qué falló:

```json
{
  "status": "error",
  "message": "Archivo no encontrado: src/Collections/OrderedCollection.class.st"
}
```

```json
{
  "status": "error",
  "message": "Método 'foo:' no encontrado en OrderedCollection"
}
```

```json
{
  "status": "error",
  "message": "Formato inválido en línea 12: se esperaba '!' al final del método"
}
```

---

## Roadmap

### Fase 1: Lectura (prioridad alta)

Construir primero las herramientas de lectura porque:
- Son las más útiles para que el agente entienda el código existente.
- No tienen riesgo de corrupción de datos.
- Permiten validar el parser Tonel antes de usarlo para escritura.

Herramientas en esta fase:
1. `tonel_read_class`
2. `tonel_list_package`
3. `tonel_read_method`

### Fase 2: Búsqueda

Herramientas de navegación que no requieren parser completo, solo búsqueda textual sobre el filesystem:

4. `tonel_find_implementors`
5. `tonel_find_senders`

### Fase 3: Escritura

Las más delicadas porque modifican el filesystem. Requieren que el parser Tonel esté validado:

6. `tonel_write_method`
7. `tonel_write_class`

### Fase 4: Integración con imagen (opcional)

- `tonel_validate_class`: carga la clase en una imagen headless y reporta errores de compilación.
- `tonel_run_tests`: ejecuta los tests de un paquete en imagen headless.

---

## Implementación recomendada para la primera iteración

**Node.js con `@modelcontextprotocol/sdk`.**

Razones:
- El SDK oficial de MCP para Node.js está maduro y bien documentado.
- El parser Tonel puede implementarse como un módulo JavaScript simple (el formato es regular y bien especificado).
- No requiere dependencias externas pesadas.
- Fácil de distribuir y ejecutar en CI.

Estructura de archivos sugerida:

```
cuis-tonel/
  mcp/
    server.js          # Entry point del servidor MCP
    tonel-parser.js    # Parser de archivos .st
    tonel-writer.js    # Escritura/serialización de archivos .st
    tools/
      read-class.js
      list-package.js
      read-method.js
      write-class.js
      write-method.js
      find-implementors.js
      find-senders.js
    package.json
```
