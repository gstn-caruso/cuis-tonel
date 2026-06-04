# Contribuir

## Limitaciones conocidas

Estas son las áreas donde la implementación actual es incompleta. Son buenos puntos de entrada para contribuir.

### El importer no elimina métodos borrados

Si se elimina un método del `.class.st` y se reimporta, el método sigue en la imagen. El importer solo agrega y sobreescribe; para borrar hay que hacerlo manualmente.

### El importer no actualiza variables de instancia ni de clase

Si la clase ya existe y el archivo Tonel tiene variables distintas, el importer solo recompila métodos. Para cambiar la estructura hay que modificar la clase manualmente o eliminarla primero.

### Sin soporte de traits

Cuis soporta traits. Los archivos Tonel para traits usan `Trait {` en lugar de `Class {`. El reader y el writer actuales solo manejan clases.

### Sin exportación por nombre de paquete

No existe `TonelImageExporter exportPackage: 'Tonel' to: dir`. Por ahora hay que obtener las clases manualmente:

```smalltalk
clases := Smalltalk allClasses select: [ :c |
    (TonelWriter packageNameForCategory: c category) = 'Tonel' ].
TonelImageExporter exportClasses: clases to: dir.
```
