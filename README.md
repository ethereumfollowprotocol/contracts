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

EFP is a native Ethereum protocol for following and tagging other Ethereum accounts.

Users mint an NFT called the "EFP List NFT".

### EFP List NFT

#### Minting
- Users mint this NFT to create an EFP List.

#### Price
TBD

#### Roles (Held by Ethereum addresses):
Every EFP List NFT has three roles:
1. **Owner:**
   - Has overall control over the NFT.
   - Can transfer ownership, edit the Manager, and set the User.
2. **Manager:**
   - Can edit List Records.
   - Can set the Manager and User roles.
3. **User:**
   - The individual for whom the list is intended; they follow other Ethereum accounts.

Typically, all three roles (Owner, Manager, User) are the same Ethereum account, but they can be distinct.

---

### Record Storage

#### Location
- EFP NFT specifies where the list records are stored, which can be:
   1. Ethereum L1 smart contract address.
   2. CCIP-read pointers for storage outside Ethereum L1.

---

### Record Types

1. **List Record:**
   - Contains an Ethereum address with zero or multiple tags.
2. **Transitive Record:**
   - Points to another person's list (via that list's EFP List NFT token ID).
   - Can specify tags or remain unfiltered.

---

### Tags

Each list record can have zero or more tags.

If a list record has no tags, that is interpreted as a simple follow without further categorization.

#### Standard Tags
- **"block"**
   - Ensures both parties (user and the blocked person) don't see each other's activity.
- **"mute"**
   - The user won't see the muted person’s activity, but the muted person might see the user’s activity.

#### Custom Tags:
- Users can define custom tags and assign their meanings.

---

### Followers

#### Definition
- **Followers** count EFP NFTs that have a record pointing to a specific Ethereum address.

#### Conditions:
- Exclude records with "block" or "mute" tags.
- Multiple EFP NFTs with an identical User are considered a single follower.
