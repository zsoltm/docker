#!/bin/bash
set -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. "${DIR}/env.sh"
. "${DIR}/preconditions.sh"

# populate ${GITLAB_LOG_DIR}
[ ! -e ${GITLAB_LOG_DIR}/supervisor ] && mkdir -m 0755 -p ${GITLAB_LOG_DIR}/supervisor && chown root:root ${GITLAB_LOG_DIR}/supervisor
[ ! -e ${GITLAB_LOG_DIR}/nginx ] && mkdir -m 0755 -p ${GITLAB_LOG_DIR}/nginx && chown git:git ${GITLAB_LOG_DIR}/nginx
[ ! -e ${GITLAB_LOG_DIR}/gitlab ] && mkdir -m 0755 -p ${GITLAB_LOG_DIR}/gitlab && chown git:git ${GITLAB_LOG_DIR}/gitlab
[ ! -e ${GITLAB_LOG_DIR}/gitlab-shell ] && mkdir -m 0755 -p ${GITLAB_LOG_DIR}/gitlab-shell && chown git:git ${GITLAB_LOG_DIR}/gitlab-shell

# enable SidekiqMemoryKiller
export SIDEKIQ_MEMORY_KILLER_MAX_RSS=true

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

  . "${DIR}/init_config.sh"

  # remove stale unicorn and sidekiq pid's if they exist.
  rm -rf tmp/pids/unicorn.pid
  rm -rf tmp/pids/sidekiq.pid

  # remove state unicorn socket if it exists
  rm -rf tmp/sockets/gitlab.socket

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

  sudo -u git -H bundle exec rake $@ RAILS_ENV=production
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
