# Plan de Implementación TDD — Tonel en Cuis Smalltalk

Metodología: **Tidy First + TDD + Trunk Based Development**

Cada etapa sigue el ciclo Red → Green → Refactor.
Antes de cada etapa se hace el chequeo **Tidy First**: si hay limpieza pendiente, va en un commit separado antes de agregar comportamiento.

---

## Convenciones de naming en Cuis

- Los tests van en el paquete `Tonel-Support-Tests`.
- Las clases de test siguen el patrón `TonelXxxTest` (subclase de `TestCase`).
- Los métodos de test se nombran `test<Descripción>` en camelCase, empezando con minúscula después de `test`.
  - Ejemplo: `testParseEmptyDictionary`, `testParseSimpleKeyValue`.
- Los métodos `setUp` y `tearDown` son opcionales; usarlos solo cuando haya estado compartido real.
- Los mensajes de fallo de `assert:` deben ser descriptivos: usar `assert: x equals: y` en lugar de `assert: (x = y)`.
- Nombrar las instancias de SUT como `parser`, `writer`, `reader` según el caso.
- Los fixtures (strings de input) se definen como métodos `private` que retornan literales, no como variables de instancia.

---

## Etapa 0: Setup

### Objetivo
Verificar que el entorno está listo para comenzar el desarrollo.

### Precondiciones
- Imagen Cuis disponible en `CuisImage/`.
- VM disponible en `CuisVM.app/`.
- Los paquetes `Tonel-Support` y `Tonel-Support-Tests` ya existen en la imagen.

### Pasos
1. Arrancar la imagen con `RunCuisOnMac.sh` y verificar que carga sin errores.
2. Abrir un Workspace y ejecutar `TestRunner open` para confirmar que SUnit está operativo.
3. Correr los tests existentes en `Tonel-Support-Tests` (si los hay) y verificar que pasan o están vacíos.
4. Confirmar que `TonelStonParser`, `TonelParser`, `TonelReader`, `TonelWriter` **no** existen todavía (o están vacíos).

### Criterio de done
- La imagen arranca.
- SUnit corre sin errores de infraestructura.
- El entorno está limpio y listo para la Etapa 1.

### Nota Tidy First
Revisar si hay clases fantasma, métodos huérfanos o cambios no guardados en la imagen antes de continuar.
Si los hay, limpiarlos y guardar la imagen como paso previo.

---

## Etapa 1: TonelStonParser

### Objetivo
Implementar un parser de un subset de STON que soporte la sintaxis de metadata usada en archivos Tonel:
`{ #key: value, #key2: value2 }` donde los valores pueden ser strings, symbols o arrays de strings.

### Precondiciones
- Etapa 0 completada.
- La clase `TonelStonParser` no existe o está vacía.
- La clase de test `TonelStonParserTest` no existe o está vacía.

### Tests en orden incremental

#### 1. Parsear diccionario vacío
```
testParseEmptyDictionary
    | result |
    result := TonelStonParser parse: '{}'.
    self assert: result equals: Dictionary new.
```

#### 2. Parsear par simple con string
```
testParseSimpleStringValue
    | result |
    result := TonelStonParser parse: '{ #name: ''Foo'' }'.
    self assert: (result at: #name) equals: 'Foo'.
```

#### 3. Parsear valor symbol
```
testParseSymbolValue
    | result |
    result := TonelStonParser parse: '{ #type: #normal }'.
    self assert: (result at: #type) equals: #normal.
```

#### 4. Parsear array de strings
```
testParseStringArray
    | result |
    result := TonelStonParser parse: '{ #instVars: [ ''x'' ''y'' ] }'.
    self assert: (result at: #instVars) equals: #('x' 'y').
```

#### 5. Parsear metadata completa de clase real
```
testParseFullClassMetadata
    | input result |
    input := '{ #name: ''Point'', #superclass: ''Object'', #instVars: [ ''x'' ''y'' ], #category: ''Kernel'' }'.
    result := TonelStonParser parse: input.
    self assert: (result at: #name) equals: 'Point'.
    self assert: (result at: #superclass) equals: 'Object'.
    self assert: (result at: #instVars) equals: #('x' 'y').
    self assert: (result at: #category) equals: 'Kernel'.
```

