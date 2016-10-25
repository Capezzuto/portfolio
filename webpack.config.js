var webpack = require('webpack');
var path = require('path');
var CompressionPlugin = require('compression-webpack-plugin');

module.exports = {
  entry: './src/index.js',
  output: {
    path: path.join(__dirname, 'dist'),
    filename: 'bundle.js'
  },
  plugins: [
    new webpack.ProvidePlugin({
      riot: 'riot'
    }),
    new CompressionPlugin({
      asset: '[path].gz[query]',
      algorithm: 'gzip',
      test: /\.js$|\.tag$|\.css$|\.scss$|\.html$|\.(png | jpg | gif | woff | otf)$/,
      threshold: 10240,
      minRatio: 0.8      
    })
  ],
  resolve: {
    modulesDirectories: ["node_modules"],
    extensions: ['', '.js', '.tag']
  },
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
