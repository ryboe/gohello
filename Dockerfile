# 1. build statically linked Go binary.
#    CGO_ENABLED=0 forces static linking of glibc (no runtime dependencies yay!)
# 2. zip up a timezone db (zoneinfo.zip). used by Go's time.LoadLocation func
FROM golang:1.10 AS builder
ENV CGO_ENABLED 0
COPY ./ /root/go/src/github.com/y0ssar1an/gohello
WORKDIR /root/go/src/github.com/y0ssar1an/gohello
RUN apt update && apt install -y zip && rm -rf /var/lib/apt/lists/*
RUN zip -0 -r /zoneinfo.zip /usr/share/zoneinfo
RUN go build -ldflags "-s -w -X main.version=$(git describe --tags --dirty --match='*.*.*' --abbrev=0)"

# super-minimal container that holds our Go binary
# $ZONEINFO is how time.LoadLocation finds the timezone db
FROM scratch
ENV ZONEINFO /zoneinfo.zip
COPY --from=builder /zoneinfo.zip /
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
WORKDIR /app
COPY --from=builder /root/go/src/github.com/y0ssar1an/gohello/gohello .
EXPOSE 8001
CMD ["./gohello"]