#### 6. Error en input malformado
```
testMalformedInputRaisesError
    self
        should: [ TonelStonParser parse: '{ #name: ' ]
        raise: Error.
```

### Criterio de done
- Todos los tests pasan.
- `TonelStonParser` tiene un solo punto de entrada público: `parse: aString`.
- El código interno está refactoreado: sin duplicación, con nombres claros.

### Nota Tidy First
Antes de agregar código, verificar que no hay métodos sueltos o clases sin categoría en los paquetes.

---

## Etapa 2: TonelParser — comentario y tipo

### Objetivo
Implementar el reconocimiento de las líneas de encabezado de un archivo Tonel:
el comentario opcional y la keyword de tipo (`Class`, `Trait`, `Extension`).

### Precondiciones
- Etapa 1 completada y todos sus tests pasan.
- `TonelParser` no existe o está vacío.
- `TonelParserTest` no existe o está vacío.

### Tests en orden incremental

#### 1. Parsear línea de comentario
```
testParseComment
    | parser result |
    parser := TonelParser on: '"Este es el comentario del paquete"'.
    result := parser parseComment.
    self assert: result equals: 'Este es el comentario del paquete'.
```

#### 2. Reconocer keyword Class
```
testRecognizeClassKeyword
    | parser |
    parser := TonelParser on: 'Class { #name: ''Foo'' }'.
    self assert: parser parseTypeKeyword equals: #Class.
```

#### 3. Reconocer keyword Trait
```
testRecognizeTraitKeyword
    | parser |
    parser := TonelParser on: 'Trait { #name: ''TFoo'' }'.
    self assert: parser parseTypeKeyword equals: #Trait.
```

#### 4. Reconocer keyword Extension
```
testRecognizeExtensionKeyword
    | parser |
    parser := TonelParser on: 'Extension { #name: ''Bar'' }'.
    self assert: parser parseTypeKeyword equals: #Extension.
```

#### 5. Error en keyword desconocido
```
testUnknownKeywordRaisesError
    | parser |
    parser := TonelParser on: 'Widget { #name: ''Foo'' }'.
    self
        should: [ parser parseTypeKeyword ]
        raise: Error.
```

### Criterio de done
- Todos los tests pasan.
- `TonelParser` se construye con `on: aString` y parsea desde ese string.
- Los métodos `parseComment` y `parseTypeKeyword` están definidos.

### Nota Tidy First
Revisar que `TonelStonParser` no tiene código muerto antes de agregar `TonelParser`.

---

## Etapa 3: TonelParser — definición de tipo completa

### Objetivo
Parsear la línea completa de declaración de tipo: keyword + metadata STON.
Soportar `Class`, `Trait` y `Extension`.

### Precondiciones
- Etapa 2 completada y todos sus tests pasan.

### Tests en orden incremental

#### 1. Parsear declaración de clase simple
```
testParseClassDefinition
    | parser result |
    parser := TonelParser on: 'Class { #name: ''Foo'', #superclass: ''Object'' }'.
    result := parser parseTypeDefinition.
    self assert: (result at: #keyword) equals: #Class.
    self assert: ((result at: #metadata) at: #name) equals: 'Foo'.
    self assert: ((result at: #metadata) at: #superclass) equals: 'Object'.
```

#### 2. Parsear clase con comment previo
```
testParseClassWithComment
    | input parser result |
    input := '"Comentario de la clase"
Class { #name: ''Foo'', #superclass: ''Object'' }'.
    parser := TonelParser on: input.
    result := parser parseTypeDefinition.
    self assert: (result at: #comment) equals: 'Comentario de la clase'.
    self assert: (result at: #keyword) equals: #Class.
```

#### 3. Parsear Trait
```
testParseTraitDefinition
    | parser result |
    parser := TonelParser on: 'Trait { #name: ''TFoo'' }'.
    result := parser parseTypeDefinition.
    self assert: (result at: #keyword) equals: #Trait.
    self assert: ((result at: #metadata) at: #name) equals: 'TFoo'.
```

