(* This is free and unencumbered software released into the public domain. *)

val print_program : Format.formatter -> program -> unit

val print_definition : Format.formatter -> definition -> unit

val print_parameter : Format.formatter -> parameter -> unit

val print_expression : Format.formatter -> expression -> unit

val print_literal : Format.formatter -> literal -> unit
