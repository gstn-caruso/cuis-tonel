# Tonel VAST – relevamiento inicial

## Paquetes reutilizables (independientes de ENVY)

| Carpeta | Contenido | Observaciones |
| --- | --- | --- |
| `TonelReaderModel` | Parser, scanners y objetos de dominio (`TonelParser`, `TonelReader*Definition`, `TonelScanner`, etc.). | Depende de `STON` para leer metadata/definitions. Extiende `EsString`/`CfsPath`. Código Smalltalk puro → portable reimplementando el filesystem y reemplazando `STON`.
| `TonelReaderTests` | SUnit para parser/reader. | Necesitan `TonelParser`, `TonelReader`, `TonelScanner`, etc. | 
| `TonelWriterModel` | Serialización Tonel (`TonelWriter`, `TonelArtifactWriter`). | Usa `STONWriter` y wrappers de filesystem. No toca ENVY directo.
| `TonelWriterTests` | Pruebas para writer. | Dependen del filesystem Tonel y `STONWriter`.
| `TonelFileSystem` | Abstracciones para filesystem (`TonelAbstractFileSystem`, `TonelCfsFileSystem`, etc.). | Implementa adaptadores a `CfsPath`. Podemos mapear a `FileDirectory` en Cuis.
| `TonelSubapplication`, `TonelWriterTest*` | Fixtures auxiliares (clases mock) usadas en tests. | Se portan como datos de prueba.

## Paquetes dependientes de ENVY/VAST (requieren reescritura)

| Carpeta | Función |
| --- | --- |
| `TonelLoaderModel`, `TonelLoaderInteractiveApp` | Integración con Application Manager y Config Maps de ENVY. Manejan prerequisitos, versiones y sesiones transaccionales. |
| `TonelWriterModel` (parcial) | Las partes que escriben Applications/Config Maps específicas de VAST (versiones, estrategias) deberán re-implementar la contraparte en Cuis (CodePackage/ChangeSet). |
| `TonelBaseApp`, `TonelTools`, `TonelLoaderTests` | Capas UI/Feature de VAST, menús Transcript y tests que dependen de la librería ENVY. |
| `.configmaps`, `.properties`, `EmLibraryToolsApp` | Infraestructura de deployment de VAST. No aplica a Cuis. |

## Dependencias externas imprescindibles

- **STON** (`STONReader`, `STONWriter`, etc.): no viene en el repo, es un prerequisito. Necesitamos portarlo o implementar lector/escritor compatible.
- **Filesystem `CfsPath`**: se reimplementa con `FileDirectory`/`Path` de Cuis.
- **SUnit**: Cuis ya trae `TestCase`, por lo que los tests son portables con ajustes menores.

## Gap funcional esperado en Cuis

1. No existe ENVY → reemplazaremos Applications/Config Maps por `CodePackage` y `ChangeSet`.
2. Los menús GUI embebidos en Application Manager se reemplazarán por comandos/menús propios en el Browser de Cuis.
3. Integración “auto git versioning” cae de maduro: en Cuis el workflow será `TonelWriter` → filesystem → git CLI.

## Referencia canónica (pharo-vcs/tonel)

- El spec “oficial” vive en `https://github.com/pharo-vcs/tonel` (branch `Pharo14`).
- Allí están las clases `TonelParser`, `TonelReader`, `TonelCommentScanner`, etc., empaquetadas en `MonticelloTonel-Core.package` con tests.
- Usaremos ese repo como fuente primaria para la semántica del parser y de los scanners, y el repo de Instantiations como guía de integración con herramientas externas.

## Próximos pasos

1. Crear paquetes `Tonel-Support` y `Tonel-Support-Tests` en la imagen Cuis. ✅
2. Portar STON mínimo (lector/escritor) para satisfacer las dependencias del parser. ✅
3. Migrar `TonelReaderModel` + tests respetando TDD (tomando como base `pharo-vcs/tonel`).
4. Construir `TonelWriter` y adapters de filesystem.
5. Reemplazar loader VAST por integración con `CodePackage` (import/export) y asegurar exportación `.pck.st`.

---

## Documentos de referencia (generados)

- [`tonel-pharo-deps.md`](tonel-pharo-deps.md) — Análisis detallado de dependencias Pharo y sus reemplazos en Cuis
- [`tonel-design.md`](tonel-design.md) — Modelo de objetos limpio para la implementación en Cuis
- [`tonel-implementation-plan.md`](tonel-implementation-plan.md) — Plan TDD etapa por etapa (TonelStonParser → TonelMCPServer)
- [`tonel-mcp-integration.md`](tonel-mcp-integration.md) — Diseño de la integración MCP: herramientas, flujo y roadmap
