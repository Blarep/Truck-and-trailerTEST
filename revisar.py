import os

# Ruta principal
ruta = "instances200-1500-17-8"
a = 0
for carpeta, subcarpetas, archivos in os.walk(ruta):
    print(f"{carpeta}: {len(archivos)} archivos")
    a += len(archivos)

print(a)
