FROM node:20 as frontend

WORKDIR /app
COPY package.json package-lock.json vite.config.js /app/

RUN npm install

ENV NODE_ENV=production

COPY resources/js ./resources/js
COPY resources/css ./resources/css

RUN npm run build


FROM dunglas/frankenphp

WORKDIR /app

# Copy Frontend build
COPY --from=frontend /app/node_modules/ ./node_modules/
COPY --from=frontend /app/public/build/ ./public/build/

COPY . .

ENV COMPOSER_ALLOW_SUPERUSER=1

COPY --from=composer /usr/bin/composer /usr/bin/composer
RUN composer install

ENTRYPOINT [ "php", "artisan", "octane:start", "--host", "0.0.0.0"]
