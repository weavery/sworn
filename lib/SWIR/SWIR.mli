(* This is free and unencumbered software released into the public domain. *)

#include "grammar.ml"
#include "print.mli"
#include "compile.mli"

val program_constants : program -> program

val program_globals : program -> program

val program_functions : program -> program
