(* This is free and unencumbered software released into the public domain. *)

type t =
  | Auto
  | JS
  | SWIR
  | Wasm
  | Wat

let of_string = function
  | "auto" -> Ok Auto
  | "js" -> Ok JS
  | "swir" -> Ok SWIR
  | "wasm" -> Ok Wasm
  | "wat" -> Ok Wat
  | _ -> Error (`Msg "invalid output format")

let to_string = function
  | Auto -> "auto"
  | JS -> "js"
  | SWIR -> "swir"
  | Wasm -> "wasm"
  | Wat -> "wat"
