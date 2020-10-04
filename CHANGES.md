# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.4.0] - 2020-10-05

### Added

- Support for Clarity keywords such as `block-height`.
- Support for `as-max-len?`.
- Support for `asserts!`.

## [0.3.0] - 2020-09-29

### Changed

- Rewrote the Clarity parser to support more of the syntax.
- The JavaScript target now requires [Clarity.js].

[Clarity.js]: https://github.com/weavery/clarity.js

### Added

- Support for the `buff`, `principal`, `response`, and `tuple` types.
- Support for `buff` and `uint` literals.
- Support for `{ k: v }` tuple literals.
- Support for function calls.
- Support for `if` expressions.
- Support for `is-ok`, `is-err`, and `err`.
- Support for `try!` and all `unwrap*` forms.
- Support for `append` and `concat`.
- Support for `filter`, `fold`, and `map`.
- Support for `to-int` and `to-uint`.

## [0.2.0] - 2020-09-22

### Added

- Support for all arithmetic operations.
- Support for boolean literals and logic.
- Support for relational operators.
- Support for optional values and expressions.
- Support for sequence operators.
- Support for `define-constant`.
- Support for `define-map`.
- Support for `list` types and expressions.
- Support for the `string-ascii` and `string-utf8` types.

## 0.1.0 - 2020-09-18

### Added

- The first public prototype.
- Compiles the `counter.clar` example.

[0.4.0]: https://github.com/weavery/sworn/compare/0.3.0...0.4.0
[0.3.0]: https://github.com/weavery/sworn/compare/0.2.0...0.3.0
[0.2.0]: https://github.com/weavery/sworn/compare/0.1.0...0.2.0
