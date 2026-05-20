# Diseño del modelo de objetos — Tonel para Cuis Smalltalk

Documento de diseño para implementar el soporte de formato Tonel en Cuis Smalltalk, sin dependencias de Pharo, sin jerarquías innecesarias, sin metaprogramación compleja.

---

## Contexto

Tonel es un formato file-per-class para Smalltalk. Cada archivo `.st` representa una clase o extensión, con sus métodos. La especificación del formato es:

```
[" comment "]
Class|Trait|Extension { metadata STON }
(
    [{ methodMetadata }]
    ClassName >> selector [
        methodBody
    ]
)*
```

El metadata es STON plano:

```
{ #name: 'Foo', #superclass: 'Object', #instVars: ['x', 'y'] }
```

Un directorio Tonel contiene además un archivo `package.st` con el metadata del paquete.

---

## Principios de diseño

- **Simple**: pocas clases, responsabilidades claras, sin herencias innecesarias.
- **Smalltalk idiomático Cuis**: no Pharo, sin dependencias externas al paquete.
- **Los resultados del parse son Dictionaries**: no se introducen objetos de dominio propios para representar definiciones. Esto mantiene el código liviano y fácil de inspeccionar.
- **MCP-friendly**: las operaciones principales son invocables como herramientas sin estado de imagen acumulado.
- **Bien documentado**: cada clase y método con comentario de clase.

---

## Diagrama del modelo

```
Capa 1 — Parsing
┌─────────────────────┐     usa     ┌──────────────────────┐
│    TonelParser      │────────────>│  TonelStonParser     │
│  stream: ReadStream │             │  stream: ReadStream  │
└─────────────────────┘             └──────────────────────┘
         │
         │ produce
         ▼
  OrderedCollection of Dictionary
  (type definition + method definitions)

Capa 2 — Reading
┌─────────────────────┐     usa     ┌─────────────────────┐
│    TonelReader      │────────────>│   TonelParser       │
│  directory: String  │             └─────────────────────┘
└─────────────────────┘
         │
         │ produce
         ▼
  Dictionary { #name, #classes, #extensions }

Capa 3 — Writing
┌─────────────────────┐
│    TonelWriter      │
│  stream: WriteStream│
└─────────────────────┘
         │
         │ consume CodePackage → produce
         ▼
  String (texto Tonel válido)

Capa 4 — MCP Interface
┌──────────────────────┐     usa     ┌─────────────────────┐
│  TonelMCPServer      │────────────>│   TonelReader       │
│  (sin ivars de estado│             │   TonelWriter       │
│   de imagen)         │             └─────────────────────┘
└──────────────────────┘
```

---

## Capa 1 — Parsing

### TonelParser

**Responsabilidad**: parsear el texto de un archivo `.st` de Tonel y producir una colección de Dictionaries: uno con la definición del tipo (clase, trait o extensión) y N con las definiciones de métodos.

**Ivars**:
- `stream` — `ReadStream` sobre el `String` del contenido del archivo.

**Mensajes públicos principales**:

| Mensaje | Descripción |
|---|---|
| `TonelParser on: aString` | Constructor. Crea un parser sobre el contenido dado. |
| `parse` | Ejecuta el parse completo. Devuelve una `OrderedCollection` de `Dictionary`. |

**Formato del resultado**:

```smalltalk
"Definición de tipo (primer elemento):"
{
  #type -> 'class',         "o 'trait' o 'extension'"
  #name -> 'MyClass',
  #superclass -> 'Object',
  #instVars -> #('x' 'y'),
  #comment -> 'Optional comment.'
}

"Definición de método (elementos siguientes):"
{
  #type -> 'method',
  #className -> 'MyClass',
  #selector -> 'foo',
  #protocol -> 'accessing',
  #source -> 'foo\n\t^x'
}
```

**Ejemplo de uso**:

```smalltalk
| content result |
content := FileStream readOnlyFileNamed: 'MyClass.st'.
result := TonelParser on: content contents.
result parse.
"=> OrderedCollection(
     Dictionary(#type->'class' #name->'MyClass' ...),
     Dictionary(#type->'method' #selector->'foo' ...),
     ...
)"
```

