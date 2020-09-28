(* This is free and unencumbered software released into the public domain. *)

open Wasm.Ast
open Wasm.Operators

let (@@) = Wasm.Source.(@@)
let at = Wasm.Source.no_region
let name = Wasm.Utf8.decode

let rec compile_program (program : SWIR.program) : Wasm.Ast.module_ =
  let globals = SWIR.program_globals program in
  let funcs = SWIR.program_functions program in
  let wasm_types = List.map compile_func_type funcs in
  let wasm_globals = List.map compile_global globals in
  let wasm_funcs = List.mapi compile_func funcs in
  let wasm_exports = List.mapi (compile_export wasm_funcs) funcs in
  let wasm : module_' = {
    types = wasm_types;
    globals = wasm_globals;
    tables = [];
    memories = [];
    funcs = wasm_funcs;
    start = None;
    elems = [];
    data = [];
    imports = [];
    exports = wasm_exports;
  }
  in
  wasm @@ at

and compile_global = function
  | SWIR.Const (_, type', init) ->
    let value = (compile_expression init) @@ at in
    {gtype = GlobalType (compile_type type', Immutable); value } @@ at
  | SWIR.Global (_, type', None) ->
    let value = [] @@ at in
    {gtype = GlobalType (compile_type type', Mutable); value } @@ at
  | SWIR.Global (_, type', Some init) ->
    let value = (compile_expression init) @@ at in
    {gtype = GlobalType (compile_type type', Mutable); value } @@ at
  | _ -> failwith "unreachable"

and compile_func index = function
  | SWIR.Function (_, _, _, body) ->
    let ftype = Int32.of_int index in
    let locals = [] in
    let body = compile_func_body body in
    {ftype = ftype @@ at; locals; body } @@ at
  | _ -> failwith "unreachable"

and compile_func_type = function
  | SWIR.Function (_, _, params, _) ->
    Wasm.Types.FuncType (List.map compile_func_param params, [I64Type]) @@ at  (* TODO *)
  | _ -> failwith "unreachable"

and compile_func_param = function
  | (_, Some type') -> compile_type type'
  | (_, None) -> failwith "unreachable"

and compile_func_body body =  (* TODO *)
  List.concat_map compile_expression body

and compile_expression = function
  | SWIR.Literal lit -> [compile_literal lit]
  | SWIR.SomeExpression expr -> compile_expression expr
  | SWIR.VarGet _ -> [GlobalGet (0l @@ at) @@ at]  (* TODO *)
  | SWIR.VarSet (_, val') -> (compile_expression val') @ [GlobalSet (0l @@ at) @@ at]  (* TODO *)
  | SWIR.Ok expr -> compile_expression expr
  | SWIR.Add [a; b] -> (compile_expression a) @ (compile_expression b) @ [i64_add @@ at]
  | SWIR.Sub [a; b] -> (compile_expression a) @ (compile_expression b) @ [i64_sub @@ at]
  | SWIR.Mul [a; b] -> (compile_expression a) @ (compile_expression b) @ [i64_mul @@ at]
  | SWIR.Div [a; b] -> (compile_expression a) @ (compile_expression b) @ [i64_div_s @@ at]
  | SWIR.Mod (a, b) -> (compile_expression a) @ (compile_expression b) @ [i64_rem_s @@ at]
  | SWIR.Pow (_, _) -> failwith "pow not implemented yet"  (* TODO *)
  | _ -> failwith "compile_expression: not implemented yet"  (* TODO *)

and compile_literal = function
  | SWIR.NoneLiteral -> (i32_const (0l @@ at)) @@ at  (* TODO *)
  | SWIR.BoolLiteral b -> (i32_const (Int32.of_int (if b then 1 else 0) @@ at)) @@ at
  | SWIR.I64Literal z | U64Literal z -> (i64_const (z @@ at)) @@ at
  | SWIR.I128Literal z | U128Literal z ->
    begin match Big_int.int64_of_big_int_opt z with
    | Some z -> (i64_const (z @@ at)) @@ at
    | None -> failwith "TODO: compile_literal not implemented for 128-bit integers"  (* TODO *)
    end
  | SWIR.StringLiteral _ -> failwith "TODO: compile_literal: string"  (* TODO *)

and compile_export _funcs index = function
  | SWIR.Function (_, s, _, _) ->
    {name = name (mangle_name s); edesc = FuncExport (Int32.of_int index @@ at) @@ at} @@ at  (* TODO *)
  | _ -> failwith "unreachable"

and compile_type = function
  | SWIR.Bool -> Wasm.Types.I32Type
  | SWIR.I64 -> I64Type
  | SWIR.U64 -> I64Type
  | SWIR.I128 -> I64Type  (* TODO *)
  | SWIR.U128 -> I64Type  (* TODO *)
  | _ -> failwith "TODO: compile_type"  (* TODO *)

and mangle_name s = String.map (fun c -> if c = '-' then '_' else c) s
