FROM php:7.2-apache

WORKDIR /var/www/html/w

# System Dependencies.
RUN apt-get update && apt-get install -y \
    git \
    imagemagick \
    libicu-dev \
    # Required for SyntaxHighlighting
    python3 \
    # Extensions
    unzip \
    --no-install-recommends && rm -r /var/lib/apt/lists/*

# Install the PHP extensions we need
RUN docker-php-ext-install mbstring mysqli opcache intl

# Install the default object cache.
RUN    pecl channel-update pecl.php.net \
    && pecl install apcu \
    && docker-php-ext-enable apcu

# PHP.ini settings
## see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
        echo 'opcache.memory_consumption=128'; \
        echo 'opcache.interned_strings_buffer=8'; \
        echo 'opcache.max_accelerated_files=4000'; \
        echo 'opcache.revalidate_freq=60'; \
        echo 'opcache.fast_shutdown=1'; \
        echo 'opcache.enable_cli=1'; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini

## enable file uploads
RUN echo 'file_uploads = On' > /usr/local/etc/php/conf.d/docker-php-uploads.ini

# SQLite Directory Setup
RUN    mkdir -p /var/www/data \
    && chown -R www-data:www-data /var/www/data

# Version
ENV MEDIAWIKI_MAJOR_VERSION 1.31
ENV MEDIAWIKI_BRANCH REL1_31
ENV MEDIAWIKI_VERSION 1.31.1
ENV MEDIAWIKI_SHA512 ee49649cc37d0a7d45a7c6d90c822c2a595df290be2b5bf085affbec3318768700a458a6e5b5b7e437651400b9641424429d6d304f870c22ec63fae86ffc5152

# MediaWiki setup
RUN    curl -fSL "https://releases.wikimedia.org/mediawiki/${MEDIAWIKI_MAJOR_VERSION}/mediawiki-${MEDIAWIKI_VERSION}.tar.gz" -o mediawiki.tar.gz \
    && echo "${MEDIAWIKI_SHA512} *mediawiki.tar.gz" | sha512sum -c - \
    && tar -xz --strip-components=1 -f mediawiki.tar.gz \
    && rm mediawiki.tar.gz \
    && curl https://getcomposer.org/composer.phar -o composer.phar

# Manually install extensions & skins
RUN    curl -fSL 'https://extdist.wmflabs.org/dist/extensions/AbuseFilter-REL1_31-adc0789.tar.gz' | tar -xz -C ./extensions \
    && curl -fSL 'https://extdist.wmflabs.org/dist/extensions/AntiSpoof-REL1_31-48ed1f8.tar.gz' | tar -xz -C ./extensions \
    && curl -fSL 'https://extdist.wmflabs.org/dist/extensions/GeoData-REL1_31-96cda6b.tar.gz' | tar -xz -C ./extensions \
    && curl -fSL 'https://extdist.wmflabs.org/dist/extensions/MobileFrontend-REL1_31-289f540.tar.gz' | tar -xz -C ./extensions \
    && curl -fSL 'https://extdist.wmflabs.org/dist/extensions/OpenIDConnect-REL1_31-baea47f.tar.gz' | tar -xz -C ./extensions \
    && curl -fSL 'https://extdist.wmflabs.org/dist/extensions/PluggableAuth-REL1_31-300ac44.tar.gz' | tar -xz -C ./extensions \
    && curl -fSL 'https://extdist.wmflabs.org/dist/extensions/Scribunto-REL1_31-106fbf4.tar.gz' | tar -xz -C ./extensions \
    && curl -fSL 'https://extdist.wmflabs.org/dist/extensions/UserMerge-REL1_31-86f0e02.tar.gz' | tar -xz -C ./extensions \
    # Skins
    && curl -fSL 'https://extdist.wmflabs.org/dist/skins/MinervaNeue-REL1_31-2e70e79.tar.gz' | tar -xz -C ./skins

# Built-in Extensions
RUN { \
        echo '{'; \
        echo '    "require": {'; \
        echo '        "mediawiki/maps": "^7",'; \
        echo '        "pear/mail": "1.4.1",'; \
        echo '        "pear/net_smtp": "1.8.0"'; \
        echo '    },'; \
        echo '    "extra": {'; \
        echo '        "merge-plugin": {'; \
        echo '            "include": ['; \
        echo '                "extensions/OpenIDConnect/composer.json"'; \
        echo '            ]'; \
        echo '        }'; \
        echo '    }'; \
        echo '}'; \
    } > /var/www/html/w/composer.local.json

# Install built-in extensions + extension dependencies
RUN    php composer.phar update --no-dev \
    && php composer.phar install -d ./extensions/AbuseFilter

# Permissions
RUN chown -R www-data:www-data cache extensions images skins
