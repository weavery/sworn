# Sworn

[![Project license](https://img.shields.io/badge/license-Public%20Domain-blue.svg)](https://unlicense.org)
[![Discord](https://img.shields.io/discord/755852964513579099?label=discord)](https://discord.gg/vNF5a3M)

**Sworn** compiles [Clarity] smart contracts into [SmartWeave] contracts that
run on the [Arweave] blockchain.

More specifically, the Sworn compiler, called `sworn`, parses `.clar` files and
compiles them into an equivalent SmartWeave program in the form of JavaScript
code.

Sworn also includes experimental WebAssembly contract generation, but we
recommend JavaScript output since the generated JS contracts are perfectly
human readable and thus feasible to audit.

[![Screencast](https://asciinema.org/a/360104.svg)](https://asciinema.org/a/360104)

## Installation

### Binary Downloads

The latest release binaries for macOS and Linux are available here:

- [sworn-1.0.0-macos.tar.gz](https://github.com/weavery/sworn/releases/download/1.0.0/sworn-1.0.0-macos.tar.gz)

- [sworn-1.0.0-linux.tar.gz](https://github.com/weavery/sworn/releases/download/1.0.0/sworn-1.0.0-linux.tar.gz)

To install, after downloading untar the archive and copy the binary to
`/usr/local/bin`, as follows:

#### macOS

```bash
wget https://github.com/weavery/sworn/releases/download/1.0.0/sworn-1.0.0-macos.tar.gz

tar xf sworn-1.0.0-macos.tar.gz

sudo install sworn-1.0.0-macos /usr/local/bin/sworn
```

#### Linux

```bash
wget https://github.com/weavery/sworn/releases/download/1.0.0/sworn-1.0.0-linux.tar.gz

tar xf sworn-1.0.0-linux.tar.gz

sudo install sworn-1.0.0-linux /usr/local/bin/sworn
```

### Source Code

If you wish to try out the latest and greatest Sworn, you will need to build
it from source code yourself, which entails setting up an OCaml development
environment. Reserve at least half an hour of time and
[see further down](#development) in this document for the particulars.

## Usage

To view Sworn's built-in man page that documents all command-line options, run:

```bash
sworn --help
```

![Manpage](https://github.com/weavery/sworn/blob/master/etc/manpage.jpg)

### Compiling for SmartWeave

To compile the Clarity [`counter.clar`] example contract, run:

```bash
sworn -t js counter.clar
```

The previous writes out the JavaScript program to standard output, which is
helpful during development and debugging.

However, you can alternatively specify an output file name in the usual way,
with the target type inferred from the output file extension:

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
you're certainly better off sticking with the JavaScript output. Additionally,
JavaScript contracts are human readable and thus auditable.

## Examples

### Counter Example

#### [`counter.clar`]

```scheme
(define-data-var counter int 0)

(define-read-only (get-counter)
  (ok (var-get counter)))

(define-public (increment)
  (begin
    (var-set counter (+ (var-get counter) 1))
    (ok (var-get counter))))

(define-public (decrement)
  (begin
    (var-set counter (- (var-get counter) 1))
    (ok (var-get counter))))
```

#### [`counter.js`]

```bash
sworn -t js counter.clar
```

```javascript
clarity.requireVersion("0.1")

function getCounter(state) {
  return clarity.ok(state.counter);
}

function increment(state) {
  state.counter = clarity.add(state.counter, 1);
  return {state, result: clarity.ok(state.counter)};
}

function decrement(state) {
  state.counter = clarity.sub(state.counter, 1);
  return {state, result: clarity.ok(state.counter)};
}

export function handle(state, action) {
  const input = action.input;
  if (input.function === 'getCounter') {
    return {result: getCounter(state)};
  }
  if (input.function === 'increment') {
    return increment(state);
  }
  if (input.function === 'decrement') {
    return decrement(state);
  }
  return {state};
}
```

[`counter.clar`]: https://github.com/weavery/sworn/blob/master/test/examples/counter.clar
[`counter.js`]: https://github.com/weavery/sworn/blob/master/test/examples/counter.expected

## Notes

### Notes on the JavaScript target

The generated SmartWeave code requires [Clarity.js], which implements the
necessary runtime support for Clarity's standard library.

The generated SmartWeave code may make use of JavaScript's [`BigInt`] feature
to represent 128-bit integers. All modern browsers [support this].
On the server side, Node.js 10.4+ supports `BigInt`.

[`BigInt`]:     https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/BigInt
[support this]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/BigInt#Browser_compatibility

### Mapping of Clarity types

Clarity | TypeScript | JavaScript | Notes
------- | ---------- | ---------- | -----
[`bool`](https://docs.blockstack.org/references/language-types#clarity-type-system) | `boolean` | `boolean` |
[`(buff N)`](https://docs.blockstack.org/references/language-types#clarity-type-system) | `Uint8Array` | `Uint8Array` |
[`err`](https://docs.blockstack.org/references/language-types#clarity-type-system) | `Err<T>` | `Err` |
[`int`](https://docs.blockstack.org/references/language-types#clarity-type-system) | `number` or `bigint` | `number` or `BigInt` |
[`(list N T)`](https://docs.blockstack.org/references/language-types#clarity-type-system) | `Array<T>` | `Array` |
[`(optional T)`](https://docs.blockstack.org/references/language-types#clarity-type-system) | `T` or `null` | `T` or `null` |
[`principal`](https://docs.blockstack.org/references/language-types#clarity-type-system) | `String` | `String` |
[`(response T E)`](https://docs.blockstack.org/references/language-types#clarity-type-system) | `T` or `Err<E>` | `T` or `Err` |
[`(string-ascii N)`](https://docs.blockstack.org/references/language-types#clarity-type-system) | `String` | `String` |
[`(string-utf8 N)`](https://docs.blockstack.org/references/language-types#clarity-type-system) | `String` | `String` |
[`(tuple ...)`](https://docs.blockstack.org/references/language-types#clarity-type-system) | `Map<String, any>` | `Map` |
[`uint`](https://docs.blockstack.org/references/language-types#clarity-type-system) | `number` or `bigint` | `number` or `BigInt` |

## Frequently Asked Questions

### Q: Why do arithmetic operations call Clarity.js functions?

In order to support Clarity's language semantics of 128-bit integers and safe
arithmetic that traps on numeric overflow and underflow, arithmetic operations
need runtime support. Thus, in the general case, an operation such as `(* a b)`
must be compiled to `clarity.mul(a, b)` instead of the trivial but ultimately
incorrect `a * b`.

## Design

Sworn is written in [OCaml], an excellent programming language for crafting
compiler toolchains.

Sworn is a standard multi-pass compiler consisting of the following stages:

![Flowchart](https://github.com/weavery/sworn/blob/master/etc/flowchart.png)

The Clarity parser and abstract syntax tree ([AST]) originally developed for
Sworn have been spun off into a standalone project and OCaml library called
[Clarity.ml]. This enables anyone familiar with OCaml to quickly and easily
develop more best-of-class tooling for Clarity contracts.

### Lexical analysis

See Clarity.ml's [`lexer.mll`] for the lexical analyzer source code.

[`lexer.mll`]: https://github.com/weavery/clarity.ml/blob/master/src/lexer.mll

### Syntactic analysis

See Clarity.ml's [`parser.mly`] and [`parse.ml`] for the parser source code.

[`parse.ml`]:   https://github.com/weavery/clarity.ml/blob/master/src/parse.ml
[`parser.mly`]: https://github.com/weavery/clarity.ml/blob/master/src/parser.mly

### Semantic analysis

See Clarity.ml's [`grammar.ml`] for the structure of the Clarity [AST].

[`grammar.ml`]: https://github.com/weavery/clarity.ml/blob/master/src/grammar.ml

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

The JavaScript generation is implemented using OCaml's powerful standard
[pretty-printing facility], which means that the resulting code is perfectly
human readable as well as nicely formatted. (File bug reports if you should
find this to not be the case.)

The WebAssembly generation is implemented using the [WebAssembly reference
implementation], also written in OCaml. This means that Sworn's WebAssembly
output is always up-to-date with regards to any changes and features in the
latest WebAssembly standard, as well as (by definition) 100% compliant.

[pretty-printing facility]: https://ocaml.org/learn/tutorials/format.html
[WebAssembly reference implementation]: https://github.com/WebAssembly/spec/tree/master/interpreter

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

- [Clarity.ml] for parsing Clarity code

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

- [Wasm](https://opam.ocaml.org/packages/wasm/)
  for WebAssembly code generation

These aforementioned dependencies are all best installed via OPAM:

```bash
opam install -y alcotest cmdliner cppo iso8601 num ocolor wasm
opam pin add -y clarity-lang https://github.com/weavery/clarity.ml -k git
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

We thank [Blockstack] and [Algorand] for having developed the Clarity language,
an important evolution for the future of smart contracts.

[Algorand]:       https://algorand.com
[Arweave]:        https://arweave.org
[AST]:            https://en.wikipedia.org/wiki/Abstract_syntax_tree
[Blockstack]:     https://blockstack.org
[Clarity]:        https://clarity-lang.org
[Clarity.js]:     https://github.com/weavery/clarity.js
[Clarity.ml]:     https://github.com/weavery/clarity.ml
[IR]:             https://en.wikipedia.org/wiki/Intermediate_representation
[OCaml]:          https://ocaml.org
[SmartWeave]:     https://github.com/ArweaveTeam/SmartWeave
[WebAssembly]:    https://webassembly.org

## Status

### Supported Clarity features

Feature | Type | JavaScript | WebAssembly | Notes
------- | ---- | ---------- | ----------- | -----
[`*`](https://docs.blockstack.org/references/language-functions#-multiply) | function | ✅ | ✅ |
[`+`](https://docs.blockstack.org/references/language-functions#-add) | function | ✅ | ✅ |
[`-`](https://docs.blockstack.org/references/language-functions#--subtract) | function | ✅ | ✅ |
[`/`](https://docs.blockstack.org/references/language-functions#-divide) | function | ✅ | ✅ |
[`<`](https://docs.blockstack.org/references/language-functions#-less-than) | function | ✅ | 🚧 |
[`<=`](https://docs.blockstack.org/references/language-functions#-less-than-or-equal) | function | ✅ | 🚧 |
[`>`](https://docs.blockstack.org/references/language-functions#-greater-than) | function | ✅ | 🚧 |
[`>=`](https://docs.blockstack.org/references/language-functions#-greater-than-or-equal) | function | ✅ | 🚧 |
[`and`](https://docs.blockstack.org/references/language-functions#and) | syntax | ✅ | 🚧 |
[`append`](https://docs.blockstack.org/references/language-functions#append) | function | ✅ | 🚧 |
[`as-contract`](https://docs.blockstack.org/references/language-functions#as-contract) | syntax | ✅ | 🚧 |
[`as-max-len?`](https://docs.blockstack.org/references/language-functions#as-max-len) | syntax | ✅ | 🚧 |
[`asserts!`](https://docs.blockstack.org/references/language-functions#asserts) | syntax | ✅ | 🚧 |
[`at-block`](https://docs.blockstack.org/references/language-functions#at-block) | syntax | ❌ | ❌ | Not supported by SmartWeave.
[`begin`](https://docs.blockstack.org/references/language-functions#begin) | syntax | ✅ | ✅ |
[`block-height`](https://docs.blockstack.org/references/language-keywords#block-height) | keyword | ✅ | 🚧 |
[`bool`](https://docs.blockstack.org/references/language-functions#clarity-type-system) | type | ✅ | ✅ |
[`buff`](https://docs.blockstack.org/references/language-functions#clarity-type-system) | type | ✅ | 🚧 |
[`concat`](https://docs.blockstack.org/references/language-functions#concat) | function | ✅ | 🚧 |
[`contract-call?`](https://docs.blockstack.org/references/language-functions#contract-call) | function | ❌ | ❌ | Not supported by SmartWeave.
[`contract-caller`](https://docs.blockstack.org/references/language-keywords#contract-caller) | keyword | ✅ | 🚧 |
[`contract-of`](https://docs.blockstack.org/references/language-functions#contract-of) | function | ❌ | ❌ | Not supported by SmartWeave.
[`default-to`](https://docs.blockstack.org/references/language-functions#default-to) | function | ✅ | 🚧 |
[`define-constant`](https://docs.blockstack.org/references/language-functions#define-constant) | syntax | ✅ | ✅ |
[`define-data-var`](https://docs.blockstack.org/references/language-functions#define-data-var) | syntax | ✅ | ✅ |
[`define-fungible-token`](https://docs.blockstack.org/references/language-functions#define-fungible-token) | syntax | 🚧 | 🚧 |
[`define-map`](https://docs.blockstack.org/references/language-functions#define-map) | syntax | ✅ | 🚧 |
[`define-non-fungible-token`](https://docs.blockstack.org/references/language-functions#define-non-fungible-token) | syntax | 🚧 | 🚧 |
[`define-private`](https://docs.blockstack.org/references/language-functions#define-private) | syntax | ✅ | ✅ |
[`define-public`](https://docs.blockstack.org/references/language-functions#define-public) | syntax | ✅ | ✅ |
[`define-read-only`](https://docs.blockstack.org/references/language-functions#define-read-only) | syntax | ✅ | ✅ |
[`define-trait`](https://docs.blockstack.org/references/language-functions#define-trait) | syntax | ❌ | ❌ | Not supported by SmartWeave.
[`err`](https://docs.blockstack.org/references/language-functions#err) | function | ✅ | 🚧 |
[`false`](https://docs.blockstack.org/references/language-keywords#false) | constant | ✅ | ✅ |
[`filter`](https://docs.blockstack.org/references/language-functions#filter) | function | ✅ | 🚧 |
[`fold`](https://docs.blockstack.org/references/language-functions#fold) | function | ✅ | 🚧 |
[`ft-get-balance`](https://docs.blockstack.org/references/language-functions#ft-get-balance) | function | ✅ | 🚧 |
[`ft-mint?`](https://docs.blockstack.org/references/language-functions#ft-mint) | function | ✅ | 🚧 |
[`ft-transfer?`](https://docs.blockstack.org/references/language-functions#ft-transfer) | function | ✅ | 🚧 |
[`get`](https://docs.blockstack.org/references/language-functions#get) | syntax | ✅ | 🚧 |
[`get-block-info?`](https://docs.blockstack.org/references/language-functions#get-block-info) | function | ❌ | ❌ | Not supported by SmartWeave.
[`hash160`](https://docs.blockstack.org/references/language-functions#hash160) | function | ✅ | 🚧 |
[`if`](https://docs.blockstack.org/references/language-functions#if) | syntax | ✅ | 🚧 |
[`impl-trait`](https://docs.blockstack.org/references/language-functions#impl-trait) | syntax | ❌ | ❌ | Not supported by SmartWeave.
[`int`](https://docs.blockstack.org/references/language-functions#clarity-type-system) | type | ✅ | ✅ |
[`is-eq`](https://docs.blockstack.org/references/language-functions#is-eq) | function | ✅ | 🚧 |
[`is-err`](https://docs.blockstack.org/references/language-functions#is-err) | function | ✅ | 🚧 |
[`is-none`](https://docs.blockstack.org/references/language-functions#is-none) | function | ✅ | 🚧 |
[`is-ok`](https://docs.blockstack.org/references/language-functions#is-ok) | function | ✅ | 🚧 |
[`is-some`](https://docs.blockstack.org/references/language-functions#is-some) | function | ✅ | 🚧 |
[`keccak256`](https://docs.blockstack.org/references/language-functions#keccak256) | function | ✅ | 🚧 |
[`len`](https://docs.blockstack.org/references/language-functions#len) | function | ✅ | 🚧 |
[`let`](https://docs.blockstack.org/references/language-functions#let) | syntax | ✅ | 🚧 |
[`list`](https://docs.blockstack.org/references/language-functions#clarity-type-system) | type | ✅ | 🚧 |
[`list`](https://docs.blockstack.org/references/language-functions#list) | function | ✅ | 🚧 |
[`map`](https://docs.blockstack.org/references/language-functions#map) | function | ✅ | 🚧 |
[`map-delete`](https://docs.blockstack.org/references/language-functions#map-delete) | function | ✅ | 🚧 |
[`map-get?`](https://docs.blockstack.org/references/language-functions#map-get) | function | ✅ | 🚧 |
[`map-insert`](https://docs.blockstack.org/references/language-functions#map-insert) | function | ✅ | 🚧 |
[`map-set`](https://docs.blockstack.org/references/language-functions#map-set) | function | ✅ | 🚧 |
[`match`](https://docs.blockstack.org/references/language-functions#match) | syntax | ✅ | 🚧 |
[`mod`](https://docs.blockstack.org/references/language-functions#mod) | function | ✅ | ✅ |
[`nft-get-owner?`](https://docs.blockstack.org/references/language-functions#nft-get-owner) | function | ✅ | 🚧 |
[`nft-mint?`](https://docs.blockstack.org/references/language-functions#nft-mint) | function | ✅ | 🚧 |
[`nft-transfer?`](https://docs.blockstack.org/references/language-functions#nft-transfer) | function | ✅ | 🚧 |
[`none`](https://docs.blockstack.org/references/language-keywords#none) | constant | ✅ | 🚧 |
[`not`](https://docs.blockstack.org/references/language-functions#not) | function | ✅ | 🚧 |
[`ok`](https://docs.blockstack.org/references/language-functions#ok) | function | ✅ | ✅ |
[`optional`](https://docs.blockstack.org/references/language-functions#clarity-type-system) | type | ✅ | ✅ |
[`or`](https://docs.blockstack.org/references/language-functions#or) | syntax | ✅ | 🚧 |
[`pow`](https://docs.blockstack.org/references/language-functions#pow) | function | ✅ | ✅ |
[`principal`](https://docs.blockstack.org/references/language-functions#clarity-type-system) | type | ✅ | 🚧 |
[`print`](https://docs.blockstack.org/references/language-functions#print) | function | ✅ | 🚧 |
[`response`](https://docs.blockstack.org/references/language-functions#clarity-type-system) | type | ✅ | 🚧 |
[`sha256`](https://docs.blockstack.org/references/language-functions#sha256) | function | ✅ | 🚧 |
[`sha512`](https://docs.blockstack.org/references/language-functions#sha512) | function | ✅ | 🚧 |
[`sha512/256`](https://docs.blockstack.org/references/language-functions#sha512256) | function | ✅ | 🚧 |
[`some`](https://docs.blockstack.org/references/language-functions#some) | function | ✅ | 🚧 |
[`stx-burn?`](https://docs.blockstack.org/references/language-functions#stx-burn) | function | ❌ | ❌ | Not supported by SmartWeave.
[`stx-get-balance`](https://docs.blockstack.org/references/language-functions#stx-get-balance) | function | ❌ | ❌ | Not supported by SmartWeave.
[`stx-transfer?`](https://docs.blockstack.org/references/language-functions#stx-transfer) | function | ❌ | ❌ | Not supported by SmartWeave.
[`to-int`](https://docs.blockstack.org/references/language-functions#to-int) | function | ✅ | 🚧 |
[`to-uint`](https://docs.blockstack.org/references/language-functions#to-uint) | function | ✅ | 🚧 |
[`true`](https://docs.blockstack.org/references/language-keywords#true) | constant | ✅ | ✅ |
[`try!`](https://docs.blockstack.org/references/language-functions#try) | function | ✅ | 🚧 |
[`tuple`](https://docs.blockstack.org/references/language-functions#clarity-type-system) | type | ✅ | 🚧 |
[`tx-sender`](https://docs.blockstack.org/references/language-keywords#tx-sender) | keyword | ✅ | 🚧 |
[`uint`](https://docs.blockstack.org/references/language-functions#clarity-type-system) | type | ✅ | ✅ |
[`unwrap!`](https://docs.blockstack.org/references/language-functions#unwrap) | function | ✅ | 🚧 |
[`unwrap-err!`](https://docs.blockstack.org/references/language-functions#unwrap-err) | function | ✅ | 🚧 |
[`unwrap-err-panic`](https://docs.blockstack.org/references/language-functions#unwrap-err-panic) | function | ✅ | 🚧 |
[`unwrap-panic`](https://docs.blockstack.org/references/language-functions#unwrap-panic) | function | ✅ | 🚧 |
[`use-trait`](https://docs.blockstack.org/references/language-functions#use-trait) | syntax | ❌ | ❌ | Not supported by SmartWeave.
[`var-get`](https://docs.blockstack.org/references/language-functions#var-get) | function | ✅ | ✅ |
[`var-set`](https://docs.blockstack.org/references/language-functions#var-set) | function | ✅ | ✅ |
[`xor`](https://docs.blockstack.org/references/language-functions#xor) | function | ✅ | 🚧 |

**Legend**: ❌ = not supported. 🚧 = work in progress. ✅ = supported.
