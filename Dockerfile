FROM mediawiki:1.35.7
ENV BRANCH="REL1_35"

RUN apt update

RUN apt install unzip curl git -y

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
