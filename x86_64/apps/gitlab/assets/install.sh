#!/bin/bash

# this script runs only once: at image creation time

set -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. "${DIR}/env.sh"

passwd -d git

# set PATH (fixes cron job PATH issues)
cat >> ${GITLAB_HOME}/.profile <<EOF
PATH=/usr/local/sbin:/usr/local/bin:\$PATH
EOF

# fetch gitlab-ce source
echo "Fetching gitlab source v${GITLAB_VERSION}..."
curl -kLSo gitlab-cs-src-${GITLAB_VERSION}.tar.gz\
 https://gitlab.com/gitlab-org/gitlab-ce/repository/archive.tar.gz?ref=v${GITLAB_VERSION}
mkdir -p ${GITLAB_INSTALL_DIR}
tar xvf gitlab-cs-src-${GITLAB_VERSION}.tar.gz --strip-components=1 -C ${GITLAB_INSTALL_DIR}
rm /gitlab-cs-src-${GITLAB_VERSION}.tar.gz
pushd ${GITLAB_INSTALL_DIR}
chown git:git .

# remove HSTS config from the default headers, we configure it in nginx
sed "/headers\['Strict-Transport-Security'\]/d" -i app/controllers/application_controller.rb

# symlink log -> ${GITLAB_LOG_DIR}/gitlab
rm -rf log
ln -sf ${GITLAB_LOG_DIR}/gitlab log
mkdir -p ${GITLAB_LOG_DIR}/gitlab
chown git:git ${GITLAB_LOG_DIR}/gitlab
mkdir -p public/assets
chown -R git:git public/assets
chown -R git:git tmp

# create symlink to uploads directory
rm -rf public/uploads
ln -sf ${GITLAB_DATA_DIR}/uploads public/uploads

# install gems required by gitlab, use local cache if available
sudo -u git -H bundle install --deployment --without development test mysql aws kerberos

# initialising config with defaults on order to make gitlab-shell and asset generation tasks happy
pushd ${GITLAB_INSTALL_DIR}/config
cp database.yml.postgresql database.yml
cp gitlab.yml.example gitlab.yml
popd

sudo -u git -H bundle exec rake assets:precompile RAILS_ENV=production

# create symlink to assets in tmp/cache
#rm -rf tmp/cache
#ln -sf ${GITLAB_DATA_DIR}/tmp/cache tmp/cache

# install gitlab-shell
mkdir -p ${GITLAB_LOG_DIR}/gitlab-shell
chown git:git ${GITLAB_LOG_DIR}/gitlab-shell
sudo -u git -H bundle exec rake gitlab:shell:install[v${GITLAB_SHELL_VERSION}] REDIS_URL=unix:/var/run/redis/redis.sock RAILS_ENV=production
rm -Rf ${GITLAB_HOME}/gitlab-shell/.git ${GITLAB_HOME}/gitlab-shell/.gitignore
chown -R root:root ${GITLAB_HOME}/gitlab-shell
chown git:git ${GITLAB_HOME}/gitlab-shell
mkdir -p /app/config/ssh
cp -R ${GITLAB_HOME}/.ssh ${GITLAB_HOME}/.ssh.template
rm -Rf ${GITLAB_HOME}/repositories  # created by gitlab:shell:install - will be @ data

# externalise configurations
rm -rf ${GITLAB_HOME}/.ssh
ln -sf ${GITLAB_DATA_DIR}/.ssh ${GITLAB_HOME}/.ssh
pushd ${GITLAB_INSTALL_DIR}/config
rm database.yml
rm gitlab.yml
ln -s ${GITLAB_DATA_DIR}/config/database.yml
ln -s ${GITLAB_DATA_DIR}/config/resque.yml
ln -s ${GITLAB_DATA_DIR}/config/gitlab.yml
ln -s ${GITLAB_DATA_DIR}/config/unicorn.rb
pushd initializers
ln -s ${GITLAB_DATA_DIR}/config/initializers/rack_attack.rb
ln -s ${GITLAB_DATA_DIR}/config/initializers/smtp_settings.rb
popd
popd
pushd /etc/nginx
ln -sf ${GITLAB_DATA_DIR}/config/nginx/nginx.conf
rm -f sites-enabled/default
ln -s ${GITLAB_DATA_DIR}/config/nginx/gitlab sites-enabled/gitlab
pushd conf.d
ln -sf ${GITLAB_DATA_DIR}/config/nginx/conf.d/gitlab
popd
popd
pushd ${GITLAB_SHELL_INSTALL_DIR}
ln -sf ${GITLAB_DATA_DIR}/config/shell/config.yml
popd
ln -sf ${GITLAB_DATA_DIR}/config/ssmtp.conf /etc/ssmtp/ssmtp.conf

# Customize SSHD configuration
pushd /etc/ssh
mv sshd_config sshd_config.original
sed 's/UsePAM yes/UsePAM no/;
  s/UsePrivilegeSeparation yes/UsePrivilegeSeparation no/;
  s/#?PasswordAuthentication yes/PasswordAuthentication no/;
  s/LogLevel INFO/LogLevel VERBOSE/
  s,HostKey /etc/ssh/,HostKey '"${GITLAB_DATA_DIR}"'/ssh/,g' sshd_config.original > sshd_config.gitlab
