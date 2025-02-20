FROM php:8.1-fpm

# Installer les dépendances système requises
RUN apt-get update && apt-get install -y \
    nginx unzip curl git libpng-dev libjpeg-dev libfreetype6-dev \
    libzip-dev libxml2-dev libpq-dev libonig-dev && \
    docker-php-ext-install gd zip xml pdo pdo_pgsql intl opcache mbstring && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Définir la mémoire PHP pour éviter des crashs
RUN echo "memory_limit=512M" > /usr/local/etc/php/conf.d/memory-limit.ini

# Définir le répertoire de travail
WORKDIR /var/www/orocommerce

# Cloner le dépôt sans l’historique complet
RUN git clone --depth=1 https://github.com/oroinc/orocommerce-application.git /var/www/orocommerce

# Changer les permissions pour éviter les erreurs sur Render
RUN chmod -R 777 /var/www/orocommerce

# Supprimer les fichiers corrompus et les recréer
RUN rm -f /var/www/orocommerce/.env /var/www/orocommerce/.env.dist /var/www/orocommerce/config/parameters.yml
RUN touch /var/www/orocommerce/.env /var/www/orocommerce/.env.dist /var/www/orocommerce/config/parameters.yml

# Corriger le format des fichiers d'environnement
RUN echo 'ORO_POST_INSTALL_CMD=""' >> /var/www/orocommerce/.env
RUN echo 'ORO_POST_INSTALL_CMD=""' >> /var/www/orocommerce/.env.dist
RUN echo 'ORO_POST_INSTALL_CMD: ""' >> /var/www/orocommerce/config/parameters.yml

# Supprimer les fichiers de cache potentiellement corrompus
RUN rm -rf vendor composer.lock

# Installer Composer proprement
RUN composer install --no-dev --optimize-autoloader --no-interaction --ignore-platform-reqs || \
    composer update --no-dev --optimize-autoloader --no-interaction --ignore-platform-reqs

# Copier la configuration Nginx
COPY nginx.conf /etc/nginx/sites-available/default

# Exposer uniquement le port 8080 pour Render
EXPOSE 8080

# Démarrer Nginx et PHP-FPM ensemble
CMD service nginx start && php-fpm -F
