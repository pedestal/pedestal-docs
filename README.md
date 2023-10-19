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

## Setup

The site is built using [Antora](https://antora.org/).

* You must have a recent version of [NodeJS](https://nodejs.org/)
* You need the  [watchexec command](https://github.com/watchexec/watchexec); on OS X: `brew install watchexec`
* Finally, a local install of Antora: `npm install` will download Antora and its dependencies

## Building the Site

When building locally, you will need two sibling workspaces: one for this repository, and one for the main
Pedestal source.

Retrieve the content:

* `git clone https://github.com/pedestal/pedestal-docs.git` (or your own fork)
* `git clone https://github.com/pedestal/pedestal.git` (or your own fork)
* `cd pedestal-docs`
* `script/local-build.sh`

Console output will identify the local file URL to load to see the generated site.

The `local-build.sh` script uses `watchexec` to monitor the `pedestal/docs` folders for changes and (almost instantly!)
rebuild the output documentation (you'll have to manually refresh your browser). It will also generate
desktop notifications when it runs, on supported platforms.

CAUTION: Working inside NuBank will screw up `package-lock.json` file, polluting it with references to NuBank's internal repository; 
`package-lock.json` has been temporarily added to `.gitignore` until we work out a better approach.

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

Be careful to keep `antora-playbook.yml` and `local-antora-playbook.yml` in sync.

We are currently using the default Antora UI, with overrides in the `ui-overrides` directory.

We (at least temporarily) added `package-lock.json` to `.gitignore`, as it kept getting filled up
with NuBank-specific URLs; this adds some risk that the environment for the GitHub action that does
the publishing will drift from local.

Some old directories from the jBake build are still present, such as `content`, `assets`,
and `templates`.  They are being kept for reference as UI updates to the Antora-generated
site continue.

Publishing of the site is currently to http://pedestal.io/antora/pedestal/0.7-pre/index.html (note the `antora` directory), to keep the current (jBake-generated) site stable.

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
