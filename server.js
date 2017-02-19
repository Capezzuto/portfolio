require('dotenv').config();
const express = require('express');
const app = express();
const bluebird = require('bluebird');
const mongoose = require('mongoose');
mongoose.Promise = bluebird;

const WeeklyBoxOffice = require('./server/boxOffice/boxOfficeWeeklyModel.js');

const redis = require('redis');
bluebird.promisifyAll(redis.RedisClient.prototype);
bluebird.promisifyAll(redis.Multi.prototype);

const cache = require('./server/redis/start-routine.js')

const config = require('./server/config/config.js');
const boxOfficeRoutes = require('./server/boxOffice/boxOfficeRoutes.js');
const PORT = config.port;

const options = { server: { socketOptions: { keepAlive: 300000, connectTimeoutMS: 30000 } },
                replset: { socketOptions: { keepAlive: 300000, connectTimeoutMS : 30000 } } };

let db, client;
mongoose.connect(config.db, (err, database) => {
  if(err) console.log('unable to connect to mongo,', err);
  db = database;
  console.log(`connected to db at ${config.db}`);

  client = redis.createClient();
  client.on('error', function(err) {
    console.log('Error in connecting to redis', err);
  });
  client.on('connect', function(response) {
    console.log('successfully connected to redis...', response);
  });
  cache.populateMenu(client)
    .then(() => {
      console.log('in cache.populateMenu')
      return cache.getLatestWeeklyBoxOffice(client);
    })
    .then(() => {
      // mongoose.disconnect();
      client.quit();
    })


})

process.on('SIGINT', function() {
  mongoose.disconnect(function(err) {
    process.exit(err ? 1 : 0);
  });
});


require('./server/middleware')(app);

app.use('/', express.static(__dirname + '/src'));
app.use('/dist',express.static(__dirname + '/dist'));

app.use('/data/boxoffice/', boxOfficeRoutes)



app.listen(PORT, () => {
  console.log(`Listening on port ${PORT}`);
  // if (config.env === 'production') process.send('ready');
})
