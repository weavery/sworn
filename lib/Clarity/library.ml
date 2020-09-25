(* This is free and unencumbered software released into the public domain. *)

let is_primitive = function
  | "append" -> true
  | "concat" -> true
  | "filter" -> true
  | "fold" -> true
  | "is-eq" -> true
  | "is-err" -> true
  | "is-none" -> true
  | "is-ok" -> true
  | "is-some" -> true
  | "map" -> true
  | "ok" -> true
  | "print" -> true
  | "some" -> true
  | "to-int" -> true
  | "to-uint" -> true
  | _ -> false
