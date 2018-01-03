var path = require('path');
var webpack = require('webpack');

module.exports = {
  entry: {
    polyfill: 'babel-polyfill',
    gold: __dirname + '/synchro_app/synchro/frontend_source/synchro.js'
  },
  output: {
    filename: 'synchro.js',
    path: __dirname + '/synchro_app/synchro/frontend_build'
  },
  devtool: 'source-map',
  module: {
    loaders: [
      {
        test: /\.js$/,
        include: path.join(__dirname, 'synchro_app/synchro/frontend_source'),
        loader: 'babel-loader',
        query: {
          presets: ["es2015"],  
        }
      }
    ]
  },
  debug: true
};
