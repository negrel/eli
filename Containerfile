FROM docker.io/library/alpine:3

# Install buildah
RUN apk update \
    && apk add \
        bash \
        buildah

RUN mkdir /eli
ADD eli /eli
ADD cmd/ /eli/cmd/
ADD lib/ /eli/lib/
ADD templates/ /eli/templates/

ENTRYPOINT ["/eli/eli"]
CMD ["--help"]
