FROM mediawiki:latest

RUN cd /var/www/html/extensions \
    && git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/AntiSpoof AntiSpoof \
    && cd AntiSpoof \
    && composer install --no-dev
