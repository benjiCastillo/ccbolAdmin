# API REST GOOMOVIL con Slim Skeleton Application

Esta aplicación esta basada en el esqueleto básico de slim.

# Iniciando el proyecto
  1. Tener Instalado Composer  
  https://getcomposer.org/
  2. Instalar slim-skeleton
  ```sh
    composer create-project slim/slim-skeleton [my-app-name]
  ```
  3. Instalar dependencias (FluentPdo, Json Web Token) con composer,
  añadir las siguientes lineas al archivo composer.json
  ```sh
     "require": {
        "fpdo/fluentpdo": "1.1.*", //fluentPdo
        "firebase/php-jwt": "^4.0" //JWT
    }
  ```
  4. Actualizar dependencias composer

 ```sh
    composer update
  ```
