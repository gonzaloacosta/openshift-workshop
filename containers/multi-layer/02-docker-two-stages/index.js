const express = require('../01-docker-one-stage/node_modules/express')
const app = express()

app.get('/', (req, res) => res.send('Hello World!'))

app.listen(3000, () => {
  console.log(`Example app listening on port 3000!`)
})