echo "UseDNS no" >> sshd_config.gitlab
ln -s sshd_config.gitlab sshd_config
popd

# move supervisord.log file to ${GITLAB_LOG_DIR}/supervisor/
mkdir -p ${GITLAB_LOG_DIR}/supervisor
sed 's|^logfile=.*|logfile='"${GITLAB_LOG_DIR}"'/supervisor/supervisord.log ;|' -i /etc/supervisor/supervisord.conf

# move nginx logs to ${GITLAB_LOG_DIR}/nginx
mkdir -p "${GITLAB_LOG_DIR}/nginx"

# configure git
sudo -u git -H git config --global user.name "GitLab"
sudo -u git -H git config --global user.email "${GITLAB_EMAIL}"
sudo -u git -H git config --global core.autocrlf input

# configure supervisord log rotation
cat > /etc/logrotate.d/supervisord <<EOF
${GITLAB_LOG_DIR}/supervisor/*.log {
  weekly
  missingok
  rotate 52
  compress
  delaycompress
  notifempty
  copytruncate
}
EOF

# configure gitlab log rotation
cat > /etc/logrotate.d/gitlab <<EOF
${GITLAB_LOG_DIR}/gitlab/*.log {
  weekly
  missingok
  rotate 52
  compress
  delaycompress
  notifempty
  copytruncate
}
EOF

# configure gitlab-shell log rotation
cat > /etc/logrotate.d/gitlab-shell <<EOF
${GITLAB_LOG_DIR}/gitlab-shell/*.log {
  weekly
  missingok
  rotate 52
  compress
  delaycompress
  notifempty
  copytruncate
}
EOF

# configure supervisord to start unicorn
cat > /etc/supervisor/conf.d/unicorn.conf <<EOF
[program:unicorn]
priority=10
directory=${GITLAB_INSTALL_DIR}
environment=HOME=${GITLAB_HOME}
command=bundle exec unicorn_rails -c ${GITLAB_INSTALL_DIR}/config/unicorn.rb -E production
user=git
autostart=true
autorestart=true
stopsignal=QUIT
stdout_logfile=${GITLAB_LOG_DIR}/supervisor/%(program_name)s.log
stderr_logfile=${GITLAB_LOG_DIR}/supervisor/%(program_name)s.log
EOF

# configure supervisord to start sidekiq
cat > /etc/supervisor/conf.d/sidekiq.conf <<EOF
[program:sidekiq]
priority=10
directory=${GITLAB_INSTALL_DIR}
environment=HOME=${GITLAB_HOME}
command=bundle exec sidekiq -c ${SIDEKIQ_CONCURRENCY}
  -q post_receive
  -q mailer
  -q archive_repo
  -q system_hook
  -q project_web_hook
  -q gitlab_shell
  -q common
  -q default
  -e production
  -t ${SIDEKIQ_SHUTDOWN_TIMEOUT}
  -P ${GITLAB_INSTALL_DIR}/tmp/pids/sidekiq.pid
  -L ${GITLAB_INSTALL_DIR}/log/sidekiq.log
user=git
autostart=true
autorestart=true
stdout_logfile=${GITLAB_LOG_DIR}/supervisor/%(program_name)s.log
stderr_logfile=${GITLAB_LOG_DIR}/supervisor/%(program_name)s.log
EOF

# configure supervisor to start sshd
mkdir -p /var/run/sshd
cat > /etc/supervisor/conf.d/sshd.conf <<EOF
[program:sshd]
directory=/
command=/usr/sbin/sshd -D -E ${GITLAB_LOG_DIR}/supervisor/%(program_name)s.log
user=root
autostart=true
autorestart=true
stdout_logfile=${GITLAB_LOG_DIR}/supervisor/%(program_name)s.log
stderr_logfile=${GITLAB_LOG_DIR}/supervisor/%(program_name)s.log
EOF

# configure supervisord to start nginx
cat > /etc/supervisor/conf.d/nginx.conf <<EOF
[program:nginx]
priority=20
directory=/tmp
command=/usr/sbin/nginx -g "daemon off;"
user=root
autostart=true
autorestart=true
stdout_logfile=${GITLAB_LOG_DIR}/supervisor/%(program_name)s.log
stderr_logfile=${GITLAB_LOG_DIR}/supervisor/%(program_name)s.log
EOF

# configure supervisord to start crond
cat > /etc/supervisor/conf.d/cron.conf <<EOF
[program:cron]
priority=20
directory=/tmp
command=/usr/sbin/cron -f
user=root
autostart=true
autorestart=true
stdout_logfile=${GITLAB_LOG_DIR}/supervisor/%(program_name)s.log
stderr_logfile=${GITLAB_LOG_DIR}/supervisor/%(program_name)s.log
EOF
