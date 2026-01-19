const { gitDescribeSync } = require("git-describe");
const glob = require("glob");
const webpack = require("webpack");
const path = require("path");

/** Determines the version of our app via `git-describe` */
function getVersion() {
  const gitInfo = gitDescribeSync();
  return gitInfo.distance > 0 ? gitInfo.raw.replace("-dirty", "") : gitInfo.tag;
}

module.exports = function (options, argv) {
  const isProduction = process.env.NODE_ENV === "prod";

  // Find all migration files and create entry points for them at build time.
  const migrationFiles = glob.sync("./src/database/migration/**/*.ts").reduce((acc, file) => {
    const entryName = path.relative("./src", file).replace(/\.ts$/, "");
    acc[entryName] = path.resolve(__dirname, file);
    return acc;
  }, {});

  return {
    ...options,
    output: {
      ...options.output,
      filename: "[name].js",
      library: {
        // Specify the output type so our migrations are usable during dynamic loading
        type: "commonjs2",
      },
    },
    entry: {
      main: options.entry,
      ...migrationFiles,
    },
    devServer: {
      hot: false, // Disable Hot Module Replacement (HMR)
    },
    devtool: "inline-source-map",
    plugins: [
      ...options.plugins,
      // Define relevant variables
      new webpack.DefinePlugin({
        "process.env.APP_VERSION": webpack.DefinePlugin.runtimeValue(() => JSON.stringify(getVersion())),
        "process.env.BUILD_DATE": webpack.DefinePlugin.runtimeValue(() => JSON.stringify(new Date().toISOString())),
        "process.env.IS_DEV_BUILD": !isProduction,
        "process.env.SECRET_KEY": isProduction ? undefined : JSON.stringify("DEV-KEY"),
      }),

      // Keys only used for development
      !isProduction
        ? new webpack.BannerPlugin({
            banner: `process.env.sprout_encryptionKey = ${JSON.stringify("7dcfdb8a5d3fda79627788dddb100a9d26e09150580b831d501805463d085971")};`,
            raw: true,
            entryOnly: true,
          })
        : undefined,
    ],
  };
};
