FROM bitnami/git:2.40.1 as git-repo

WORKDIR /repo

COPY ../../ .
RUN git clone --bare  --shared . /bare

WORKDIR /bare
RUN git update-server-info
COPY ./git/config .

FROM nginx:mainline-alpine3.17-slim

RUN apk add git fcgiwrap 

COPY  --chmod=0664 ./conf.d /etc/nginx/conf.d
COPY  --chmod=0664 ./passwd.d /etc/nginx/passwd.d
COPY  --chmod=0664 --chown=www-data:www-data ../../build /var/www/modules/pub
COPY  --chmod=0664 --chown=www-data:www-data ../../build /var/www/modules/prv
COPY  --from=git-repo --chown=www-data:www-data /bare /var/www/git/redis.git

RUN rc-update add fcgiwrap && /etc/init.d/fcgiwrap start
