(* This is free and unencumbered software released into the public domain. *)

let import_type symbol =
  let open Wasm.Types in
  match symbol with
  | "add" | "div" | "mul" | "sub" -> FuncType ([I64Type; I64Type], [I64Type])
  | "ok" -> FuncType ([I64Type], [I64Type])
  | _ -> FuncType ([], [])
