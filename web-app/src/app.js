const express = require('express');
const mongoose = require('mongoose');
const userRoutes = require('./routes/userRoutes');

const app = express();
const port = process.env.PORT || 3000;

// Database connection
const DB_HOST = process.env.DB_HOST || 'localhost';
const DB_PORT = process.env.DB_PORT || '27017';
const DB_NAME = process.env.DB_NAME || 'mydatabase';

mongoose.connect(`mongodb://${DB_HOST}:${DB_PORT}/${DB_NAME}`, { useNewUrlParser: true, useUnifiedTopology: true })
  .then(() => console.log('Connected to MongoDB'))
  .catch(err => console.error('Could not connect to MongoDB', err));

app.use(express.json());

// Routes
app.use('/api/users', userRoutes);

app.get('/', (req, res) => {
  res.send('Hello World from web-app!');
});

app.listen(port, () => {
  console.log(`Web-app listening on port ${port}`);
});
