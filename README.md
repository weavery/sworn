# Sworn

[![Project license](https://img.shields.io/badge/license-Public%20Domain-blue.svg)](https://unlicense.org)
[![Discord](https://img.shields.io/discord/755852964513579099?label=discord)](https://discord.gg/vNF5a3M)

**Sworn** compiles [Clarity] smart contracts into [SmartWeave] contracts.

[![Screencast](https://asciinema.org/a/360104.svg)](https://asciinema.org/a/360104)

*Note: Here be dragons. This is a pre-alpha, [work-in-progress](#status)
project. Assume nothing works, and you may be pleasantly surprised on
occasion.*

## Installation

We are working on building release binaries for Windows, macOS, and Linux.
They will be available here soon.

In the meantime, if you wish to try out Sworn, you will need to build it from
source code yourself, which entails setting up an OCaml development
environment.

For the impatient and adventurous, reserve at least an hour of time and
[see further down](#development) in this document for the particulars.

## Usage

To view Sworn's built-in man page that documents all command-line options, run:

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

[`counter.clar`]: https://github.com/clarity-lang/overview/blob/master/counter.clar

### Compiling to WebAssembly

There is preliminary and experimental support for compiling to [WebAssembly].
Both the textual representation (`.wat`) and binary bytecode (`.wasm`) format
are supported as targets:

```bash
sworn -t wat counter.clar

sworn -o counter.wasm counter.clar
```

Note that SmartWeave itself has no WebAssembly interface as yet, so for now
you're better off sticking with the JavaScript output.

## Notes

### Notes on the JavaScript target

The generated SmartWeave code may make use of JavaScript's [`BigInt`] feature
to represent 128-bit integers. All modern browsers [support this].
On the server side, Node.js 10.4+ supports `BigInt`.

[`BigInt`]:     https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/BigInt
[support this]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/BigInt#Browser_compatibility

## Design

Sworn is written in [OCaml], an excellent programming language for crafting
compiler toolchains.

Sworn is a multi-pass compiler consisting of the following stages:

![Flowchart](https://github.com/weavery/sworn/blob/master/etc/flowchart.png)

### Lexical analysis

### Syntactic analysis

### Semantic analysis

(See [`Clarity/grammar.ml`] for the structure of the Clarity [AST].)

[`Clarity/grammar.ml`]: https://github.com/weavery/sworn/blob/master/lib/Clarity/grammar.ml

### Intermediate representation

Sworn converts Clarity code into an intermediate representation ([IR]) called
SWIR, standing for SmartWeave Intermediate Representation. (See
[`SWIR/grammar.ml`] for the structure of SWIR.)

Currently, SWIR is very similar to the Clarity AST. However, the Clarity to
SWIR conversion stage is nonetheless needed for several reasons:

1. The Clarity language doesn't yet have a stable specification, and it's
   easier to keep up with language changes upstream if they only require
   changes to the compiler frontend instead of throughout the compiler.

2. SWIR facilitates essential optimizations, such as avoiding unnecessary code
   generation of relatively expensive 128-bit arithmetic operations in cases
   where the compiler can prove that 64-bit arithmetic will be safe.

3. SWIR facilitates code generation for multiple targets such as JavaScript and
   WebAssembly.

4. Sworn will in the future endeavor to support other input languages beyond
   Clarity, which will in any case necessitate an IR.

[`SWIR/grammar.ml`]: https://github.com/weavery/sworn/blob/master/lib/SWIR/grammar.ml

### Code generation

SWIR is converted into either JavaScript or WebAssembly's [AST], which can be
serialized in binary or text formats.

## Development

This section documents how to get set up with a development environment for
building Sworn from source code. It is only of interest to people who wish to
contribute to Sworn.

### Prerequisites

The following baseline tooling is required in order to build Sworn from source
code:

- [Git](https://git-scm.com/downloads)

- [OCaml] 4.11+

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

### Dependencies

The following OCaml tools and libraries are required in order to build
Sworn from source code:

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

### Running the program

```bash
alias sworn='dune exec bin/sworn/sworn.exe --'

sworn --help
```

### Installing from source code

```bash
git clone https://github.com/weavery/sworn.git

cd sworn

dune build

sudo install _build/default/bin/sworn/sworn.exe /usr/local/bin/sworn
```

## Acknowledgments

We thank [Arweave] and [Blockstack] for sponsoring the development of Sworn.

We thank Blockstack and [Algorand] for having developed the Clarity language,
an important evolution for the future of smart contracts.

[Algorand]:       https://algorand.com
[Arweave]:        https://arweave.org
[AST]:            https://en.wikipedia.org/wiki/Abstract_syntax_tree
[Blockstack]:     https://blockstack.org
[Clarity]:        https://clarity-lang.org
[IR]:             https://en.wikipedia.org/wiki/Intermediate_representation
[OCaml]:          https://ocaml.org
[SmartWeave]:     https://github.com/ArweaveTeam/SmartWeave
[WebAssembly]:    https://webassembly.org

## Status

### Supported Clarity features

Feature | Type | JavaScript | WebAssembly
------- | ---- | ---------- | -----------
`*` | function | ✅ | ✅
`+` | function | ✅ | ✅
`-` | function | ✅ | ✅
`/` | function | ✅ | ✅
`<` | function | ✅ |
`<=` | function | ✅ |
`>` | function | ✅ |
`>=` | function | ✅ |
`and` | syntax | ✅ |
`begin` | syntax | ✅ | ✅
`bool` | type | ✅ | ✅
`default-to` | function | ✅ |
`define-constant` | syntax | ✅ | ✅
`define-data-var` | syntax | ✅ | ✅
`define-map` | syntax | ✅ |
`define-private` | syntax | ✅ | ✅
`define-public` | syntax | ✅ | ✅
`define-read-only` | syntax | ✅ | ✅
`int` | type | ✅ | ✅
`is-eq` | function | ✅ |
`is-none` | function | ✅ |
`is-some` | function | ✅ |
`len` | function | ✅ |
`list` | type | ✅ |
`list` | function | ✅ |
`mod` | function | ✅ | ✅
`none` | constant | ✅ |
`not` | function | ✅ |
`ok` | function | ✅ | ✅
`optional` | type | ✅ | ✅
`or` | syntax | ✅ |
`pow` | function | ✅ | ✅
`print` | function | ✅ |
`some` | function | ✅ |
`uint` | type | ✅ | ✅
`var-get` | function | ✅ | ✅
`var-set` | function | ✅ | ✅
`xor` | function | ✅ |
