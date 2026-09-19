import { before as swaggerBefore } from "@nestjs/swagger/plugin";
import { defineConfig } from "@rspack/cli";
import { rspack } from "@rspack/core";
import pkg from "git-describe";
import { glob } from "glob";
import path from "node:path";

/** Determines the version of our app via `git-describe` */
function getVersion() {
  const { gitDescribeSync } = pkg;
  const gitInfo = gitDescribeSync();
  return gitInfo.distance && gitInfo.distance > 0 ? gitInfo.raw.replace("-dirty", "") : gitInfo.tag;
}

export default defineConfig((options) => {
  const isProduction = process.env.NODE_ENV === "prod";

  // Find all migration files and create entry points for them at build time.
  const migrationFiles = glob.sync("./src/database/migration/**/*.ts").reduce((acc, file) => {
    const entryName = path.relative("./src", file).replace(/\.ts$/, "");
    acc[entryName] = path.resolve(import.meta.dirname, file);
    return acc;
  }, {});

  return {
    target: "node",
    node: {
      __dirname: false,
      __filename: false,
    },
    // Keep native modules external
    externals: ["better-sqlite3", "bcrypt"],
    externalsPresets: {
      node: true,
    },
    entry: {
      main: options.entry || "./src/main.ts",
      ...migrationFiles,
    },
    output: {
      path: path.resolve(import.meta.dirname, "dist"),
      filename: "[name].js",
      module: true,
      chunkFormat: "module",
      library: {
        type: "module",
      },
      sourceRoot: "",
      devtoolModuleFilenameTemplate: (info) => {
        return path.resolve(info.absoluteResourcePath).replace(/\\/g, "/");
      },
      devtoolFallbackModuleFilenameTemplate: (info) => {
        return path.resolve(info.absoluteResourcePath).replace(/\\/g, "/");
      },
    },
    devtool: "source-map",
    module: {
      rules: [
        {
          test: /\.tsx?$/,
          exclude: /node_modules/,
          use: [
            {
              // ts-loader is slow but required so we have proper metadata for nestjs' swagger plugin
              loader: "ts-loader",
              options: {
                transpileOnly: false,
                configFile: path.resolve(import.meta.dirname, "tsconfig.build.json"),
                getCustomTransformers: (program) => ({
                  before: [
                    swaggerBefore(
                      {
                        dtoFileNameSuffix: [".dto.ts", ".model.ts", ".type.ts"],
                        introspectComments: true,
                        esmCompatible: true,
                      },
                      program,
                    ),
                  ],
                }),
              },
            },
          ],
        },
        {
          test: /\.tsx?$/,
          include: /node_modules/,
          use: [
            {
              loader: "builtin:swc-loader",
              options: {
                jsc: {
                  parser: {
                    syntax: "typescript",
                  },
                },
              },
            },
          ],
        },
        {
          test: /\.node$/,
          use: "node-loader",
        },
        {
          test: /\.sql$/,
          type: "asset/source",
        },
      ],
    },
    optimization: {
      minimizer: [
        new rspack.SwcJsMinimizerRspackPlugin({
          minimizerOptions: {
            compress: {
              keep_classnames: true,
              keep_fnames: true,
            },
            mangle: {
              keep_classnames: true,
              keep_fnames: true,
            },
          },
        }),
      ],
    },
    plugins: [
      new rspack.IgnorePlugin({
        checkResource(resource) {
          return /@nestjs\/(microservices|websockets)/.test(resource) || resource === "cache-manager/package.json";
        },
      }),
      new rspack.CircularCheckRspackPlugin({
        failOnError: true,
        exclude: /node_modules/,
      }),
      new rspack.BannerPlugin({
        banner: `import { fileURLToPath as __fileURLToPath } from 'node:url';import { dirname as __pathDirname } from 'node:path';const __filename = __fileURLToPath(import.meta.url);const __dirname = __pathDirname(__filename);`,
        raw: true,
        entryOnly: false,
      }),
      new rspack.CopyRspackPlugin({
        patterns: [
          {
            from: path.resolve("src", "email", "templates"),
            to: "templates",
          },
          {
            from: "**/*.sql",
            context: path.resolve(import.meta.dirname, "src"),
            noErrorOnMissing: true,
          },
        ],
      }),
      new rspack.DefinePlugin({
        "process.env.APP_VERSION": JSON.stringify(getVersion()),
        "process.env.BUILD_DATE": JSON.stringify(new Date().toISOString()),
        "process.env.IS_DEV_BUILD": !isProduction,
        "process.env.SECRET_KEY": isProduction ? undefined : JSON.stringify("DEV-KEY"),
      }),
      !isProduction
        ? new rspack.BannerPlugin({
            banner: `process.env.sprout_encryptionKey = process.env.sprout_encryptionKey || ${JSON.stringify("7dcfdb8a5d3fda79627788dddb100a9d26e09150580b831d501805463d085971")};`,
            raw: true,
            entryOnly: true,
          })
        : undefined,
    ].filter(Boolean),
  };
});
