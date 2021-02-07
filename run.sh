#!/bin/bash
set -eu

NODE_VERSION=${NODE_VERSION:-15.6.0}
CDK_VERSION=${CDK_VERSION:-1.88.0}
CRC32_STREAM_VERSION=${CRC32_STREAM_VERSION:-4.0.2}
ARCHIVER_VERSION=${ARCHIVER_VERSION:-5.2.0}

scriptdir=$(cd $(dirname $0) && pwd)

darwin=false
if uname -a | grep Darwin; then
  darwin=true
fi

function install_node {
  pushd .node-versions
  archive_name=nodejs-${NODE_VERSION}.archive

  if ${darwin}; then
    node_url=https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-darwin-x64.tar.gz
    dir_name=node-v${NODE_VERSION}-darwin-x64
    tar_flags=zxf
  else
    node_url=https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz
    dir_name=node-v${NODE_VERSION}-linux-x64
    tar_flags=xf
  fi

  if [ ! -f ${archive_name} ]; then
    echo "Downloading NodeJS from ${node_url}"
    curl -o ${archive_name} ${node_url}
    tar ${tar_flags} ${archive_name}
  fi

  export PATH=$(pwd)/${dir_name}/bin:${PATH}
  export PATH=${scriptdir}/node_modules/.bin:${PATH}
  pushd ${scriptdir}
  npm install yarn
  rm package-lock.json
  popd
  popd
}

function use_version {
  package=$1
  version=$2
  echo "Using ${package} version ${version}"
  if ${darwin}; then
    sed -i ".bak" -E "s|(${package}.*: )\".*\"|\1\"${version}\"|g" ${scriptdir}/package.json
  else
    sed -i -E "s|(${package}.*: )\".*\"|\1\"${version}\"|g" ${scriptdir}/package.json
  fi

}

function use_cdk {
  use_version "aws-cdk" ${1}
}

function use_crc32_stream {
  use_version "crc32-stream" ${1}
}

function use_archiver {
  use_version "archiver" ${1}
}

mkdir -p ${scriptdir}/.node-versions
pushd ${scriptdir}

echo "Installing NodeJS ${NODE_VERSION}"
install_node

use_cdk ${CDK_VERSION}
use_crc32_stream ${CRC32_STREAM_VERSION}
use_archiver ${ARCHIVER_VERSION}

pushd ${scriptdir}

yarn install

echo "Compiling..."
npm run build

echo "Synthesizing..."
cdk synth

echo "Destroying previous stack"
cdk destroy

echo "Removing relevant assets from staging bucket"
staging_bucket=$(aws cloudformation describe-stack-resources --stack-name CDKToolkit --logical-resource-id StagingBucket --query 'StackResources[].PhysicalResourceId' --output=text)
for asset in $(ls cdk.out | grep asset); do
  hash=$(echo ${asset} | cut -d'.' -f2)
  aws s3 rm s3://${staging_bucket}/assets/${hash}.zip
done
echo "Removing cdk.out"
rm -rf cdk.out

echo "Deploying"
set +e
cdk deploy
exit_code=$?
set -e

echo "Destroying"
cdk destroy -f

if [ ${exit_code} -eq 0 ]; then
  echo -e "Success"
else
  echo -e "Failure"
fi

echo " - NODE_VERSION: $(node --version)"
echo " - CDK_VERSION: $(cdk --version)"
echo " - CRC32_STREAM_VERSION: $(node -p 'require(path.join(path.dirname(path.dirname(require.resolve("crc32-stream"))), "package.json")).version')"
echo " - ARCHIVER_VERSION: $(node -p 'require(path.join(path.dirname(require.resolve("archiver")), "package.json")).version')"

popd

exit ${exit_code}