require('dotenv').config();
const express = require('express');
const app = express();
const path = require('path');
const mongoose = require('mongoose');
const config = require('./server/config/config.js');
const boxOfficeRoutes = require('./server/boxOffice/boxOfficeRoutes');
const PORT = config.port;

let db;
mongoose.connect(config.db, (err, database) => {
  db = database;
  console.log(`connected to db at ${config.db}`);
//   const testSchema = mongoose.Schema({
//     testName: String,
//     testDate: Date
//   });
// //the _model_ name is the name of the *collection*, made lowercase and pluralized
//   let TestEntry = mongoose.model('TestEntry', testSchema);
//   TestEntry.create({
//     testName: 'test1',
//     testDate: Date.now()
//   }, function(err, doc) {
//     if (err) {
//       console.log(err);
//     } else {
//       console.log(doc);
//     }
//   })
});

require('./server/middleware')(app);

app.use('/', express.static(__dirname + '/src'));
app.use('/dist',express.static(__dirname + '/dist'));

app.use('/data/boxoffice/', boxOfficeRoutes)



app.listen(PORT, () => {
  console.log(`Listening on port ${PORT}`);
})
