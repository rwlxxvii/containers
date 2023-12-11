FROM docker.io/alpine:3.19

# url with main/master branch of code to scan
ARG URL

# name for report output
ARG CODE_NAME

# https://snyk.io/login?cta=sign-up&loc=nav&page=support_docs_page
# To authenticate using your API token:
#Go to your Snyk account (Account Settings > API Token section).
#In the KEY field, click click to show; then select and copy your API token. A screenshot follows.
#In the CLI, run snyk auth [<API_TOKEN>] or snyk config set api=<token>. The <API_TOKEN>is validated by the Snyk API.

ARG SNYK_API

LABEL org.opencontainers.image.name='So Now You Know.' \
    org.opencontainers.image.description='Scan code directories for code quality and security checks.' \
    org.opencontainers.image.usage='https://snyk.io/' \
    MAINTAINER="@rw"
    
RUN \
    addgroup -g 65535 snyk; \
    adduser -h /home/snyk --shell /bin/nologin --disabled-password --uid 65535 --ingroup snyk --gecos '' snyk; \
    apk add --no-cache bash
    
WORKDIR /home/snyk

SHELL ["/bin/bash", "-c"]

RUN \
    apk add --no-cache -t .snyk-deps ca-certificates npm unzip wget; \
    wget --progress=bar:force ${URL} -O codebase.zip; \
    unzip codebase.zip; \
    echo -e $'for d in ./*/; do \n\
      if [[ $d =~ (master|main)[0-9]? ]]; then \n\
        break; \n\
      fi \n\
    done; \n\
    if ((${#BASH_REMATCH[@]} > 0)); then \n\
        cd $d \n\
    fi' | tee change_dir.sh; chmod +x change_dir.sh; bash -c "./change_dir.sh"; \
    #snyk cli scan
    npm install -g snyk; \
    npm install -g snyk-to-html; \
    snyk config set api=${SNYK_API}; \
    snyk code test --all-projects --json | snyk-to-html -o /home/snyk/${CODE_NAME}-code-review.html; \
    snyk test --all-projects --json | snyk-to-html -o /home/snyk/${CODE_NAME}-dependencies.html; \
    snyk monitor; \
    npm uninstall -g snyk; \
    npm uninstall -g snyk-to-html; \
    apk del --purge .snyk-deps; \
    chown -R snyk:snyk /home/snyk

USER snyk
CMD ["sh"]
