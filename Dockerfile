FROM php:8.1-fpm

# Installer Nginx et Composer
RUN apt-get update && apt-get install -y nginx unzip curl git supervisor && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Définir le répertoire de travail
WORKDIR /var/www/orocommerce

# Cloner OroCommerce et installer les dépendances
RUN git clone https://github.com/oroinc/orocommerce-application.git /var/www/orocommerce && \
    cd /var/www/orocommerce && \
    composer install --no-dev --optimize-autoloader

# Copier la configuration Nginx
COPY nginx.conf /etc/nginx/sites-available/default

# Exposer le port 8080 pour Render
EXPOSE 8080

# Lancer Nginx et PHP-FPM ensemble
CMD service nginx start && php-fpm -F
