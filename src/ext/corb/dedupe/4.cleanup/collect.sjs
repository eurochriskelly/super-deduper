// CORB VARIABLES
var LIMIT, KEEP_COLLECTIONS

// Collect any uris with the collections we use for managing the process
// e.g. /dedupe/assigned, /dedupe/processed
// These additional collections (can) be removed in this step unless KEEP_COLLECTIONS is 'true'

const { uris, orQuery, collectionQuery } = cts
const { cols } = require('/ext/corb/dedupe/common.sjs')

if (KEEP_COLLECTIONS) {
    Sequence.from([0, Sequence.from([])])
} else {
    const useLimit = LIMIT ? +LIMIT : 10
    const collected = fn.subsequence(uris(null, null, orQuery([
        [
            cols.assigned,
            cols.processed,
            cols.identified
        ].map(c => collectionQuery(c)),
    ])), 1, useLimit)
    fn.insertBefore(collected,0,fn.count(collected))
}