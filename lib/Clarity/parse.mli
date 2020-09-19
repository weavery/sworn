(* This is free and unencumbered software released into the public domain. *)

val parse_program : string -> program

val parse_definition : Sexplib.Sexp.t -> definition

val parse_expression : Sexplib.Sexp.t -> expression

val parse_type : Sexplib.Sexp.t -> type'
