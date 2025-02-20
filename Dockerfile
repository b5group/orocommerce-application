FROM php:8.1-fpm

# Installer les dépendances système nécessaires
RUN apt-get update && apt-get install -y \
    nginx unzip curl git libpng-dev libjpeg-dev libfreetype6-dev \
    libzip-dev libxml2-dev libpq-dev && \
    docker-php-ext-install gd zip xml pdo pdo_pgsql intl opcache && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Définir le répertoire de travail
WORKDIR /var/www/orocommerce

# Cloner le dépôt sans l’historique complet
RUN git clone --depth=1 https://github.com/oroinc/orocommerce-application.git /var/www/orocommerce

# Supprimer les éventuels fichiers de cache
RUN rm -rf /var/www/orocommerce/vendor /var/www/orocommerce/composer.lock

# Définir la mémoire PHP pour éviter des crashs
RUN echo "memory_limit=512M" > /usr/local/etc/php/conf.d/memory-limit.ini

# Passer au bon répertoire pour l’installation
WORKDIR /var/www/orocommerce

# Installer Composer proprement (avec plus de mémoire)
RUN COMPOSER_MEMORY_LIMIT=-1 composer install --no-dev --optimize-autoloader --no-interaction --ignore-platform-reqs

# Copier la configuration Nginx
COPY nginx.conf /etc/nginx/sites-available/default

# Exposer uniquement le port 8080 pour Render
EXPOSE 8080

# Démarrer Nginx et PHP-FPM ensemble
CMD service nginx start && php-fpm -F
