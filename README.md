# Pedestal Docs [![CI](https://github.com/pedestal/pedestal-docs/actions/workflows/ci.yml/badge.svg)](https://github.com/pedestal/pedestal-docs/actions/workflows/ci.yml)

This is an open-source repository of documentation for the
[Pedestal](https://github.com/pedestal/pedestal) libraries.

## Get Started with Pedestal

[Read Pedestal Docs](http://pedestal.io)

##  Contributing

If you wish to point out an issue in the site or propose a new page,
you can do so by filing a GitHub issue at
https://github.com/pedestal/pedestal/issues

If you wish to make a contribution (typo, modification, or new
content), see [CONTRIBUTING.md](./CONTRIBUTING.md).

## Building the Site

The site is built using [Antora](https://antora.org/).


When building locally, you will need two sibling workspaces: one for this repository, and one for the main
Pedestal source.

Retrieve the content:

* `git clone https://github.com/pedestal/pedestal-docs.git` (or your own fork)
* `git clone https://github.com/pedestal/pedestal.git` (or your own fork)
* `cd pedestal-docs`
* `script/local-build.sh`

Console output will identify the local file URL to load to see the generated site.

The script uses `watchexec` to monitor the `pedestal/docs` folders for changes and (almost instantly!)
rebuild the output documentation (you'll have to manually refresh your browser). It will also generate
desktop notifications when it runs, on supported platforms.

### Pedestal API Documentation

Pedestal API documentation should be updated after each Pedestal release; this is accomplished via
the `script/gen-api-doc.sh` script.

This generates API documentation into the `api` directory.  When deploying, the contents of
the `api` directory are merged with the generated content in `output`.

The `api` directory is tracked by Git; you should commit and push the changes to ensure that the
official CI (Continuous Integration, via a GitHub action) build generates the `pedestal.io` site using
the updated API documentation.

NOTE: May change this to a more Antora-friendly approach soon!


### Antora Notes
 
On OS X, Antora stores Git repos in `~/Library/Caches/antora/` by default.

License
-------
Copyright 2014-2023 Cognitect, Inc.

The use and distribution terms for this software are covered by the
[Eclipse Public License 1.0](http://opensource.org/licenses/eclipse-1.0)
which can be found in the file [epl-v10.html](epl-v10.html) at the root of this
distribution.

By using this software in any fashion, you are agreeing to be bound by
the terms of this license.

You must not remove this notice, or any other, from this software.
