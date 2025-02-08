¡Claro! Vamos a securizar tu sistema Ubuntu 24.04 LTS con un enfoque de "denegar todo por defecto" y luego habilitar servicios específicos. Este es un enfoque excelente para la seguridad.  Necesito la hoja de instrucciones del GEM a la que haces referencia para darte una respuesta precisa y adaptada, pero como no me la has proporcionado, te daré una guía completa basada en las mejores prácticas de seguridad para Linux y, en particular, Ubuntu, asumiendo que el "GEM" se refiere a una metodología o conjunto de herramientas genéricas de endurecimiento (hardening).

**Aquí tienes un plan de acción detallado, dividido en secciones:**

1.  **Firewall (Cortafuegos) con `ufw` (y transición a `nftables` si quieres lo más avanzado):**

    *   **`ufw` (Uncomplicated Firewall):** Es la forma más sencilla de empezar en Ubuntu y es *muy* recomendable para la mayoría de los usuarios.

        ```bash
        sudo ufw default deny incoming   # Denegar todo el tráfico entrante por defecto
        sudo ufw default deny outgoing   # Denegar todo el tráfico saliente por defecto
        sudo ufw enable                # Habilitar el firewall
        ```

        *Ahora, habilita *solo* lo necesario.  Ejemplos (¡ajusta a tus necesidades!):*

        ```bash
        sudo ufw allow ssh       # Permitir SSH (puerto 22 por defecto, ¡considera cambiarlo!)
        sudo ufw allow http      # Permitir tráfico web (puerto 80)
        sudo ufw allow https     # Permitir tráfico web seguro (puerto 443)
        sudo ufw allow out to any port 53  # Permitir DNS (tanto TCP como UDP)
        sudo ufw allow out to any port 123 proto udp #Permitir NTP (sincronización de hora)
        # Si usas una VPN, permite el puerto y protocolo de tu VPN.  Ejemplo (OpenVPN, UDP, puerto 1194):
        # sudo ufw allow out 1194/udp

        #Si necesitas, por poner un ejemplo de una app que tengas corriendo localmente, y necesites
        # conectarte desde otro equipo de la red, o desde fuera, a un servicio que corra en un puerto no estandar
        # deberas de especificar la ip origen, si se trata de una LAN (direccionamiento 192.168.x.x , 10.x.x.x o 172.16.x.x a 172.31.x.x)
        # y el puerto. Ademas de especificar a la ip que tienes asignada en local (ifconfig o ip addr show),
        # la mascara (/32 es individual, /24 es la red completa clase C (de 1 a 254) y el protocolo.
        sudo ufw allow from 192.168.1.0/24 to 192.168.1.100 port 8080 proto tcp
        ```

        *Verifica el estado:*

        ```bash
        sudo ufw status verbose  # Muestra las reglas activas y su estado
        ```

        *   **MUY IMPORTANTE:** Antes de habilitar `ufw` con las reglas `deny outgoing`, asegúrate de tener una sesión SSH ya abierta *o* acceso físico a la máquina.  Si no lo haces, podrías bloquearte a ti mismo.  Si te bloqueas, necesitarás acceso físico para corregirlo.

    *   **`nftables` (Nivel Avanzado):**  Es el sucesor de `iptables` y ofrece mayor flexibilidad y rendimiento.  Si `ufw` se queda corto (raro, pero posible si necesitas reglas muy complejas), considera `nftables`.  La configuración es más compleja, así que *solo* ve por este camino si tienes experiencia o estás dispuesto a aprender.

        *   Instalación (si no está ya instalado): `sudo apt update && sudo apt install nftables`
        *   Configuración básica (similar a la lógica de `ufw`, pero con sintaxis diferente).  *Este es solo un punto de partida; necesitarás adaptarlo:*

            ```bash
            sudo nft add table inet filter  # Crear la tabla principal
            sudo nft add chain inet filter input { type filter hook input priority 0 \; policy drop \; }
            sudo nft add chain inet filter forward { type filter hook forward priority 0 \; policy drop \; }
            sudo nft add chain inet filter output { type filter hook output priority 0 \; policy drop \; }

            # Permitir conexiones establecidas y relacionadas
            sudo nft add rule inet filter input ct state established,related accept
            sudo nft add rule inet filter output ct state established,related accept

            # Permitir loopback (tráfico interno)
            sudo nft add rule inet filter input iif lo accept
            sudo nft add rule inet filter output oif lo accept

            # Permitir SSH (ejemplo, puerto 22) - ¡Ajusta según sea necesario!
            sudo nft add rule inet filter input tcp dport 22 accept

            # Permitir DNS
            sudo nft add rule inet filter output udp dport 53 accept
            sudo nft add rule inet filter output tcp dport 53 accept
             # Permitir NTP
            sudo nft add rule inet filter output udp dport 123 accept

            # Resto de tus reglas...

            sudo nft list ruleset  # Ver las reglas
            sudo nft flush ruleset # Vaciar TODAS las reglas (¡cuidado!)
            ```

            Para hacer las reglas persistentes (que se carguen al reiniciar), usa:

            ```bash
             sudo nft list ruleset > /etc/nftables.conf
             # Edita /etc/nftables.conf si es necesario
             # Activa el servicio:
             sudo systemctl enable nftables
             sudo systemctl start nftables

            ```
        * **Recomendación:** Si eres nuevo en firewalls, empieza con `ufw`.  Si te sientes cómodo, investiga `nftables` en un entorno de pruebas *antes* de implementarlo en producción.

