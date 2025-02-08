# Guía de uso e instalación del paquete "mcamara/laravel-localization"

Esta es una guía de uso e instalación del paquete `mcamara/laravel-localization`, con ejemplos concretos basados en la documentación oficial:

**Instalación**

1.  A través de composer:
    ```bash
    composer require mcamara/laravel-localization
    ```

2.  Añade el Service Provider en `config/app.php`:

    ```php
    'providers' => [
        // ...
        Mcamara\LaravelLocalization\LaravelLocalizationServiceProvider::class,
    ],
    ```

3.  Publica la configuración:

    ```bash
    php artisan vendor:publish --provider="Mcamara\LaravelLocalization\LaravelLocalizationServiceProvider"
    ```

**Configuración básica**

*   Edita el archivo `config/localization.php`:
    *   `supportedLocales`:  Define los idiomas que soportará tu aplicación.
    *   `hideDefaultLocaleInURL`:  Si quieres ocultar el idioma por defecto en la URL.
    *   `useAcceptLanguageHeader`:  Para que la aplicación detecte el idioma del navegador.

**Ejemplos de uso**

*   **Rutas traducidas:**

    ```php
    // Definición de rutas
    Route::group([
        'prefix' => LaravelLocalization::setLocale(),
        'middleware' => [ 'localeSessionRedirect', 'localizationRedirect', 'localeViewPath' ]
    ], function() {
        Route::get('/', function() {
            return View::make('hello');
        });

        Route::get('test',function(){
            return View::make('test');
        });
    });
    ```

*   **Generar URLs traducidas:**

    ```php
    // URL a la ruta 'route-name' en español
    echo LaravelLocalization::getLocalizedURL('es', route('route-name')); 
    ```

*   **Traducir contenido en las vistas:**

    ```blade
    @extends('layouts.app')

    @section('content')
        <h1>{{ __('Welcome to our website!') }}</h1>
    @endsection
    ```

**Consideraciones adicionales**

*   Combina este paquete con `spatie/laravel-translatable` para traducir modelos de Eloquent.
*   Revisa la documentación oficial para obtener más información y ejemplos.