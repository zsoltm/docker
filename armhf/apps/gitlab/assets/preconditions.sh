#!/bin/bash

# Early fail

[ -z ${POSTGRES_PORT_5432_TCP_ADDR} ] && echo "A PostgreSQL image named \"postgres\" must be linked" && exit 1
[ -z ${REDIS_PORT_6379_TCP_ADDR} ] && echo "A Redis image named \"redis\" must be linked" && exit 1

[ -z ${GITLAB_HOST} ] && echo "GITLAB_HOST most be specified!" && exit 1
[ -z ${GITLAB_EMAIL_FROM} ] && echo "GITLAB_EMAIL_FROM most be specified!" && exit 1
[ -z ${GITLAB_EMAIL_REPLY_TO} ] && echo "GITLAB_EMAIL_DISPLAY_NAME most be specified!" && exit 1
