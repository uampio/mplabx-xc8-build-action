FROM alpine:latest

COPY docker-action /docker-action
COPY entrypoint.sh /entrypoint.sh

RUN ls -la $(pwd)

# Mount the GitHub workspace
VOLUME /github/workspace

RUN ["chmod", "+x", "/entrypoint.sh"]

RUN apk add --update --no-cache docker

ENTRYPOINT ["/entrypoint.sh"]