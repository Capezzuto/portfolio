const controllers = require('./boxOfficeController.js');
const router = require('express').Router();

for(const route in controllers) {
  router.route(route)
    .get(controllers[route].get);
}

module.exports = router;