#### 4. Parsear Extension
```
testParseExtensionDefinition
    | parser result |
    parser := TonelParser on: 'Extension { #name: ''Bar'' }'.
    result := parser parseTypeDefinition.
    self assert: (result at: #keyword) equals: #Extension.
    self assert: ((result at: #metadata) at: #name) equals: 'Bar'.
```

### Criterio de done
- Todos los tests pasan.
- `parseTypeDefinition` retorna un `Dictionary` con claves `#keyword`, `#metadata`, y opcionalmente `#comment`.
- `TonelStonParser` es llamado internamente; no se duplica lógica de parsing STON.

### Nota Tidy First
Refactorear `TonelParser` si los métodos de las etapas anteriores tienen duplicación con la nueva lógica.

---

## Etapa 4: TonelParser — métodos

### Objetivo
Parsear las definiciones de métodos dentro de un archivo Tonel.
Soportar métodos de instancia, de clase, con metadata y cuerpo completo.

### Precondiciones
- Etapa 3 completada y todos sus tests pasan.

### Tests en orden incremental

#### 1. Parsear método de instancia (declaración)
```
testParseInstanceMethodDeclaration
    | parser result |
    parser := TonelParser on: 'Foo >> bar [
    ^self
]'.
    result := parser parseMethodDefinition.
    self assert: (result at: #className) equals: 'Foo'.
    self assert: (result at: #side) equals: #instance.
    self assert: (result at: #selector) equals: 'bar'.
```

#### 2. Parsear método de clase
```
testParseClassSideMethodDeclaration
    | parser result |
    parser := TonelParser on: 'Foo class >> new [
    ^super new
]'.
    result := parser parseMethodDefinition.
    self assert: (result at: #className) equals: 'Foo'.
    self assert: (result at: #side) equals: #class.
    self assert: (result at: #selector) equals: 'new'.
```

#### 3. Parsear metadata de método
```
testParseMethodMetadata
    | parser result |
    parser := TonelParser on: '{ #category: ''accessing'' }
Foo >> bar [
    ^self
]'.
    result := parser parseMethodDefinition.
    self assert: ((result at: #metadata) at: #category) equals: 'accessing'.
```

#### 4. Parsear método completo con metadata + cuerpo
```
testParseCompleteMethod
    | input parser result |
    input := '{ #category: ''accessing'' }
Foo >> x [
    ^x
]'.
    parser := TonelParser on: input.
    result := parser parseMethodDefinition.
    self assert: (result at: #selector) equals: 'x'.
    self assert: (result at: #body) isNil not.
    self assert: ((result at: #metadata) at: #category) equals: 'accessing'.
```

### Criterio de done
- Todos los tests pasan.
- `parseMethodDefinition` retorna un `Dictionary` con claves `#className`, `#side`, `#selector`, `#body`, y opcionalmente `#metadata`.
- El cuerpo del método se captura como string crudo (sin parsear Smalltalk).

### Nota Tidy First
Verificar que no hay lógica de parsing duplicada entre `parseTypeDefinition` y `parseMethodDefinition`.

---

## Etapa 5: TonelParser — documento completo

### Objetivo
Parsear un archivo `.st` Tonel completo: tipo + cero o más métodos.

### Precondiciones
- Etapa 4 completada y todos sus tests pasan.

### Tests en orden incremental

#### 1. Parsear clase con un método
```
testParseClassWithOneMethod
    | input parser result |
    input := 'Class { #name: ''Foo'', #superclass: ''Object'' }

{ #category: ''accessing'' }
Foo >> bar [
    ^42
]'.
    parser := TonelParser on: input.
    result := parser parse.
    self assert: ((result at: #typeDefinition) at: #keyword) equals: #Class.
    self assert: (result at: #methods) size equals: 1.
```

#### 2. Parsear clase con múltiples métodos
```
testParseClassWithMultipleMethods
    | input parser result |
    input := 'Class { #name: ''Foo'', #superclass: ''Object'' }

Foo >> bar [ ^42 ]

Foo >> baz [ ^43 ]'.
    parser := TonelParser on: input.
    result := parser parse.
    self assert: (result at: #methods) size equals: 2.
```

