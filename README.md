# cuis-tonel

Soporte nativo del formato Tonel para Cuis Smalltalk. Permite serializar clases desde la imagen a archivos `.class.st`, parsear esos archivos, importarlos de vuelta a la imagen, y exportar conjuntos enteros de clases a una estructura de directorios compatible con git.

---

## El problema que resuelve

El mecanismo tradicional de persistencia de Cuis son los *change sets* y los paquetes `.pck.st`. Ambos usan el formato *chunk*: un archivo de texto donde las definiciones de clases y métodos están separadas por el carácter `!`. El resultado es un archivo monolítico donde cualquier cambio mínimo —renombrar un método, agregar una línea— modifica el archivo completo.

En la práctica, esto hace que trabajar con git sea difícil:

- Un `git diff` de un cambio de una línea muestra cientos de líneas de contexto irrelevante.
- Es imposible ver en un PR qué método cambió y por qué.
- El historial por clase o por método no existe: solo hay historial del paquete completo.
- Los merges son propensos a conflictos innecesarios.

**Tonel resuelve todo esto.**

---

## El formato Tonel

Tonel es un formato de persistencia de código fuente para Smalltalk diseñado explícitamente para ser legible por humanos y amigable con git. Fue desarrollado por el equipo de Pharo y adoptado después por VAST, GemStone, Squeak y otras implementaciones.

Las reglas son simples:

- **Un archivo por clase**, con extensión `.class.st`.
- El archivo empieza con un bloque de metadatos en formato STON que describe el nombre de la clase, su superclase, las variables de instancia, las variables de clase, el paquete y el tag.
- Los métodos siguen inmediatamente: cada uno tiene una línea de categoría entre `{ }` y el cuerpo entre `[` `]`.
- Los archivos se organizan en directorios por paquete dentro de `src/`.
- Un archivo `.properties` en la raíz de `src/` marca el directorio como un repositorio Tonel.

### Ejemplo de un archivo `.class.st` real

Este es `src/Tonel/TonelWriter.class.st`, tal como lo genera este paquete:

```smalltalk
Class {
	#name : 'TonelWriter',
	#superclass : 'Object',
	#category : 'Tonel',
	#package : 'Tonel'
}

{ #category : 'writing' }
TonelWriter class >> sourceForClass: aClass [
	^ String streamContents: [ :stream | self writeClass: aClass on: stream ]
]

{ #category : 'writing' }
TonelWriter class >> writeClass: aClass on: stream [
	| comment category package tag classVars pools |
	comment := aClass organization classComment.
	comment isEmptyOrNil ifFalse: [
		stream nextPut: $"; newLine; nextPutAll: comment; newLine; nextPut: $"; newLine ].
	...
]
```

Comparado con el mismo contenido en formato chunk:

```
TonelWriter subclass: #TonelWriter instanceVariableNames: '' classVariableNames: '' ...!
!TonelWriter class methodsFor: 'writing'!
sourceForClass: aClass
	^ String streamContents: [ :stream | self writeClass: aClass on: stream ]! !
!TonelWriter class methodsFor: 'writing'!
writeClass: aClass on: stream
	...! !
```

La diferencia en un `git diff` es dramática: con Tonel, un cambio en `sourceForClass:` toca exactamente las líneas del método. Con chunk, todo el archivo cambia.

---

## Componentes

El paquete tiene seis clases:

| Clase | Responsabilidad |
|---|---|
| `TonelWriter` | Serializa una clase de la imagen al texto del formato Tonel |
| `TonelReader` | Parsea el contenido de un `.class.st` y devuelve una `TonelClassDefinition` |
| `TonelClassDefinition` | Objeto de valor que contiene los metadatos de una clase leída desde Tonel |
| `TonelMethodDefinition` | Objeto de valor que contiene el source y la categoría de un método |
| `TonelImporter` | Compila una `TonelClassDefinition` en la imagen (crea la clase y sus métodos) |
| `TonelImageExporter` | Exporta un conjunto de clases a una estructura de directorios Tonel |

---

## Instalación

### Desde la imagen (interactivo)

```smalltalk
CodePackageFile installPackage: '/ruta/a/cuis-tonel/dist/Tonel.pck.st' asFileEntry.
```

Para los tests también:

