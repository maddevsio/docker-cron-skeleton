FROM php:7.4-cli-alpine

ARG cron
ARG tz
ARG command

RUN apk add bash tzdata

ENV TZ="$tz"

COPY . /usr/src/myapp
WORKDIR /usr/src/myapp

RUN touch crontab.tmp \
    && echo " $cron cd /usr/src/myapp; $command" > crontab.tmp \
    && crontab crontab.tmp \
    && rm -rf crontab.tmp

CMD ["/usr/sbin/crond", "-f", "-d", "0"]