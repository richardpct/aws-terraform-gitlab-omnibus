.PHONY: init init_base init_bastion init_database init_webserver init_runner \
clean clean_base clean_bastion clean_database clean_webserver clean_runner \
apply \
destroy destroy_runner destroy_webserver destroy_database destroy_bastion destroy_base

.DEFAULT_GOAL := apply

init: init_base init_bastion init_database init_webserver init_runner
clean: clean_base clean_bastion clean_database clean_webserver clean_runner
apply: apply_base apply_bastion apply_database apply_webserver
destroy: destroy_runner destroy_webserver destroy_database destroy_bastion destroy_base

TFVARS = ~/terraform_secrets/aws-terraform-gitlab-omnibus.tfvars
MY_IP = $(shell curl -s 'https://duckduckgo.com/?q=ip&t=h_&ia=answer' | sed -e 's/.*Your IP address is \([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\) in.*/\1/')/32
BUCKET = $(shell awk '/bucket/{print $$NF}' ${TFVARS})
REGION = $(shell awk '/region/{print $$NF}' ${TFVARS})
BASE_KEY = $(shell awk '/_base_key/{print $$NF}' ${TFVARS})
BASTION_KEY = $(shell awk '/_bastion_key/{print $$NF}' ${TFVARS})
DATABASE_KEY = $(shell awk '/_database_key/{print $$NF}' ${TFVARS})
WEBSERVER_KEY = $(shell awk '/_webserver_key/{print $$NF}' ${TFVARS})
RUNNER_KEY = $(shell awk '/_runner_key/{print $$NF}' ${TFVARS})

init_base:
	cd 00-base; \
	terraform init \
	-backend-config="bucket=${BUCKET}" \
	-backend-config="key=${BASE_KEY}" \
	-backend-config="region=${REGION}"

init_bastion: init_base
	cd 01-bastion; \
	terraform init \
	-backend-config="bucket=${BUCKET}" \
	-backend-config="key=${BASTION_KEY}" \
	-backend-config="region=${REGION}"

init_database: init_bastion
	cd 02-database; \
	terraform init \
	-backend-config="bucket=${BUCKET}" \
	-backend-config="key=${DATABASE_KEY}" \
	-backend-config="region=${REGION}"

init_webserver: init_database
	cd 03-webserver; \
	terraform init \
	-backend-config="bucket=${BUCKET}" \
	-backend-config="key=${WEBSERVER_KEY}" \
	-backend-config="region=${REGION}"

init_runner: init_webserver
	cd 04-runner; \
	terraform init \
	-backend-config="bucket=${BUCKET}" \
	-backend-config="key=${RUNNER_KEY}" \
	-backend-config="region=${REGION}"

clean_base:
	rm -rf 00-base/.terraform
	rm -f apply_base

clean_bastion:
	rm -rf 01-bastion/.terraform
	rm -f apply_bastion

clean_database:
	rm -rf 02-database/.terraform
	rm -f apply_database

clean_webserver:
	rm -rf 03-webserver/.terraform
	rm -f apply_webserver

clean_runner:
	rm -rf 04-runner/.terraform
	rm -f apply_runner

apply_base:
	cd 00-base; \
	terraform apply -auto-approve -var-file="${TFVARS}" -var="my_ip_address=${MY_IP}"
	@touch $@

apply_bastion: apply_base
	cd 01-bastion; \
	terraform apply -auto-approve -var-file="${TFVARS}"
	@touch $@

apply_database: apply_bastion
	cd 02-database; \
	terraform apply -auto-approve -var-file="${TFVARS}"
	@touch $@

apply_webserver: apply_database
	cd 03-webserver; \
	terraform apply -auto-approve -var-file="${TFVARS}"
	@touch $@

apply_runner: apply_webserver
	cd 04-runner; \
	terraform apply -auto-approve -var-file="${TFVARS}"
	@touch $@

destroy_runner:
ifeq ($(shell [ -f apply_runner ] && echo exists), exists)
	cd 04-runner; \
	terraform destroy -auto-approve -var-file="${TFVARS}" -var="gitlab_token=idontknow"
	@rm -f apply_runner
endif

destroy_webserver: destroy_runner
ifeq ($(shell [ -f apply_webserver ] && echo exists), exists)
	cd 03-webserver; \
	terraform destroy -auto-approve -var-file="${TFVARS}"
	@rm -f apply_webserver
endif

destroy_database: destroy_webserver
ifeq ($(shell [ -f apply_database ] && echo exists), exists)
	cd 02-database; \
	terraform destroy -auto-approve -var-file="${TFVARS}"
	@rm -f apply_database
endif

destroy_bastion: destroy_database
ifeq ($(shell [ -f apply_bastion ] && echo exists), exists)
	cd 01-bastion; \
	terraform destroy -auto-approve -var-file="${TFVARS}"
	@rm -f apply_bastion
endif

destroy_base: destroy_bastion
ifeq ($(shell [ -f apply_base ] && echo exists), exists)
	cd 00-base; \
	terraform destroy -auto-approve -var-file="${TFVARS}" -var="my_ip_address=${MY_IP}"
	@rm -f apply_base
endif
