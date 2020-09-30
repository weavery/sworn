(* This is free and unencumbered software released into the public domain. *)

val compile_program : Clarity.program -> program

val compile_definition : Clarity.definition -> definition

val compile_expression : Clarity.expression -> expression

val compile_type : Clarity.type' -> type'
