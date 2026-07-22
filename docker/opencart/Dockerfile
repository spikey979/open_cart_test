FROM php:8.2-apache

ARG OPENCART_VERSION=4.1.0.3

RUN apt-get update && apt-get install -y --no-install-recommends \
        unzip \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libzip-dev \
        libwebp-dev \
        libcurl4-openssl-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j"$(nproc)" gd zip mysqli curl \
    && docker-php-ext-enable gd zip mysqli curl \
    && a2enmod rewrite \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL -o /tmp/opencart.zip \
        "https://github.com/opencart/opencart/releases/download/${OPENCART_VERSION}/opencart-${OPENCART_VERSION}.zip" \
    && mkdir -p /tmp/opencart /usr/src/opencart \
    && unzip -q /tmp/opencart.zip -d /tmp/opencart \
    && cp -a /tmp/opencart/upload/. /usr/src/opencart/ \
    && rm -rf /tmp/opencart.zip /tmp/opencart

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /var/www/html
ENTRYPOINT ["entrypoint.sh"]
CMD ["apache2-foreground"]
