const path = require('path');
const HtmlWebPackPlugin = require('html-webpack-plugin');
const CopyPlugin = require('copy-webpack-plugin');

module.exports = {
  entry: './src/index.js',
  devtool: 'inline-source-map',
  devServer: {
    liveReload: true,
    hot: true,
    contentBase: path.resolve(__dirname, './dist'),
    compress: true,
  },
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'bundle.js'
  },
  module: {
    rules: [
      {
        test: /\.s[ac]ss$/i,
        use: [
          'style-loader',
          {
            loader: 'css-loader',
            options: {
              sourceMap: true,
            },
          },
          'resolve-url-loader',
          {
            loader: 'sass-loader',
            options: {
              sourceMap: true,
            }
          },
        ],
      },
      {
        test: /\.css$/i,
        use: [
          'style-loader',
          {
            loader: 'css-loader',
            options: {
              sourceMap: true,
            },
          },
        ],
      },
      {
        test: /\.(png|svg|jpg|jpeg|gif)$/i,
        type: 'asset/resource',
      },
      {
        test: /\.m?js$/,
        exclude: /(node_modules|bower_components)/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['@babel/preset-env']
          }
        }
      },
      {
        test: /\.(woff|woff2|ttf|eot|gif)$/i,
        type: 'asset/resource',
      },
    ],
  },
  plugins: [
    new HtmlWebPackPlugin({
      filename: 'index.html',
      template: './src/index.html'
    }),
    new CopyPlugin({
      patterns: [{
        from: 'src/images',
        to: 'images'
      }]
    }),
  ],
  resolve: {
    alias: {
      // Ensure the right Vue build is used
      'vue$': path.resolve(__dirname, 'node_modules/vue/dist/vue.esm-browser.js'),
    }
  }
};
