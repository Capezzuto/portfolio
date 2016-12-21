const mongoose = require('mongoose');

const weeklyBoxSchema = mongoose.Schema({
  week: String,
  movies: [{
    rank: Number,
    prev_rank: Number,
    title: { type: String, required: true, trim: true },
    studio: String,
    week_gross: Number,
    pct_change: Number,
    theaters: Number,
    theater_change: Number,
    avg: Number,
    total: Number,
    budget: Number,
    week: Number
  }],
  total_gross: Number
});

module.exports = mongoose.model('boxoffice_weekly', weeklyBoxSchema);