**Sin dependencias externas** salvo `TonelStonParser` para parsear los bloques de metadata.

---

### TonelStonParser

**Responsabilidad**: parsear el subconjunto mínimo de STON que usa Tonel. No es un parser STON completo; solo maneja el subset necesario para los bloques de metadata de Tonel.

**Ivars**:
- `stream` — `ReadStream` sobre el `String` del bloque STON.

**Subset soportado**:

| Construcción | Ejemplo |
|---|---|
| Dictionary literal | `{ #key: 'value' }` |
| String value | `'MyClass'` |
| Symbol value | `#instVars` |
| Array de Strings | `['x' 'y']` |
| Nil / true / false | `nil`, `true`, `false` |

**Mensajes públicos principales**:

| Mensaje | Descripción |
|---|---|
| `TonelStonParser on: aString` | Constructor. |
| `parse` | Devuelve un `Dictionary` con las claves y valores del bloque. |

**Ejemplo de uso**:

```smalltalk
| result |
result := TonelStonParser on: '{ #name: ''Foo'', #superclass: ''Object'', #instVars: [''x'' ''y''] }'.
result parse.
"=> Dictionary(#name->'Foo' #superclass->'Object' #instVars->OrderedCollection('x' 'y'))"
```

**Nota**: si en el futuro se necesita STON más completo, se puede delegar a la librería STON de Cuis sin cambiar la interfaz pública.

---

## Capa 2 — Reading

### TonelReader

**Responsabilidad**: leer un directorio con estructura Tonel y devolver una descripción del paquete como `Dictionary`. Coordina la lectura de `package.st` y de cada archivo de clase o extensión.

**Ivars**:
- `directory` — `String` con el path al directorio Tonel, o `FileDirectory`.

**Mensajes públicos principales**:

| Mensaje | Descripción |
|---|---|
| `TonelReader on: aPath` | Constructor. |
| `read` | Lee el directorio completo. Devuelve un `Dictionary` de package definition. |
| `readFile: aFilename` | Lee y parsea un archivo individual. Devuelve `OrderedCollection` de `Dictionary`. |

**Formato del resultado de `read`**:

```smalltalk
{
  #name -> 'MyPackage',
  #classes -> OrderedCollection(
    OrderedCollection(   "uno por archivo .st de clase"
      Dictionary(#type->'class' #name->'MyClass' ...),
      Dictionary(#type->'method' #selector->'foo' ...),
      ...
    )
  ),
  #extensions -> OrderedCollection(
    OrderedCollection(   "uno por archivo .st de extensión"
      Dictionary(#type->'extension' #name->'Object' ...),
      ...
    )
  )
}
```

**Ejemplo de uso**:

```smalltalk
| reader packageDef |
reader := TonelReader on: '/path/to/MyPackage'.
packageDef := reader read.
packageDef at: #name.       "=> 'MyPackage'"
packageDef at: #classes.    "=> OrderedCollection(...)"
```

---

## Capa 3 — Writing

### TonelWriter

**Responsabilidad**: serializar un `CodePackage` de Cuis al formato Tonel. Produce el texto Tonel válido para cada clase y sus métodos, listo para ser escrito a disco.

**Ivars**:
- `stream` — `WriteStream` sobre `String`.

**Mensajes públicos principales**:

| Mensaje | Descripción |
|---|---|
| `TonelWriter new` | Constructor. |
| `writePackage: aCodePackage to: aDirectory` | Escribe el paquete completo en el directorio. Crea archivos `.st` por clase y `package.st`. |
| `serializeClass: aClass` | Devuelve un `String` con el contenido Tonel de una clase y sus métodos. |
| `serializeMethod: aCompiledMethod` | Devuelve un `String` con el bloque de un método. |

**Ejemplo de uso**:

```smalltalk
| writer |
writer := TonelWriter new.
writer writePackage: (PackageOrganizer default packageNamed: 'MyPackage')
       to: '/path/to/output/'.
"Crea /path/to/output/MyPackage/MyClass.st, etc."
```

