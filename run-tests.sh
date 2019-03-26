#!/bin/bash -ex

set -o pipefail
cd "$(dirname "$0")"

if [[ $TRAVIS_PULL_REQUEST != false && $TRAVIS_COMMIT_RANGE ]]; then
  # We are testing a Pull Request
  DOCKER_ORG=alipierdev
  #RUN_SETUP=1
  #[[ $TRAVIS_PYTHON_VERSION == 3* ]] && RUN_DOCK=1 || RUN_DOCK=
  #git diff --name-only $TRAVIS_COMMIT_RANGE | grep -q ^setup.py$ || RUN_SETUP=
  #git diff --name-only $TRAVIS_COMMIT_RANGE | grep -q ^dock/     || RUN_DOCK=
  #DOCKER_REPO=aliswdev
elif [[ $TRAVIS_PULL_REQUEST == false && $TRAVIS_BRANCH == master ]]; then
  # We are testing the master branch (e.g. when PR is merged)
  DOCKER_ORG=alipier
fi

# Load Docker Hub user and password
DOCKER_USER=$(eval echo \$DOCKER_USER_${DOCKER_ORG})
DOCKER_PASS=$(eval echo \$DOCKER_PASS_${DOCKER_ORG})

# Only rebuild containers that changed (TODO: now only works in PRs)
while read DOCK; do
  # Rebuild all containers that changed
  [[ -d $DOCK && ! -L $DOCK ]] || continue
  echo "I would rebuild container image $DOCK"
done < <(git diff --name-only $TRAVIS_COMMIT_RANGE | grep / | cut -d/ -f1,2 | sort -u)

while read DOCK; do
  # Repush all symlinks that changed
  [[ -L $DOCK ]] || continue
  DOCK_ORIG="$(dirname $DOCK)/$(readlink $DOCK)"
  echo "I would relink container image $DOCK (points to $DOCK_ORIG)"
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
