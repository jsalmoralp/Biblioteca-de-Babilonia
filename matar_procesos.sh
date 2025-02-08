#!/bin/bash

# ------------------------------------------------------------------------------
# Script para matar procesos con menú interactivo
# ------------------------------------------------------------------------------

# Fuente de las funciones de logging
source "$HOME/.bin/lib/logging.sh"

# ------------------------------------------------------------------------------
# Funciones
# ------------------------------------------------------------------------------

# Función para mostrar el menú principal
mostrar_menu_principal() {
  clear
  echo "-------------------------"
  echo "  Menú Matar Procesos   "
  echo "-------------------------"
  echo "1. Filtrar por usuario"
  echo "2. Filtrar por programa"
  echo "3. Salir"
  echo "-------------------------"
  read -p "Elige una opción: " opcion_principal
}

# Función para mostrar el submenú de selección de procesos
mostrar_submenu_procesos() {
  clear
  echo "-------------------------"
  echo "  Seleccionar Procesos  "
  echo "-------------------------"
  ps aux | grep "$filtro" | awk '{print $2, $11}'  # Mostrar PID y comando
  echo "-------------------------"
  echo "1. Matar todos los procesos"
  echo "2. Matar procesos seleccionados"
  echo "3. Volver al menú principal"
  echo "-------------------------"
  read -p "Elige una opción: " opcion_submenu
}

# Función para matar un proceso por su PID
matar_proceso_por_pid() {
  local pid="$1"
  log 1 "Matando proceso con PID: $pid"
  sudo kill -9 "$pid" || log_error "No se pudo matar el proceso con PID $pid"
}

# Función para matar todos los procesos filtrados
matar_todos_los_procesos() {
  log 1 "Matando todos los procesos con filtro: $filtro"
  sudo pkill -9 "$filtro" || log_error "No se pudo matar ningún proceso con filtro $filtro"
}

# ------------------------------------------------------------------------------
# Bucle principal
# ------------------------------------------------------------------------------

while true; do
  mostrar_menu_principal
  case "$opcion_principal" in
    1)  # Filtrar por usuario
      read -p "Introduce el nombre de usuario: " filtro
      mostrar_submenu_procesos
      case "$opcion_submenu" in
        1)
          matar_todos_los_procesos
          ;;
        2)
          read -p "Introduce los PIDs de los procesos a matar (separados por espacios): " pids
          for pid in $pids; do
            matar_proceso_por_pid "$pid"
          done
          ;;
        3)
          continue  # Volver al menú principal
          ;;
        *)
          echo "Opción inválida."
          ;;
      esac
      ;;
    2)  # Filtrar por programa
      read -p "Introduce el nombre del programa: " filtro
      mostrar_submenu_procesos
      case "$opcion_submenu" in
        1)
          matar_todos_los_procesos
          ;;
        2)
          read -p "Introduce los PIDs de los procesos a matar (separados por espacios): " pids
          for pid in $pids; do
            matar_proceso_por_pid "$pid"
          done
          ;;
        3)
          continue  # Volver al menú principal
          ;;
        *)
          echo "Opción inválida."
          ;;
      esac
      ;;
    3)  # Salir
      log 1 "Saliendo..."
      echo "Saliendo..."
      exit 0
      ;;
    *)
      echo "Opción inválida."
      ;;
  esac
  read -p "Presiona Enter para continuar..."
done
