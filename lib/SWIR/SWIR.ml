(* This is free and unencumbered software released into the public domain. *)

#include "grammar.ml"
#include "print.ml"

let program_constants program =
  let filter = function (Const _) as c -> Some c | _ -> None in
  List.filter_map filter program

let program_globals program =
  let filter = function
  | (Const _) as g -> Some g
  | (Global _) as g -> Some g
  | _ -> None in
  List.filter_map filter program

let program_functions program =
  let filter = function (Function _) as f -> Some f | _ -> None in
  List.filter_map filter program
