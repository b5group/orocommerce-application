FROM php:8.1-fpm

# Installer Nginx, Git et Composer
RUN apt-get update && apt-get install -y nginx unzip curl git && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Définir le répertoire de travail
WORKDIR /var/www/orocommerce

# Cloner OroCommerce
RUN git clone --depth 1 https://github.com/oroinc/orocommerce-application.git /var/www/orocommerce

# Installer les dépendances PHP
WORKDIR /var/www/orocommerce
RUN composer install --no-dev --optimize-autoloader --no-interaction --ignore-platform-reqs

# Copier la configuration Nginx
COPY nginx.conf /etc/nginx/sites-available/default

# Exposer uniquement le port 8080 pour Render
EXPOSE 8080

# Lancer Nginx et PHP-FPM ensemble
CMD service nginx start && php-fpm -F
