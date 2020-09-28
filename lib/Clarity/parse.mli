(* This is free and unencumbered software released into the public domain. *)

val parse_program : string -> program

val parse_definition : Sexp.t -> definition

val parse_expression : Sexp.t -> expression

val parse_type : Sexp.t -> type'
