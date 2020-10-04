(* This is free and unencumbered software released into the public domain. *)

val print_program : Format.formatter -> SWIR.program -> unit

val print_expression : Format.formatter -> SWIR.expression -> unit

val print_literal : Format.formatter -> SWIR.literal -> unit
