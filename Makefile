.PHONY: all
all: build

export ROOT_DIR := $(realpath .)
export DOCKER_IMAGE := coretext/es-proxy
export DOCKER_REGISTRY := 508054367788.dkr.ecr.us-east-1.amazonaws.com

export AWS_ACCESS_KEY=$(shell sed -n 's/.*aws_access_key_id *= *\([^ ]*.*\)/\1/p' < ~/.aws/credentials)
export AWS_SECRET_ACCESS_KEY=$(shell sed -n 's/.*aws_secret_access_key *= *\([^ ]*.*\)/\1/p' < ~/.aws/credentials)

help:
	@echo
	@echo '  make'
	@echo '  make install'

.PHONY: build
build:
	docker build -t $(DOCKER_IMAGE):latest .

.PHONY: install
install:
	docker run --rm -d -p 9200:9200 -e "AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY)" -e "AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY)" $(DOCKER_IMAGE):latest -listen :9200 -endpoint "${ES_ENDPOINT}" -verbose

.PHONE: repository
repository:
	aws ecr create-repository --repository-name $(DOCKER_IMAGE) --region us-east-1

.PHONY: push
push:
	make
	docker tag $(DOCKER_IMAGE):latest $(DOCKER_REGISTRY)/$(DOCKER_IMAGE)
	docker push $(DOCKER_REGISTRY)/$(DOCKER_IMAGE)
