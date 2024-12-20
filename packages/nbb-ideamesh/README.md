## Description
### For Ideamesh users

`nbb-ideamesh` provides [easy CLJS scripting on
Node.js](https://github.com/babashka/nbb) for Ideamesh. Since ideamesh is primarily
written with [ClojureScript](https://clojurescript.org/), this scripting
environment has capabilities that are not possible in any other environment. For
example, [see here](examples/#query.cljs) for a script that queries any ideamesh
graph.

### For Clojure users

`nbb-ideamesh` is a custom version of [nbb](https://github.com/babashka/nbb) that
bundles support for datascript, datascript-transit and a couple other cljs
libraries that are useful to ideamesh. A good amount of the datascript API is
available as [seen by its
tests](https://github.com/babashka/nbb-features/blob/main/test/features/datascript/test_runner.cljs).
Since nbb only loads features/libraries when they are required, users can write
datascript based CLIs without concern of loading the other libraries.

## Usage

Install `nbb-ideamesh` from npm:

`npm install @ideamesh/nbb-ideamesh -g`

Omit `-g` for a local install.

All the usage examples from https://github.com/babashka/nbb#usage apply to
`nbb-ideamesh` e.g.

```clojure
$ nbb-ideamesh -e '(+ 1 2 3)'
6
```

## Dependency Management

`nbb-ideamesh` can use libraries from both NPM and ClojureScript. For NPM
libraries,  use `package.json` like you would in a Node.js project. For
ClojureScript libraries, create a `nbb.edn` file and [install
babashka](https://github.com/babashka/babashka#installation). The two main keys
a `nbb.edn` file supports are `:deps` and `:paths`. See [babashka
docs](https://book.babashka.org/#_paths_and_deps) for more about the format of
this file and those keys. See [nbb's
docs](https://github.com/babashka/nbb#dependencies) for more info about how
nbb's dependencies generally work.

### Ideamesh as a Dependency

Ideamesh's graph parser is a ClojureScript library with npm dependencies. To use
it as a dependency requires a `nbb.edn` for the ClojureScript code and a
`package.json` for the npm dependencies. For a quickstart with these files, copy
them from the [fly.io example](examples/fly-io). Note that Ideamesh code is fetched
via git with `nbb.edn` so a specific commit and git repository can be
specified.

## Projects using nbb-ideamesh

* https://github.com/khulnasoft/ideamesh - github action to validate graph
* https://github.com/cldwalker/ideamesh-query - commandline tool
* https://github.com/khulnasoft/bb-tasks#ideameshbb-tasksnbb - bb tasks that use nbb-ideamesh
* https://github.com/dom8509/ideamesh-to-markdown - CLI to export graph to Hugo Markdown files
* https://github.com/khulnasoft/docs/tree/master/script - Scripts to query docs
* https://github.com/khulnasoft/rdf-export - github action to export graph to RDF
* For more examples see the [examples directory](examples).

## CLIs

Starting with version 1.2.168, `nbb-ideamesh` supports publishing node CLIs with
a `nbb.edn`. This means that it's possible to write a script that uses [ideamesh's
graph-parser](https://github.com/khulnasoft/ideamesh/tree/master/deps/graph-parser)
and share it with others so they can install it on their `$PATH`.

Community CLIs with a `nbb.edn`:

* [ideamesh-graph-ast](https://github.com/khulnasoft/ideamesh/tree/main/examples/from-js#graph_astmjs) - CLI to print graph's ast data
* [ideamesh-graph-validator](https://github.com/khulnasoft/ideamesh#cli) - CLI to run validations on the current graph
* [ideamesh-rdf-export](https://github.com/khulnasoft/rdf-export#cli) - CLI to export graph as RDF
* https://github.com/cldwalker/ideamesh-clis - Collection of CLIs to run on graphs
* [nbb-ideamesh-test-runner](https://github.com/khulnasoft-cldwalker/nbb-test-runner#cli) - CLI that runs
  cljs.test tests for a nbb compatible project
* [ideamesh-publish-spa](https://github.com/khulnasoft/publish-spa#cli) - CLI that publishes a graph as a
  single page app

To install or build a CLI locally, install
[babashka](https://github.com/babashka/babashka#installation) and
[clojure](https://clojure.org/guides/install_clojure).

### Install a CLI

From any script directory that has a `nbb.edn`, install CLIs on `$PATH` with
`yarn global add $PWD` or `npm i -g`. If using `yarn` and `~/.yarn/bin` is not
on `$PATH`, add it to your shell's rc file e.g. `export
PATH="$HOME/.yarn/bin:$PATH"`.

### Build a CLI

To convert a nbb-ideamesh cljs script into a CLI that others can install and use:

* Create a wrapper `.mjs` file that invokes your nbb-ideamesh cljs script.
  * Copy [the graph_ast.mjs example](examples/from-js/graph_ast.mjs) and change the cljs file inside it.
* Add a `bin` entry to `package.json` that maps your CLI name to the cljs file.

For a tutorial on doing the above, read [nbb's publish
doc](https://github.com/babashka/nbb/tree/main/doc/publish).

## Versioning

`nbb-ideamesh` follows the same versioning as `nbb`. In other words, an 0.4.0 for
`nbb-ideamesh` provides `nbb` 0.4.0 with the additional libraries.

## Contributing

Example contributions are welcome. For feature contributions, please discuss
them first as this is a low level library that will be relied on by multiple
CLIs.

## LICENSE

See LICENSE.md

## Development

These sections for those developing this project.

### QA local branch

To QA that your branch works as expected on a dependent repository e.g.
[ideamesh/graph-parser](https://github.com/khulnasoft/ideamesh/tree/master/deps/graph-parser):

* `bb release` in this repo to build a local release.
* `yarn add /path/to/nbb-ideamesh` in a dependent's repo.
* Run `yarn nbb-ideamesh FILE.cljs` to run a given file. The graph-parser can confirm all it's namespaces load nbb-ideamesh with `bb test:load-all-namespaces-with-nbb`.

### Release process

Steps to publish a new npm package:

1. Update CHANGELOG.md if anything specific to nbb-ideamesh has been updated.
2. Update nbb with `bb update-nbb` on https://github.com/babashka/nbb-features and confirm CI passes.
  * This is done to confirm that datascript and datascript-transit tests pass.
3. Update nbb with `bb update-nbb` on this repo and confirm CI passes.
  * This is done to run the test suite passes which includes cljs-time tests.
4. Run `bb publish X.Y.Z` where X.Y.Z is the version to publish. Push to github to publish.
