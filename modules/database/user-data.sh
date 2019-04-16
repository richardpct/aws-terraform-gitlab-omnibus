#!/bin/bash

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -y upgrade
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.deb.sh | bash
apt-get -y install gitlab-ee
sed -i 's/^\(external_url.*\)/#\1/' /etc/gitlab/gitlab.rb
POSTGRESQL_PASSWORD_HASH=`echo ${database_pass} | gitlab-ctl pg-password-md5 gitlab`

cat << EOF >> /etc/gitlab/gitlab.rb
roles ['postgres_role']
repmgr['enable'] = false
consul['enable'] = false
prometheus['enable'] = false
alertmanager['enable'] = false
pgbouncer_exporter['enable'] = false
redis_exporter['enable'] = false
gitlab_monitor['enable'] = false

postgresql['listen_address'] = '0.0.0.0'
postgresql['port'] = 5432
postgresql['sql_user_password'] = '$POSTGRESQL_PASSWORD_HASH'
postgresql['trust_auth_cidr_addresses'] = %w(0.0.0.0/0)
gitlab_rails['auto_migrate'] = false
EOF

gitlab-ctl reconfigure
gitlab-ctl reconfigure

gitlab-psql -c 'ALTER USER gitlab CREATEDB;'
gitlab-psql -c 'ALTER USER gitlab WITH SUPERUSER;'
