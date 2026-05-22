# cuis-tonel

Soporte nativo del formato Tonel para Cuis Smalltalk. Permite exportar clases desde la imagen, importar archivos `.class.st` y mantener el código fuente versionado en repositorios Git.

## ¿Qué es Tonel?

Tonel es un formato de persistencia de código fuente para Smalltalk: un archivo por clase, legible por humanos y amigable con los sistemas de control de versiones. Cada archivo `.class.st` contiene la definición de una clase y todos sus métodos.

Especificación de referencia: [pharo-vcs/tonel](https://github.com/pharo-vcs/tonel).

## Funcionalidades

- **`TonelWriter`** — Serializa una clase de la imagen al formato Tonel.
- **`TonelReader`** — Parsea el contenido de un archivo `.class.st` y devuelve una `TonelClassDefinition`.
- **`TonelImporter`** — Compila una definición Tonel en la imagen Cuis (crea la clase y sus métodos).
- **`TonelImageExporter`** — Exporta un conjunto de clases de la imagen a un directorio con estructura Tonel.

## Estructura del repositorio

```
dist/
  Tonel.pck.st          ← paquete distribuible principal
  Tests-Tonel.pck.st    ← tests (requiere Tonel)
src/
  Tonel/                ← fuente Tonel de las clases del paquete
  Tests/                ← fuente Tonel de los tests
.github/
  workflows/ci.yml      ← CI con GitHub Actions
  scripts/
    run-tests.sh        ← script de tests headless
    run-tests.st        ← script Smalltalk de tests
    export-tonel.st     ← script Smalltalk de exportación
```

## Instalación

Desde el Browser de Cuis o con `CodePackageFile`:

```smalltalk
CodePackageFile installPackage: '/ruta/a/cuis-tonel/dist/Tonel.pck.st' asFileEntry.
```

Para instalar los tests también:

```smalltalk
CodePackageFile installPackage: '/ruta/a/cuis-tonel/dist/Tests-Tonel.pck.st' asFileEntry.
```

## Uso

### Exportar una clase al formato Tonel

```smalltalk
| source |
source := TonelWriter sourceForClass: OrderedCollection.
Transcript show: source.
```

### Exportar todas las clases de la imagen a un directorio

```smalltalk
TonelImageExporter exportAllTo: '/ruta/de/salida' asDirectoryEntry.
```

Esto genera una estructura como:

```
/ruta/de/salida/
  src/
    Kernel/
      Object.class.st
      ...
    Collections/
      OrderedCollection.class.st
      ...
  manifest.txt
```

### Importar desde un archivo Tonel

```smalltalk
TonelImporter importFile: '/ruta/a/MiClase.class.st' asFileEntry.
```

### Parsear el contenido de un archivo Tonel

```smalltalk
| definition |
definition := TonelReader readStream: '/ruta/a/MiClase.class.st' asFileEntry readStream.
definition className.         "=> #MiClase"
definition superclassName.    "=> #Object"
definition instanceVariableNames. "=> #('x' 'y')"
definition methods size.      "=> 3"
```

### Reimportar (actualizar) una clase existente

El importador compila los métodos sin recrear la clase si esta ya existe:

```smalltalk
TonelImporter importStream: miArchivoTonelActualizado readStream.
```

## Ejecutar los tests

### En la imagen

```smalltalk
| suite result |
suite := TestSuite new.
#(TonelWriterTest TonelReaderTest TonelImporterTest TonelImageExporterTest)
    do: [:name | (Smalltalk classNamed: name) addToSuiteFromSelectors: suite].
suite run printReport.
```

### Headless (desde la terminal)

```bash
CUIS_DEV_ROOT=/ruta/a/Cuis-Smalltalk-Dev \
  CUIS_VM_ARGS="-vm-sound-null -vm-display-null" \
  bash .github/scripts/run-tests.sh
```

## Desarrollo

El flujo de trabajo para modificar el paquete sigue la regla invariante de Cuis:

1. Modificar el código **dentro de la imagen** (via MCP o scripts headless).
2. Exportar con `TonelImageExporter` o con la herramienta de exportación del fork.
3. Actualizar `dist/*.pck.st` (exportar desde el Package Browser de Cuis).
4. Commitear los archivos generados.

**Nunca editar los archivos `.class.st` de `src/` o los `.pck.st` de `dist/` directamente.**

## Compatibilidad

Desarrollado y probado con **Cuis Smalltalk 7.7** (update 7777).

## Licencia

Este proyecto se distribuye bajo la [GNU General Public License v3.0](LICENSE).

Al usar, modificar o redistribuir este software, las versiones derivadas deben
mantener la misma licencia libre y publicar el código fuente.

---

Proyecto mantenido por [Gastón Caruso](https://github.com/gstn-caruso).
