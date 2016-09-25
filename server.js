var express = require('express');
var path = require('path');
var app = express();

var PORT = 3000;
app.get('/', (req, res) => {
  res.send(path.resolve('index.html'));
})

app.listen(PORT, () => {
  console.log(`Listening on port ${PORT}`);
})
