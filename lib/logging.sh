#!/bin/bash

# ------------------------------------------------------------------------------
# Funciones de registro
# ------------------------------------------------------------------------------

# Función para registrar mensajes
# Parámetros:
#   $1: Nivel de registro (0: error, 1: info, 2: debug)
#   $2: Mensaje a registrar
log() {
  local level=$1
  local message=$2
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  local log_file="/var/log/actualizacion.log"  # Definimos la variable localmente
  if [[ $level -le $LOG_LEVEL ]]; then
    echo "[$timestamp] $message" | sudo tee -a "$log_file" > /dev/null
  fi
}

# Función para registrar errores
# Parámetros:
#   $1: Mensaje de error
log_error() {
  log 0 "Error: $1"
}