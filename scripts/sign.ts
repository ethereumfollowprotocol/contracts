import { Bytes, concat, joinSignature } from '@ethersproject/bytes'
import { keccak256 } from '@ethersproject/keccak256'
import { toUtf8Bytes } from '@ethersproject/strings'
import { recoverAddress } from '@ethersproject/transactions'
import { ethers } from 'ethers'

export const messagePrefix = '\x19Ethereum Signed Message:\n'

// for logging only (this is done internally in signMessage)
function hashMessage(message: string | Bytes): string {
  if (typeof message === 'string') {
    message = toUtf8Bytes(message)
  }
  return keccak256(concat([toUtf8Bytes(messagePrefix), toUtf8Bytes(String(message.length)), message]))
}

async function signMessage(message = 'Hello, World!') {
  const mnemonic = 'test test test test test test test test test test test junk'
  const path = "m/44'/60'/0'/0/0"
  const wallet: ethers.Wallet = ethers.Wallet.fromMnemonic(mnemonic, path)

  console.log('Message           :', message)

  // sign the hashed message
  const signature = await wallet.signMessage(message)
  // also manually calculate the hashMessage used internally within signMessage
  //   const signatureHash = hashMessage(message)
  //   console.log('Signature Hash    :', signatureHash)
  console.log('EIP-191 Signature         :', signature)

  //   const signatureComponents = ethers.utils.splitSignature(signature)
  //   console.log('r:', signatureComponents.r)
  //   console.log('s:', signatureComponents.s)
  //   console.log('v:', signatureComponents.v)

  const recoveredAddress = ethers.utils.verifyMessage(message, signature)
  console.log('EIP-191 Recovered Address :', recoveredAddress)
  console.log('EIP-191 Expected Address  :', wallet.address)
  console.log()

  // raw ECDSA signing
  const signRaw = (message: string) => {
    const signingKey = wallet._signingKey()
    const keccakMessage = keccak256(toUtf8Bytes(message))
    const rawSignature: ethers.Signature = signingKey.signDigest(keccakMessage)
    const rawSignatureStr: string = joinSignature(rawSignature)
    return rawSignatureStr
  }

  const recoverAddressRaw = (message: string, rawSignatureStr: string) => {
    const keccakMessage = keccak256(toUtf8Bytes(message))
    const rawRecoveredAddress = recoverAddress(keccakMessage, rawSignatureStr)
    return rawRecoveredAddress
  }

  const rawSignatureStr = signRaw(message)
  console.log('Raw Signature             :', rawSignatureStr)
  const rawRecoveredAddress = recoverAddressRaw(message, rawSignatureStr)
  console.log('Raw Recovered Address     :', rawRecoveredAddress)
  console.log('Expected Address          :', wallet.address)
  console.log()

  // EFP SCHEMA
  //         // Create a unique message for validation using the following structure:
  //   // - Start with a 0x19 byte ensuring the data isn't considered valid RLP.
  //   // - Follow with version 0x00 and a 3-byte "EFP" prefix.
  //   // - Attach the token ID (32 bytes)
  //   // - then "manager" (7 bytes)
  //   // - and the claimed manager's address (20 bytes).
  //   // The resulting 64-byte message is optimized for efficient gas usage during signature verification.

  //   bytes memory message = abi.encodePacked(
  //     "\x19\x00EFP",
  //     bytes32(tokenId),
  //     "manager",
  //     bytes20(manager)
  // );

  function makeEFPMessage(tokenId: number, address: `0x${string}`): Uint8Array {
    const messageBytes: Uint8Array = concat([
      toUtf8Bytes('\x19\x00EFP'),
      ethers.utils.hexZeroPad(ethers.utils.hexlify(tokenId), 32),
      toUtf8Bytes('manager'),
      ethers.utils.hexZeroPad(address, 20),
    ])
    return messageBytes
  }

  const tokenId = 0
  const managerAddress = '0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496'
  const efpMessageBytes: Uint8Array = makeEFPMessage(tokenId, managerAddress)
  console.log('EFP Message               :', ethers.utils.hexlify(efpMessageBytes))
  const efpMessageHashed = keccak256(efpMessageBytes)
  const efpSignature = joinSignature(wallet._signingKey().signDigest(efpMessageHashed))
  console.log('EFP Signature             :', efpSignature)
  const efpRecoveredAddress = recoverAddress(efpMessageHashed, efpSignature)
  console.log('EFP Recovered Address     :', efpRecoveredAddress)
  console.log()
}

// If there is a command line argument, use it as the message
const inputMessage = process.argv[2]
signMessage(inputMessage)
