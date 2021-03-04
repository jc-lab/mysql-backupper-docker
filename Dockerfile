FROM alpine:3.13.2

RUN apk update && \
    apk add bash openssh-client curl openssl ca-certificates mariadb-client

COPY "./opt" "/opt/"
RUN chmod +x /opt/*.sh

