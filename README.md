# cuis-tonel

Soporte del formato [Tonel](https://github.com/pharo-vcs/tonel) para Cuis Smalltalk — un archivo por clase, diffs legibles en git por método.

## Instalación

```smalltalk
CodePackageFile installPackage: '/ruta/a/dist/Tonel.pck.st' asFileEntry.
CodePackageFile installPackage: '/ruta/a/dist/Tests-Tonel.pck.st' asFileEntry.
```

O descargá los `.pck.st` desde [Releases](../../releases).

## Uso

**Exportar clases a Tonel:**

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
