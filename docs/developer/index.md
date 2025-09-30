---
title: Developer Overview
description: Learn about the inter-workings of Sprout.
hide:
    - footer
---

# Development Overview

Sprout is built with a **mobile first** approach using [Flutter](https://flutter.dev/) for its interfaces and a [Node.js](https://nodejs.org/en) backend.

## Environment

For development, we recommend using [VS Code](https://code.visualstudio.com/). The repository includes a [VS Code workspace file](https://github.com/cameronroudebush/sprout/blob/master/.vscode/sprout.code-workspace) that sets up recommended extensions and debug configurations. You can launch the debuggers directly from VS Code to run and debug both the Flutter frontend and Node.js backend.

## Useful Commands

To simplify common development tasks, several npm scripts have been created. These commands are run from the project's root directory.

```bash
# Build the Docker image
npm run docker:build
# Fixes code styling issues
npm run prettier:write
# Serves mkdocs locally for doc updating
npm run docs:serve
```

## Contributions

For feature requests and bug reports, please [open an issue on GitHub](https://github.com/cameronroudebush/sprout/issues). We appreciate all reports and contributions!
