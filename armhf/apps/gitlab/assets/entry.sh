#!/bin/bash
set -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. "${DIR}/env.sh"

case "${GITLAB_HTTPS}" in
  true)
    GITLAB_PORT=${GITLAB_PORT:-443}
    NGINX_X_FORWARDED_PROTO=${NGINX_X_FORWARDED_PROTO:-https}
    ;;
  *)
    GITLAB_PORT=${GITLAB_PORT:-80}
    NGINX_X_FORWARDED_PROTO=${NGINX_X_FORWARDED_PROTO:-\$scheme}
    ;;
esac

if [ ! -e ${GITLAB_DATA_DIR}/ssh/ssh_host_rsa_key ]; then
  # create ssh host keys and move them to the data store.
  dpkg-reconfigure openssh-server
  mkdir -p ${GITLAB_DATA_DIR}/ssh/
  mv /etc/ssh/ssh_host_*_key* ${GITLAB_DATA_DIR}/ssh/
fi
# configure sshd to pick up the host keys from ${GITLAB_DATA_DIR}/ssh/
sed -i 's,HostKey /etc/ssh/,HostKey '"${GITLAB_DATA_DIR}"'/ssh/,g' -i /etc/ssh/sshd_config

# populate ${GITLAB_LOG_DIR}
mkdir -m 0755 -p ${GITLAB_LOG_DIR}/supervisor   && chown -R root:root ${GITLAB_LOG_DIR}/supervisor
mkdir -m 0755 -p ${GITLAB_LOG_DIR}/nginx        && chown -R git:git ${GITLAB_LOG_DIR}/nginx
mkdir -m 0755 -p ${GITLAB_LOG_DIR}/gitlab       && chown -R git:git ${GITLAB_LOG_DIR}/gitlab
mkdir -m 0755 -p ${GITLAB_LOG_DIR}/gitlab-shell && chown -R git:git ${GITLAB_LOG_DIR}/gitlab-shell

cd ${GITLAB_INSTALL_DIR}

# copy configuration templates
case "${GITLAB_HTTPS}" in
  true)
    if [ -f "${SSL_CERTIFICATE_PATH}" -a -f "${SSL_KEY_PATH}" -a -f "${SSL_DHPARAM_PATH}" ]; then
      cp ${SYSCONF_TEMPLATES_DIR}/nginx/gitlab-ssl /etc/nginx/sites-enabled/gitlab
    else
      echo "SSL keys and certificates were not found."
      echo "Assuming that the container is running behind a HTTPS enabled load balancer."
      cp ${SYSCONF_TEMPLATES_DIR}/nginx/gitlab /etc/nginx/sites-enabled/gitlab
    fi
    ;;
  *) cp ${SYSCONF_TEMPLATES_DIR}/nginx/gitlab /etc/nginx/sites-enabled/gitlab ;;
esac

sudo -u git -H cp ${SYSCONF_TEMPLATES_DIR}/gitlab-shell/config.yml    ${GITLAB_SHELL_INSTALL_DIR}/config.yml
sudo -u git -H cp ${SYSCONF_TEMPLATES_DIR}/gitlabhq/gitlab.yml        config/gitlab.yml
sudo -u git -H cp ${SYSCONF_TEMPLATES_DIR}/gitlabhq/resque.yml        config/resque.yml
sudo -u git -H cp ${SYSCONF_TEMPLATES_DIR}/gitlabhq/database.yml      config/database.yml
sudo -u git -H cp ${SYSCONF_TEMPLATES_DIR}/gitlabhq/unicorn.rb        config/unicorn.rb
sudo -u git -H cp ${SYSCONF_TEMPLATES_DIR}/gitlabhq/rack_attack.rb    config/initializers/rack_attack.rb
[ "${SMTP_ENABLED}" == "true" ] && \
sudo -u git -H cp ${SYSCONF_TEMPLATES_DIR}/gitlabhq/smtp_settings.rb  config/initializers/smtp_settings.rb

# override default configuration templates with user templates
case "${GITLAB_HTTPS}" in
  true)
    if [ -f "${SSL_CERTIFICATE_PATH}" -a -f "${SSL_KEY_PATH}" -a -f "${SSL_DHPARAM_PATH}" ]; then
      [ -f ${USERCONF_TEMPLATES_DIR}/nginx/gitlab-ssl ] && cp ${USERCONF_TEMPLATES_DIR}/nginx/gitlab-ssl /etc/nginx/sites-enabled/gitlab
    else
      [ -f ${USERCONF_TEMPLATES_DIR}/nginx/gitlab ] && cp ${USERCONF_TEMPLATES_DIR}/nginx/gitlab /etc/nginx/sites-enabled/gitlab
    fi
    ;;
  *) [ -f ${USERCONF_TEMPLATES_DIR}/nginx/gitlab ] && cp ${USERCONF_TEMPLATES_DIR}/nginx/gitlab /etc/nginx/sites-enabled/gitlab ;;