```smalltalk
CodePackageFile installPackage: '/ruta/a/cuis-tonel/dist/Tests-Tonel.pck.st' asFileEntry.
```

### Descarga directa

Cada push a `main` genera un release en GitHub con los archivos `.pck.st` adjuntos como assets. Se pueden descargar desde la sección [Releases](../../releases) del repositorio e instalar con el mismo `CodePackageFile installPackage:`.

---

## API completa con ejemplos

### `TonelWriter` — serializar una clase a texto

`TonelWriter` es stateless. Toda su API es de clase.

**Serializar una clase como texto Tonel:**

```smalltalk
| source |
source := TonelWriter sourceForClass: OrderedCollection.
Transcript show: source.
```

La salida incluye la definición STON completa y todos los métodos de instancia y de clase, ordenados alfabéticamente por selector:

```
Class {
	#name : 'OrderedCollection',
	#superclass : 'SequenceableCollection',
	#instVars : [
		'firstIndex',
		'lastIndex'
	],
	#category : 'Collections-Sequenceable',
	#package : 'Collections'
}

{ #category : 'adding' }
OrderedCollection >> add: newObject [
	...
]
...
```

**Escribir directamente sobre un stream:**

```smalltalk
| stream |
stream := ReadWriteStream on: ''.
TonelWriter writeClass: OrderedCollection on: stream.
stream reset.
Transcript show: stream upToEnd.
```

**Obtener el nombre del paquete a partir de una categoría:**

```smalltalk
TonelWriter packageNameForCategory: 'Collections-Sequenceable'.
"=> 'Collections'"

TonelWriter packageNameForCategory: 'Tonel'.
"=> 'Tonel'"
```

Las categorías en Cuis siguen la convención `Paquete-Tag`. El writer separa en el primer guion para determinar el directorio de destino.

---

### `TonelReader` — parsear un archivo `.class.st`

`TonelReader` lee un stream y devuelve una `TonelClassDefinition`.

**Parsear desde un archivo:**

```smalltalk
| entry definition |
entry := '/ruta/a/src/Tonel/TonelWriter.class.st' asFileEntry.
entry readStreamDo: [ :stream |
    definition := TonelReader readStream: stream ].

definition className.              "=> #TonelWriter"
definition superclassName.         "=> #Object"
definition instanceVariableNames.  "=> #()"
definition classVariableNames.     "=> #()"
definition category.               "=> #'Tonel'"
definition package.                "=> #'Tonel'"
definition methods size.           "=> 8"
```

**Inspeccionar los métodos leídos:**

```smalltalk
definition methods do: [ :method |
    Transcript
        show: method selector;
        show: ' (';
        show: (method classSide ifTrue: ['clase'] ifFalse: ['instancia']);
        show: ') — categoría: ';
        show: method protocol;
        newLine ].
```

**Parsear desde un string en memoria:**

```smalltalk
| source definition |
source := 'Class {
	#name : ''MiClase'',
	#superclass : ''Object'',
	#category : ''MiPaquete'',
	#package : ''MiPaquete''
}

{ #category : ''accessing'' }
MiClase >> valor [
	^ 42
]'.

definition := TonelReader readStream: source readStream.
definition className.   "=> #MiClase"
definition methods first selector.  "=> #valor"
```

---

### `TonelClassDefinition` y `TonelMethodDefinition` — objetos de valor

`TonelClassDefinition` es lo que devuelve el reader. Contiene todo lo necesario para reconstruir la clase en la imagen.

```smalltalk
| definition |
"... (parsear como en el ejemplo anterior)"

definition className.                  "=> #TonelWriter"
definition superclassName.             "=> #Object"
definition instanceVariableNames.      "=> #()"
definition classVariableNames.         "=> #()"
definition classInstanceVariableNames. "=> #()"
definition poolDictionaries.           "=> #()"
definition category.                   "=> #'Tonel'"
definition package.                    "=> #'Tonel'"
definition tag.                        "=> nil (o #'Tonel' si hay tag)"
definition comment.                    "=> '' (o el texto del comentario de clase)"
definition methods.                    "=> OrderedCollection de TonelMethodDefinition"
```

Cada elemento de `definition methods` es una `TonelMethodDefinition`:

