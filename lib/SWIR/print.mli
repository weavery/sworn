(* This is free and unencumbered software released into the public domain. *)

val print_program : Format.formatter -> program -> unit

val print_definition : Format.formatter -> definition -> unit

val print_expression : Format.formatter -> expression -> unit

val print_type : Format.formatter -> type' -> unit

val type_to_string : type' -> string
