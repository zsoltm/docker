#! /bin/bash

set -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. "${DIR}/../assets/env.sh"

apt-get update
apt-get install -y --no-install-recommends\
 libgmp-dev\
 ruby2.1-dev\
 libgmpxx4ldbl\
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

pushd /tmp/out

if [ ! -e gitlab-cs-src-${GITLAB_VERSION}.tar.gz ]; then
  curl -kLSo gitlab-cs-src-${GITLAB_VERSION}.tar.gz\
   https://gitlab.com/gitlab-org/gitlab-ce/repository/archive.tar.gz?ref=v${GITLAB_VERSION}
else
  echo "Using existing gitlab source"
fi

rm -Rf gitlab-ce.git
tar xvf gitlab-cs-src-${GITLAB_VERSION}.tar.gz

cd gitlab-ce.git

cp config/gitlab.yml.example config/gitlab.yml
cp config/database.yml.postgresql config/database.yml
bundle install --deployment --without development test mysql aws kerberos
tar czvf /tmp/out/gitlab-bundle.tar.gz --exclude='vendor/bundle/ruby/2.1.0/cache/*' vendor/bundle
cd ..
rm -Rf gitlab-ce.git
popd
