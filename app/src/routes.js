const routes = require('express').Router();
//const { initDatabase, getSubscribers, addSubscriber } = require('./controllers/controllers')

routes.get('/', (req, res) => {
    return res.send(`Hello World! ${new Date()}`)
})

// routes.get('/init', initDatabase);
module.exports = routes;