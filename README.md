# Sworn

[![Project license](https://img.shields.io/badge/license-Public%20Domain-blue.svg)](https://unlicense.org)
[![Discord](https://img.shields.io/discord/755852964513579099?label=discord)](https://discord.gg/vNF5a3M)

**Sworn** compiles [Clarity] contracts into [SmartWeave] contracts.

[![Screencast](https://asciinema.org/a/360104.svg)](https://asciinema.org/a/360104)

*Note: Here be dragons. This is a pre-alpha, work-in-progress project.*
*Assume nothing works, and you may be pleasantly surprised on occasion.*

## Installation

We are working on building release binaries for Windows, macOS, and Linux.
They will be available here soon.

In the meantime, if you wish to try out Sworn, you will need to build it from
source code yourself, which entails setting up an OCaml development
environment.

For the impatient and adventurous, reserve at least an hour of time and see
further down in this document for the particulars.

## Usage

To view Sworn's built-in man page, just run:

```bash
sworn --help
```

### Compiling for SmartWeave

To compile the Clarity [`counter.clar`] example contract, run:

```bash
sworn -t js counter.clar
```

The previous writes out the JavaScript program to standard output, which is
helpful during development and debugging.

However, you can alternatively specify an output file name in the usual way:

```bash
sworn -o counter.js counter.clar
```

### Compiling to WebAssembly

There is preliminary and experimental support for compiling to [WebAssembly].
Both the textual representation (`.wat`) and binary bytecode (`.wasm`) format
are supported:

```bash
sworn -t wat counter.clar

sworn -o counter.wasm counter.clar
```

Note that SmartWeave itself has no WebAssembly interface as yet, so for now
you're better off sticking with the JavaScript output.

## Prerequisites

The following baseline tooling is required in order to build Sworn from source
code:

- [Git](https://git-scm.com/downloads)

- [OCaml](https://ocaml.org) 4.11+

- [OPAM](https://opam.ocaml.org)

- [Dune](https://dune.build)

- [Docker](https://docs.docker.com/get-docker/) (for release builds only)

We would recommend you *don't* install OCaml from a package manager.

Rather, [get set up with OPAM](https://opam.ocaml.org/doc/Install.html) and
then let OPAM install the correct version of OCaml as follows:

```bash
opam init -c 4.11.1        # if OPAM not yet initialized
opam switch create 4.11.1  # if OPAM already initialized
```

Once OPAM and OCaml are available, install Dune as follows:

```bash
opam install dune
```

## Dependencies

The following OCaml tools and libraries are required in order to build
Sworn:

- [Alcotest](https://opam.ocaml.org/packages/alcotest/)
  for unit tests

- [Cmdliner](https://opam.ocaml.org/packages/cmdliner/)
  for the command-line interface

- [Cppo](https://opam.ocaml.org/packages/cppo/)
  for code preprocessing

- [ISO8601](https://opam.ocaml.org/packages/ISO8601/)
  for date handling

- [Num](https://opam.ocaml.org/packages/num/)
  for 128-bit integers

- [Ocolor](https://opam.ocaml.org/packages/ocolor/)
  for terminal colors

- [Sexplib](https://opam.ocaml.org/packages/sexplib/)
  for S-expression parsing

- [Wasm](https://opam.ocaml.org/packages/wasm/)
  for WebAssembly code generation

These aforementioned dependencies are all best installed via OPAM:

```bash
opam install alcotest cmdliner cppo iso8601 num ocolor sexplib wasm
```

## Development

```bash
alias sworn='dune exec bin/sworn/sworn.exe --'

sworn --help
```

## Installation from Source Code

```bash
git clone https://github.com/weavery/sworn.git

cd sworn

dune build

sudo install _build/default/bin/sworn/sworn.exe /usr/local/bin/sworn
```

## Acknowledgments

We thank [Arweave] and [Blockstack] for sponsoring the development of Sworn,
and Blockstack and [Algorand] for having developed the Clarity language.

[Algorand]:       https://algorand.com
[Arweave]:        https://arweave.org
[Blockstack]:     https://blockstack.org
[Clarity]:        https://clarity-lang.org
[SmartWeave]:     https://github.com/ArweaveTeam/SmartWeave
[WebAssembly]:    https://webassembly.org

[`counter.clar`]: https://github.com/clarity-lang/overview/blob/master/counter.clar
