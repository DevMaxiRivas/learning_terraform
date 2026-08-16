#!/usr/bin/env bash

# Script Generado con IA

set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Uso: $0 <ruta>"
  exit 1
fi

TARGET_DIR="$1"

if [ ! -d "$TARGET_DIR" ]; then
  echo "Error: la ruta '$TARGET_DIR' no existe o no es un directorio."
  exit 1
fi

echo "Limpiando artefactos de Terraform en: $TARGET_DIR"
echo "Se conservaran unicamente los archivos con extension .tf"

# Archivos de estado y lock
find "$TARGET_DIR" -type f \( \
  -name '*.tfstate' -o \
  -name '*.tfstate.backup' -o \
  -name '.terraform.lock.hcl' -o \
  -name 'crash.log' -o \
  -name 'terraform.log' -o \
  -name '.terraform.tfstate' \
\) -print -delete

# Carpetas de terraform
find "$TARGET_DIR" -type d \( \
  -name '.terraform' -o \
  -name '.terraform.lock.hcl' \
\) -print -exec rm -rf {} + 2>/dev/null || true

# Eliminar todo lo que NO sea un archivo .tf dentro de la ruta
# (conserva directorios y archivos .tf, borra el resto de archivos sueltos)
# find "$TARGET_DIR" -type f ! -name '*.tf' -print -delete

echo "Limpieza completada."
