(* This is free and unencumbered software released into the public domain. *)

let is_primitive = function
  | "append" -> true
  | "concat" -> true
  | "filter" -> true
  | "fold" -> true
  | "map" -> true
  | "print" -> true
  | _ -> false
