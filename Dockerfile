# syntax=docker/dockerfile:1
FROM golang:1.21 AS build

# build statically linked Go binary.
# CGO_ENABLED=0 forces static linking of glibc (no runtime dependencies yay!)
ENV CGO_ENABLED="0"
COPY ./ /go/src/gohello
WORKDIR /go/src/gohello
RUN go install -ldflags "-s -w -X main.version=$(git describe --tags --dirty --match='*.*.*' --abbrev=0)"

# update CA cert list
FROM alpine:latest AS os_deps
RUN apk add --update ca-certificates

# super-minimal container that holds our Go binary
FROM scratch
COPY --from=os_deps /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
WORKDIR /app
COPY --from=build /go/bin/gohello .
EXPOSE 8001
CMD ["/app/gohello"]
