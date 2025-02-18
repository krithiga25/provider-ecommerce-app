const express = require('express');

const body_parser = require('body-parser');

const userRouter = require('./routes/users_routes');

const app = express();

// after connecting to the mongo db,
// and then run the POST command with the email id and password from the extension of .router file. 
//app.use(body_parser.json());

//app.use('/', userRouter);

module.exports = app;