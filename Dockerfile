# Samba AD-DC
FROM alpine:3.20

RUN apk --no-cache add \
    bash \
    samba-dc \
    heimdal \
    supervisor \
    bind-tools \
    pwgen \
    acl-dev \
    attr-dev \
    blkid \
    gnutls-dev \
    readline-dev \
    python3-dev \
    linux-pam-dev \
    py3-pip \
    popt-dev \
    openldap-dev \
    libbsd-dev \
    cups-dev \
    ca-certificates \
    py3-certifi \
    rsyslog \
    expect \
    tdb \
    tdb-dev \
    py3-tdb \
    acl \
    py3-dnspython

ADD kdb5_util_create.expect kdb5_util_create.expect
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD named.conf /etc/bind/named.conf
ADD named.conf.options /etc/bind/named.conf.options

COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

EXPOSE 22 53 389 88 135 139 138 445 464 3268 3269
ENTRYPOINT ["/entrypoint.sh"]
CMD ["app:start"]