esac

[ -f ${USERCONF_TEMPLATES_DIR}/gitlab-shell/config.yml ]   && sudo -u git -H cp ${USERCONF_TEMPLATES_DIR}/gitlab-shell/config.yml   ${GITLAB_SHELL_INSTALL_DIR}/config.yml
[ -f ${USERCONF_TEMPLATES_DIR}/gitlabhq/gitlab.yml ]       && sudo -u git -H cp ${USERCONF_TEMPLATES_DIR}/gitlabhq/gitlab.yml       config/gitlab.yml
[ -f ${USERCONF_TEMPLATES_DIR}/gitlabhq/resque.yml ]       && sudo -u git -H cp ${USERCONF_TEMPLATES_DIR}/gitlabhq/resque.yml       config/resque.yml
[ -f ${USERCONF_TEMPLATES_DIR}/gitlabhq/database.yml ]     && sudo -u git -H cp ${USERCONF_TEMPLATES_DIR}/gitlabhq/database.yml     config/database.yml
[ -f ${USERCONF_TEMPLATES_DIR}/gitlabhq/unicorn.rb ]       && sudo -u git -H cp ${USERCONF_TEMPLATES_DIR}/gitlabhq/unicorn.rb       config/unicorn.rb
[ -f ${USERCONF_TEMPLATES_DIR}/gitlabhq/rack_attack.rb ]   && sudo -u git -H cp ${USERCONF_TEMPLATES_DIR}/gitlabhq/rack_attack.rb   config/initializers/rack_attack.rb
[ "${SMTP_ENABLED}" == "true" ] && \
[ -f ${USERCONF_TEMPLATES_DIR}/gitlabhq/smtp_settings.rb ] && sudo -u git -H cp ${USERCONF_TEMPLATES_DIR}/gitlabhq/smtp_settings.rb config/initializers/smtp_settings.rb

# configure git for the 'git' user
sudo -u git -H git config --global user.name "GitLab"
sudo -u git -H git config --global user.email "${GITLAB_EMAIL}"
sudo -u git -H git config --global core.autocrlf input

# configure sidekiq concurrency
sed 's/{{SIDEKIQ_CONCURRENCY}}/'"${SIDEKIQ_CONCURRENCY}"'/' -i /etc/supervisor/conf.d/sidekiq.conf

# configure sidekiq shutdown timeout
sed 's/{{SIDEKIQ_SHUTDOWN_TIMEOUT}}/'"${SIDEKIQ_SHUTDOWN_TIMEOUT}"'/' -i /etc/supervisor/conf.d/sidekiq.conf

# enable SidekiqMemoryKiller
## The MemoryKiller is enabled by gitlab if the `SIDEKIQ_MEMORY_KILLER_MAX_RSS` is
## defined in the programs environment and has a non-zero value.
##
## Simply exporting the variable makes it available in the programs environment and
## therefore should enable the MemoryKiller.
##
## Every other MemoryKiller option specified in the docker env will automatically
## be exported, so why bother
export SIDEKIQ_MEMORY_KILLER_MAX_RSS

# configure nginx vhost
sed 's,{{GITLAB_INSTALL_DIR}},'"${GITLAB_INSTALL_DIR}"',g' -i /etc/nginx/sites-enabled/gitlab
sed 's/{{YOUR_SERVER_FQDN}}/'"${GITLAB_HOST}"'/' -i /etc/nginx/sites-enabled/gitlab
sed 's/{{GITLAB_PORT}}/'"${GITLAB_PORT}"'/' -i /etc/nginx/sites-enabled/gitlab
sed 's,{{SSL_CERTIFICATE_PATH}},'"${SSL_CERTIFICATE_PATH}"',' -i /etc/nginx/sites-enabled/gitlab
sed 's,{{SSL_KEY_PATH}},'"${SSL_KEY_PATH}"',' -i /etc/nginx/sites-enabled/gitlab
sed 's,{{SSL_DHPARAM_PATH}},'"${SSL_DHPARAM_PATH}"',' -i /etc/nginx/sites-enabled/gitlab
sed 's/{{SSL_VERIFY_CLIENT}}/'"${SSL_VERIFY_CLIENT}"'/' -i /etc/nginx/sites-enabled/gitlab
if [ -f /usr/local/share/ca-certificates/ca.crt ]; then
  sed 's,{{CA_CERTIFICATES_PATH}},'"${CA_CERTIFICATES_PATH}"',' -i /etc/nginx/sites-enabled/gitlab