```smalltalk
| method |
method := definition methods first.

method selector.    "=> #sourceForClass:"
method classSide.   "=> true"
method protocol.    "=> #'writing'"
method source.      "=> 'sourceForClass: aClass\n\t^ String streamContents: ...'"
method className.   "=> #TonelWriter"
```

Estos objetos son inmutables en uso normal. Se crean solo desde el reader o en tests.

---

### `TonelImporter` — importar una definición a la imagen

`TonelImporter` toma una `TonelClassDefinition` y la compila en la imagen.

**Importar un archivo directamente:**

```smalltalk
TonelImporter importFile: '/ruta/a/MiClase.class.st' asFileEntry.
```

**Importar desde un stream:**

```smalltalk
'/ruta/a/MiClase.class.st' asFileEntry readStreamDo: [ :stream |
    TonelImporter importStream: stream ].
```

**Importar una definición ya parseada:**

```smalltalk
| definition |
definition := TonelReader readStream: miStream.
TonelImporter importDefinition: definition.
```

**Importar todo un directorio de archivos Tonel:**

```smalltalk
TonelImporter importDirectory: '/ruta/a/src/MiPaquete' asDirectoryEntry.
```

Esto recorre el directorio recursivamente e importa todos los archivos `.st` que encuentre.

**Reimportar (actualizar una clase existente):**

El importer no recrea la clase si ya existe: detecta si `Smalltalk classNamed: className` devuelve algo. Si la clase existe, solo recompila los métodos. Esto permite actualizar el código de una clase en ejecución sin perder el estado de la imagen.

```smalltalk
"Primera vez: crea la clase"
TonelImporter importFile: 'MiClase.class.st' asFileEntry.

"Después de modificar el archivo: actualiza los métodos"
TonelImporter importFile: 'MiClase.class.st' asFileEntry.
```

