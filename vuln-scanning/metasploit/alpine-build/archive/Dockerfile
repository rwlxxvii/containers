FROM docker.io/alpine:3.17.1

ENV LANG=C.UTF-8
ENV RUBY_MAJOR=3.1
ENV RUBY_VERSION=3.1.3
ENV RUBY_DOWNLOAD_SHA256=4ee161939826bcdfdafa757cf8e293a7f14e357f62be7144f040335cc8c7371a
ENV GEM_HOME=/usr/local/bundle
ENV BUNDLE_SILENCE_ROOT_WARNING=1 BUNDLE_APP_CONFIG=/usr/local/bundle

#ruby install from source, msf needs < 3.2
RUN set -eux; \
        \
    apk add --no-cache -t .ruby-builddeps \
    autoconf bison bzip2 bzip2-dev ca-certificates \
    coreutils dpkg-dev dpkg g++ gcc gdbm-dev glib-dev \
    libc-dev libffi-dev libxml2-dev libxslt-dev \
    linux-headers make ncurses-dev openssl openssl-dev \
    patch procps readline-dev ruby tar xz yaml-dev zlib-dev; \
    rustArch=; apkArch="$(apk --print-arch)"; \
    case "$apkArch" in 'x86_64') rustArch='x86_64-unknown-linux-musl'; \
    rustupUrl='https://static.rust-lang.org/rustup/archive/1.25.1/x86_64-unknown-linux-musl/rustup-init'; \
    rustupSha256='95427cb0592e32ed39c8bd522fe2a40a746ba07afb8149f91e936cddb4d6eeac';; 'aarch64') \
    rustArch='aarch64-unknown-linux-musl'; \
    rustupUrl='https://static.rust-lang.org/rustup/archive/1.25.1/aarch64-unknown-linux-musl/rustup-init'; \
    rustupSha256='7855404cdc50c20040c743800c947b6f452490d47f8590a4a83bc6f75d1d8eda' ;; esac; \
    if [ -n "$rustArch" ]; \
    then mkdir -p /tmp/rust; \
    wget -O /tmp/rust/rustup-init "$rustupUrl"; \
    echo "$rustupSha256 */tmp/rust/rustup-init" | sha256sum --check --strict; \
    chmod +x /tmp/rust/rustup-init; \
    export RUSTUP_HOME='/tmp/rust/rustup' \
    CARGO_HOME='/tmp/rust/cargo'; \
    export PATH="$CARGO_HOME/bin:$PATH"; \
    /tmp/rust/rustup-init -y --no-modify-path --profile minimal --default-toolchain '1.66.0' --default-host "$rustArch"; \
    rustc --version; cargo --version; fi; \
    wget -O ruby.tar.xz "https://cache.ruby-lang.org/pub/ruby/${RUBY_MAJOR%-rc}/ruby-$RUBY_VERSION.tar.xz"; \
    echo "$RUBY_DOWNLOAD_SHA256 *ruby.tar.xz" | sha256sum --check --strict; \
    mkdir -p /usr/src/ruby; tar -xJf ruby.tar.xz -C /usr/src/ruby --strip-components=1; \
    rm ruby.tar.xz; cd /usr/src/ruby; \
    wget -O 'thread-stack-fix.patch' 'https://bugs.ruby-lang.org/attachments/download/7081/0001-thread_pthread.c-make-get_main_stack-portable-on-lin.patch'; \
    echo '3ab628a51d92fdf0d2b5835e93564857aea73e0c1de00313864a94a6255cb645 *thread-stack-fix.patch' | sha256sum --check --strict; \
    patch -p1 -i thread-stack-fix.patch; \
    rm thread-stack-fix.patch; export ac_cv_func_isnan=yes ac_cv_func_isinf=yes; \
    { echo '#define ENABLE_PATH_CHECK 0'; echo; cat file.c; } > file.c.new; \
    mv file.c.new file.c; \
    autoconf; gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
    ./configure \
    --build="$gnuArch" \
    --disable-install-doc \
    --enable-shared \
    ${rustArch:+--enable-yjit}; \
    make -j "$(nproc)"; \
    make install; \
    rm -rf /tmp/rust; \
    runDeps="$( scanelf --needed --nobanner --format '%n#p' --recursive /usr/local | tr ',' '\n' | sort -u | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' 	)"; \
    apk add --no-network -t .ruby-rundeps $runDeps; \
    apk del --no-network .ruby-builddeps; cd /; rm -r /usr/src/ruby; \
    if apk --no-network list --installed | grep -v '^[.]ruby-rundeps' | grep -i ruby; \
    then exit 1; fi; \
    [ "$(command -v ruby)" = '/usr/local/bin/ruby' ]; \
    ruby --version; \
    gem --version; \
    bundle --version

