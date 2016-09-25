var webpack = require('webpack');
var path = require('path');

module.exports = {
  entry: './app/index',
  output: {
    path: path.join(__dirname, 'dist'),
    filename: 'bundle.js'
  },
  plugins: [
    new webpack.ProvidePlugin({
      riot: 'riot'
    })
  ],
  module: {
    preLoaders: [
      { test: /\.tag$/, exclude: /node_modules/, loader: 'riotjs-loader', query: { type: 'none' } }
    ],
    loaders: [
      { test: /\.js$|\.tag$/, exclude: /node_modules/, loader: 'babel-loader' },
      { test: /\.scss$/, exclude: /node_modules/, loader: 'style-loader!css-loader!sass-loader' },
      { test: /\.(png | jpg | gif | woff | otf)$/, exclude: /node_modules/, loader: 'url-loader?limit=10000' }
    ]
  },
  devServer: {
    contentBase: './public'
  }
};
