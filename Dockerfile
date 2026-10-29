FROM mediawiki:latest

WORKDIR /var/www/html

RUN apt update

RUN apt install unzip curl git -y

COPY --from=composer/composer:latest-bin /composer /usr/bin/composer

RUN cd /var/www/html/extensions \
    && git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/AntiSpoof \
    && cd AntiSpoof \
    && composer install --no-dev

RUN COMPOSER=composer.local.json composer require --no-update mediawiki/maps:~14.0
RUN composer update mediawiki/maps --no-dev -o
