(* This is free and unencumbered software released into the public domain. *)

#include "grammar.ml"

let int_literal z = IntLiteral (Big_int.big_int_of_int z)
let uint_literal n = UintLiteral (Big_int.big_int_of_int n)

#include "compare.ml"
#include "print.ml"
#include "sexp.ml"
#include "library.ml"
#include "compile.ml"

#include "parser.ml"
#include "lexer.ml"

#include "parse.ml"