**Limitación actual**: si se eliminaron métodos del archivo `.class.st`, el importer no los borra de la imagen. Solo agrega y sobreescribe. Ver sección [Lo que falta](#lo-que-falta).

---

### `TonelImageExporter` — exportar clases desde la imagen

`TonelImageExporter` toma un conjunto de clases y las escribe en una estructura de directorios.

**Exportar clases específicas:**

```smalltalk
| exportDir |
exportDir := '/tmp/mi-export' asDirectoryEntry.

TonelImageExporter exportClasses: {
    TonelWriter.
    TonelReader.
    TonelImporter.
    TonelImageExporter
} to: exportDir.
```

Genera la siguiente estructura:

```
/tmp/mi-export/
  src/
    .properties          ← marca el directorio como repositorio Tonel
    Tonel/
      TonelWriter.class.st
      TonelReader.class.st
      TonelImporter.class.st
      TonelImageExporter.class.st
  manifest.txt           ← resumen del export (fecha, imagen, conteo de clases)
```

El archivo `.properties` contiene:
```
{
	#format : #tonel
}
```

El `manifest.txt` registra cuántas clases y métodos se exportaron, desde qué imagen, y qué paquetes están presentes.

**Exportar todas las clases de la imagen:**

```smalltalk
TonelImageExporter exportAllTo: '/tmp/cuis-export' asDirectoryEntry.
```

Esto recorre `Smalltalk allClasses`, las ordena por nombre, y las escribe. Dependiendo de la imagen puede generar varios miles de archivos.

**Exportar las clases de un paquete específico:**

```smalltalk
| clases |
clases := Smalltalk allClasses select: [ :c |
    (TonelWriter packageNameForCategory: c category) = 'Tonel' ].

TonelImageExporter exportClasses: clases to: '/tmp/export-tonel' asDirectoryEntry.
```

**Exportar y luego abrir el directorio:**

```smalltalk
| dir |
dir := TonelImageExporter exportClasses: { OrderedCollection } to: '/tmp/test' asDirectoryEntry.
dir pathString.  "=> '/tmp/test'"
```

`exportClasses:to:` devuelve el `DirectoryEntry` del directorio raíz del export.

---

## Ejecutar los tests

### Desde la imagen

```smalltalk
| suite result |
suite := TestSuite new.
#(TonelWriterTest TonelReaderTest TonelImporterTest TonelImageExporterTest)
    do: [ :name | (Smalltalk classNamed: name) addToSuiteFromSelectors: suite ].
result := suite run.
result printReport.
```

### Headless desde la terminal

```bash
CUIS_DEV_ROOT=/ruta/a/Cuis-Smalltalk-Dev \
  CUIS_VM_ARGS="-vm-sound-null -vm-display-null" \
  bash .github/scripts/run-tests.sh
```

El script detecta automáticamente la arquitectura (x86_64 / arm64) y localiza la VM y la imagen dentro de `CUIS_DEV_ROOT`.

---

## Flujo de desarrollo

El código vive en la imagen. Los archivos en `src/` y `dist/` son artefactos de exportación, no la fuente de verdad. **No editar esos archivos directamente.**

El ciclo de trabajo es:

1. Modificar el código dentro de la imagen (via MCP, Browser, o Workspace).
2. Exportar con `TonelImageExporter` para actualizar `src/`.
3. Guardar el paquete `.pck.st` desde el Package Browser para actualizar `dist/`.
4. Commitear los archivos generados.

El CI verifica que los tests pasen en Linux (amd64 y arm64). Cada push a `main` genera automáticamente un release en GitHub con los `.pck.st` como assets descargables.

---

## Lo que falta

Esta es la lista de limitaciones conocidas de la implementación actual. Están documentadas acá para que quien quiera contribuir sepa dónde empezar.

### Sin soporte de métodos de extensión

En Tonel, una clase puede tener métodos agregados desde otro paquete. Esos métodos van en un archivo separado con extensión `.extension.st`. Por ejemplo, si el paquete `Morphic` agrega métodos a `OrderedCollection`, esos métodos irían en `src/Collections/OrderedCollection.extension.st`.

El writer y el reader actuales no manejan este archivo. Todo método se escribe en el `.class.st` de su clase, sin distinción de paquete de origen.

### El importer no elimina métodos borrados

Si se elimina un método del archivo `.class.st` y se reimporta, el método sigue existiendo en la imagen. El importer solo agrega y sobreescribe; no compara qué había antes para detectar borrados. Para eliminar un método hay que hacerlo manualmente desde la imagen.

### El importer no actualiza variables de instancia ni de clase

Si la clase ya existe en la imagen y el archivo Tonel tiene una lista diferente de variables de instancia o de clase, el importer no actualiza la clase. Solo recompila los métodos. Para cambiar la estructura de una clase hay que hacerlo manualmente o eliminarla primero.

### Sin soporte de traits

Cuis soporta traits. Los archivos Tonel para traits tienen una declaración `Trait {` en lugar de `Class {`. El reader y el writer actuales solo manejan `Class {`.

### Sin soporte del formato `.properties` con version

El archivo `.properties` generado contiene solo `#format : #tonel`, sin especificar versión. La especificación de referencia del formato también soporta `#format : 'tonel'` (string) además de symbol. Si en el futuro se necesita interoperabilidad con tooling externo que valide la versión, puede ser necesario ajustar el writer.

### `importDirectory:` no omite `.properties`

`TonelImporter class >> importDirectory:` importa todos los archivos que terminan en `.st`. El archivo `.properties` no termina en `.st`, así que no hay problema hoy. Pero si se agrega algún archivo de configuración con esa extensión en el futuro, sería importado como Smalltalk.

### Sin exportación por paquete directa

No existe `TonelImageExporter exportPackage: 'Tonel' to: dir`. Hay que obtener las clases manualmente:

```smalltalk
clases := Smalltalk allClasses select: [ :c |
    (TonelWriter packageNameForCategory: c category) = 'Tonel' ].
TonelImageExporter exportClasses: clases to: dir.
```

Una API de alto nivel que tome el nombre del paquete y resuelva las clases sería una mejora natural.

---

## Compatibilidad

Desarrollado y probado con **Cuis Smalltalk 7.7** (update 7777). El formato generado es compatible con la especificación [pharo-vcs/tonel](https://github.com/pharo-vcs/tonel).

El CI corre en Linux amd64 y Linux arm64 en cada push.

---

## Licencia

Distribuido bajo la [GNU General Public License v3.0](LICENSE).

Las versiones derivadas deben mantener la misma licencia libre y publicar el código fuente.

---

Proyecto mantenido por [Gastón Caruso](https://github.com/gstn-caruso).
