// CORB VARIABLES
var LIMIT, ENTITY

const { collections, andQuery, collectionQuery, notQuery } = cts
const { cols } = require('../common.sjs')

const setLimit = LIMIT ? +LIMIT : 100

// Collect temporal stack id's not already assigned for processing
const collected = collections(`/${ENTITY}`, `limit=${setLimit}`, andQuery([
    // todo: Further generalize this script to adapt to different scenarios
    collectionQuery(cols.temporal),
    notQuery(collectionQuery(cols.assigned))
]))

fn.insertBefore(collected,0,fn.count(collected))
