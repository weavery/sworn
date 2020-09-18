# Sworn

[![Project license](https://img.shields.io/badge/license-Public%20Domain-blue.svg)](https://unlicense.org)
[![Discord](https://img.shields.io/discord/755852964513579099?label=discord)](https://discord.gg/vNF5a3M)

**Sworn** compiles [Clarity] contracts into [SmartWeave] contracts.

[![Screencast](https://asciinema.org/a/360104.svg)](https://asciinema.org/a/360104)

## Prerequisites

The following baseline tooling is required in order to build Sworn:

- [Git](https://git-scm.com/downloads)

- [OCaml](https://ocaml.org) 4.11+

- [OPAM](https://opam.ocaml.org)

- [Dune](https://dune.build)

- [Docker](https://docs.docker.com/get-docker/) (for release builds only)

We recommend you *don't* install OCaml from a package manager.

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

- [Ocolor](https://opam.ocaml.org/packages/ocolor/)
  for terminal colors

- [Sexplib](https://opam.ocaml.org/packages/sexplib/)
  for S-expression parsing

- [Wasm](https://opam.ocaml.org/packages/wasm/)
  for WebAssembly code generation

These aforementioned dependencies are best installed via OPAM:

```bash
opam install alcotest cmdliner cppo iso8601 ocolor sexplib wasm
```

## Development

```bash
alias sworn='dune exec bin/sworn/sworn.exe --'

sworn --help
```

## Installation

```bash
dune build

sudo install _build/default/bin/sworn/sworn.exe /usr/local/bin/sworn
```

[Clarity]:    https://clarity-lang.org
[SmartWeave]: https://github.com/ArweaveTeam/SmartWeave
