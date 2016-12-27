module.exports = {
  db: `mongodb://${process.env.db_user}:${process.env.db_pass}@${process.env.db_host}`,
  user: process.env.db_user,
  pass: process.env.db_pass
};
