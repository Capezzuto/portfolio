var fs = require('fs');
console.log('CROOOOOOOOOON!');
console.log(process.env.NODE_ENV);
var dateString = Date.now().toString();
fs.writeFile('cronout.txt', process.env.NODE_ENV + ' ' + dateString, 'utf8');
