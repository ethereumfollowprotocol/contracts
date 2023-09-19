# beta-contracts
Core smart contracts of Ethereum Follow Protocol Beta

## Development

### Dependencies
[Install Foundry](https://book.getfoundry.sh/getting-started/installation)

### Build
To build, run
```bash
forge build
```

Build artifacts are stored in `out/`.

### Test
To build and test, run
```
forge test
```

## Design Specification

### Ethereum Follow Protocol (EFP) Overview:

EFP is a native Ethereum protocol for following and tagging Ethereum accounts.

To begin, users first mint an NFT called the "EFP List NFT".

### EFP List NFT

Users mint the EFP List NFT to create an EFP List.

#### Roles
Every EFP List NFT has two roles, each of which are held by an Ethereum account, either an EOA or contract address.

1. **Owner:**
   - Is the owner of the EFP List NFT
   - Can transfer the Owner role
   - Can edit the User role
   - Can edit the List Records Storage Location
2. **User:**
   - The Ethereum address for whom the list is intended; the Ethereum account that is following the Ethereum accounts in the list.

Typically, both roles (Owner, User) are the same Ethereum account, but they can be distinct.

---

### Record Storage

Your EFP NFT specifies a **List Records Storage Location** where the List Records are stored, which can be one of the following:
  * Ethereum L1 smart contract address
  * CCIP-read pointers for storage outside Ethereum L1

The List Records Storage Location itself (the smart contract or off-chain system) must specify a **Manager** role, typically an Ethereum account that is able to edit the List Records. Typically, the Manager will be the same Ethereum account as the Owner and User roles of the EFP NFT, but they can be distinct.

---

### List Record Types

* **Entry Record:**
   - Contains an Ethereum address, with zero or more tags.
   - These records are typically interpreted as a "follow" of the specified Ethereum address, with some exceptions explained in the Followers section below.
* **Transitive Record:**
   - Contains an EFP List NFT token ID, with zero or more tags.
   - This typically means the user intends to "follow" some or all of the Entry Records in the specified list.
   - If no tag is included, it means the user follows every Entry Record on the specified list. If a tag or set of tags is included, it means the user follows only the Entry Records with any one of those tags.

---

### Tags

Each Entry Record can have zero or more tags.

#### Standard Tags
- **no tag**
  - If an Entry Record has no tags, it is interpreted as a simple follow without further categorization.

- **"block"**
  - This tag means neither the user nor the blocked account should see each other’s activity.
  - Entry Records with this tag are not included in Followers count, even if the Entry Record has other tags.
  - If both “block” and “mute” tags are present, “block” takes precedence.

- **"mute"**
  - This tag means the user shouldn't see the muted account’s activity, but the muted account might still be able to see the user’s activity.
  - Entry Records with this tag are not included in Followers count, even if the Entry Record has other tags.
  - If both “block” and “mute” tags are present, “block” takes precedence.

#### Custom Tags:
Users can use arbitrary custom tags.

---

### Followers

#### Definition
- **Followers** is the total number of EFP NFTs that have at least one Entry Record with a specific Ethereum address, plus EFP NFTs that have a Transitive Record that points to an Entry Record with a specific Ethereum address, with the following additional conditions:

- Exclude records with either the "block" or "mute" tags, even if the records have other tags.
- Multiple EFP NFTs with an identical User are counted as a single follower.
