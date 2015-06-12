FROM zsoltm/debian-armhf:jessie

RUN apt-get update \
    && apt-get install -y --no-install-recommends git-core

RUN apt-get purge -y --auto-remove 

git -H git config --global core.autocrlf input

VOLUME /config
VOLUME /

------- build

RUN adduser --disabled-login --gecos 'GitLab' git

apt-get install -y\
 libyaml-dev\
 libssl-dev\
 libgdbm-dev\
 libreadline-dev\
 libncurses5-dev\
 libffi-dev\
 libxml2-dev\
 libxslt-dev\
 libcurl4-openssl-dev\
 libicu-dev\
 logrotate\
 checkinstall\
 python-docutils\
 pkg-config\
 cmake\
 nodejs\
 ruby\
 bundler\
 gem\
 sudo

sudo -i git

git clone https://gitlab.com/gitlab-org/gitlab-ce.git -b 7-11-stable gitlab

cd /home/git/gitlab
cp config/gitlab.yml.example config/gitlab.yml  # needs customization, scripting
cp config/unicorn.rb.example config/unicorn.rb  # needs customization, scripting
cp config/initializers/rack_attack.rb.example config/initializers/rack_attack.rb
cp config/resque.yml.example config/resque.yml
cp config/database.yml.postgresql config/database.yml

editor config/gitlab.yml
editor config/resque.yml
editor config/unicorn.rb
editor config/database.yml

mkdir /home/git/gitlab-satellites
# TODO link config to /
# TODO link config to /

chmod o-rwx config/database.yml  # should be readable by git user only as it contains passes


bundle install --deployment --without development test mysql aws kerberos

# >>>>>>>>>>>>>
tar czvf /tmp/out/bundle.tar.gz vendor/bundle

bundle exec rake gitlab:shell:install[v2.6.3] REDIS_URL=unix:/var/run/redis/redis.sock RAILS_ENV=production

