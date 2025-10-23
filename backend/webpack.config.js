const { gitDescribeSync } = require("git-describe");
const webpack = require("webpack");

/** Determines the version of our app via `git-describe` */
function getVersion() {
  const gitInfo = gitDescribeSync();
  return gitInfo.distance > 0 ? gitInfo.raw.replace("-dirty", "") : gitInfo.tag;
}

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
        APP_VERSION: webpack.DefinePlugin.runtimeValue(() => JSON.stringify(getVersion())),
        BUILD_DATE: webpack.DefinePlugin.runtimeValue(() => JSON.stringify(new Date().toISOString())),
        IS_DEV_BUILD: !isProduction,
        SECRET_KEY: isProduction ? undefined : JSON.stringify("DEV-KEY"),
      }),
    ],
  };
};
