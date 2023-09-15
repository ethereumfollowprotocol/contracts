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

  // raw ECDSA signing
  const signingKey = wallet._signingKey()
  const keccakMessage = keccak256(toUtf8Bytes(message))
  const rawSignature: ethers.Signature = signingKey.signDigest(keccakMessage)
  const rawSignatureStr: string = joinSignature(rawSignature)
  console.log('Raw Signature         :', rawSignatureStr)
  const rawRecoveredAddress = recoverAddress(keccakMessage, rawSignatureStr)
  console.log('Raw Recovered Address :', rawRecoveredAddress)
  console.log('Expected Address      :', wallet.address)
}

// If there is a command line argument, use it as the message
const inputMessage = process.argv[2]
signMessage(inputMessage)
