/**
 * Copy the following code into MarkLogic Query console 
 * and run on desired database.
 * 
 */
declareUpdate()

const { invokeFunction, documentInsert, } = xdmp
const { collectionQuery } = cts
const { cols } = require('/ext/corb/dedupe/common')
const template = (id, data = '') => ({ instance: { data } })
const testcol = '/sd/test-data'
const NUM = 80

const result = [
    // Insert some documents
    () => {
        ['test', 'test1', 'test2', 'test3', 'test4'].forEach(name => {
            [...Array(80).keys()].forEach((id, i) => {
                // temporal insert!!
                const uriCol = `/MyEnt/${name}.json`
                const uri = i ? `/MyEnt/${name}.${id}.json` : `/MyEnt/${name}.json`
                documentInsert(uri, template(id, Math.round(Math.random() * 3)), {
                    collections: [testcol, cols.temporal, uriCol]
                })
                xdmp.documentPutMetadata(uri, {
                    startTime: `0000${NUM - id}`.slice(-4),
                    endTime: `0000${(NUM - id) + 1}`.slice(-4)
                })
            })
        })
    },
    // confirm docments were created
    () => {
        return Array.from(cts.uris('', [], collectionQuery(testcol)))
    }
].map(fn => invokeFunction(fn, { isolation: 'different-transaction', transactionMode: 'update-auto-commit' }))

result