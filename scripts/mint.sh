#!/usr/bin/env bash

set -e


function mint() {
  echo
  echo
  echo
  echo "============================================================"
  echo "Minting total supply: ${1}"
  echo "============================================================"
  echo
  MINT_INITIAL_TOTAL_SUPPLY=${1} forge script scripts/mint.s.sol --fork-url ${ETHEREUM_LOCAL_NODE_URL:-http://localhost:8545} --broadcast --private-key ${PRIVATE_KEY} ${FORGE_ARGS}
}

start=50
end=${MINT_INITIAL_TOTAL_SUPPLY:-50}
step=${MINT_BATCH_SIZE:-50}

# we will pass this to the forge script ourselves
unset MINT_INITIAL_TOTAL_SUPPLY

# change to 1000 for large mint test
for ((i=start; i<=end; i+=step))
do
  mint $i
done
