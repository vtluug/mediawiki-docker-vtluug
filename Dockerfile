FROM mediawiki:latest

RUN apt update

RUN apt install php-cli php-curl php-mbstring unzip curl git -y

RUN curl -sS https://getcomposer.org/installer -o composer-setup.php \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && rm composer-setup.php

RUN cd /var/www/html/extensions \
    && git clone https://gerrit.wikimedia.org/r/mediawiki/extensions/AntiSpoof AntiSpoof \
    && cd AntiSpoof \
    && composer install --no-dev
