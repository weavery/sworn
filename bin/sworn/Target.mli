(* This is free and unencumbered software released into the public domain. *)

type t =
  | Auto
  | JS
  | SWIR
  | Wasm
  | Wat

val of_string : string -> (t, [ `Msg of string ]) result
val to_string : t -> string
