FROM rockylinux:9

LABEL maintainer="tjung03"
LABEL org.opencontainers.image.title="infra-nfs"
LABEL org.opencontainers.image.description="NFSv4 server image for shared web container log storage"

RUN dnf -y install nfs-utils procps-ng iproute util-linux \
  && dnf clean all \
  && rm -rf /var/cache/dnf

RUN mkdir -p /exports/share/logs /etc/exports.d /proc/fs/nfsd /var/lib/nfs/rpc_pipefs /run

COPY default-share/ /exports/share/
COPY exports.d/nfs.exports /etc/exports.d/nfs.exports
COPY entrypoint.sh /usr/local/sbin/entrypoint.sh

RUN chmod 755 /usr/local/sbin/entrypoint.sh \
  && chmod 755 /exports \
  && chmod 777 /exports/share /exports/share/logs

EXPOSE 2049/tcp

VOLUME ["/exports"]

ENTRYPOINT ["/usr/local/sbin/entrypoint.sh"]