2.  **SSH (Acceso Remoto Seguro):**

    *   **Cambia el puerto por defecto (22):**  Esto reduce los ataques automatizados.
        *   Edita `/etc/ssh/sshd_config`:  `sudo nano /etc/ssh/sshd_config`
        *   Busca `Port 22` y cámbialo a un puerto alto (ej: `Port 2222`).  *Asegúrate de que el puerto no esté en uso.*
        *   Guarda y cierra el archivo.
        *   Reinicia el servicio SSH: `sudo systemctl restart ssh`
        *   **Actualiza tu regla de firewall** para permitir el nuevo puerto (`sudo ufw allow 2222/tcp` si usaste 2222).  *Antes* de cerrar la sesión actual, abre una *nueva* sesión SSH usando el nuevo puerto para verificar que funciona.
    *   **Desactiva el login con contraseña:** Usa claves SSH en su lugar. Esto es *mucho* más seguro.
        *   Genera un par de claves SSH en tu máquina *local* (la que usas para conectarte): `ssh-keygen -t ed25519 -C "tu_email@ejemplo.com"` (o `rsa` si `ed25519` no es compatible)
        *   Copia la clave pública a tu servidor: `ssh-copy-id -i ~/.ssh/id_ed25519.pub raskan@tu_ip_o_hostname -p 2222` (usa el puerto que configuraste).
        *   Edita `/etc/ssh/sshd_config` en el servidor:

            ```
            PasswordAuthentication no          # Desactivar login con contraseña
            PubkeyAuthentication yes        # Activar autenticación con clave
            # Opcional, pero recomendable:
            PermitRootLogin no             # Desactivar login directo como root
            AllowUsers raskan             # Permitir solo al usuario 'raskan' (o tus usuarios)
            ```

        *   Reinicia SSH: `sudo systemctl restart ssh`
        *   **Prueba:**  Intenta conectarte con tu clave SSH.  *No* debería pedirte contraseña.
    *   **Considera `fail2ban`:**  Esta herramienta banea IPs que fallan repetidamente al autenticarse.

        ```bash
        sudo apt update && sudo apt install fail2ban
        sudo systemctl enable fail2ban
        sudo systemctl start fail2ban

        #Configuralo
        sudo nano /etc/fail2ban/jail.local
        ```

        Y dentro del archivo añade/modifica..

        ```
        [sshd]
        enabled = true
        port = 2222 #o el puerto en el que tengas configurado el ssh
        filter = sshd
        logpath = /var/log/auth.log
        maxretry = 3
        findtime = 600
        bantime = 3600
        ignoreip = 127.0.0.1/8 192.168.1.0/24 # Lista blanca de IPs (opcional)
        ```

