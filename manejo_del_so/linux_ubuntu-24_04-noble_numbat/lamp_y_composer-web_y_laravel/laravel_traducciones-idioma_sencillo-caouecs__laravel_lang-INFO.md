## caouecs/laravel-lang:  Traducciones sencillas para tu proyecto Laravel

**Descripción:**

`caouecs/laravel-lang` te proporciona una forma rápida y sencilla de añadir traducciones a tu proyecto Laravel.  Incluye traducciones para varios idiomas, incluyendo español, para que puedas llegar a una audiencia global.

**Uso:**

* Instala el paquete con Composer.
* Publica los archivos de idioma.
* Selecciona el idioma deseado en la configuración de tu aplicación.
* Utiliza la función `__()` o `trans()` para traducir cadenas de texto en tus vistas y controladores.

**Instalación:**

```bash
composer require caouecs/laravel-lang
```

**Publicación de archivos:**

```bash
php artisan vendor:publish --provider="Caouecs\LaravelLang\LaravelLangServiceProvider"
```

**Configuración:**

* En `config/app.php`:

```php
'locale' => 'es', 
```

* O en tiempo de ejecución:

```php
App::setLocale('es');
```

**Traducción:**

```php
{{ __('Welcome to our website') }}
echo trans('messages.welcome');
```

**Personalización:**

Crea un nuevo archivo de idioma en `resources/lang` con tus propias traducciones.

**Ventajas:**

* Fácil de instalar y usar.
* Traducciones para varios idiomas.
* Buena documentación y soporte de la comunidad.

**Desventajas:**

* No traduce modelos de Eloquent.
* Funcionalidades de internacionalización limitadas.

**Conclusión:**

`caouecs/laravel-lang` es una buena opción si necesitas traducciones básicas para tu aplicación Laravel. Si en el futuro necesitas funcionalidades más avanzadas, puedes considerar otros paquetes como `arcanedev/localization`.
