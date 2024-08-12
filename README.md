<p align="center"><a href="https://laravel.com" target="_blank"><img src="https://raw.githubusercontent.com/laravel/art/master/logo-lockup/5%20SVG/2%20CMYK/1%20Full%20Color/laravel-logolockup-cmyk-red.svg" width="400" alt="Laravel Logo"></a></p>


## Laravel 

Laravel adalah salah satu framework PHP yang paling populer untuk pengembangan aplikasi web.

## Cara Melakukan Instalasi
1. Melakukan update
```sh
sudo apt update
```
2. Install docker compose
```sh
sudo apt install docker-compose
```
3. Membuat direktori untuk mendeploy app
```sh
mkdir laravel-docker
```
4. Masuk ke direktori dan lalu membuat file untuk mendeploy docker image
```sh
touch dockerfile
```
5. Memasukkan konfigurasi di dockerfile
```sh
# Use the official PHP image with Apache
FROM php:8.3-apache

# Install dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libonig-dev \
    zip \
    jpegoptim \
    optipng \
    pngquant \
    gifsicle \
    unzip \
    git \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# Set working directory
WORKDIR /var/www/laravel3

# Copy existing application directory contents
COPY . /var/www/laravel3

# Set permissions for the web directory
RUN chown -R www-data:www-data /var/www/laravel3 \
    && find /var/www/laravel3 -type d -exec chmod 755 {} \; \
    && find /var/www/laravel3 -type f -exec chmod 644 {} \;
RUN mkdir -p /var/www/laravel3/storage /var/www/laravel3/bootstrap/cache \
    && chown -R www-data:www-data /var/www/laravel3


# Expose port 80
EXPOSE 80

# Start Apache server
CMD ["apache2-foreground"]
```
6. Membuat file docker-compose.yml untuk menjalankan beberapa kontainer
```sh
touch docker-compose.yml
```
7. Memasukkan konfigurasi pada file docker-composer.yml
```sh
version: '3.8'

networks:
  app-network:
    driver: bridge

volumes:
  app-data:
    driver: local
  app-vendor:
    driver: local
  app-node-modules:
    driver: local
  dbdata:
    driver: local

services:
  app:
    build:
      context: /home/danesh1/laravel-docker
      dockerfile: Dockerfile
    container_name: my-laravel-app
    image: laravel-app
    networks:
      - app-network
    ports:
      - "8080:80"
    restart: unless-stopped
    volumes:
      - /home/danesh1/laravel-docker:/var/www/laravel3
    environment:
      - APACHE_RUN_USER=www-data
      - APACHE_RUN_GROUP=www-data

  db:
    container_name: my-mysql-db
    environment:
      MYSQL_DATABASE: laravel
      MYSQL_ROOT_PASSWORD: danesh1
    image: mysql:8.0.37
    networks:
      - app-network
    ports:
      - "3307:3306"
    restart: unless-stopped
    volumes:
      - dbdata:/var/lib/mysql

```
8. Membangun dan memulai kontainer
```sh
sudo docker-compose up -d --build 
```
## Untuk memastikan container berjalan lakukan
```sh
sudo docker ps
```
output yang seharusnya keluar adalah 
```sh
CONTAINER ID   IMAGE          COMMAND                  CREATED       STATUS         PORTS                                                  NAMES
dab79c38e73f   mysql:8.0.37   "docker-entrypoint.s…"   2 weeks ago   Up 7 minutes   33060/tcp, 0.0.0.0:3307->3306/tcp, :::3307->3306/tcp   my-mysql-db
ca93fcac2de2   laravel-app    "docker-php-entrypoi…"   2 weeks ago   Up 7 minutes   0.0.0.0:8080->80/tcp, :::8080->80/tcp                  my-laravel-app
```