3.  **Actualizaciones Automáticas:**

    *   Es *fundamental* mantener el sistema actualizado.
    *   Usa `unattended-upgrades`:

        ```bash
        sudo apt update && sudo apt install unattended-upgrades
        sudo dpkg-reconfigure --priority=low unattended-upgrades
        ```

        *   Configura las opciones (se te preguntará durante la instalación).  Es recomendable habilitar las actualizaciones automáticas de seguridad.
        *   Edita `/etc/apt/apt.conf.d/50unattended-upgrades` para personalizar aún más (ej: qué paquetes actualizar, cuándo, si reiniciar automáticamente, etc.).  *Revisa bien las opciones.*  Un ejemplo de configuración:

            ```
            Unattended-Upgrade::Allowed-Origins {
                "<span class="math-inline">\{distro\_id\}\:</span>{distro_codename}";
                "<span class="math-inline">\{distro\_id\}\:</span>{distro_codename}-security";
                // "<span class="math-inline">\{distro\_id\}\:</span>{distro_codename}-updates";  // Descomenta si quieres actualizaciones no solo de seguridad
                // "<span class="math-inline">\{distro\_id\}\:</span>{distro_codename}-proposed"; // Evita -proposed a menos que sepas lo que haces
                // "<span class="math-inline">\{distro\_id\}\:</span>{distro_codename}-backports"; // Evita backports a menos que sepas lo que haces
            };
            Unattended-Upgrade::Package-Blacklist {
                // Lista de paquetes que NUNCA se actualizarán automáticamente (ej: si tienes versiones específicas)
            };

             Unattended-Upgrade::Automatic-Reboot "true";  //Reiniciar automaticamente si lo requieren las actualizaciones (true o false)
             Unattended-Upgrade::Automatic-Reboot-Time "02:00"; //Hora a la que se reinicia (si es necesario)
            ```

4.  **Usuarios y Permisos:**

    *   **No uses `root` directamente.** Usa `sudo` para tareas administrativas.  Tu usuario (`raskan`) ya debería estar en el grupo `sudo`.
    *   **Crea usuarios con los mínimos privilegios necesarios.**  No les des `sudo` a menos que sea absolutamente necesario.
    *   **Revisa los permisos de archivos y directorios.**  Usa `chmod`, `chown`, y `chgrp` para asegurarte de que solo los usuarios y grupos correctos tengan acceso.
        *   `chmod`: Cambia permisos (lectura, escritura, ejecución) para el propietario, el grupo y otros.  Usa la notación numérica (ej: `chmod 700 archivo` - solo el propietario tiene todos los permisos) o simbólica (ej: `chmod u+x archivo` - añade permiso de ejecución al propietario).
        *   `chown`: Cambia el propietario de un archivo o directorio.
        *   `chgrp`: Cambia el grupo de un archivo o directorio.
    *   **Considera `umask`:**  Controla los permisos *por defecto* para archivos y directorios nuevos.  Un valor común y seguro es `022` (el propietario tiene todos los permisos, el grupo y otros tienen permiso de lectura).  Puedes configurar `umask` en `/etc/profile` o en el archivo de configuración de tu shell (`.bashrc`, `.zshrc`).

5.  **Servicios:**

    *   **Desactiva servicios innecesarios.**  Ubuntu 24.04 no debería tener muchos servicios innecesarios por defecto, pero revísalo:

        ```bash
        systemctl list-units --type=service --state=running  # Lista los servicios en ejecución
        ```

        *   Investiga cada servicio que no reconozcas.  Si no lo necesitas, desactívalo:

            ```bash
            sudo systemctl stop servicio  # Detener el servicio
            sudo systemctl disable servicio # Desactivar el servicio (no se iniciará al arrancar)
            ```

            *   **Ejemplos comunes que *podrías* querer desactivar (depende de tu uso):**
                *   `cups` (si no usas impresoras)
                *   `avahi-daemon` (si no usas Bonjour/mDNS)
                *   `bluetooth` (si no usas Bluetooth)

