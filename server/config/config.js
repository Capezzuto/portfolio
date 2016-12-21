const config = {
    dev: 'development',
    test: 'test',
    prod: 'production',
    port: process.env.PORT || 3000
}

process.env.NODE_ENV = process.env.NODE_ENV || config.dev;
config.env = process.env.NODE_ENV;

let envconfig;

try {
  envconfig = require(`./${config.env}`);
  envconfig = envconfig || {};
} catch(err) {
  envconfig = {};
}

module.exports = Object.assign(config, envconfig);
