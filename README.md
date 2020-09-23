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

[`counter.clar`]: https://github.com/weavery/sworn/blob/master/etc/counter.clar

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

_(To be written.)_

### Syntactic analysis

_(To be written.)_

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

Feature | Type | JavaScript | WebAssembly | Notes
------- | ---- | ---------- | ----------- | -----
[`*`](https://docs.blockstack.org/references/language-clarity#multiply) | function | ✅ | ✅ |
[`+`](https://docs.blockstack.org/references/language-clarity#add) | function | ✅ | ✅ |
[`-`](https://docs.blockstack.org/references/language-clarity#subtract) | function | ✅ | ✅ |
[`/`](https://docs.blockstack.org/references/language-clarity#divide) | function | ✅ | ✅ |
[`<`](https://docs.blockstack.org/references/language-clarity#less-than) | function | ✅ |  |
[`<=`](https://docs.blockstack.org/references/language-clarity#less-than-or-equal) | function | ✅ |  |
[`>`](https://docs.blockstack.org/references/language-clarity#greater-than) | function | ✅ |  |
[`>=`](https://docs.blockstack.org/references/language-clarity#greater-than-or-equal) | function | ✅ |  |
[`and`](https://docs.blockstack.org/references/language-clarity#and) | syntax | ✅ |  |
[`as-contract`](https://docs.blockstack.org/references/language-clarity#as-contract) | syntax | ✅ |  | Requires Clarity.js.
[`at-block`](https://docs.blockstack.org/references/language-clarity#at-block) | syntax | ✅ |  | Requires Clarity.js.
[`begin`](https://docs.blockstack.org/references/language-clarity#begin) | syntax | ✅ | ✅ |
[`block-height`](https://docs.blockstack.org/references/language-clarity#block-height) | keyword | ✅ |  | Requires Clarity.js.
[`bool`](https://docs.blockstack.org/references/language-clarity#clarity-type-system) | type | ✅ | ✅ |
[`buff`](https://docs.blockstack.org/references/language-clarity#clarity-type-system) | type | ✅ |  |
[`contract-call?`](https://docs.blockstack.org/references/language-clarity#contract-call) | function | ✅ |  | Requires Clarity.js.
[`contract-caller`](https://docs.blockstack.org/references/language-clarity#contract-caller) | keyword | ✅ |  | Requires Clarity.js.
[`contract-of`](https://docs.blockstack.org/references/language-clarity#contract-of) | function | ✅ |  | Requires Clarity.js.
[`default-to`](https://docs.blockstack.org/references/language-clarity#default-to) | function | ✅ |  |
[`define-constant`](https://docs.blockstack.org/references/language-clarity#define-constant) | syntax | ✅ | ✅ |
[`define-data-var`](https://docs.blockstack.org/references/language-clarity#define-data-var) | syntax | ✅ | ✅ |
[`define-map`](https://docs.blockstack.org/references/language-clarity#define-map) | syntax | ✅ |  |
[`define-private`](https://docs.blockstack.org/references/language-clarity#define-private) | syntax | ✅ | ✅ |
[`define-public`](https://docs.blockstack.org/references/language-clarity#define-public) | syntax | ✅ | ✅ |
[`define-read-only`](https://docs.blockstack.org/references/language-clarity#define-read-only) | syntax | ✅ | ✅ |
[`false`](https://docs.blockstack.org/references/language-clarity#false) | constant | ✅ | ✅ |
[`ft-get-balance`](https://docs.blockstack.org/references/language-clarity#ft-get-balance) | function | ✅ |  | Requires Clarity.js.
[`ft-mint?`](https://docs.blockstack.org/references/language-clarity#ft-mint) | function | ✅ |  | Requires Clarity.js.
[`ft-transfer?`](https://docs.blockstack.org/references/language-clarity#ft-transfer) | function | ✅ |  | Requires Clarity.js.
[`get-block-info?`](https://docs.blockstack.org/references/language-clarity#get-block-info) | function | ✅ |  | Requires Clarity.js.
[`hash160`](https://docs.blockstack.org/references/language-clarity#hash160) | function | ✅ |  | Requires Clarity.js.
[`int`](https://docs.blockstack.org/references/language-clarity#clarity-type-system) | type | ✅ | ✅ |
[`is-eq`](https://docs.blockstack.org/references/language-clarity#is-eq) | function | ✅ |  |
[`is-none`](https://docs.blockstack.org/references/language-clarity#is-none) | function | ✅ |  |
[`is-some`](https://docs.blockstack.org/references/language-clarity#is-some) | function | ✅ |  |
[`keccak256`](https://docs.blockstack.org/references/language-clarity#keccak256) | function | ✅ |  | Requires Clarity.js.
[`len`](https://docs.blockstack.org/references/language-clarity#len) | function | ✅ |  |
[`list`](https://docs.blockstack.org/references/language-clarity#clarity-type-system) | type | ✅ |  |
[`list`](https://docs.blockstack.org/references/language-clarity#list) | function | ✅ |  |
[`mod`](https://docs.blockstack.org/references/language-clarity#mod) | function | ✅ | ✅ |
[`nft-get-owner?`](https://docs.blockstack.org/references/language-clarity#nft-get-owner) | function | ✅ |  | Requires Clarity.js.
[`nft-mint?`](https://docs.blockstack.org/references/language-clarity#nft-mint) | function | ✅ |  | Requires Clarity.js.
[`nft-transfer?`](https://docs.blockstack.org/references/language-clarity#nft-transfer) | function | ✅ |  | Requires Clarity.js.
[`none`](https://docs.blockstack.org/references/language-clarity#none) | constant | ✅ |  |
[`not`](https://docs.blockstack.org/references/language-clarity#not) | function | ✅ |  |
[`ok`](https://docs.blockstack.org/references/language-clarity#ok) | function | ✅ | ✅ |
[`optional`](https://docs.blockstack.org/references/language-clarity#clarity-type-system) | type | ✅ | ✅ |
[`or`](https://docs.blockstack.org/references/language-clarity#or) | syntax | ✅ |  |
[`pow`](https://docs.blockstack.org/references/language-clarity#pow) | function | ✅ | ✅ |
[`principal`](https://docs.blockstack.org/references/language-clarity#clarity-type-system) | type | ✅ |  |
[`print`](https://docs.blockstack.org/references/language-clarity#print) | function | ✅ |  |
[`response`](https://docs.blockstack.org/references/language-clarity#clarity-type-system) | type | ✅ |  |
[`sha256`](https://docs.blockstack.org/references/language-clarity#sha256) | function | ✅ |  | Requires Clarity.js.
[`sha512`](https://docs.blockstack.org/references/language-clarity#sha512) | function | ✅ |  | Requires Clarity.js.
[`sha512/256`](https://docs.blockstack.org/references/language-clarity#sha512256) | function | ✅ |  | Requires Clarity.js.
[`some`](https://docs.blockstack.org/references/language-clarity#some) | function | ✅ |  |
[`stx-burn?`](https://docs.blockstack.org/references/language-clarity#stx-burn) | function | ❎ | ❎ | Not supported.
[`stx-get-balance`](https://docs.blockstack.org/references/language-clarity#stx-get-balance) | function | ❎ | ❎ | Not supported.
[`stx-transfer?`](https://docs.blockstack.org/references/language-clarity#stx-transfer) | function | ❎ | ❎ | Not supported.
[`true`](https://docs.blockstack.org/references/language-clarity#true) | constant | ✅ | ✅ |
[`tuple`](https://docs.blockstack.org/references/language-clarity#clarity-type-system) | type | ✅ |  |
[`tx-sender`](https://docs.blockstack.org/references/language-clarity#tx-sender) | keyword | ✅ |  | Requires Clarity.js.
[`uint`](https://docs.blockstack.org/references/language-clarity#clarity-type-system) | type | ✅ | ✅ |
[`var-get`](https://docs.blockstack.org/references/language-clarity#var-get) | function | ✅ | ✅ |
[`var-set`](https://docs.blockstack.org/references/language-clarity#var-set) | function | ✅ | ✅ |
[`xor`](https://docs.blockstack.org/references/language-clarity#xor) | function | ✅ |  |
