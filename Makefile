IMAGE=satishweb/bottlerocket-ephemeral-disk-setup
ALPINE_PLATFORMS=linux/amd64,linux/arm64,linux/arm/v7,linux/arm/v6
WORKDIR=$(shell pwd)
TAGNAME?=devel

# Set L to + for debug
L=@

ALPINE_IMAGE=alpine:latest

ifdef PUSH
	EXTRA_BUILD_PARAMS = --push-images --push-git-tags
endif

ifdef LATEST
	EXTRA_BUILD_PARAMS += --mark-latest
endif

all:
	$(L)TAGNAME=$$(docker run --rm --entrypoint=sh ${ALPINE_IMAGE} -c \
		"apk update >/dev/null 2>&1; apk info e2fsprogs" \
		|grep -e '^e2fsprogs-*.*description'\
		|awk '{print $$1}'\
		|sed -e 's/^[ \t]*//;s/[ \t]*$$//;s/ /-/g'\
		|sed $$'s/[^[:print:]\t]//g'\
		|sed 's/^e2fsprogs-//' \
		|cut -d '-' -f 1) ;\
	${MAKE} build-alpine TAGNAME=$$TAGNAME

build-alpine:
	$(L)./build.sh \
	  --image-name "${IMAGE}" \
	  --platforms "${ALPINE_PLATFORMS}" \
	  --work-dir "${WORKDIR}" \
	  --git-tag "${TAGNAME}-alpine" \
	  --docker-file "Dockerfile.alpine" \
	  ${EXTRA_BUILD_PARAMS}

test:
	$(L)docker build -t ${IMAGE}:${TAGNAME} -f ./Dockerfile.${OSF}
