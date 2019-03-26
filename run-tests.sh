#!/bin/bash -e

set -o pipefail
cd "$(dirname "$0")"

DOCKER_ORG=alipier

if [[ $TRAVIS_PULL_REQUEST != false && $TRAVIS_COMMIT_RANGE ]]; then
  # We are testing a Pull Request: do not push
  DOCKER_PUSH=
elif [[ $TRAVIS_PULL_REQUEST == false && $TRAVIS_BRANCH == master ]]; then
  # We are testing the master branch (e.g. when PR is merged)
  DOCKER_PUSH=1
fi

# Load Docker Hub user and password
if [[ $DOCKER_PUSH ]]; then
  docker login -u "$(eval echo \$DOCKER_USER_${DOCKER_ORG})" \
               -p "$(eval echo \$DOCKER_PASS_${DOCKER_ORG})"
fi

# Only rebuild containers that changed (TODO: now only works in PRs)
while read DOCK; do
  # Rebuild all containers that changed
  [[ -d $DOCK && ! -L $DOCK ]] || continue
  pushd "$DOCK" &> /dev/null
    DOCKER_IMAGE="$DOCKER_ORG/${DOCK//\//:}"
    echo "Building Docker image $DOCKER_IMAGE"
    docker build . -t "$DOCKER_IMAGE"
    if [[ $DOCKER_PUSH ]]; then
      docker push "$DOCKER_IMAGE"
    fi
  popd &> /dev/null
done < <(git diff --name-only $TRAVIS_COMMIT_RANGE | grep / | cut -d/ -f1,2 | sort -u)

if [[ $DOCKER_PUSH ]]; then
  while read DOCK; do
    # Repush all symlinks that changed
    [[ -L $DOCK ]] || continue
    DOCKER_IMAGE="$DOCKER_ORG/${DOCK//\//:}"
    DOCKER_IMAGE_ORIG="$DOCKER_ORG/$(dirname $DOCK):$(readlink $DOCK)"
    echo "Retagging Docker image $DOCKER_IMAGE -> $DOCKER_IMAGE_ORIG"
    docker pull "$DOCKER_IMAGE_ORIG"
    docker tag "$DOCKER_IMAGE_ORIG" "$DOCKER_IMAGE"
  done < <(git diff --name-only $TRAVIS_COMMIT_RANGE | grep / | cut -d/ -f1,2 | sort -u)
fi

echo failing deliberately
false