6.  **Auditoría (Opcional, pero muy recomendable):**

    *   `auditd` es una herramienta poderosa para registrar eventos del sistema.  Es útil para detectar intrusiones y problemas.

        ```bash
        sudo apt update && sudo apt install auditd audispd-plugins
        sudo systemctl enable auditd
        sudo systemctl start auditd
        ```

        *   Configuración: `/etc/audit/auditd.conf` y `/etc/audit/rules.d/audit.rules`.  La configuración por defecto es un buen punto de partida, pero puedes personalizarla para monitorizar eventos específicos (ej: accesos a archivos, cambios de configuración, etc.).  Ejemplos de reglas:

            ```
            # Monitorizar cambios en archivos críticos
            -w /etc/passwd -p wa -k passwd_changes
            -w /etc/shadow -p wa -k shadow_changes
            -w /etc/group -p wa -k group_changes
            -w /etc/sudoers -p wa -k sudoers_changes
            -w /etc/ssh/sshd_config -p wa -k sshd_config_changes

            # Monitorizar intentos de login fallidos
            -a always,exit -F arch=b64 -S execve -C uid!=euid -F euid=0 -k root_exec
            -a always,exit -F arch=b32 -S execve -C uid!=euid -F euid=0 -k root_exec
            -a always,exit -F arch=b64 -S execve -F key=root_exec -F exit=-EACCES -k access_denied
            -a always,exit -F arch=b32 -S execve -F key=root_exec -F exit=-EACCES -k access_denied
            -w /var/log/auth.log -p wa -k auth_log_changes
            ```

        *   Para ver los registros: `sudo ausearch -m AVC,USER_AUTH,USER_LOGIN,USER_START,USER_END,CRED_ACQ,CRED_DISP -ts recent` (y muchas otras opciones; consulta `man ausearch`).  También puedes usar `aureport` para generar informes.
    *   Considera usar un sistema de gestión de logs centralizado (ej: ELK stack, Graylog) si necesitas monitorizar múltiples servidores.

7.  **SELinux (Opcional, nivel avanzado):**

    *   Ubuntu usa AppArmor por defecto, que es un sistema de control de acceso obligatorio (MAC). AppArmor es más fácil de usar que SELinux.
    *   Si *realmente* necesitas SELinux (por ejemplo, si tienes requisitos de cumplimiento muy estrictos), puedes instalarlo:

        ```bash
        sudo apt update && sudo apt install selinux-basics selinux-utils
        sudo selinux-activate
        sudo reboot
        ```

    *   **Advertencia:** SELinux es complejo.  Configurarlo incorrectamente puede causar problemas.  Si eres nuevo en SELinux, investiga a fondo en un entorno de pruebas.  Empieza en modo permisivo (`sudo setenforce 0`) para ver qué políticas se violarían, y luego ajústalas antes de pasar a modo enforcing (`sudo setenforce 1`).  Usa `semanage`, `semodule`, y `audit2allow` para administrar las políticas. La documentación de Red Hat es un buen recurso, aunque estés usando Ubuntu.

8.  **Contenedores (Docker/Podman):**

    *   Si vas a ejecutar aplicaciones, considera usar contenedores (Docker o Podman).  Esto aísla las aplicaciones del sistema principal, mejorando la seguridad.
        *   Instala Docker:  Sigue las instrucciones oficiales de Docker para Ubuntu: [https://docs.docker.com/engine/install/ubuntu/](https://www.google.com/url?sa=E&source=gmail&q=https://docs.docker.com/engine/install/ubuntu/)
        *   O instala Podman (una alternativa a Docker, a menudo preferida por su modelo sin daemon):  `sudo apt update && sudo apt install podman`
        *   Aprende a usar Dockerfiles para construir imágenes de tus aplicaciones.

9. **Superficie de ataque de la red**

    * Desactivar la respuesta a ping. Aunque no es una vulnerabilidad en si misma, puede ayudar a que un potencial atacante identifique que tu equipo está activo en la red.

       ```
       sudo sysctl -w net.ipv4.icmp_echo_ignore_all=1
       ```
      Para que sea permanente, agrega `net.ipv4.icmp_echo_ignore_all=1` al archivo `/etc/sysctl.conf`.