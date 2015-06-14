#!/bin/bash
set -e

mkdir -p ${GITLAB_DATA_DIR}/.ssh
mkdir ${GITLAB_DATA_DIR}/config
mkdir ${GITLAB_DATA_DIR}/gitlab-satellites
mkdir -p ${GITLAB_DATA_DIR}/tmp/cache
mkdir ${GITLAB_DATA_DIR}/uploads
chown -R git:git ${GITLAB_DATA_DIR}

# create repositories dir
mkdir -p ${GITLAB_DATA_DIR}/repositories
chown git:git ${GITLAB_DATA_DIR}/repositories

pushd ${GITLAB_DATA_DIR}/config
if [ ! -e database.yml ]; then
  cp /app/config/gitlab/database.yml .
  sed "s/{{DB_NAME}}/${DB_NAME}/;
    s/{{DB_HOST}}/${DB_HOST}/;
    s/{{DB_PORT}}/${DB_PORT}/;
    s/{{DB_USER}}/${DB_USER}/;
    s/{{DB_PASS}}/${DB_PASS}/;
    s/{{DB_POOL}}/${DB_POOL}/" -i database.yml
fi

if [ ! -e resque.yml ]; then
  cp /app/config/gitlab/resque.yml .
  sed "s/{{REDIS_HOST}}/${REDIS_HOST}/;
    s/{{REDIS_PORT}}/${REDIS_PORT}/;" -i resque.yml
fi

if [ ! -e gitlab.yml ]; then
  cp /app/config/gitlab/gitlab.yml .
  sed 's/{{GITLAB_HOST}}/'"${GITLAB_HOST}"'/;
    s^{{GITLAB_PORT}}^'"${GITLAB_PORT}"'^;
    s^{{GITLAB_TIMEZONE}}^'"${GITLAB_TIMEZONE}"'^;
    s/{{GITLAB_EMAIL_FROM}}/'"${GITLAB_EMAIL_FROM}"'/;
    s/{{GITLAB_EMAIL_DISPLAY_NAME}}/'"${GITLAB_EMAIL_DISPLAY_NAME}"'/;
    s/{{GITLAB_EMAIL_REPLY_TO}}/'"${GITLAB_EMAIL_REPLY_TO}"'/;
    s^{{GITLAB_DATA_DIR}}^'"${GITLAB_DATA_DIR}"'^;
    s^{{GITLAB_BACKUP_DIR}}^'"${GITLAB_BACKUP_DIR}"'^;
    s^{{GITLAB_SHELL_INSTALL_DIR}}^'"${GITLAB_SHELL_INSTALL_DIR}"'^' -i gitlab.yml
fi

if [ ! -e unicorn.rb ]; then
  cp /app/config/gitlab/unicorn.rb .
  sed 's/{{UNICORN_WORKERS}}/'"${UNICORN_WORKERS}"'/;
    s^{{GITLAB_INSTALL_DIR}}^'"${GITLAB_INSTALL_DIR}"'^;
    s/{{UNICORN_TIMEOUT}}/'"${UNICORN_TIMEOUT}"'/' -i unicorn.rb
fi

if [ ! -e initializers/rack_attack.rb ]; then
  mkdir -p initializers
  cp /app/config/gitlab/rack_attack.rb initializers/
fi

if [ ! -e initializers/smtp_settings.rb ]; then
  mkdir -p initializers
  cp /app/config/gitlab/smtp_settings.rb initializers/
fi


if [ ! -e initializers/smtp_settings.rb ]; then

fi

popd
