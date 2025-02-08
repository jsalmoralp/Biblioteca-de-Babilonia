#!/bin/bash

# ------------------------------------------------------------------------------
# Funciones de gestión de paquetes (apt)
# ------------------------------------------------------------------------------

# Fuente de las funciones de logging
source "$HOME/.bin/lib/logging.sh"

# Función para manejar errores de apt
# Parámetros:
#   $1: Comando que ha fallado
manejar_error_apt() {
  local command=$1
  log_error "$command"
  case "$command" in
    "sudo apt update" | "sudo pro refresh")
      echo "Intentando solucionar problemas de conexión..."
      log 1 "Verificando la conexión a Internet..."
      ping -c 4 8.8.8.8 > /dev/null 2>&1
      if [[ $? -eq 0 ]]; then
        echo "Conexión a Internet establecida."
        log 1 "Conexión a Internet establecida."
        echo "Intentando actualizar la lista de paquetes de nuevo..."
        log 1 "Intentando actualizar la lista de paquetes de nuevo..."
        sudo apt update || manejar_error_apt "sudo apt update"
        sudo pro refresh || manejar_error_apt "sudo pro refresh"
      else
        echo "Error: No se pudo establecer conexión a Internet."
        log_error "No se pudo establecer conexión a Internet."
        echo "Por favor, verifica tu conexión y vuelve a intentarlo."
        exit 1
      fi
      ;;
    "sudo apt upgrade" | "sudo apt full-upgrade" | "sudo apt autoremove" | "sudo pro fix")
      echo "Intentando solucionar problemas de dependencias..."
      log 1 "Intentando solucionar problemas de dependencias..."
      sudo apt --fix-broken install || manejar_error_apt "$command"
      sudo pro fix || manejar_error_apt "sudo pro fix"
      ;;
    *)
      echo "Error desconocido. Saliendo..."
      log_error "Error desconocido: $command"
      exit 1
      ;;
  esac
}

# Función para solucionar paquetes retenidos
solucionar_retenidos() {
  echo "Solucionando paquetes retenidos..."
  log 1 "Solucionando paquetes retenidos..."
  echo "Intentando con apt-get dist-upgrade..."
  log 2 "Intentando con apt-get dist-upgrade..."
  sudo apt-get -o Debug::pkgProblemResolver=yes dist-upgrade
  if [[ $? -ne 0 ]]; then
    echo "apt-get dist-upgrade falló. Intentando con dpkg --configure -a..."
    log 2 "apt-get dist-upgrade falló. Intentando con dpkg --configure -a..."
    sudo dpkg --configure -a
  fi
  echo "Proceso de solución de paquetes retenidos finalizado."
  log 1 "Proceso de solución de paquetes retenidos finalizado."
}

# Función para actualizar la lista de paquetes
actualizar_lista() {
  echo "Actualizando la lista de paquetes..."
  log 1 "Actualizando la lista de paquetes..."
  sudo apt update || manejar_error_apt "sudo apt update"
  if [[ $? -eq 0 ]]; then
    echo "Actualizando repositorios de Ubuntu Pro..."
    log 1 "Actualizando repositorios de Ubuntu Pro..."
    sudo pro refresh || manejar_error_apt "sudo pro refresh"
  fi
  echo "Lista de paquetes actualizada."
  log 1 "Lista de paquetes actualizada."
}

# Función para actualizar los paquetes
actualizar_paquetes() {
  echo "Actualizando los paquetes..."
  log 1 "Actualizando los paquetes..."
  sudo apt upgrade -y || manejar_error_apt "sudo apt upgrade"
  echo "Paquetes actualizados."
  log 1 "Paquetes actualizados."
}

# Función para actualizar completamente el sistema
actualizar_completo() {
  echo "Realizando una actualización completa del sistema..."
  log 1 "Realizando una actualización completa del sistema..."
  sudo apt full-upgrade -y || manejar_error_apt "sudo apt full-upgrade"
  echo "Actualización completa del sistema finalizada."
  log 1 "Actualización completa del sistema finalizada."
}

# Función para eliminar paquetes innecesarios
eliminar_paquetes() {
  echo "Eliminando paquetes innecesarios..."
  log 1 "Eliminando paquetes innecesarios..."
  sudo apt autoremove -y || manejar_error_apt "sudo apt autoremove"
  echo "Paquetes innecesarios eliminados."
  log 1 "Paquetes innecesarios eliminados."
}

# Función para limpiar archivos residuales
limpiar_archivos() {
  echo "Limpiando archivos residuales..."
  log 1 "Limpiando archivos residuales..."
  sudo apt autoclean -y
  echo "Archivos residuales limpiados."
  log 1 "Archivos residuales limpiados."
}

# Función para el mantenimiento completo del sistema
mantenimiento_completo() {
  log 1 "Iniciando mantenimiento completo del sistema..."
  echo "Iniciando mantenimiento completo del sistema..."

  verificar_espacio_en_disco
  actualizar_lista
  actualizar_paquetes
  actualizar_sistema_completo
  solucionar_conflictos
  limpiar_paquetes
  limpiar_archivos
  solucionar_retenidos
  limpiar_cache

  echo "Mantenimiento completo del sistema finalizado."
  log 1 "Mantenimiento completo del sistema finalizado."
}