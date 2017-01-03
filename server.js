require('dotenv').config();
const express = require('express');
const app = express();
const path = require('path');
const mongoose = require('mongoose');
mongoose.Promise = global.Promise;
const config = require('./server/config/config.js');
const boxOfficeRoutes = require('./server/boxOffice/boxOfficeRoutes.js');
const PORT = config.port;

var options = { server: { socketOptions: { keepAlive: 300000, connectTimeoutMS: 30000 } },
                replset: { socketOptions: { keepAlive: 300000, connectTimeoutMS : 30000 } } };

let db;
mongoose.connect(config.db, (err, database) => {
  if(err) console.log('unable to connect to mongo,', err);
  db = database;
  console.log(`connected to db at ${config.db}`);
})

process.on('SIGINT', function() {
  console.log('SIGINT ALERT');
  mongoose.disconnect(function(err) {
    process.exit(err ? 1 : 0);
  });
})

require('./server/middleware')(app);

app.use('/', express.static(__dirname + '/src'));
app.use('/dist',express.static(__dirname + '/dist'));

app.use('/data/boxoffice/', boxOfficeRoutes)



app.listen(PORT, () => {
  console.log(`Listening on port ${PORT}`);
  if (config.env === 'production') process.send('ready');
})
