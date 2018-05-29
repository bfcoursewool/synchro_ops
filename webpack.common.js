var path = require('path');
var webpack = require('webpack');
var ExtractTextPlugin = require('extract-text-webpack-plugin');

module.exports = {
  context: path.resolve(__dirname, './synchro_app/synchro/frontend_source'),
  entry: {
    synchro: './synchro.js',
  },
  output: {
    path: path.resolve(__dirname, './synchro_app/synchro/static'),
    filename: '[name].bundle.js',
  },
 // plugins: [
 //   new ExtractTextPlugin({
 //     filename: 'skinmotion.css',
 //     allChunks: true
 //   })
 // ],
  module: {
    rules: [
      {
        test: /\.js$/,
        include: path.join(__dirname, './synchro_app/synchro/frontend_source'),
        use: [{
          loader: 'babel-loader',
          options: {
            cacheDirectory: true
          }
        }]
      },
      {
        test: /\.scss$/,
        use: ExtractTextPlugin.extract({
          loader: 'css-loader!sass-loader'
        })
      },
      {
        test: /\.css$/,
        use: [ 'style-loader', 'css-loader' ]
      }
    ]
  },
  watchOptions: {
    poll: true
  }
};