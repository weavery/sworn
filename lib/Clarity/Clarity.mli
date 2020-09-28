(* This is free and unencumbered software released into the public domain. *)

#include "integer.mli"
#include "grammar.ml"

val int_literal : int -> literal
val uint_literal : int -> literal

#include "compare.mli"
#include "sexp.mli"
#include "library.mli"
#include "compile.mli"

#include "parser.mli"
#include "lexer.mli"

#include "parse.mli"
#include "print.mli"
