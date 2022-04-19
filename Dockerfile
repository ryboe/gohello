# build statically linked Go binary.
# CGO_ENABLED=0 forces static linking of glibc (no runtime dependencies yay!)
FROM golang:1.18 AS build
LABEL maintainer="ryanboehning@gmail.com"
ENV CGO_ENABLED 0
COPY ./ /go/src/gohello
WORKDIR /go/src/gohello
RUN go install -ldflags "-s -w -X main.version=$(git describe --tags --dirty --match='*.*.*' --abbrev=0)"

# 1. zip up a timezone db (zoneinfo.zip). used by Go's time.LoadLocation func
# 2. update CA cert list
FROM alpine:latest AS os_deps
RUN apk add --no-cache ca-certificates

# super-minimal container that holds our Go binary
FROM scratch
COPY --from=os_deps /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
WORKDIR /app
COPY --from=build /go/bin/gohello .
EXPOSE 8001
CMD ["/app/gohello"]
