#!/bin/bash -ex

set -o pipefail
cd "$(dirname "$0")"

if [[ $TRAVIS_PULL_REQUEST != false && $TRAVIS_COMMIT_RANGE ]]; then
  # We are testing a Pull Request: do not push
  DOCKER_ORG=
elif [[ $TRAVIS_PULL_REQUEST == false && $TRAVIS_BRANCH == master ]]; then
  # We are testing the master branch (e.g. when PR is merged)
  DOCKER_ORG=alipier
fi

# Load Docker Hub user and password
if [[ $DOCKER_ORG ]]; then
  docker login -u "$(eval echo \$DOCKER_USER_${DOCKER_ORG})" \
               -p "$(eval echo \$DOCKER_PASS_${DOCKER_ORG})"
fi

# Only rebuild containers that changed (TODO: now only works in PRs)
while read DOCK; do
  # Rebuild all containers that changed
  [[ -d $DOCK && ! -L $DOCK ]] || continue
  pushd "$DOCK"
    DOCKER_IMAGE="$DOCKER_ORG/${DOCK//\//:}"
    echo docker build . -t "$DOCKER_IMAGE"
    if [[ $DOCKER_ORG ]]; then
      echo docker push "$DOCKER_IMAGE"
    fi
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

echo failing deliberately
false
