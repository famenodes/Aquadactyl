const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const authRoutes = require('./routes/auth');

const app = express();

mongoose.connect('mongodb://localhost:27017/aquadactyl', { useNewUrlParser: true, useUnifiedTopology: true });

app.use(bodyParser.json());
app.use(express.static('client'));

app.use('/auth', authRoutes);

app.listen(3000, () => {
    console.log('Server is running on http://localhost:3000');
});
