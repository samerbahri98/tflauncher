FROM nginx:mainline-alpine3.17-slim

COPY  --chmod=0664 ./modules/nginx/conf.d /etc/nginx/conf.d
COPY  --chmod=0664 ./modules/nginx/passwd.d /etc/nginx/passwd.d
COPY  --chmod=0664 --chown=www-data:www-data ./build /var/www/modules/pub
COPY  --chmod=0664 --chown=www-data:www-data ./build /var/www/modules/prv

ENV FCGI_SOCKET_OWNER="nginx"
ENV FCGI_SOCKET_GROUP="nginx"
ENV FCGI_MODE="700"

# RUN /etc/conf.d/spawn-fcgi && /etc/init.d/fcgiwrap.sh start
