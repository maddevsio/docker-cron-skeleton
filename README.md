# Cron inside Docker Contaiters

This is a skeleton project you can use to run your code via [cron](https://crontab.guru/) inside Docker. There are a lot of examples if how to make the same case, but this is the simpliest one, easy to configure via ```docker-compose.yml``` and based on [Alpine Linux](https://alpinelinux.org/) images.

The example in the repo shows how to run your php script under cron, but you can run any code on any programming language, just change to base image in Dockerfile.

If you have to run in cron some simple php script there are almost nothing to change in Dockerfile, only args in ```docker-compose.yml```

## Docker compose file example with comments
```yaml
version: "3"

services:
    test-service:
        restart: always
        build:
            context: .
            dockerfile: Dockerfile
            args:
                cron: "* * * * *" # configure cron
                tz: "Asia/Bangkok" # set your timezone
                command: "php main.php" # put your command here
        environment:
            - TEST_VAR=Test Value #this will go to your script, if needed
```

## Dockerfile example with comments

```dockerfile
FROM php:7.4-cli-alpine 
# you can change the base image to other alpine based. for example python:3.7-alpine if you have to run python sctript

ARG cron
ARG tz
ARG command
# this is our args that we have passed in docker-compose.yaml

RUN apk add bash tzdata

ENV TZ="$tz"

COPY . /usr/src/myapp
WORKDIR /usr/src/myapp

# our crontab rules and script command injection are here
RUN touch crontab.tmp \
    && echo " $cron cd /usr/src/myapp; $command" > crontab.tmp \ 
    && crontab crontab.tmp \
    && rm -rf crontab.tmp

CMD ["/usr/sbin/crond", "-f", "-d", "0"]
```

# How to test

In the default files we have a php script which is running by cron every minute

```bash
$> docker-compose build
$> docker-compose up
Recreating docker-cron-skeleton_test-service_1 ... done
Attaching to docker-cron-skeleton_test-service_1
test-service_1  | crond: crond (busybox 1.31.1) started, log level 0
test-service_1  | crond: user:root entry:* * * * * cd /usr/src/myapp; php main.php
test-service_1  | 111111111111111111111111111111111111111111111111111111111111
test-service_1  | 111111111111111111111111
test-service_1  | 11111111111111111111111111111111
test-service_1  | 111111111111
test-service_1  | 1111111
test-service_1  | crond: user:root entry:* * * * * cd /usr/src/myapp; php main.php
test-service_1  | 111111111111111111111111111111111111111111111111111111111111
test-service_1  | 111111111111111111111111
test-service_1  | 11111111111111111111111111111111
test-service_1  | 111111111111
test-service_1  | 1111111
test-service_1  | crond: wakeup dt=6
test-service_1  | crond: file root:
test-service_1  | crond:  line cd /usr/src/myapp; php main.php
test-service_1  | crond:  job: 0 cd /usr/src/myapp; php main.php
test-service_1  | crond: child running /bin/ash
test-service_1  | crond: USER root pid   6 cmd cd /usr/src/myapp; php main.php
test-service_1  | 
test-service_1  | 
test-service_1  | Hello from Cron & Docker
test-service_1  | TEST_ENV_VAR = Test Value
test-service_1  | 
test-service_1  | crond: wakeup dt=10
test-service_1  | crond: wakeup dt=50
test-service_1  | crond: file root:
test-service_1  | crond:  line cd /usr/src/myapp; php main.php
test-service_1  | crond:  job: 0 cd /usr/src/myapp; php main.php
test-service_1  | crond: child running /bin/ash
test-service_1  | crond: USER root pid   7 cmd cd /usr/src/myapp; php main.php
test-service_1  | 
test-service_1  | 
test-service_1  | Hello from Cron & Docker
test-service_1  | TEST_ENV_VAR = Test Value
test-service_1  | 
test-service_1  | crond: wakeup dt=10
```

This is it. Feel free to contribute
