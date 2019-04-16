#!/bin/bash

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -y upgrade
apt-get -y install docker.io
curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | bash
apt-get -y install gitlab-runner
gitlab-runner register \
  --non-interactive \
  --url "http://${alb_internal_dns_name}" \
  --clone-url "http://${alb_internal_dns_name}" \
  --registration-token "${gitlab_token}" \
  --executor "docker" \
  --docker-image alpine:latest \
  --description "docker-runner"