else
  sed '/{{CA_CERTIFICATES_PATH}}/d' -i /etc/nginx/sites-enabled/gitlab
fi

sed 's/worker_processes .*/worker_processes '"${NGINX_WORKERS}"';/' -i /etc/nginx/nginx.conf
sed 's/{{NGINX_PROXY_BUFFERING}}/'"${NGINX_PROXY_BUFFERING}"'/' -i /etc/nginx/sites-enabled/gitlab
sed 's/{{NGINX_ACCEL_BUFFERING}}/'"${NGINX_ACCEL_BUFFERING}"'/' -i /etc/nginx/sites-enabled/gitlab
sed 's/{{NGINX_MAX_UPLOAD_SIZE}}/'"${NGINX_MAX_UPLOAD_SIZE}"'/' -i /etc/nginx/sites-enabled/gitlab
sed 's/{{NGINX_X_FORWARDED_PROTO}}/'"${NGINX_X_FORWARDED_PROTO}"'/' -i /etc/nginx/sites-enabled/gitlab

if [ "${GITLAB_HTTPS_HSTS_ENABLED}" == "true" ]; then
  sed 's/{{GITLAB_HTTPS_HSTS_MAXAGE}}/'"${GITLAB_HTTPS_HSTS_MAXAGE}"'/' -i /etc/nginx/sites-enabled/gitlab
else
  sed '/{{GITLAB_HTTPS_HSTS_MAXAGE}}/d' -i /etc/nginx/sites-enabled/gitlab
fi

sed 's,{{GITLAB_RELATIVE_URL_ROOT}},/,' -i /etc/nginx/sites-enabled/gitlab
sed 's,{{GITLAB_RELATIVE_URL_ROOT__with_trailing_slash}},/,' -i /etc/nginx/sites-enabled/gitlab
sudo -u git -H sed '/{{GITLAB_RELATIVE_URL_ROOT}}/d' -i config/unicorn.rb

# disable ipv6 support
sed -e '/listen \[::\]:80/ s/^#*/#/' -i /etc/nginx/sites-enabled/gitlab
sed -e '/listen \[::\]:443/ s/^#*/#/' -i /etc/nginx/sites-enabled/gitlab

# fix permission and ownership of ${GITLAB_DATA_DIR}
chmod 755 ${GITLAB_DATA_DIR}
chown git:git ${GITLAB_DATA_DIR}

# set executable flags on ${GITLAB_DATA_DIR} (needed if mounted from a data-only
# container using --volumes-from)
chmod +x ${GITLAB_DATA_DIR}

# create the repositories directory and make sure it has the right permissions
sudo -u git -H mkdir -p ${GITLAB_DATA_DIR}/repositories/
chown git:git ${GITLAB_DATA_DIR}/repositories/
chmod ug+rwX,o-rwx ${GITLAB_DATA_DIR}/repositories/
sudo -u git -H chmod g+s ${GITLAB_DATA_DIR}/repositories/

# create the satellites directory and make sure it has the right permissions
sudo -u git -H mkdir -p ${GITLAB_DATA_DIR}/gitlab-satellites/
chmod u+rwx,g=rx,o-rwx ${GITLAB_DATA_DIR}/gitlab-satellites
chown git:git ${GITLAB_DATA_DIR}/gitlab-satellites

# remove old cache directory (remove this line after a few releases)
rm -rf ${GITLAB_DATA_DIR}/cache

# create the backups directory
mkdir -p ${GITLAB_BACKUP_DIR}
chown git:git ${GITLAB_BACKUP_DIR}

# create the uploads directory
sudo -u git -H mkdir -p ${GITLAB_DATA_DIR}/uploads/
chmod -R u+rwX ${GITLAB_DATA_DIR}/uploads/
chown git:git ${GITLAB_DATA_DIR}/uploads/

# create the .ssh directory
sudo -u git -H mkdir -p ${GITLAB_DATA_DIR}/.ssh/
touch ${GITLAB_DATA_DIR}/.ssh/authorized_keys
chmod 700 ${GITLAB_DATA_DIR}/.ssh
chmod 600 ${GITLAB_DATA_DIR}/.ssh/authorized_keys
chown -R git:git ${GITLAB_DATA_DIR}/.ssh

waitForDb() {
  prog="pg_isready -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -d ${DB_NAME} -t 1"
  timeout=60
  printf "Waiting for database server to accept connections"
  while ! ${prog} >/dev/null 2>&1
  do
    timeout=$(expr $timeout - 1)
    if [ $timeout -eq 0 ]; then
      printf "\nCould not connect to database server. Aborting...\n"
      exit 1
    fi
    printf "."
    sleep 1
  done
  echo
}

