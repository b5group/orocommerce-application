FROM php:8.1-fpm

# Installer les dépendances système
RUN apt-get update && apt-get install -y nginx unzip curl git libpng-dev libjpeg-dev libfreetype6-dev libzip-dev libxml2-dev && \
    docker-php-ext-install gd zip xml pdo pdo_mysql intl opcache && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Définir le répertoire de travail
WORKDIR /var/www/orocommerce

# Cloner le dépôt
RUN git clone --depth 1 https://github.com/oroinc/orocommerce-application.git /var/www/orocommerce

# Supprimer d’éventuels fichiers de cache
RUN rm -rf /var/www/orocommerce/vendor /var/www/orocommerce/composer.lock

# Installer les dépendances Composer proprement
WORKDIR /var/www/orocommerce
RUN composer install --no-dev --optimize-autoloader --no-interaction --ignore-platform-reqs || composer update --no-dev --optimize-autoloader --no-interaction --ignore-platform-reqs

# Copier la configuration Nginx
COPY nginx.conf /etc/nginx/sites-available/default

# Exposer uniquement le port 8080 pour Render
EXPOSE 8080

# Démarrer Nginx et PHP-FPM ensemble
CMD service nginx start && php-fpm -F
