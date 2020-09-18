(* This is free and unencumbered software released into the public domain. *)

#include "SWIR/grammar.ml"
#include "SWIR/print.ml"

let program_globals program =
  let filter = function (Global _) as g -> Some g | _ -> None in
  List.filter_map filter program

let program_functions program =
  let filter = function (Function _) as f -> Some f | _ -> None in
  List.filter_map filter program
