var path = require('path');
var webpack = require('webpack');

module.exports = {
  entry: {
    polyfill: 'babel-polyfill',
    gold: './synchro_app/synchro/frontend_src/gold.js'
  },
  output: {
      publicPath: '/',
      filename: 'main.js'
  },
  devtool: 'source-map',
  module: {
    loaders: [
      {
        test: /\.js$/,
        include: path.join(__dirname, 'src'),
        loader: 'babel-loader',
        query: {
          presets: ["es2015"],  
        }
      }
    ]
  },
  debug: true
};
