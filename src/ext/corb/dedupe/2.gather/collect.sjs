// CORB VARIABLES
var LIMIT, ENTITY

const { collections, andQuery, collectionQuery, notQuery } = cts
const { cols } = require('../common.sjs')

const setLimit = LIMIT ? +LIMIT : 100

// Collect temporal stack id's not already assigned for processing
const collected = collections(`/${ENTITY}`, `limit=${setLimit}`, andQuery([
    // todo: generalize this for more projects
    collectionQuery(cols.temporal),
    notQuery(collectionQuery(cols.assigned))
]))

console.log(`Collected are`, collected)
fn.insertBefore(collected,0,fn.count(collected))