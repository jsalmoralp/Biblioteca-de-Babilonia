# Optimizar tu "servidor web" en Ubuntu, para una aplicación Laravel.

Vamos a instalar Apache2, PHP y MariaDB con las extensiones y configuraciones necesarias.

**1. Instalar Apache2 y habilitar módulos necesarios:**

Laravel, al ser un framework PHP, requiere un servidor web. Apache2 es una opción robusta y popular.

```bash
sudo apt update
sudo apt install apache2
```

**2. Instalar PHP y extensiones esenciales para Laravel:**

* `php`:  El paquete principal de PHP.
* `libapache2-mod-php`:  Módulo para que Apache2 pueda ejecutar PHP.
* `php-mysql`:  Conector para MariaDB/MySQL.
* `php-xml`:  Soporte para XML, esencial para Laravel.
* `php-mbstring`:  Manejo de cadenas multibyte.
* `php-zip`:  Soporte para archivos ZIP, usado por Laravel para gestionar dependencias.
* `php-curl`:  Para realizar peticiones HTTP, útil para APIs externas.
* `php-gd`:  Para manipulación de imágenes.
* `php-bcmath`:  Para operaciones matemáticas de precisión arbitraria.

```bash
sudo apt install php libapache2-mod-php php-mysql php-xml php-mbstring php-zip php-curl php-gd php-bcmath
```

**3. Instalar MariaDB:**

MariaDB será la base de datos para tu aplicación Laravel.

```bash
sudo apt install mariadb-server
```

**4. Asegurar MariaDB:**

Sigue las instrucciones del script para configurar una contraseña root, eliminar usuarios anónimos, deshabilitar el acceso remoto del usuario root, etc.

```bash
sudo mysql_secure_installation
```

* **4.1. Que responder a las preguntas:**

Al ejecutar `sudo mysql_secure_installation`, te hará una serie de preguntas para mejorar la seguridad de tu instalación de MariaDB. Aquí te dejo unas recomendaciones sobre cómo responderlas, teniendo en cuenta que estás configurando un servidor para desarrollo con Laravel:

  * **0. Switch to unix_socket authentication [Y/n]**
    Para la pregunta "Switch to unix_socket authentication [Y/n]" en el script `mysql_secure_installation`, te recomiendo que respondas `n` (no).

    Aquí te explico por qué:

  * **Autenticación con contraseña:**  La autenticación con `unix_socket` es un método alternativo para que los usuarios locales se conecten a MariaDB sin necesidad de una contraseña.  Aunque esto puede ser conveniente para algunos usuarios del sistema,  en el contexto de una aplicación web con Laravel, es más seguro y recomendable usar la autenticación con contraseña.
  * **Control de acceso:**  La autenticación con contraseña te permite tener un control más granular sobre el acceso a la base de datos, ya que puedes crear usuarios con diferentes permisos y contraseñas.  Esto es importante para la seguridad de tu aplicación, especialmente si vas a desplegarla en un entorno de producción.
  * **Compatibilidad:**  Laravel está diseñado para usar la autenticación con contraseña para conectarse a la base de datos.  Si cambias a `unix_socket`,  tendrás que modificar la configuración de Laravel para que use este método de autenticación, lo que puede ser complejo y causar problemas de compatibilidad.

    En resumen, para una instalación de MariaDB que se usará con Laravel, es mejor mantener la autenticación con contraseña y responder `n` a la pregunta "Switch to unix_socket authentication [Y/n]".

    **1.  Enter current password for root (enter for none):** 

  * Presiona Enter, ya que no has establecido una contraseña root todavía.

    **2.  Set root password? [Y/n]** 

  * Escribe `Y` y presiona Enter. 
  * Elige una contraseña segura y anótala en un lugar seguro.  La necesitarás para acceder a MariaDB.

    **3.  Remove anonymous users? [Y/n]** 

  * Escribe `Y` y presiona Enter. Esto elimina cuentas de usuario que podrían ser usadas para acceder a tu base de datos sin autenticación.

    **4.  Disallow root login remotely? [Y/n]** 

  * Si solo vas a acceder a MariaDB desde el mismo servidor donde está instalado (lo cual es común en desarrollo), escribe `Y` y presiona Enter.  Esto deshabilita el acceso remoto para el usuario root, lo que aumenta la seguridad.  Si necesitas acceder remotamente, puedes crear un usuario con permisos específicos para ello más adelante.

    **5.  Remove test database and access to it? [Y/n]** 

  * Escribe `Y` y presiona Enter.  La base de datos de prueba es innecesaria en tu caso y podría ser un riesgo de seguridad.

    **6.  Reload privilege tables now? [Y/n]** 

  * Escribe `Y` y presiona Enter. Esto aplica los cambios que has realizado en la configuración de seguridad de MariaDB.


Con estas respuestas, habrás mejorado la seguridad de tu instalación de MariaDB, lo cual es importante incluso en un entorno de desarrollo.

**5. Habilitar el módulo de PHP y reiniciar Apache2:**

```bash
sudo a2enmod php
sudo systemctl restart apache2
```

**6. Configurar Apache2 para Laravel:**

* **Habilitar el módulo `rewrite`:**

Este módulo es necesario para que funcione el enrutamiento de Laravel.

```bash
sudo a2enmod rewrite
```

* **Configurar el archivo de host virtual:**

Crea un nuevo archivo de host virtual en `/etc/apache2/sites-available/laravel.conf` con el siguiente contenido (ajusta las rutas según tu instalación):

```apache
<VirtualHost *:80>
    ServerName tu-dominio.com  # Reemplaza con tu dominio o IP
    ServerAdmin webmaster@localhost
    DocumentRoot /ruta/a/tu/proyecto/laravel/public

    <Directory /ruta/a/tu/proyecto/laravel/public>
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```

* **Habilitar el host virtual:**

```bash
sudo a2ensite laravel.conf
sudo systemctl reload apache2
```

**7. Instalar Composer:**

Composer es el gestor de dependencias de PHP, esencial para Laravel.

```bash
sudo apt install composer
```

**8. Clonar el proyecto Laravel (o crear uno nuevo) y configurar el archivo `.env`:**

Clona tu proyecto Laravel existente o crea uno nuevo con Composer.  Luego, configura el archivo `.env` con las credenciales de tu base de datos MariaDB y otras configuraciones necesarias.

**9. Generar la clave de la aplicación:**

```bash
php artisan key:generate
```

**10.  Otorgar permisos al directorio `storage`:**

Esto permitirá que Laravel escriba archivos en el directorio `storage`.

```bash
sudo chown -R www-data:www-data /ruta/a/tu/proyecto/laravel/storage
```

**11. (Opcional) Instalar Node.js y npm:**

Si tu aplicación Laravel usa frontend frameworks como Vue.js o React, necesitarás instalar Node.js y npm:

```bash
sudo apt install nodejs npm
```

**Conclusión:**

Con estos pasos, tu servidor estará listo para ejecutar tu aplicación Laravel. 

Recuerda que esta es una configuración básica. Puedes ajustarla según las necesidades específicas de tu proyecto.
