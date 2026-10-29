FROM mediawiki:1.46.2

RUN apt update

RUN apt install unzip curl git -y

COPY --from=composer/composer:latest-bin /composer /usr/bin/composer

WORKDIR /var/www/html/extensions

RUN git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/AntiSpoof \
    && cd AntiSpoof \
    && composer install --no-dev

RUN git clone https://github.com/ProfessionalWiki/Maps \
    && cd Maps \
    && composer install --no-dev

RUN git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/MobileFrontend \
    && cd MobileFrontend \
    && composer install --no-dev

RUN git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/GeoData \
    && cd GeoData \
    && composer install --no-dev

RUN git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/PluggableAuth \
    && cd PluggableAuth \
    && composer install --no-dev

RUN git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/OpenIDConnect \
    && cd OpenIDConnect \
    && composer install --no-dev

RUN git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/Usermerge \
    && cd Usermerge \
    && composer install --no-dev
