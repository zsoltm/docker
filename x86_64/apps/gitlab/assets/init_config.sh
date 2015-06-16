#!/bin/bash
set -e

if [ ! -e ${GITLAB_DATA_DIR}/ssh/ssh_host_rsa_key ]; then
  # create ssh host keys and move them to the data store.
  ln -sf /etc/ssh/sshd_config.original /etc/ssh/sshd_config
  dpkg-reconfigure openssh-server
  mkdir -p ${GITLAB_DATA_DIR}/ssh
  mv /etc/ssh/ssh_host_*_key* ${GITLAB_DATA_DIR}/ssh/
  ln -sf /etc/ssh/sshd_config.gitlab /etc/ssh/sshd_config
fi

mkdir -p ${GITLAB_DATA_DIR}/config
# mkdir -p ${GITLAB_DATA_DIR}/tmp/cache

if [ ! -e ${GITLAB_DATA_DIR}/uploads ]; then
  mkdir -p ${GITLAB_DATA_DIR}/uploads
  chown git:git ${GITLAB_DATA_DIR}/uploads
fi

if [ ! -e ${GITLAB_REPO_ROOT}/repositories ]; then
  mkdir -p ${GITLAB_REPO_ROOT}/repositories
  chown git:git ${GITLAB_REPO_ROOT}/repositories
  chmod ug+rwX,o-rwx ${GITLAB_REPO_ROOT}/repositories/
fi

if [ ! -e ${GITLAB_DATA_DIR}/gitlab-satellites ]; then
  mkdir -p ${GITLAB_DATA_DIR}/gitlab-satellites
  chown git:git ${GITLAB_DATA_DIR}/gitlab-satellites
fi

if [ ! -e ${GITLAB_DATA_DIR}/.ssh ]; then
  mkdir -m 0770 -p ${GITLAB_DATA_DIR}/.ssh
  cp ${GITLAB_HOME}/.ssh.template/* ${GITLAB_DATA_DIR}/.ssh/
  chown -R git:git ${GITLAB_DATA_DIR}/.ssh
  chmod 640 ${GITLAB_DATA_DIR}/.ssh/*
fi

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
    s/{{REDIS_TCP_PORT}}/${REDIS_TCP_PORT}/;" -i resque.yml
fi

if [ ! -e gitlab.yml ]; then
  cp /app/config/gitlab/gitlab.yml .
  sed 's/{{GITLAB_HOST}}/'"${GITLAB_HOST}"'/;
    s^{{GITLAB_PORT}}^'"${GITLAB_PORT}"'^;
    s^{{GITLAB_TIMEZONE}}^'"${GITLAB_TIMEZONE}"'^;
    s/{{GITLAB_EMAIL_FROM}}/'"${GITLAB_EMAIL_FROM}"'/;
    s/{{GITLAB_EMAIL_DISPLAY_NAME}}/'"${GITLAB_EMAIL_DISPLAY_NAME}"'/;
    s/{{GITLAB_EMAIL_REPLY_TO}}/'"${GITLAB_EMAIL_REPLY_TO}"'/;
    s/{{GITLAB_HTTPS_ENABLED}}/'"${GITLAB_HTTPS_ENABLED}"'/;
    s^{{GITLAB_DATA_DIR}}^'"${GITLAB_DATA_DIR}"'^;
    s^{{GITLAB_BACKUP_DIR}}^'"${GITLAB_BACKUP_DIR}"'^;
    s^{{GITLAB_REPO_ROOT}}^'"${GITLAB_REPO_ROOT}"'^;
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
  sed 's/{{SMTP_HOST}}/'"${SMTP_HOST}"'/;
   s/{{SMTP_PORT}}/'"${SMTP_PORT}"'/;
   s/{{SMTP_USER}}/'"${SMTP_USER}"'/;
   s/{{SMTP_PASSWORD}}/'"${SMTP_PASSWORD}"'/;
   s/{{SMTP_DOMAIN}}/'"${SMTP_DOMAIN}"'/;
   s/{{SMTP_AUTH}}/'"${SMTP_AUTH}"'/;
   s/{{SMTP_VERIFY}}/'"${SMTP_VERIFY}"'/;' -i initializers/smtp_settings.rb
fi

if [ ! -e nginx/nginx.conf ]; then
  mkdir -p nginx
  cp /app/config/nginx/nginx.conf nginx/
  sed 's|access_log /var/log/nginx/access.log;|access_log '"${GITLAB_LOG_DIR}"'/nginx/access.log;|;
   s|error_log /var/log/nginx/error.log;|error_log '"${GITLAB_LOG_DIR}"'/nginx/error.log;|' -i nginx/nginx.conf
fi

if [ ! -e nginx/gitlab ]; then
  mkdir -p nginx
  cp /app/config/nginx/gitlab nginx/
  sed 's^{{GITLAB_INSTALL_DIR}}^'"${GITLAB_INSTALL_DIR}"'^;
   s/{{GITLAB_HOST}}/'"${GITLAB_HOST}"'/' -i nginx/gitlab
fi

if [ ! -f ssmtp.conf ]; then
  cp /app/config/ssmtp.conf .
  echo "Warning: default smsmtp.conf created; please edit"
fi

if [ ! -f shell/config.yml ]; then
  mkdir -p shell
  cp /app/config/gitlab-shell/config.yml shell/
  sed 's^{{GITLAB_LOG_DIR}}^'"${GITLAB_LOG_DIR}"'^;
   s^{{GITLAB_DATA_DIR}}^'"${GITLAB_DATA_DIR}"'^;
   s/{{REDIS_HOST}}/'"${REDIS_HOST}"'/;
   s^{{GITLAB_REPO_ROOT}}^'"${GITLAB_REPO_ROOT}"'^;
   s/{{REDIS_TCP_PORT}}/'"${REDIS_TCP_PORT}"'/;' -i shell/config.yml
fi

popd
