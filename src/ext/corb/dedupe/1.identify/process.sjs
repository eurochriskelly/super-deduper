var URI, HASHTYPE

declareUpdate()

const { doc } = cts
const { hash64, documentSetCollections, documentGetMetadata, documentPutMetadata, documentGetCollections, quote } = xdmp
const { cols, props } = require('/ext/corb/dedupe/common.sjs')

const hashCalc = {
    xml: uri => hash64(quote(doc(uri).xpath('//*:instance'))),
    json: uri => hash64(JSON.stringify(doc(uri).toObject().instance))
}

// Process all URIs in the batch
Sequence.from(URI.split(';')
    .filter(x => x.trim())
    .map(uri => {
        if (documentGetMetadata(uri)[props.hash])
            return `Skipping URI [${uri}]. Already has instance hash.`
        // store the hash of the instance so we can identify duplicates
        const instanceMetaData = { [`${props.hash}`]: hashCalc[HASHTYPE](uri) }
        documentPutMetadata(uri, instanceMetaData)
        // let's not collect later (it should be resumable)
        const docCols = documentGetCollections(uri)
        documentSetCollections(uri, [...docCols, cols.identified])
        return `Processed URI [${uri}]. `
    }))