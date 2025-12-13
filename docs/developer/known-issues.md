---
title: Known Issues
description: Known issues regarding Sprout.
hide:
    - footer
---

# Known Issues

Just like every application, there's some issues that we just can't seem to fix because, normally, it's out of our hands. Below is a table of exactly that.

## Web Autofill

Some browsers that try to auto-fill with password managers may experience issues where the input flickers but nothing happens. Unfortunately, this is out of our hands and is [reported directly to the flutter developers](https://github.com/flutter/flutter/issues/127694). We'll have to wait for a result on that to see if it gets fixed.

In the meantime, we suggest using one of the [App's](../getting-started/access.md#apps) as they won't have this issue.

## Context Menu

Most platforms (IOS/Android) have their own context menus built in that have some nice features in them like translate, web search, etc. Currently we do not have the ability to revert these to use the platforms context menu. We'll keep looking to [this ticket](https://github.com/flutter/flutter/issues/107578) in the hopes that changes.
