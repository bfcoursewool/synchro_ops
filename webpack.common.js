var path = require('path');
var webpack = require('webpack');
var globImporter = require('node-sass-glob-importer');
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
  plugins: [
    new ExtractTextPlugin({
      filename: 'synchro.css',
      allChunks: true
    }),
    new webpack.ProvidePlugin({
      "$":"jquery",
      "jQuery":"jquery",
      "window.jQuery":"jquery",
      "window.Tether": 'tether'
    })
  ],
  resolve : {
      alias: {
        // bind version of jquery-ui
        "jquery-ui": "jquery-ui/jquery-ui.js",      
        // bind to modules;
        modules: path.join(__dirname, "node_modules"),
      }
  },
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
        use: ExtractTextPlugin.extract([
          {
            loader: 'css-loader'
          }, {
            loader: 'sass-loader',
            options: {
              importer: globImporter()
            }
          }
        ])
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