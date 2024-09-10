const User = require('../models/userModel');

exports.getUsers = async (req, res) => {
  try {
    const users = await User.find();
    res.render('users', {
      title: 'Users',
      users
    });
  } catch (error) {
    res.status(500).send(error);
  }
};
