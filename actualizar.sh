#!/bin/bash

# ------------------------------------------------------------------------------
# Script principal de actualización
# ------------------------------------------------------------------------------

# Fuente de las funciones de apt y mantenimiento
source "$HOME/.bin/lib/apt.sh"
source "$HOME/.bin/lib/mantenimiento.sh"

# ------------------------------------------------------------------------------
# Configuración
# ------------------------------------------------------------------------------

# Nivel de registro (0: solo errores, 1: información básica, 2: información detallada)
LOG_LEVEL=2

# Umbral de espacio libre en disco (en MB)
DISK_SPACE_THRESHOLD=500

# ------------------------------------------------------------------------------
# Funciones adicionales
# ------------------------------------------------------------------------------

# Función para actualizar completamente el sistema, incluyendo Flatpak y otros gestores
actualizar_sistema_completo() {
  echo "Actualizando el sistema al completo..."
  log 1 "Actualizando el sistema al completo..."

  # Actualizar paquetes APT
  sudo apt update || manejar_error_apt "sudo apt update"
  sudo apt full-upgrade -y || manejar_error_apt "sudo apt full-upgrade"

  # Actualizar paquetes Flatpak
  flatpak update -y || log_error "flatpak update"

  # Actualizar paquetes Snap (opcional, si se usan)
  # snap refresh || log_error "snap refresh"

  # Otros gestores de paquetes que se quieran incluir...

  echo "Sistema actualizado al completo."
  log 1 "Sistema actualizado al completo."
}

# Función para solucionar conflictos de paquetes
solucionar_conflictos() {
  echo "Solucionando conflictos..."
  log 1 "Solucionando conflictos..."

  if sudo apt --fix-broken install; then
    echo "Conflictos solucionados."
    log 1 "Conflictos solucionados."
  else
    # Mostrar mensaje de error en rojo y con letras más grandes
    echo -e "\e[1;31m\e[4mERROR: No se pudieron solucionar los conflictos.\e[0m"
    log_error "No se pudieron solucionar los conflictos."
  fi
}

# ------------------------------------------------------------------------------
# Funciones de menú
# ------------------------------------------------------------------------------

# Función para mostrar el menú
mostrar_menu() {
  clear
  echo "-------------------------"
  echo "  Menú de Actualización  "
  echo "-------------------------"
  echo "0. Mantenimiento completo del sistema"
  echo "   - Ejecuta todas las opciones de mantenimiento del sistema."
  echo "1. Actualizar lista de paquetes APT"
  echo "   - Actualiza la lista de paquetes disponibles en los repositorios."
  echo "2. Actualizar paquetes APT"
  echo "   - Actualiza los paquetes instalados a sus últimas versiones."
  echo "3. Actualizar sistema al completo"
  echo "   - Actualiza todos los paquetes del sistema, incluyendo Flatpak y otros gestores."
  echo "4. Eliminar paquetes innecesarios"
  echo "   - Elimina los paquetes que ya no son necesarios."
  echo "5. Limpiar archivos residuales"
  echo "   - Limpia los archivos de paquetes .deb que ya no se necesitan."
  echo "6. Solucionar paquetes retenidos"
  echo "   - Intenta solucionar problemas con paquetes retenidos."
  echo "7. Habilitar Ubuntu Pro"
  echo "   - Habilita Ubuntu Pro en tu sistema."
  echo "8. Deshabilitar Ubuntu Pro"
  echo "   - Deshabilita Ubuntu Pro en tu sistema."
  echo "9. Comprobar Livepatch"
  echo "   - Comprueba si Livepatch está habilitado y si tienes todos los agregados free."
  echo "10. Actualizar completo (LTS)"
  echo "   - Actualiza el sistema a la última versión LTS disponible."
  echo "11. Solucionar problemas"
  echo "   - Intenta solucionar problemas de incompatibilidad y paquetes dañados."
  echo "12. Limpiar paquetes"
  echo "   - Elimina paquetes innecesarios y purga sus archivos de configuración."
  echo "13. Limpiar caché"
  echo "   - Limpia la caché de paquetes APT."
  echo "14. Salir"
  echo "   - Sale del script."
  echo "-------------------------"
  read -p "Elige una opción: " opcion
}

# ------------------------------------------------------------------------------
# Manejo de señales
# ------------------------------------------------------------------------------

trap 'log 1 "Recibida señal SIGINT. Saliendo..."; exit 1' SIGINT
trap 'log 1 "Recibida señal SIGTERM. Saliendo..."; exit 1' SIGTERM

# ------------------------------------------------------------------------------
# Bucle principal
# ------------------------------------------------------------------------------

while true; do
  mostrar_menu
  case "$opcion" in
    0)
      mantenimiento_completo
      ;;
    1)
      verificar_espacio_en_disco
      actualizar_lista
      ;;
    2)
      verificar_espacio_en_disco
      actualizar_paquetes
      ;;
    3)
      verificar_espacio_en_disco
      actualizar_sistema_completo
      solucionar_conflictos # Solucionar posibles conflictos después de la actualización
      limpiar_paquetes # Purgar paquetes innecesarios después de la actualización
      ;;
    4)
      eliminar_paquetes
      ;;
    5)
      limpiar_archivos
      ;;
    6)
      solucionar_retenidos
      ;;
    7)
      habilitar_ubuntu_pro
      ;;
    8)
      deshabilitar_ubuntu_pro
      ;;
    9)
      comprobar_livepatch
      ;;
    10)
      actualizar_completo_lts
      ;;
    11)
      solucionar_problemas
      ;;
    12)
      limpiar_paquetes
      ;;
    13)
      limpiar_cache
      ;;
    14)
      log 1 "Saliendo..."
      echo "Saliendo..."
      exit 0
      ;;
    *)
      echo "Opción inválida. Por favor, elige una opción del menú."
      ;;
  esac
  read -p "Presiona Enter para continuar..."
done