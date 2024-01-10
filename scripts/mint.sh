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

# change to 1000 for large mint test
for i in {0..100..50}
do
  if [ $i -ne 0 ]; then
    mint $i
  fi
done
