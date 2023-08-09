FROM alpine:3.18.3

USER root

WORKDIR /app
RUN apk update
RUN apk update
RUN apk add bash docker openssh sshpass

ADD main.sh /app
ADD start.sh /app
ADD version.txt /app
ADD utils/ /app/utils/

ENTRYPOINT [ "./start.sh" ]