#!/bin/bash -ex

set -o pipefail
cd "$(dirname "$0")"

if [[ $TRAVIS_PULL_REQUEST != false && $TRAVIS_COMMIT_RANGE ]]; then
  # We are testing a Pull Request
  DOCKER_ORG=alipierdev
elif [[ $TRAVIS_PULL_REQUEST == false && $TRAVIS_BRANCH == master ]]; then
  # We are testing the master branch (e.g. when PR is merged)
  DOCKER_ORG=alipier
fi

# Load Docker Hub user and password
docker login -u "$(eval echo \$DOCKER_USER_${DOCKER_ORG})" \
             -p "$(eval echo \$DOCKER_PASS_${DOCKER_ORG})"

# Only rebuild containers that changed (TODO: now only works in PRs)
while read DOCK; do
  # Rebuild all containers that changed
  [[ -d $DOCK && ! -L $DOCK ]] || continue
  pushd "$DOCK"
    DOCKER_IMAGE="$DOCKER_ORG/${DOCK//\//:}"
    echo docker build . -t "$DOCKER_IMAGE"
    echo docker push "$DOCKER_IMAGE"
  popd
done < <(git diff --name-only $TRAVIS_COMMIT_RANGE | grep / | cut -d/ -f1,2 | sort -u)

while read DOCK; do
  # Repush all symlinks that changed
  [[ -L $DOCK ]] || continue
  DOCKER_IMAGE="$DOCKER_ORG/${DOCK//\//:}"
  DOCKER_IMAGE_ORIG="$DOCKER_ORG/$(dirname $DOCK):$(readlink $DOCK)"
  echo docker pull "$DOCKER_IMAGE_ORIG"
  echo docker tag "$DOCKER_IMAGE_ORIG" "$DOCKER_IMAGE"
done < <(git diff --name-only $TRAVIS_COMMIT_RANGE | grep / | cut -d/ -f1,2 | sort -u)

echo exit here just for fun
false


# Docker
if [[ $RUN_DOCK ]]; then
  docker login -u "$DOCKER_USER" -p "$DOCKER_PASS"
  pushd dock
    docker build . -t "$DOCKER_REPO"/alidock:latest
    docker tag "$DOCKER_REPO"/alidock:latest "$DOCKER_REPO"/alidock:cc7
  popd
  docker push "$DOCKER_REPO"/alidock:latest
  docker push "$DOCKER_REPO"/alidock:cc7
fi
