FROM alpine:3.12.2

RUN apk update && \
    apk add bash openssh-client curl openssl ca-certificates

ARG ETCD_VER=v3.4.14
ARG DOWNLOAD_URL=https://storage.googleapis.com/etcd
#ARG DOWNLOAD_URL=https://github.com/etcd-io/etcd/releases/download

COPY "etcd_arch.sh" "/etcd_arch.sh"
RUN chmod +x /etcd_arch.sh && \
    ETCD_ARCH=$(/etcd_arch.sh) && \
    echo "ETCD_ARCH=$ETCD_ARCH" && \
    curl -L ${DOWNLOAD_URL}/${ETCD_VER}/etcd-${ETCD_VER}-linux-${ETCD_ARCH}.tar.gz -o /tmp/etcd.tar.gz

RUN mkdir -p /usr/local/etcd && \
    tar xzvf /tmp/etcd.tar.gz -C /usr/local/etcd --strip-components=1 && \
    rm -f /tmp/etcd.tar.gz && \
    ln -s /usr/local/etcd/etcdctl /usr/bin/etcdctl && \
    ln -s /usr/local/etcd/etcd /usr/bin/etcd

COPY "./opt" "/opt/"
RUN chmod +x /opt/*.sh

