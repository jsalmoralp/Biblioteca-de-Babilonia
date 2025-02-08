#!/bin/bash

# ------------------------------------------------------------------------------
# Script para instalar paquetes extra
# ------------------------------------------------------------------------------

# Fuente de las funciones de logging
source "$HOME/.bin/lib/logging.sh"

# ------------------------------------------------------------------------------
# Variables globales
# ------------------------------------------------------------------------------

# Paquetes seleccionados
editor_seleccionado="nano"
servidor_web_seleccionado="apache2"
servidor_bd_seleccionado="mariadb-server"
sesion_seleccionada="screen"

# ------------------------------------------------------------------------------
# Funciones
# ------------------------------------------------------------------------------

# Función para instalar un paquete
instalar_paquete() {
  local paquete="$1"
  log 1 "Instalando paquete: $paquete"
  sudo apt install -y "$paquete" || log_error "No se pudo instalar el paquete $paquete"
}

# Función para mostrar el menú principal
mostrar_menu_principal() {
  clear
  echo "----------------------------------"
  echo "  Menú de Instalación de Paquetes  "
  echo "----------------------------------"
  echo "1. Editores de texto [${editor_seleccionado}]"
  echo "2. Servidores web [${servidor_web_seleccionado}]"
  echo "3. Servidores de bases de datos [${servidor_bd_seleccionado}]"
  echo "4. Manejo de sesiones [${sesion_seleccionada}]"
  echo "5. Instalar paquetes básicos"
  echo "6. Instalar paquetes seleccionados"
  echo "7. Salir"
  echo "----------------------------------"
  read -p "Elige una opción: " opcion_principal
}

# Función para mostrar el submenú de editores de texto
mostrar_submenu_editores() {
  clear
  echo "-------------------------"
  echo "  Editores de texto  "
  echo "-------------------------"
  echo "1. nano"
  echo "2. vim"
  echo "3. emacs"
  echo "4. Volver al menú principal"
  echo "-------------------------"
  read -p "Elige una opción: " opcion_editor
}

# Función para mostrar el submenú de servidores web
mostrar_submenu_servidores_web() {
  clear
  echo "-------------------------"
  echo "  Servidores web  "
  echo "-------------------------"
  echo "1. apache2"
  echo "2. nginx"
  echo "3. lighttpd"
  echo "4. Volver al menú principal"
  echo "-------------------------"
  read -p "Elige una opción: " opcion_servidor_web
}

# Función para mostrar el submenú de servidores de bases de datos
mostrar_submenu_servidores_bd() {
  clear
  echo "-----------------------------"
  echo "  Servidores de bases de datos  "
  echo "-----------------------------"
  echo "1. mysql-server"
  echo "2. mariadb"
  echo "3. postgresql"
  echo "4. Volver al menú principal"
  echo "-----------------------------"
  read -p "Elige una opción: " opcion_servidor_bd
}

# Función para mostrar el submenú de manejo de sesiones
mostrar_submenu_sesiones() {
  clear
  echo "-------------------------"
  echo "  Manejo de sesiones  "
  echo "-------------------------"
  echo "1. screen"
  echo "2. tmux"
  echo "3. Volver al menú principal"
  echo "-------------------------"
  read -p "Elige una opción: " opcion_sesion
}

# Función para instalar los paquetes básicos (siempre se instalan)
instalar_paquetes_basicos() {
  log 1 "Instalando paquetes básicos..."
  instalar_paquete "build-essential"
  instalar_paquete "zip"
  instalar_paquete "unzip"
  instalar_paquete "rar"
  instalar_paquete "unrar"
  instalar_paquete "p7zip-full" 
  instalar_paquete "gzip"
  instalar_paquete "bzip2"
  instalar_paquete "xz-utils"
  instalar_paquete "tar"
  instalar_paquete "7z"
  instalar_paquete "cabextract"
  instalar_paquete "arj"
  instalar_paquete "lha"
  log 1 "Paquetes básicos instalados."
}

# Función para instalar los paquetes predeterminados
instalar_paquetes_predeterminados() {
  log 1 "Instalando paquetes predeterminados..."
  instalar_paquete "$editor_seleccionado"
  instalar_paquete "$servidor_web_seleccionado"
  instalar_paquete "$servidor_bd_seleccionado"
  instalar_paquete "$sesion_seleccionada"
  log 1 "Paquetes predeterminados instalados."
}

# Función para instalar los paquetes seleccionados
instalar_paquetes_seleccionados() {
  log 1 "Instalando paquetes seleccionados..."
  instalar_paquetes_basicos
  instalar_paquetes_predeterminados
  log 1 "Paquetes seleccionados instalados."
}

# ------------------------------------------------------------------------------
# Bucle principal
# ------------------------------------------------------------------------------

while true; do
  mostrar_menu_principal
  case "$opcion_principal" in
    1)  # Editores de texto
      mostrar_submenu_editores
      case "$opcion_editor" in
        1)
          editor_seleccionado="nano"
          ;;
        2)
          editor_seleccionado="vim"
          ;;
        3)
          editor_seleccionado="emacs"
          ;;
        4)
          continue  # Volver al menú principal
          ;;
        *)
          echo "Opción inválida."
          ;;
      esac
      ;;
    2)  # Servidores web
      mostrar_submenu_servidores_web
      case "$opcion_servidor_web" in
        1)
          servidor_web_seleccionado="apache2"
          ;;
        2)
          servidor_web_seleccionado="nginx"
          ;;
        3)
          servidor_web_seleccionado="lighttpd"
          ;;
        4)
          continue  # Volver al menú principal
          ;;
        *)
          echo "Opción inválida."
          ;;
      esac
      ;;
    3)  # Servidores de bases de datos
      mostrar_submenu_servidores_bd
      case "$opcion_servidor_bd" in
        1)
          servidor_bd_seleccionado="mysql-server"
          ;;
        2)
          servidor_bd_seleccionado="mariadb-server"
          ;;
        3)
          servidor_bd_seleccionado="postgresql"
          ;;
        4)
          continue  # Volver al menú principal
          ;;
        *)
          echo "Opción inválida."
          ;;
      esac
      ;;
    4)  # Manejo de sesiones
      mostrar_submenu_sesiones
      case "$opcion_sesion" in
        1)
          sesion_seleccionada="screen"
          ;;
        2)
          sesion_seleccionada="tmux"
          ;;
        3)
          continue  # Volver al menú principal
          ;;
        *)
          echo "Opción inválida."
          ;;
      esac
      ;;
    5)  # Instalar paquetes básicos
      instalar_paquetes_basicos
      ;;
    6)  # Instalar paquetes seleccionados
      instalar_paquetes_seleccionados
      ;;
    7)  # Salir
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