ENV PATH=/usr/local/bundle/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN mkdir -p "$GEM_HOME" && chmod 777 "$GEM_HOME"

LABEL org.opencontainers.image.name='Metasploit Framework' \
    org.opencontainers.image.description='The worlds most used penetration testing framework.' \
    org.opencontainers.image.usage='https://docs.metasploit.com/' \
    org.opencontainers.image.url='https://www.metasploit.com/' \
    org.opencontainers.image.vendor='Rapid7' \
    org.opencontainers.image.schema-version='6' \
    MAINTAINER="@rw"

#install metasploit
ARG BUNDLER_ARGS="set clean 'true' set no-cache 'true' set system 'true' set without 'development test coverage'"
ENV APP_HOME=/usr/src/metasploit-framework
ENV TOOLS_HOME=/usr/src/tools
ENV BUNDLE_IGNORE_MESSAGES="true"
ENV NMAP_PRIVILEGED=""
ENV METASPLOIT_GROUP=metasploit
WORKDIR $APP_HOME

COPY Gemfile* metasploit-framework.gemspec Rakefile $APP_HOME/
COPY version.rb $APP_HOME/lib/metasploit/framework/version.rb
COPY rails_version_constraint.rb $APP_HOME/lib/metasploit/framework/rails_version_constraint.rb
COPY helper.rb $APP_HOME/lib/msf/util/helper.rb

RUN set -x; \
    apk add --no-cache -t .msf-deps \
      autoconf bash bison \
      build-base curl ruby-dev \
      openssl-dev readline-dev \
      sqlite-dev postgresql-dev \
      libpcap-dev libxml2-dev \
      libxslt-dev yaml-dev \
      zlib-dev ncurses-dev \
      git go; \
      echo "gem: --no-document" > /etc/gemrc; \
      gem update --system; \
      bundle config $BUNDLER_ARGS; \
      bundle install --jobs=8; \
      rm -rf /usr/local/bundle/cache; \
      chmod -R a+r /usr/local/bundle; \
      apk del --purge .msf-deps

ENV GO111MODULE=off
RUN set -x; \
    apk add --no-cache -t .go-deps wget tar bash go autoconf; \
    mkdir -p $TOOLS_HOME/bin; \
    cd $TOOLS_HOME/bin; \
    wget https://dl.google.com/go/go1.19.5.src.tar.gz; \
    tar -zxvf go1.19.5.src.tar.gz; \
    rm go1.19.5.src.tar.gz; \
    cd $TOOLS_HOME/bin/go/src; \
    ./make.bash; \
    apk del --purge .go-deps

RUN set -eux; \
    addgroup -S metasploit; \
    apk add --no-cache bash sqlite-libs nmap nmap-scripts nmap-nselibs \
    postgresql-libs python3 py3-pip ncurses libcap su-exec alpine-sdk \
    openssl-dev nasm mingw-w64-gcc wget unzip curl
RUN set -x; \    
    /usr/sbin/setcap cap_net_raw,cap_net_bind_service=+eip $(which ruby); \
    /usr/sbin/setcap cap_net_raw,cap_net_bind_service=+eip $(which nmap); \
    chown -R root:metasploit /usr/local/bundle; \
    cd ${APP_HOME}; \
    wget https://github.com/rapid7/metasploit-framework/archive/refs/heads/master.zip; \
    unzip master.zip; mv ./metasploit-framework-master/* ./; \
    chown -R root:metasploit $APP_HOME/; \
    chmod 664 $APP_HOME/Gemfile.lock; \
    gem update --system; \
    cp -f $APP_HOME/docker/database.yml $APP_HOME/config/database.yml; \
    python -m pip install impacket; \
    python -m pip install requests

ENV GOPATH=$TOOLS_HOME/go
ENV GOROOT=$TOOLS_HOME/bin/go
ENV PATH=${PATH}:${GOPATH}/bin:${GOROOT}/bin

WORKDIR $APP_HOME
RUN sed -e "s|require 'msfenv';|# \0|" -i ./msfconsole
ENTRYPOINT ["docker/entrypoint.sh"]
CMD ["./msfconsole", "-r", "docker/msfconsole.rc", "-y", "$APP_HOME/config/database.yml"]