optionallyInitDb() {
  QUERY="SELECT count(*) FROM information_schema.tables WHERE table_schema = 'public';"
  COUNT=$(PGPASSWORD="${DB_PASS}" psql -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -d ${DB_NAME} -Atw -c "${QUERY}")
  if [ -z "${COUNT}" -o ${COUNT} -eq 0 ]; then
    echo "Setting up GitLab for firstrun. Please be patient, this could take a while..."
    sudo -u git -H force=yes bundle exec rake gitlab:setup RAILS_ENV=production GITLAB_ROOT_PASSWORD=${GITLAB_ROOT_PASSWORD} >/dev/null
  fi
}

appInit () {
  waitForDb
  optionallyInitDb

  # remove stale unicorn and sidekiq pid's if they exist.
  rm -rf tmp/pids/unicorn.pid
  rm -rf tmp/pids/sidekiq.pid

  # remove state unicorn socket if it exists
  rm -rf tmp/sockets/gitlab.socket

  if [ "${GITLAB_BACKUPS}" != "disable" ]; then
    # setup cron job for automatic backups
    read hour min <<< ${GITLAB_BACKUP_TIME//[:]/ }
    case "${GITLAB_BACKUPS}" in
      daily)
        sudo -u git -H cat > /tmp/cron.git <<EOF
# Automatic Backups: daily
$min $hour * * * /bin/bash -l -c 'cd ${GITLAB_INSTALL_DIR} && bundle exec rake gitlab:backup:create RAILS_ENV=production'
EOF
        ;;
      weekly)
        sudo -u git -H cat > /tmp/cron.git <<EOF
# Automatic Backups: weekly
$min $hour * * 0 /bin/bash -l -c 'cd ${GITLAB_INSTALL_DIR} && bundle exec rake gitlab:backup:create RAILS_ENV=production'
EOF
        ;;
      monthly)
        sudo -u git -H cat > /tmp/cron.git <<EOF
# Automatic Backups: monthly
$min $hour 01 * * /bin/bash -l -c 'cd ${GITLAB_INSTALL_DIR} && bundle exec rake gitlab:backup:create RAILS_ENV=production'
EOF
        ;;
    esac
    crontab -u git /tmp/cron.git && rm -rf /tmp/cron.git
  fi
}

appStart () {
  appInit
  # start supervisord
  echo "Starting supervisord..."
  exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
}

appRake () {
  if [ -z ${1} ]; then
    echo "Please specify the rake task to execute. See https://github.com/gitlabhq/gitlabhq/tree/master/doc/raketasks"
    return 1
  fi

  echo "Running gitlab rake task..."

  if [ "$1" == "gitlab:backup:restore" ]; then
    # check if the BACKUP argument is specified
    for a in $@
    do
      if [[ $a == BACKUP=* ]]; then
        timestamp=${a:7}
        break
      fi
    done

    if [ -z ${timestamp} ]; then
      # user needs to select the backup to restore
      nBackups=$(ls ${GITLAB_BACKUP_DIR}/*_gitlab_backup.tar | wc -l)
      if [ $nBackups -eq 0 ]; then
        echo "No backup present. Cannot continue restore process.".
        return 1
      fi

      for b in `ls ${GITLAB_BACKUP_DIR} | sort -r`
      do
        echo " ├ $b"
      done
      read -p "Select a backup to restore: " file

      if [ ! -f "${GITLAB_BACKUP_DIR}/${file}" ]; then
        echo "Specified backup does not exist. Aborting..."
        return 1
      fi
      timestamp=$(echo $file | cut -d'_' -f1)
    fi
    sudo -u git -H bundle exec rake gitlab:backup:restore BACKUP=$timestamp RAILS_ENV=production
  else
    [ "$1" == "gitlab:import:repos" ] && appSanitize
    sudo -u git -H bundle exec rake $@ RAILS_ENV=production
  fi
}

appHelp () {
  echo "Available options:"
  echo " app:start          - Starts the gitlab server (default)"
  echo " app:init           - Initialize the gitlab server (e.g. create databases, compile assets), but don't start it."
  echo " app:rake <task>    - Execute a rake task."
  echo " app:help           - Displays the help"
  echo " [command]          - Execute the specified linux command eg. bash."
}

case "$1" in
  app:start)
    appStart
    ;;
  app:init)
    appInit
    ;;
  app:sanitize)
    appSanitize
    ;;
  app:rake)
    shift 1
    appRake $@
    ;;
  app:help)
    appHelp
    ;;
  *)
    if [ -x $1 ]; then
      $1
    else
      prog=$(which $1)
      if [ -n "${prog}" ] ; then
        shift 1
        $prog $@
      else
        appHelp
      fi
    fi
    ;;
esac

exit 0
