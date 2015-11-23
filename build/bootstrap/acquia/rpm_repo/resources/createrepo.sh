#!/bin/bash
set -e

BASEDIR=/dist
GPG_HOMEDIR=${BASEDIR}/.gnupg
REPO_PATH=${BASEDIR}/repo/main/centos/7

# Setup the repo structure and copy all packages into it
mkdir -p ${REPO_PATH}/x86_64/
cp -a ${BASEDIR}/packages/*.rpm ${REPO_PATH}/x86_64/

# If a GPG_HOMEDIR is included with the dist then sign all rpms before creating the repo.
# ~/.rpmmacros is setup to use GPG_HOMEDIR as its default %_gpg_path
if [ -d "${GPG_HOMEDIR}" ]; then
  echo "Signing packages"
  # Export the GPG public key to be imported by yum
  gpg --export -a "Acquia Engineering <engineering@acquia.com>" --homedir=${GPG_HOMEDIR} > ${BASEDIR}/repo/gpg
  # Sign all the packages
  /sign-rpm-packages.sh ${REPO_PATH}/x86_64/*.rpm
fi

# Create the repo
echo "Creating package repository"
cd ${REPO_PATH} && /usr/bin/createrepo .
