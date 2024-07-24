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
