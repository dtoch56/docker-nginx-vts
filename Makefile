IMAGE_NAME=dtoch/nginx-vts

ALPINE_VERSION=3.14
NGINX_VERSION=1.20.1
VTS_VERSION=0.1.18

FULL_IMAGE_TAG=${NGINX_VERSION}-alpine-${ALPINE_VERSION}
IMAGE_TAG=${NGINX_VERSION}-alpine
SHORT_IMAGE_TAG=${NGINX_VERSION}


# all our targets are phony (no files to check).
.PHONY: help build push login clean prune


# Regular Makefile part for buildpypi itself
help:
	@echo ''
	@echo 'Usage: make [TARGET]'
	@echo 'Targets:'
	@echo '  login    Login to dockerhub.com'
	@echo '  release  Run pull, build and push targets'
	@echo '  build    Build project related docker images'
	@echo '  push     Push project related docker images to registry'
	@echo ''


login:
	docker login

release: build push

build:
	docker build \
--no-cache \
-t $(IMAGE_NAME):$(FULL_IMAGE_TAG) \
-t $(IMAGE_NAME):$(IMAGE_TAG) \
-t $(IMAGE_NAME):$(SHORT_IMAGE_TAG) \
--build-arg ALPINE_VERSION=$(ALPINE_VERSION) \
--build-arg NGINX_VERSION=$(NGINX_VERSION) \
--build-arg VTS_VERSION=$(VTS_VERSION) \
.

push: --check_push --push --check_latest --push_latest

--check_push:
	@echo -n "Are you sure to push this image: $(IMAGE_NAME):$(FULL_IMAGE_TAG)? [y/N] " && read ans && [ $${ans:-N} = y ]

--push:
	docker push $(IMAGE_NAME):$(FULL_IMAGE_TAG)
	docker push $(IMAGE_NAME):$(IMAGE_TAG)
	docker push $(IMAGE_NAME):$(SHORT_IMAGE_TAG)

--check_latest:
	@echo -n "Tag as latest?? [y/N] " && read ans && [ $${ans:-N} = y ]

--push_latest:
	docker image tag $(IMAGE_NAME):$(IMAGE_TAG) $(IMAGE_NAME):latest
	docker push $(IMAGE_NAME):latest