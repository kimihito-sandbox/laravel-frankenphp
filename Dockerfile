FROM node:20 as frontend

WORKDIR /app
COPY package.json package-lock.json vite.config.js /app/

RUN npm install

ENV NODE_ENV=production

COPY resources/js ./resources/js
COPY resources/css ./resources/css

RUN npm run build


FROM php:8.3

RUN apt-get update -qq && apt-get install -y git libicu-dev zlib1g-dev libzip-dev libpq-dev

RUN docker-php-ext-install intl pgsql pdo_pgsql zip bcmath
RUN docker-php-ext-configure pcntl --enable-pcntl && docker-php-ext-install pcntl

WORKDIR /app

# Copy Frontend build
COPY --from=frontend /app/node_modules/ ./node_modules/
COPY --from=frontend /app/public/build/ ./public/build/

COPY . .

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer install

RUN php artisan octane:install --server=frankenphp

# ENTRYPOINT [ "php", "artisan", "octane:start", "--host", "0.0.0.0" "--port", "$PORT"]
