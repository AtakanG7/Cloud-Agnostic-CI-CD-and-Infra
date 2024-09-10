const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  username: { type: String, required: true, unique: true },
  email: { type: String, required: true, unique: true },
  createdAt: { type: Date, default: Date.now }
});

const User = mongoose.model('User', userSchema);

try {
  User.create({
    username: 'dummy111',
    email: 'dumm112y@dummy.com'
  }, (err, user) => {
    if (err) {
      console.error('Error creating dummy user:', err);
    }
  });
} catch (error) {
  console.error('Error while creating dummy user:', error);
}

module.exports = mongoose.model('User', userSchema);
