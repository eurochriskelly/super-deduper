// CORB VARIABLES
var URI

declareUpdate()

const { documentDelete, documentGetMetadataValue, documentPutMetadata } = xdmp

// console.log(`Merging URIS:`)URI.split(';').forEach(x => console.log(`- ${x}`))
Sequence.from(URI.split(';').map(workInfo => {
    const [uri, operation, startTime ] = workInfo.split(',')
    switch(operation) {
        case 'remove':
            documentDelete(uri)
            return `${uri},Removed duplicate fragment.`
        case 'modify':
            const originalStartTime = documentGetMetadataValue(uri, 'startTime')
            documentPutMetadata(uri, { startTime, originalStartTime })
            return `${uri},Updated merged fragment with new startTime.`
        default:
            return `${uri},Unknown operation [${operation}]. Taking new action.`
    }
}))
