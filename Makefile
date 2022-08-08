IMAGE=satishweb/bottlerocket-ephemeral-disk-setup
ALPINE_PLATFORMS=linux/amd64,linux/arm64,linux/arm/v7,linux/arm/v6
UBUNTU_PLATFORMS=linux/amd64,linux/arm/v7
WORKDIR=$(shell pwd)
TAGNAME?=latest
OSF?=alpine

# Set L to + for debug
L=@

UBUNTU_IMAGE=ubuntu:20.04
ALPINE_IMAGE=alpine:1.13

ifdef PUSH
	EXTRA_BUILD_PARAMS = --push-images --push-git-tags
endif

ifdef LATEST
	EXTRA_BUILD_PARAMS += --mark-latest
endif

ifdef NO-CACHE
	EXTRA_BUILD_PARAMS += --no-cache
endif

all: build-alpine build-ubuntu

build-alpine:
	$(L)./build.sh \
	  --image-name "${IMAGE}" \
	  --platforms "${ALPINE_PLATFORMS}" \
	  --work-dir "${WORKDIR}" \
	  --git-tag "${TAGNAME}-alpine" \
	  --docker-file "Dockerfile.alpine" \
	  ${EXTRA_BUILD_PARAMS}

build-ubuntu:
	$(L)./build.sh \
	  --image-name "${IMAGE}" \
	  --platforms "${UBUNTU_PLATFORMS}" \
	  --work-dir "${WORKDIR}" \
	  --git-tag "${TAGNAME}-ubuntu" \
	  --docker-file "Dockerfile.ubuntu" \
	  $$(echo ${EXTRA_BUILD_PARAMS}|sed 's/--mark-latest//')

test:
	$(L)docker build -t ${IMAGE}:${TAGNAME} -f ./Dockerfile.${OSF} .