**Notas**:
- El writer no modifica la imagen; solo produce texto.
- El orden de los métodos es determinístico (ordenado por selector) para diffs limpios en git.
- Los comentarios de clase se incluyen si están presentes.

---

## Capa 4 — MCP Interface

### TonelMCPServer

**Responsabilidad**: exponer operaciones Tonel como herramientas MCP (Model Context Protocol). Cada herramienta es stateless: recibe parámetros, opera sobre el filesystem, y devuelve un resultado serializado.

**Ivars**: ninguna de estado de imagen. Cada invocación es independiente.

**Herramientas expuestas**:

| Herramienta | Parámetros | Resultado |
|---|---|---|
| `readPackage` | `path: String` | Dictionary con package definition |
| `writePackage` | `path: String`, `packageName: String` | Confirmación o error |
| `listClasses` | `path: String` | Array de nombres de clase |
| `readClass` | `path: String`, `className: String` | Dictionary con class + methods |
| `writeClass` | `path: String`, `classDef: Dictionary` | Confirmación o error |

**Ejemplo de uso** (invocación MCP):

```json
{
  "tool": "readPackage",
  "arguments": { "path": "/path/to/MyPackage" }
}
```

```smalltalk
"Internamente:"
TonelMCPServer new readPackage: '/path/to/MyPackage'
"=> Dictionary(#name -> 'MyPackage' #classes -> ...)"
```

**Nota sobre idempotencia**: `writePackage` y `writeClass` sobrescriben si el archivo existe. No hay operaciones de merge; eso es responsabilidad del caller.

---

## Decisiones de diseño

### Por qué Dictionaries y no objetos de dominio propios

Introducir `TonelClassDefinition`, `TonelMethodDefinition`, etc. agregaría clases que solo transportan datos y no tienen comportamiento propio. Los `Dictionary` de Smalltalk ya son inspeccionables, serializables, y suficientemente expresivos para este propósito. Si en el futuro se necesita comportamiento extra (validaciones, transformaciones), se puede refactorizar entonces.

### Por qué TonelStonParser separado de TonelParser

El parsing del formato de archivo (estructura `Class { ... } ( ... )`) y el parsing del metadata STON son responsabilidades distintas. Separarlas permite testear cada parte de forma independiente y facilita reemplazar TonelStonParser por una librería STON completa si se necesita.

### Por qué TonelReader y TonelParser son clases separadas

`TonelParser` opera sobre un `String` (el contenido de un archivo). `TonelReader` opera sobre un directorio del filesystem. Separar filesystem I/O de parsing permite testear TonelParser sin acceso a disco.

### Por qué no hay TonelRepository pesada con estado

Una clase repositorio con estado acumula complejidad y hace difícil razonar sobre el estado de la imagen. Las operaciones de lectura y escritura son lo suficientemente simples como para vivir en `TonelReader` y `TonelWriter` sin coordinación adicional.

### Por qué sin integración directa con objetos Monticello

Monticello tiene su propio modelo de snapshots, patches, y ancestors. Integrarse directamente acoplaría Tonel a ese modelo. En cambio, Tonel trabaja con `CodePackage` de Cuis (más simple) y deja la integración con Monticello como un paso separado si se necesita.

### Por qué MCP-friendly desde el diseño

Las herramientas de IA (como agentes MCP) necesitan operaciones sin estado de imagen para ser predecibles. Diseñar `TonelMCPServer` como stateless desde el principio evita tener que refactorizar después y hace que cada operación sea auditeable y repetible.

---

## Lo que no se incluye (y por qué)

| Excluido | Razón |
|---|---|
| Jerarquía `*Definition` | Solo transportan datos; Dictionary es suficiente |
| `TonelRepository` con estado | Complejidad innecesaria; las operaciones son stateless |
| Herencia múltiple de scanners | Overkill para el subset STON que necesitamos |
| Integración directa con Monticello objects | Acoplamiento innecesario; CodePackage es suficiente |
| STON completo | Solo usamos el subset que Tonel necesita |
