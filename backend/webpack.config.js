const { gitDescribeSync } = require("git-describe");
const webpack = require("webpack");

// Determine our version
const gitInfo = gitDescribeSync();
const gitVersion = gitInfo.distance > 0 ? gitInfo.raw.replace("-dirty", "") : gitInfo.tag;

module.exports = function (options, argv) {
  const isProduction = argv.mode === "production";

  return {
    ...options,
    devServer: {
      hot: false, // Disable Hot Module Replacement (HMR)
    },
    plugins: [
      ...options.plugins,
      // Define relevant variables
      new webpack.DefinePlugin({
        APP_VERSION: JSON.stringify(gitVersion),
        IS_DEV_BUILD: !isProduction,
        SECRET_KEY: isProduction ? undefined : JSON.stringify("DEV-KEY"),
      }),
    ],
  };
};