#### 3. Parsear extensión pura (solo métodos, sin typeDef propia)
```
testParseExtension
    | input parser result |
    input := 'Extension { #name: ''Bar'' }

Bar >> extra [ ^nil ]'.
    parser := TonelParser on: input.
    result := parser parse.
    self assert: ((result at: #typeDefinition) at: #keyword) equals: #Extension.
    self assert: (result at: #methods) size equals: 1.
```

#### 4. Parsear archivo real de Cuis-Smalltalk-Dev
Usar un archivo `.st` real del directorio de Cuis como fixture de integración.
El test verifica que el parse no lanza errores y que el resultado tiene la estructura esperada.

```
testParseRealCuisFile
    | filePath content parser result |
    filePath := "<ruta a un archivo .st real de Cuis>".
    content := filePath asFileEntry readStream contents.
    parser := TonelParser on: content.
    result := parser parse.
    self assert: (result includesKey: #typeDefinition).
    self assert: (result includesKey: #methods).
```

### Criterio de done
- Todos los tests pasan, incluyendo el test con archivo real.
- `parse` retorna un `Dictionary` con claves `#typeDefinition` y `#methods`.
- El parser es tolerante a líneas en blanco entre secciones.

### Nota Tidy First
Refactorear el parser si los métodos son demasiado largos o tienen responsabilidades mezcladas antes de continuar.

---

## Etapa 6: TonelWriter

### Objetivo
Serializar una definición de clase/extensión/trait al formato Tonel como string.

### Precondiciones
- Etapa 5 completada y todos sus tests pasan.
- `TonelWriter` no existe o está vacío.
- `TonelWriterTest` no existe o está vacío.

### Tests en orden incremental

#### 1. Escribir comment de clase
```
testWriteClassComment
    | writer result |
    writer := TonelWriter new.
    result := writer writeComment: 'Este es el comentario'.
    self assert: result equals: '"Este es el comentario"'.
```

#### 2. Escribir metadata de clase
```
testWriteClassMetadata
    | writer metadata result |
    writer := TonelWriter new.
    metadata := Dictionary new.
    metadata at: #name put: 'Foo'.
    metadata at: #superclass put: 'Object'.
    result := writer writeTypeDefinition: #Class metadata: metadata.
    self assert: (result includesSubString: 'Class {').
    self assert: (result includesSubString: '#name: ''Foo''').
```

#### 3. Escribir declaración de método
```
testWriteMethodDeclaration
    | writer result |
    writer := TonelWriter new.
    result := writer writeMethodDeclaration: 'bar' className: 'Foo' side: #instance.
    self assert: result equals: 'Foo >> bar'.
```

#### 4. Escribir declaración de método de clase
```
testWriteClassSideMethodDeclaration
    | writer result |
    writer := TonelWriter new.
    result := writer writeMethodDeclaration: 'new' className: 'Foo' side: #class.
    self assert: result equals: 'Foo class >> new'.
```

#### 5. Round-trip: parse → write → parse da el mismo resultado
```
testRoundTrip
    | input parsed written reparsed |
    input := 'Class { #name: ''Foo'', #superclass: ''Object'' }

{ #category: ''accessing'' }
Foo >> bar [
    ^42
]'.
    parsed := TonelParser parse: input.
    written := TonelWriter write: parsed.
    reparsed := TonelParser parse: written.
    self assert: (reparsed at: #typeDefinition) equals: (parsed at: #typeDefinition).
    self assert: (reparsed at: #methods) size equals: (parsed at: #methods) size.
```

### Criterio de done
- Todos los tests pasan, incluyendo el round-trip.
- `TonelWriter` tiene un punto de entrada de clase `write: aDictionary` además de los métodos de instancia.
- El output es un string válido que `TonelParser` puede volver a parsear.

### Nota Tidy First
Verificar que el modelo de datos (Dictionary) usado entre parser y writer es consistente antes de implementar el writer.

---

## Etapa 7: TonelReader

### Objetivo
Leer un directorio con estructura Tonel y retornar la lista de definiciones encontradas.

### Precondiciones
- Etapa 6 completada y todos sus tests pasan.
- `TonelReader` no existe o está vacío.
- `TonelReaderTest` no existe o está vacío.

### Tests en orden incremental

