var express = require('express')
var app = express()
var child_process = require('child_process')

app.get('/', function (req, res) {
  const process = child_process.spawn("xclock")
  process.kill('SIGKILL') 
  res.send('Hello World!')
})

var server = app.listen(process.env.PORT || 3000, function () {
  var host = server.address().address
  var port = server.address().port
  console.log('App listening at http://%s:%s', host, port)
})
