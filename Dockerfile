FROM ubuntu:20.04

ENV DEBIAN_FRONTEND="noninteractive"

RUN echo "Etc/UTC" > /etc/timezone && \
    rm -f /etc/localtime && \
    ln -s /usr/share/zoneinfo/UTC /etc/localtime && \
    apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y certbot tini && \
    touch /etc/letsencrypt/volume_was_not_mapped

COPY start-certbot.sh /bin/
RUN chmod 755 /bin/start-certbot.sh

EXPOSE 80

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/bin/start-certbot.sh"]