#### 1. Leer directorio con un archivo .st
```
testReadDirectoryWithOneFile
    | reader dir result |
    dir := "<directorio temporal con un .st de fixture>".
    reader := TonelReader on: dir.
    result := reader read.
    self assert: result size equals: 1.
    self assert: (result first includesKey: #typeDefinition).
```

#### 2. Leer directorio con múltiples archivos
```
testReadDirectoryWithMultipleFiles
    | reader dir result |
    dir := "<directorio con 3 .st de fixture>".
    reader := TonelReader on: dir.
    result := reader read.
    self assert: result size equals: 3.
```

#### 3. Leer .properties para detectar formato
```
testReadPropertiesFile
    | reader dir props |
    dir := "<directorio con .properties que dice format=tonel>".
    reader := TonelReader on: dir.
    props := reader readProperties.
    self assert: (props at: #format) equals: 'tonel'.
```

### Criterio de done
- Todos los tests pasan.
- `TonelReader` usa `TonelParser` internamente; no duplica lógica de parsing.
- `read` retorna una colección de Dictionaries (uno por archivo `.st`).
- Si `.properties` no existe, el reader asume formato Tonel por defecto.

### Nota Tidy First
Refactorear `TonelParser` si la interfaz que usa `TonelReader` es incómoda antes de implementar el reader.

---

## Etapa 8: TonelMCPServer

### Objetivo
Exponer operaciones de Tonel como herramientas MCP (Model Context Protocol) para integración con agentes de IA.

### Precondiciones
- Etapas 1–7 completadas y todos sus tests pasan.
- Definir la interfaz MCP mínima necesaria (puede ser un objeto con un protocolo simple, sin framework externo).
- `TonelMCPServer` no existe o está vacío.
- `TonelMCPServerTest` no existe o está vacío.

### Tests en orden incremental

#### 1. Herramienta readClass
```
testReadClassTool
    | server result |
    server := TonelMCPServer new.
    result := server readClass: "<path a un .st de fixture>".
    self assert: (result includesKey: #typeDefinition).
    self assert: (result includesKey: #methods).
```

#### 2. Herramienta writeClass
```
testWriteClassTool
    | server definition path |
    server := TonelMCPServer new.
    definition := Dictionary new.
    definition at: #typeDefinition put: (Dictionary new
        at: #keyword put: #Class;
        at: #metadata put: (Dictionary new
            at: #name put: 'Bar';
            at: #superclass put: 'Object';
            yourself);
        yourself).
    definition at: #methods put: OrderedCollection new.
    path := "<path temporal>".
    server writeClass: definition to: path.
    self assert: path asFileEntry exists.
```

#### 3. Herramienta listClasses
```
testListClassesTool
    | server dir result |
    server := TonelMCPServer new.
    dir := "<directorio con varios .st>".
    result := server listClasses: dir.
    self assert: result isCollection.
    result do: [ :each | self assert: (each includesKey: #name) ].
```

#### 4. Herramienta readPackage
```
testReadPackageTool
    | server dir result |
    server := TonelMCPServer new.
    dir := "<directorio Tonel completo>".
    result := server readPackage: dir.
    self assert: (result includesKey: #classes).
    self assert: (result includesKey: #format).
```

### Criterio de done
- Todos los tests pasan.
- `TonelMCPServer` delega completamente en `TonelReader` y `TonelWriter`; no tiene lógica de parsing propia.
- Las herramientas tienen firmas claras y documentadas.
- El servidor es usable sin configuración adicional de red (opera sobre el filesystem).

### Nota Tidy First
Revisar todo el stack antes de implementar el servidor: asegurarse de que las interfaces de `TonelReader`, `TonelWriter` y `TonelParser` son coherentes y no requieren conocimiento interno para usarlas.

---

## Resumen de dependencias

```
TonelStonParser
    └── TonelParser
            ├── TonelWriter
            └── TonelReader
                    └── TonelMCPServer
```

Cada clase depende solo de las que están encima en el árbol.
Los tests de cada etapa son suficientes para confiar en la base antes de construir la siguiente capa.

---

## Referencias

- Tonel format spec: https://github.com/pharo-vcs/tonel
- Cuis Smalltalk: https://github.com/Cuis-Smalltalk/Cuis-Smalltalk-Dev
- SUnit en Cuis: ver `Kernel-Tests` en la imagen
