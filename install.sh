#!/usr/bin/env bash
# run this script locally to install dependencies

. ./constants.sh install

pushd "$REPO_ROOT/bin"

curl -L "https://download.dfinity.systems/ic/${IC_COMMIT}/openssl-static-binaries/x86_64-${OS}/ic-admin.gz" -o ic-admin.gz
gzip -fd ic-admin.gz
chmod +x ic-admin

curl -L "https://download.dfinity.systems/ic/${IC_COMMIT}/openssl-static-binaries/x86_64-${OS}/ic-nns-init.gz" -o ic-nns-init.gz
gzip -fd ic-nns-init.gz
chmod +x ic-nns-init

curl -L "https://download.dfinity.systems/ic/${IC_COMMIT}/openssl-static-binaries/x86_64-${OS}/ic-regedit.gz" -o ic-regedit.gz
gzip -fd ic-regedit.gz
chmod +x ic-regedit

curl -L "https://download.dfinity.systems/ic/${IC_COMMIT}/openssl-static-binaries/x86_64-${OS}/sns.gz" -o sns.gz
gzip -fd sns.gz
chmod +x sns

curl -L "https://github.com/dfinity/sdk/releases/download/0.14.1/dfx-0.14.1-x86_64-${OS}.tar.gz" -o dfx.tar.gz
tar -xzf dfx.tar.gz
rm dfx.tar.gz
chmod +x dfx

if [[ "${OS}" == "linux" ]]
then
  export QUILL="linux"
elif [[ "${OS}" == "darwin" ]]
then
  export QUILL="macos"
else
  echo "Unknown OS!"
  exit 1
fi

curl -L "https://github.com/dfinity/sns-quill/releases/download/v0.4.2-beta.1/sns-quill-${QUILL}-x86_64" -o sns-quill
chmod +x sns-quill

curl -L "https://github.com/dfinity/quill/releases/download/v0.4.0/quill-${QUILL}-x86_64" -o quill
chmod +x quill

if [[ "${OS}" == "linux" ]]
then
  export DIDC="linux64"
elif [[ "${OS}" == "darwin" ]]
then
  export DIDC="macos"
else
  echo "Unknown OS!"
  exit 1
fi

curl -L "https://github.com/dfinity/candid/releases/download/2022-11-17/didc-${DIDC}" -o didc
chmod +x didc

# Add $REPO_ROOT/bin to path
export PATH="$(readlink -f .):${PATH}"

popd
