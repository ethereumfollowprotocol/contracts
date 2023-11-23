# Lists

Multiple lists are stored in the `EFPLists` contract. Each list has a nonce.

## Nonce

Nonces are claimed on a first-come-first-serve basis. The nonce is used to identify the list.

Since the `EFPLists` contract can be deployed on multiple chains, the nonce allows users to claim a list and then reference it as the list location for their EFP NFT on mainnet Ethereum. Clients can read the nonce from the list location from the EFP NFT on Ethereum, and then use that nonce to find the list on the other chains.

## Basic requirements

The basic requirement for an EFP List contract is that you can add/remove records and add/remove tags for a record.

Adding or removing a record or tag should use minimal gas.

All list operations should emit an event such that clients can reconstruct the social graph from the events.

Clients should also be able to reconstruct the social graph off-chain by calling read functions on the contract.

### Rejected design - logs only

The simplest design is to store all records and tags in logs.

This is **rejected** because it is desirable to be able to read the list via contract calls without having to reconstruct the list from logs.

### Rejected design - merkle root

We could store just the merkle root of all the records and their tags.

This is **rejected** because it would not be possible to reconstruct the social graph from the contract state.

### Rejected design - mappings

One possible design is to store "true" for a record when it is added and "false" when it is removed, with a similar pattern for tags.

This adds the advantage of being able to check if a record/tag exists in the list.

But it does not provide an iterable list of records/tags.

This is **rejected** because it is not possible to reconstruct the social graph via contract calls.

Even though a client could confirm each record/tag exists in the list, it would not be possible to know which records/tags to check without already knowing the list.

### Rejected design - doubly linked lists

We could store records in a doubly linked list.

We could pair this with a mapping of record to linked list node for quick access to the linked list node for in-place deletion.

This is **rejected** because it is not possible to support reading from the list in batches at successive offsets. This is because no indexing is maintained in a linked list and we must start traversal from the beginning. So a large list would run out of gas trying to reach the offset.

This would mean clients can't construct a social graph by reading the list in batches via contract calls from a regular Ethereum node.

### Rejected design - mapping with array (swap and pop)

To provide iteration, we can store the records/tags in an array.

To delete a record/tag, we would need to know where in the array it was previously stored, so an additional mapping is required.

When a record is to be removed, we would lookup the record index in the mapping. Then we would swap the record with the last record in the array, and pop the last record off the array.

This is **rejected** because it changes the ordering of the records in the array. This is undesirable for several reasons:

- It makes it difficult to see the order in which users followed each other. Most social networks show the most recent follows first or allow scrolling through the list of follows in reverse chronological order.
- It also makes traversal over a list inconsistent. If a client is reading a list in batches via contract calls, then the list cannot be modified while the client is reading the list. An append-only methodology is preferred.

### Rejected design - mapping with array (soft delete)

Like above, we could use an array to store the records/tags and a mapping to lookup the index of a record/tag in the array.

But instead of swapping and popping to delete (and modifying the list ordering), we could store a boolean alongside each record added to the underlying array.

When a deletion is performed on a record, we would set the boolean to false. If that record is added again, we could set the boolean to true, or we could also choose to append a new record to the array.

This is **rejected** because it obfuscates the read interface in an unintuitive manner.

Instead of being able to return an array of records, we would need to return an array of records alongside their boolean is_deleted value. Clients would need to remember to check this which could be error-prone.

Moreover, even a hypothetical getRecordCount API would be unintuitive since it would not be decremented when a deletion is performed. The objects in the array are not just list records, they're list records alongside their is_deleted value.

## Chosen design - array of list operations

The chosen design is to store an array of list operations for each list.

Rather than try to index the records and tags, we simply store the operations that were performed on the list. Each list operation is encoded as a `bytes` type so it can be packed tightly for cheap storage.

```Solidity
function applyListOp(uint nonce, bytes calldata op) public onlyListManager(nonce) {
    listOps[nonce].push(op);
    emit ListOperation(nonce, op);
}
```

The advantages of this technique are:

- It is append-only, so clients can read the list while it is being modified.
- It is gas efficient since most list operations can be packed into 32-bytes or less.
- It is fully upgradable by defining new list operations. No new contract is needed.
- It is a higher abstraction than the other designs, so it is more flexible.

The disadvantages of this technique are:

- cannot revert if duplicate records/tags are added or non-existent records/tags are removed, so clients should ignore such list ops.
- It is a higher abstraction than the other designs, which is both advantageous and disadvantageous. Instead of trying to maintain an "end state" of the list in the contract, we store the "list of operations" that were performed on the list. This is more flexible, but it is also more difficult to reason about. For instance, the contract doesn't maintain a number of records for each list or number of tags for each record. Instead, clients must reconstruct this information from the list of operations.

Generally speaking, list ops are simple and we expect clients to be able to reconstruct a social graph by decoding list ops and following contract logs without too much trouble.

## Conclusion

Overall, we believe this strategy is more intuitive, gas efficient, and flexible than the other strategies.
