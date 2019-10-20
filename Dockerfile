# build statically linked Go binary.
# CGO_ENABLED=0 forces static linking of glibc (no runtime dependencies yay!)
FROM golang:1.13 AS build
LABEL maintainer="ryanboehning@gmail.com"
LABEL builder=true
ENV CGO_ENABLED 0
ENV GO111MODULE on
ENV GOFLAGS -mod=vendor
VOLUME ["/app"]
COPY ./ /go/src/gohello
WORKDIR /go/src/gohello
RUN go install -ldflags "-s -w -X main.version=$(git describe --tags --dirty --match='*.*.*' --abbrev=0)"

# 1. zip up a timezone db (zoneinfo.zip). used by Go's time.LoadLocation func
# 2. update CA cert list
FROM alpine:latest AS os_deps
RUN apk add --no-cache ca-certificates tzdata zip
RUN zip -0 -r /zoneinfo.zip /usr/share/zoneinfo

# super-minimal container that holds our Go binary
# $ZONEINFO is how time.LoadLocation finds the timezone db
FROM scratch
ENV ZONEINFO /zoneinfo.zip
COPY --from=os_deps /zoneinfo.zip /
COPY --from=os_deps /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
WORKDIR /app
COPY --from=build /go/bin/gohello .
EXPOSE 8001
CMD ["/app/gohello"]
