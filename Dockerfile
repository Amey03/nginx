# Stage 1: Build confd
FROM golang:1.15-alpine3.14 as confd
ARG CONFD_VERSION=0.16.0
ADD https://github.com/kelseyhightower/confd/archive/v${CONFD_VERSION}.tar.gz /tmp/

RUN apk add --no-cache \
    bzip2 \
    make && \
    mkdir -p /go/src/github.com/kelseyhightower/confd && \
    cd /go/src/github.com/kelseyhightower/confd && \
    tar --strip-components=1 -zxf /tmp/v${CONFD_VERSION}.tar.gz && \
    go install github.com/kelseyhightower/confd && \
    rm -rf /tmp/v${CONFD_VERSION}.tar.gz

# Stage 2: Final image
FROM alpine:3.17.3
LABEL maintainer="devops@rogerthat.com"
ARG NGINX_HTTP_PORT=80

RUN echo "UTC" > /etc/timezone

# Install necessary packages including Nginx instead of Squid
RUN apk --no-cache add \
    alpine-baselayout \
    alpine-keys \
    apk-tools \
    bash \
    busybox \
    curl \
    git \
    gzip \
    htop \
    sudo \
    supervisor \
    syslog-ng \
    tar \
    wget \
    zlib \
    nginx

# CONFD templates & files
COPY --from=confd /go/bin/confd /usr/local/bin/confd

RUN mkdir /etc/confd/ \
    && mkdir /etc/confd/conf.d/ \
    && mkdir /etc/confd/templates/
COPY config/confd/conf.d/ /etc/confd/conf.d/
COPY config/confd/templates/ /etc/confd/templates/

# CONFD directories
RUN mkdir /etc/supervisor/ \
    && mkdir /etc/supervisor/conf.d/ \
    && mkdir /run/supervisor/ \
    && mkdir /run/syslog-ng/

# Install Entrypoint script
RUN mkdir /scripts/ \
    && mkdir /scripts/start.d/
COPY config/scripts/start.sh /sbin/start.sh
RUN chmod 755 /sbin/start.sh

# Expose the Nginx HTTP port
EXPOSE ${NGINX_HTTP_PORT}/tcp

# Set the entrypoint
ENTRYPOINT ["/sbin/start.sh"]