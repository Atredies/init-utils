BUILD_DIR=build
APPS=front-end newsfeed quotes
STATIC_BASE=front-end/api/static
STATIC_PATHS=css
STATIC_ARCHIVE=$(BUILD_DIR)/static.tgz
DOCKER_TARGETS=$(addsuffix .docker, $(APPS))
DOCKER_PUSH_TARGETS=$(addsuffix .push, $(APPS))
_DOCKER_PUSH_TARGETS=$(addprefix _, $(DOCKER_PUSH_TARGETS))
ECR_URL_FILE=infra/ecr-url.txt
SSH_KEY=infra/id_rsa

static: $(STATIC_ARCHIVE)

_test: $(addprefix _, $(addsuffix .test, $(APPS)))

test:
	dojo "make _test"

_%.test:
	cd $* && python3 -m pip install -r requirements.txt && python3 -m pytest

clean:
	rm -rf $(BUILD_DIR)

$(STATIC_ARCHIVE): | $(BUILD_DIR)
	tar -c -C $(STATIC_BASE) -z -f $(STATIC_ARCHIVE) $(STATIC_PATHS)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

%.docker:
	$(eval IMAGE_NAME = $(subst -,_,$*))
	cd $* && docker buildx build --platform linux/amd64 --load -t $(IMAGE_NAME) .

_%.push:
	$(eval IMAGE_NAME = $(subst -,_,$*))
	$(eval REPO_URL := $(shell cat ${ECR_URL_FILE}))
	$$(aws ecr get-login  --no-include-email)
	docker tag $(IMAGE_NAME) $(REPO_URL)$(IMAGE_NAME)
	docker push $(REPO_URL)$(IMAGE_NAME)

%.push:
	$(eval IMAGE_NAME = $(subst -,_,$*))
	$(eval REPO_URL := $(shell cat ${ECR_URL_FILE}))
	$$(dojo "aws ecr get-login --region eu-west-1 --no-include-email")
	docker tag $(IMAGE_NAME) $(REPO_URL)$(IMAGE_NAME)
	docker push $(REPO_URL)$(IMAGE_NAME)

docker: $(DOCKER_TARGETS)

_push: $(_DOCKER_PUSH_TARGETS)
push: $(DOCKER_PUSH_TARGETS)

$(SSH_KEY):
	ssh-keygen -q -N "" -f $(SSH_KEY)
	chmod -c 0600 $(SSH_KEY)

ssh_key: $(SSH_KEY)

_%.infra: ssh_key
	cd infra/$* && rm -rf .terraform && terraform init && terraform apply -auto-approve

%.infra:
	dojo "make _$*.infra"

_%.deinfra: ssh_key
	cd infra/$* && terraform init && terraform destroy -auto-approve

%.deinfra:
	dojo "make _$*.deinfra"

_deploy_site:
	cd build &&\
	mkdir -p static &&\
	cd static &&\
	tar xf ../static.tgz &&\
	aws s3 sync . s3://news$$(cat ../../interview_id.txt)-terraform-infra-static-pages/static/

deploy_site:
	dojo "make _deploy_site"

# Interview time:

deploy_interview:
	$(MAKE) clean
	$(MAKE) static
	$(MAKE) backend-support.infra
	$(MAKE) base.infra
	$(MAKE) docker # builds all images
	$(MAKE) push
	$(MAKE) news.infra
	$(MAKE) deploy_site

destroy_interview:
	$(MAKE) news.deinfra
	$(MAKE) base.deinfra
	$(MAKE) backend-support.deinfra
