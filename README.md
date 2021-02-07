# AWS CDK Issue 12536 - Asset Corruption

This is a repository for reproducing and testing various permutations related to [Issue 12536](https://github.com/iliapolo/aws-cdk-issue12536)

## Prerequisites

- The AWS CLI must be available in the `PATH` under the `aws` command, and configured with the appropriate region.
- Mac OR Linux (Not windows).

## Usage

The repository includes a simple pre-defined [stack](./lib/asset-corruption-stack.ts) to verify proper functionality.
You can replace it with your own stack if needed.

1. `git clone https://github.com/iliapolo/aws-cdk-issue12536.git`
2. `cd aws-cdk-issue12536 && ./run.sh`

The `run.sh` script will take care of all necessary cache clearance and will destroy the stack in the end. You can simply re-run it as many times you like with different configurations. The following envrionment variables are available to control versions of the relevant components:

- `NODE_VERSION` (Default 15.6.0)
- `CDK_VERSION` (Default 1.88.0)
- `CRC32_STREAM_VERSION` (Default 4.0.2)
- `ARCHIVER_VERSION` (Default 5.2.0)

All these components, including `NodeJS` itself and `yarn`, are installed and used locally. (Under `./.node-versions` and `./node_modules`)

### Permutations

- Working: `crc32-stream` **>=** `4.0.2` **OR** Node **<=** `15.5.0`
- Non working: `crc32-stream` **<** `4.0.2` **AND** Node **>** `15.5.0`
