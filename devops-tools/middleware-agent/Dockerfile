# syntax=docker/dockerfile:1

ARG repo="docker.io" \
    base_image="alpine:3.19" \
    image_hash="13b7e62e8df80264dbb747995705a986aa530415763a6c58f84a3ca8af9a5bcd"

FROM ${repo}/${base_image}@sha256:${image_hash} AS build

# go 1.20 from source
RUN apk add --no-cache ca-certificates

ENV PATH /usr/local/go/bin:$PATH

ENV GOLANG_VERSION 1.20.12

RUN set -eux; \
	apk add --no-cache --virtual .fetch-deps gnupg; \
	arch="$(apk --print-arch)"; \
	url=; \
	case "$arch" in \
		'x86_64') \
			export GOAMD64='v1' GOARCH='amd64' GOOS='linux'; \
			;; \
		'armhf') \
			export GOARCH='arm' GOARM='6' GOOS='linux'; \
			;; \
		'armv7') \
			export GOARCH='arm' GOARM='7' GOOS='linux'; \
			;; \
		'aarch64') \
			export GOARCH='arm64' GOOS='linux'; \
			;; \
		'x86') \
			export GO386='softfloat' GOARCH='386' GOOS='linux'; \
			;; \
		'ppc64le') \
			export GOARCH='ppc64le' GOOS='linux'; \
			;; \
		'riscv64') \
			export GOARCH='riscv64' GOOS='linux'; \
			;; \
		's390x') \
			export GOARCH='s390x' GOOS='linux'; \
			;; \
		*) echo >&2 "error: unsupported architecture '$arch' (likely packaging update needed)"; exit 1 ;; \
	esac; \
	build=; \
	if [ -z "$url" ]; then \
# https://github.com/golang/go/issues/38536#issuecomment-616897960
		build=1; \
		url='https://dl.google.com/go/go1.20.12.src.tar.gz'; \
		sha256='c5bf934751d31c315c1d0bb5fb02296545fa6d08923566f7a5afec81f2ed27d6'; \
	fi; \
	\
	wget -O go.tgz.asc "$url.asc"; \
	wget -O go.tgz "$url"; \
	echo "$sha256 *go.tgz" | sha256sum -c -; \
	\
# https://github.com/golang/go/issues/14739#issuecomment-324767697
	GNUPGHOME="$(mktemp -d)"; export GNUPGHOME; \
# https://www.google.com/linuxrepositories/
	gpg --batch --keyserver keyserver.ubuntu.com --recv-keys 'EB4C 1BFD 4F04 2F6D DDCC  EC91 7721 F63B D38B 4796'; \
	gpg --batch --keyserver keyserver.ubuntu.com --recv-keys '2F52 8D36 D67B 69ED F998  D857 78BD 6547 3CB3 BD13'; \
	gpg --batch --verify go.tgz.asc go.tgz; \
	gpgconf --kill all; \
	rm -rf "$GNUPGHOME" go.tgz.asc; \
	\
	tar -C /usr/local -xzf go.tgz; \
	rm go.tgz; \
	\
	if [ -n "$build" ]; then \
		apk add --no-cache --virtual .build-deps \
			bash \
			gcc \
			go \
			musl-dev \
		; \
		\
		export GOCACHE='/tmp/gocache'; \
		\
		( \
			cd /usr/local/go/src; \
			export GOROOT_BOOTSTRAP="$(go env GOROOT)" GOHOSTOS="$GOOS" GOHOSTARCH="$GOARCH"; \
			if [ "${GOARCH:-}" = '386' ]; then \
# https://github.com/golang/go/issues/52919; https://github.com/docker-library/golang/pull/426#issuecomment-1152623837
				export CGO_CFLAGS='-fno-stack-protector'; \
			fi; \
			./make.bash; \
		); \
		\
		apk del --no-network .build-deps; \
		\
		rm -rf \
			/usr/local/go/pkg/*/cmd \
			/usr/local/go/pkg/bootstrap \
			/usr/local/go/pkg/obj \
			/usr/local/go/pkg/tool/*/api \
			/usr/local/go/pkg/tool/*/go_bootstrap \
			/usr/local/go/src/cmd/dist/dist \
			"$GOCACHE" \
		; \
	fi; \
	\
	apk del --no-network .fetch-deps; \
	\
	go version

ENV GOPATH /go
ENV PATH $GOPATH/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 1777 "$GOPATH"

WORKDIR /app

RUN apk add --no-cache \
        ca-certificates \
        git \
        openssl; \
    git clone https://github.com/middleware-labs/mw-agent; \
    cd mw-agent; \
    CGO_ENABLED=0; \
    go get -d -v ./...; \
    go mod tidy

ENV AGENT_VERSION="1.1.0-1"

RUN CGO_ENABLED=0 go build -ldflags "-s -w -X main.agentVersion=${AGENT_VERSION}" -o /tmp/mw-agent cmd/host-agent/main.go

FROM busybox:glibc
RUN mkdir -p /var/log
WORKDIR /opt/mw-host-agent
COPY --from=build /etc/ssl/certs /etc/ssl/certs
COPY --from=build /tmp/mw-agent /opt/mw-host-agent/mw-agent
COPY --from=build /app/otel-config.yaml /etc/mw-agent/otel-config.yaml
CMD [ "/opt/mw-host-agent/mw-agent", "start" ]