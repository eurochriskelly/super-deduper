// CORB VARIABLES
var LIMIT, EXTRA_COLLECTIONS = ''

const { uris, andQuery, collectionQuery, notQuery } = cts
const { cols } = require('/ext/corb/dedupe/common.sjs')

const useLimit = LIMIT ? +LIMIT : 10
const collected = fn.subsequence(uris(null, null, andQuery([
    [
        cols.temporal,
        ...EXTRA_COLLECTIONS.split(',')
    ].filter(x => x.trim()).map(c => collectionQuery(c)),
    notQuery(collectionQuery(cols.identified))
])), 1, useLimit)

fn.insertBefore(collected,0,fn.count(collected))