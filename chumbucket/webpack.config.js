const path = require("path");
const webpack = require("webpack");

module.exports = {
  entry: "./src/index.ts",
  devtool: "source-map",
  output: {
    path: path.resolve(__dirname, "dist"),
    publicPath: "/",
    filename: '[name].bundle.js',
  },
  resolve: {
    extensions: [".ts", ".tsx", ".js", ".json", ".mjs"],
    mainFields: ['browser', 'main', 'module'],
    modules: ["node_modules", path.resolve(__dirname, 'src'), "types"],
  },
  module: {
    rules: [
      {test: /\.tsx?$/, loader: "awesome-typescript-loader"},
      {enforce: "pre", test: /\.js$/, loader: "source-map-loader"}
    ]
  },
  plugins: [
    new webpack.HotModuleReplacementPlugin()
  ],
  devServer: {
    hot:true,
    historyApiFallback: true,
    disableHostCheck: true
  },
};
