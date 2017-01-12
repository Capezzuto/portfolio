const mongoose = require('mongoose');

const dailyBoxSchema = mongoose.Schema({
  date: Date,
  week: String,
  top10: [{
    rank_today: Number,
    rank_yesterday: Number,
    title: { type: String, required: true, trim: true },
    studio: String,
    daily_gross: Number,
    pct_change_yd: Number,
    pct_change_lw: Number,
    theaters: Number,
    avg: Number,
    total: Number,
    day: Number
  }]
});

module.exports = mongoose.model('boxoffice_daily', dailyBoxSchema);
