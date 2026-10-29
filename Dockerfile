FROM mediawiki:1.46.2

RUN apt update

RUN apt install unzip curl git -y

COPY --from=composer/composer:latest-bin /composer /usr/bin/composer

COPY install-extension .
RUN chmod +x install-extension

RUN REPO="https://github.com/ProfessionalWiki/Maps" \
    BRANCH="6315213691c7bdce6ec1c8a27ab2a799cbdfa0d4" \
    ./install-extension Maps

RUN ./install-extension AntiSpoof
RUN ./install-extension MobileFrontend
RUN ./install-extension GeoData
RUN ./install-extension PluggableAuth
RUN ./install-extension OpenIDConnect
RUN ./install-extension UserMerge

RUN NO_COMPOSER=1 ./install-extension Renameuser
