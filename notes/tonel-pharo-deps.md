# Dependencias Pharo-específicas en pharo-vcs/tonel

Análisis de las dependencias que existen en Pharo 14 pero no en Cuis Smalltalk, con propuesta de reemplazo para cada una.

---

## Tabla resumen

| Dependencia | Archivos afectados | Impacto | Reemplazo propuesto |
|---|---|---|---|
| `STON` | `metadata.st` | Alto — parseo de metadata | `TonelStonReader` mínimo |
| `MCClassDefinition` / `MCTraitDefinition` | `newClassDefinitionFrom:` | Alto — construcción de definiciones | Devolver `Dictionary` plano |
| `#flattened` | `document.st` | Medio — aplanado de colecciones | `inject:into:` manual |
| `select: #notNil` | `document.st` | Bajo — filtrado | `select: [:each | each notNil]` |
| `trimBoth` | varios | Bajo — normalización de strings | `trimSeparators` |
| `substrings:` | varios | Bajo — split de strings | `subStrings:` (mayúscula) |
| `FileReference` | `TonelRepository` | Alto — acceso al filesystem | `FileDirectory` / `DirectoryEntry` |

---

## 1. STON

### Qué es
STON (Smalltalk Object Notation) es el serializer de Pharo. Usado en Tonel para parsear la metadata de cada archivo `.st`.

### Dónde aparece
`metadata.st`:
```smalltalk
^ STON fromString: result contents
```

### Impacto
Sin `STON`, el parser no puede leer la metadata de ningún archivo Tonel. Es un bloqueante total.

### Reemplazo propuesto
El subset de STON que Tonel usa es mínimo: diccionarios planos con claves símbolo y valores string o símbolo, por ejemplo:
```
{ #name: 'MiClase'. #superclass: 'Object'. #category: 'MiPaquete' }
```
Implementar `TonelStonReader` con un parser ad-hoc para ese subset específico. No necesita soportar objetos tipados, anidado profundo ni referencias. Un `ReadStream` con extracción manual de pares `clave: valor` es suficiente.

---

## 2. MCClassDefinition / MCTraitDefinition

### Qué es
Clases de Monticello que representan definiciones de clase y trait. Aunque Monticello existe en Cuis, la API del constructor difiere de Pharo.

### Dónde aparece
`newClassDefinitionFrom:` (aproximadamente):
```smalltalk
definition := (MCClassDefinition named: (metadata at: #name))
    superclassName: (metadata at: #superclass);
    category: (metadata at: #category);
    ...
```

### Impacto
El parser no puede construir definiciones de clase sin conocer la API exacta de `MCClassDefinition` en Cuis. Diferencias en selectores de construcción o en los campos esperados causan errores silenciosos o excepciones.

### Reemplazo propuesto
Hacer que el parser devuelva un `Dictionary` plano con las mismas claves (`#name`, `#superclass`, `#category`, `#instanceVariables`, etc.). El consumidor (el cargador de paquetes) es responsable de construir el objeto Monticello apropiado a partir de ese diccionario. Esto desacopla el parser del modelo de Monticello.

---

## 3. `#flattened`

### Qué es
Extensión de `Collection` en Pharo que aplana una colección de colecciones un nivel.

### Dónde aparece
`document.st`:
```smalltalk
^ { self typeDef. self methodDefList. } flattened select: #notNil
```

### Impacto
`#flattened` no existe en la jerarquía base de colecciones de Cuis. La expresión falla con `doesNotUnderstand`.

### Reemplazo propuesto
```smalltalk
| result |
result := OrderedCollection new.
self typeDef ifNotNil: [:d | result add: d].
self methodDefList do: [:each | each ifNotNil: [:d | result add: d]].
^ result
```
O usando `inject:into:` si se prefiere una expresión más funcional:
```smalltalk
^ { self typeDef. self methodDefList. }
    inject: OrderedCollection new
    into: [:acc :each |
        each isCollection
            ifTrue: [each do: [:e | e ifNotNil: [acc add: e]]]
            ifFalse: [each ifNotNil: [acc add: each]].
        acc]
```

---

## 4. `select: #notNil`

### Qué es
Uso de símbolo como bloque (`Symbol >> #asBlock` / `Symbol >> #value:`). En Pharo, `#notNil` funciona como `[:each | each notNil]`. En Cuis este comportamiento no está garantizado en el mismo contexto.

### Dónde aparece
Junto a `#flattened` en `document.st` (ver arriba).

### Impacto
Bajo si se resuelve junto con `#flattened`. Si se usa en otros lugares, puede producir resultados incorrectos silenciosamente.

### Reemplazo propuesto
Reemplazar siempre con el bloque explícito:
```smalltalk
select: [:each | each notNil]
```

---

## 5. `trimBoth`

### Qué es
Selector de `String` en Pharo que elimina espacios en ambos extremos.

### Dónde aparece
Varios lugares del parser donde se normalizan nombres de clase, categorías y variables.

### Impacto
Bajo. Falla con `doesNotUnderstand` pero el reemplazo es trivial.

### Reemplazo propuesto
```smalltalk
aString trimSeparators
```
`trimSeparators` es el selector equivalente en Cuis.

---

## 6. `substrings:` vs `subStrings:`

### Qué es
Diferencia de capitalización en el selector para dividir strings. Pharo usa `substrings:` (minúscula), Cuis usa `subStrings:` (camelCase con S mayúscula).

### Dónde aparece
Parseo de listas de variables de instancia y similares:
```smalltalk
aString substrings: ' '
```

### Impacto
Bajo. Falla silenciosamente o con `doesNotUnderstand` dependiendo del contexto.

### Reemplazo propuesto
```smalltalk
aString subStrings: ' '
```
Revisar todas las ocurrencias y unificar al selector de Cuis.

---

## 7. FileReference (TonelRepository)

### Qué es
`FileReference` es la abstracción de filesystem moderna de Pharo (parte de FileSystem). `TonelRepository` la usa para leer y escribir archivos `.st` del repositorio.

### Dónde aparece
`TonelRepository` y clases relacionadas: apertura de directorios, iteración de archivos, lectura de contenidos.

### Impacto
Alto. Sin un adaptador de filesystem, el repositorio no puede leer ni escribir nada. Es el segundo bloqueante total junto con STON.

### Reemplazo propuesto
Usar la API de filesystem de Cuis:
- `FileDirectory` para directorios
- `DirectoryEntry` para entradas
- `FileStream` para lectura/escritura

Opciones:
1. **Adaptador**: implementar un objeto `TonelFileAdapter` que exponga la misma interfaz que usa `TonelRepository` internamente, con una implementación basada en `FileDirectory`.
2. **Reescritura directa**: reescribir los métodos de `TonelRepository` usando la API de Cuis directamente, sin intentar compatibilidad con `FileReference`.

La opción 2 es más simple dado que el código de `TonelRepository` es acotado.
