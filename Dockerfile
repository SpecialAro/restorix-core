FROM alpine:latest

USER root

WORKDIR /app
RUN apk update
RUN apk update
RUN apk add bash docker openssh sshpass

ADD main.sh /app
ENTRYPOINT [ "./main.sh" ]