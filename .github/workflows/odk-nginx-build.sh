#!/bin/bash

set -eo pipefail

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -p, --DOCKERFILE_PATH"
    echo "  -r, --ODK_NGINX_REPOSITORY"
    echo "  -u, --DOCKERHUB_USER"
    echo "  -t, --DOCKERHUB_TOKEN"
    echo "  -T, --TAG"
    echo "  -D, --DOCKER_BUILD_TARGET"
    echo "  -D, --OIDC_ENABLED"
    exit 1
}

DOCKERFILE_PATH="../.."
ODK_NGINX_REPOSITORY=""
DOCKERHUB_USER=""
DOCKERHUB_TOKEN=""
TAG="latest"
DOCKER_BUILD_TARGET="intermediate"
OIDC_ENABLED="false"

# Check args
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
    -p)
        DOCKERFILE_PATH="$2"
        shift 2
        ;;
    -r)
        ODK_NGINX_REPOSITORY="$2"
        shift 2
        ;;
    -u)
        DOCKERHUB_USER="$2"
        shift 2
        ;;
    -t)
        DOCKERHUB_TOKEN="$2"
        shift 2
        ;;
    -T)
        TAG="$2"
        shift 2
        ;;
    -D)
        DOCKER_BUILD_TARGET="$2"
        shift 2
        ;;
    -E)
        OIDC_ENABLED="$2"
        shift 2
        ;;
    *)
        usage
        ;;
    esac
done

# Check if required arguments are provided
if [ -z "$DOCKERFILE_PATH" ] || [ -z "$ODK_NGINX_REPOSITORY" ] || [ -z "$DOCKERHUB_USER" ]; then
    echo "Error: Missing required arguments."
    usage
fi

echo "Docker file path is ${DOCKERFILE_PATH}"
cd $DOCKERFILE_PATH

echo "Build target is: $DOCKER_BUILD_TARGET"
echo "Tag is: $TAG"

docker build \
  -f nginx.dockerfile \
  -t "${ODK_NGINX_REPOSITORY}:${TAG}" \
  --build-arg OIDC_ENABLED=$OIDC_ENABLED \
  --target $DOCKER_BUILD_TARGET \
  .

if [[ -z "${DOCKERHUB_TOKEN}" ]]; then
    # Skip if secrets aren't populated -- they're only visible for actions running in the repo (not on forks)
    echo "Skipping Docker push"
else
    # Login and push
    docker logout
    docker login --username "${DOCKERHUB_USER}" --password "${DOCKERHUB_TOKEN}"
    docker push "${ODK_NGINX_REPOSITORY}:${TAG}"
fi
