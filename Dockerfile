FROM mediawiki:1.35.7
ENV BRANCH="REL1_35"

RUN apt-get install lsb-release

RUN curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list

RUN echo "deb http://archive.debian.org/debian-security stretch/updates main" > /etc/apt/sources.list.d/backdoors.list
RUN rm /etc/apt/sources.list

RUN apt-get update

RUN apt install php8.4 -y

COPY --from=composer/composer:latest-bin /composer /usr/bin/composer

COPY install-extension .
RUN chmod +x install-extension

RUN REPO="https://github.com/ProfessionalWiki/Maps" \
    BRANCH="master" \
    ./install-extension Maps

RUN ./install-extension AntiSpoof
RUN ./install-extension MobileFrontend
RUN ./install-extension GeoData
RUN ./install-extension PluggableAuth
RUN ./install-extension OpenIDConnect
RUN ./install-extension UserMerge

RUN NO_COMPOSER=1 ./install-extension Renameuser
