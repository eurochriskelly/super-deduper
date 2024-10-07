// CORB VARIABLES
var URI

const { documentGetCollections, documentSetCollections } = cts
const { cols } = require('../common')

const toRemove = Object.keys(cols)

Sequence.from(URI.split(';').forEach(uri => {
    const collections = Array.from(documentGetCollections(uri))
    try {
        documentSetCollections(uri, collections.filter(x => toRemove.includes(xs.string(x))))
        return `${uri},SUCCESS`
    } catch (e) {
        return `${uri},FAILURE,Could not update collections. Please investigate!`
    }
}))