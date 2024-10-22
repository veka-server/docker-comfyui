# Utiliser l'image officielle PHP avec Apache
FROM php:8.1-apache

# Mettre à jour les paquets et installer SQLite 3 ainsi que les dépendances nécessaires
RUN apt-get update && apt-get install -y \
    libsqlite3-dev \
    sqlite3 \
    pkg-config \
    && docker-php-ext-install pdo pdo_sqlite

# Activer le module de réécriture Apache (utile pour .htaccess si nécessaire)
RUN a2enmod rewrite

# Copier le contenu du site dans le répertoire par défaut d'Apache
COPY src/ /var/www/html/

# Modifier les permissions pour que Apache puisse accéder aux fichiers
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Exposer le port 80 pour accéder à l'application
EXPOSE 80

# Lancer Apache en mode "foreground"
CMD ["apache2-foreground"]
