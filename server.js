var express = require('express');
var path = require('path');
var app = express();
var bodyParser = require('body-parser');

var PORT = 3000;

app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

app.use('/', express.static(__dirname + '/src'));
app.use('/dist',express.static(__dirname + '/dist'));

app.get('/data/:visId', function(req, res) {
  console.log('visId =', visId);
})

app.listen(PORT, () => {
  console.log(`Listening on port ${PORT}`);
})
