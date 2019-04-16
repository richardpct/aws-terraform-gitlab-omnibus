#!/bin/bash

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -y upgrade
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.deb.sh | bash
EXTERNAL_URL="http://${alb_dns_name}" apt-get -y install gitlab-ee > /tmp/step1.log 2>&1

cat << EOF >> /etc/gitlab/gitlab.rb
postgresql['enable'] = false
gitlab_rails['db_adapter'] = 'postgresql'
gitlab_rails['db_encoding'] = 'utf8'
gitlab_rails['db_host'] = '${database_host}'
gitlab_rails['db_port'] = 5432
gitlab_rails['db_username'] = 'gitlab'
gitlab_rails['db_password'] = '${database_pass}'
EOF

gitlab-ctl reconfigure > /tmp/step2.log 2>&1
gitlab-ctl reconfigure > /tmp/step3.log 2>&1
gitlab-ctl stop sidekiq
gitlab-ctl stop unicorn
gitlab-ctl stop gitlab-monitor
echo yes | DISABLE_DATABASE_ENVIRONMENT_CHECK=1 GITLAB_ROOT_PASSWORD='${gitlab_pass}' gitlab-rake gitlab:setup > /tmp/step4.log 2>&1
gitlab-ctl start > /tmp/step5.log 2>&1
