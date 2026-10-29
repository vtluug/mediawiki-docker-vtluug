FROM mediawiki:latest

RUN apt update

RUN apt install unzip curl git -y

COPY --from=composer/composer:latest-bin /composer /usr/bin/composer

RUN cd /var/www/html/extensions \
    && git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/AntiSpoof \
    && cd AntiSpoof \
    && composer install --no-dev

RUN cd /var/www/html/extensions \
    && git clone https://github.com/ProfessionalWiki/Maps \
    && cd Maps \
    && composer install --no-dev
