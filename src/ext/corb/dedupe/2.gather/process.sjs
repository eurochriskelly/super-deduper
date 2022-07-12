/**
 * Gather a work list based on ordered temporal stacks
 * 
 */

// CORB VARIABLES
var URI

// Update collections so we can keep track of what's already been done for subsequent step
declareUpdate() 

const { uris, collectionQuery } = cts
const { documentGetMetadata, documentAddCollections } = xdmp
const { cols, props } = require('../common')

const byStartTime = (a, b) => a.startTime > b.startTime ? -1 : a.startTime < b.startTime ? 1 : 0

let uniqId = -1 // index of the next document with unique hash found
const workList = []

URI.split(';') // processes main uris for temporal stacks
    .map(headUri => Array.from(uris('', [], collectionQuery(headUri))) // short [10 -> 100] list of URIs
        .map(uri => ({ uri, ...documentGetMetadata(uri) }))
        .sort(byStartTime)
        .map((data, i, lst) => {
            const { uri, startTime } = data
            documentAddCollections(uri, [cols.assigned])
            const isNew = !(i && lst[i - 1][props.hash] === data[props.hash])
            if (isNew) uniqId = i
            const isLastDupe = i < lst.length - 1 ? lst[i + 1][props.hash] !== data[props.hash] : true
            const isOnlyChild = isLastDupe && isNew
            workList.push({
                uri,
                startTime,
                operation: (() => {
                    if (isOnlyChild) return null
                    if (isNew) return 'modify'
                    if (isLastDupe) {
                        workList[uniqId].oldStartTime = workList[uniqId].startTime
                        workList[uniqId].startTime = data.startTime
                        return 'remove'
                    }
                    return 'remove'
                })(),
                _: {
                    isNew, isLastDupe, hash: data[props.hash], oldStartTime: data.oldStartTime
                }
            })
        }))
    

Sequence.from(workList
    .filter(x => x.operation)
    .map(x => `${x.uri},${x.operation},${x.operation === 'modify' ? x.startTime : ''},${x.oldStartTime || x.startTime},${x._.hash}`))
