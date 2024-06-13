# Samba AD-DC
FROM alpine:3.20

RUN apk --no-cache add \
    bash \
    samba-dc \
    heimdal \
    supervisor \
    rsyslog
    
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

EXPOSE 53/tcp 53/udp 88/tcp 88/udp 135/tcp 137/udp 138/udp 139/tcp 389/tcp 389/udp 445/tcp 464/tcp 464/udp 636/tcp 3268/tcp 3269/tcp 50000-55000/tcp
ENTRYPOINT ["/entrypoint.sh"]
CMD ["app:start"]