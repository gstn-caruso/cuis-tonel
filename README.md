# cuis-tonel

Soporte del formato [Tonel](https://github.com/pharo-vcs/tonel) para Cuis Smalltalk — un archivo por clase, diffs legibles en git por método.

Pensado para volcar **la imagen completa** a fuentes Tonel y reconstruirla: el ciclo
export → import → export es **byte-estable** y preserva todo lo necesario para reimportar
el 100% del código.

## Qué preserva

- Definición de clase: ivars, classVars, pools, classInstVars, categoría y comentario.
- Métodos de instancia y de clase.
- **Métodos de extensión** (`.extension.st`): métodos que un paquete agrega a clases de
  otro paquete, con su categoría `*Paquete`.
- **Forma de almacenamiento**: clases `variable` / `bytes` / `words` / `weak` se reescriben
  con `#type` y se recrean con el selector correcto (`variableByteSubclass:`, etc.); las
  fijas no llevan `#type`.

## Instalación

```smalltalk
CodePackageFile installPackage: '/ruta/a/dist/Tonel.pck.st' asFileEntry.
CodePackageFile installPackage: '/ruta/a/dist/Tests-Tonel.pck.st' asFileEntry.
```

O descargá los `.pck.st` desde [Releases](../../releases).

## Uso

**Exportar la imagen completa a Tonel** (un dir por paquete bajo `src/`):

```smalltalk
TonelImageExporter exportAllTo: '/tmp/export' asDirectoryEntry.
```

**Exportar clases puntuales:**

```smalltalk
TonelImageExporter exportClasses: { MiClase. OtraClase } to: '/tmp/export' asDirectoryEntry.
```

**Importar desde un directorio Tonel:**

```smalltalk
TonelImporter importDirectory: '/ruta/a/src/MiPaquete' asDirectoryEntry.
```

**Serializar una clase a texto:**

```smalltalk
TonelWriter sourceForClass: MiClase.
```

## Desarrollo

El código vive en la imagen. Los archivos en `src/` y `dist/` son artefactos de exportación — no editar directamente.

Ciclo:
1. Modificar el código en la imagen.
2. Exportar con `TonelImageExporter` → actualiza `src/`.
3. Guardar el paquete desde Package Browser → actualiza `dist/`.
4. Commitear.

Tests headless:

```bash
CUIS_DEV_ROOT=/ruta/a/Cuis-Smalltalk-Dev bash .github/scripts/run-tests.sh
```

Desarrollado con **Cuis 7.7** (update 7777). CI en Linux amd64 y arm64.

## Licencia

[MIT](LICENSE)
