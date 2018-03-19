#!/usr/bin/env bash

# cleanup any existing binaries
ARTIFACT_DIR="${GOPATH}/src/github.com/y0ssar1an/gohello/artifact"
rm -f "${ARTIFACT_DIR}/gohello"

# get the ID of the build container
IMAGE_ID=$(docker images --quiet --filter label=builder=true)

# mount artifact/ into the container and run it.
docker run --rm --volume "${ARTIFACT_DIR}:/app" "${IMAGE_ID}"
