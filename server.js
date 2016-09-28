var express = require('express');
var path = require('path');
var app = express();

var PORT = 3000;

app.use('/', express.static(__dirname + '/src'));
app.use('/dist',express.static(__dirname + '/dist'));

app.listen(PORT, () => {
  console.log(`Listening on port ${PORT}`);
})
