(* This is free and unencumbered software released into the public domain. *)

let fprintf = Format.fprintf

let rec print_program ppf program =
  begin match SWIR.program_constants program with
  | [] -> ()
  | constants -> begin
      Format.pp_print_list ~pp_sep:Format.pp_print_cut print_constant ppf constants;
      Format.pp_print_cut ppf ()
    end
  end;
  begin match SWIR.program_functions program with
  | [] -> ()
  | functions -> begin
      Format.pp_print_list ~pp_sep:Format.pp_print_cut print_function ppf functions;
      Format.pp_print_cut ppf ()
    end
  end;
  fprintf ppf "@[<v 2>export function handle(state, action) {@,";
  fprintf ppf "const input = action.input@,";
  fprintf ppf "%a@]@,}@." print_handle_function program

and print_constant ppf = function
  | SWIR.Const (name, _, value) -> fprintf ppf "const %s = %a@," name print_expression value
  | _ -> failwith "unreachable"

and print_handle_function ppf program =
  let functions = SWIR.program_functions program in
  let filter = function
    | (SWIR.Function (SWIR.Public, _, _, _)) as f -> Some f
    | (SWIR.Function (SWIR.PublicPure, _, _, _)) as f -> Some f
    | _ -> None
  in
  let functions = List.filter_map filter functions in
  Format.pp_print_list ~pp_sep:Format.pp_print_cut print_handle_clause ppf functions;
  fprintf ppf "@,return {state}"

and print_handle_clause ppf = function
  | Function (PublicPure, id, _, _) ->
    let js_name = mangle_name id in
    fprintf ppf "@[<v 2>if (input.function === '%s') {@,return {result: %s(state)}@]@,}" js_name js_name
  | Function (Public, id, _, _) ->
    let js_name = mangle_name id in
    fprintf ppf "@[<v 2>if (input.function === '%s') {@,return {state: %s(state)}@]@,}" js_name js_name
  | _ -> failwith "unreachable"

and print_function ppf = function
  | SWIR.Function (modifier, name, params, body) ->
    let params = ("state", None) :: params in
    fprintf ppf "@[<v 2>function %s(@[<h>%a@]) {@,let result = null@,%a"
      (mangle_name name)
      print_parameters params
      print_expressions body;
    begin match modifier with
      | Public -> fprintf ppf "@,return state"
      | _ -> fprintf ppf "@,return result"
    end;
    fprintf ppf "@]@,}@,"
  | _ -> failwith "unreachable"

and print_parameters ppf params =
  let print_comma ppf () = Format.fprintf ppf ",@ " in
  Format.pp_print_list ~pp_sep:print_comma print_parameter ppf params

and print_parameter ppf = function
  | (name, _) -> fprintf ppf "%s" (mangle_name name)

and print_expressions ppf = function
  | [expr] -> fprintf ppf "%a" print_expression expr
  | exprs -> Format.pp_print_list ~pp_sep:Format.pp_print_cut print_expression ppf exprs

and print_expression ppf = function
  | SWIR.Literal lit -> print_literal ppf lit
  | SWIR.SomeExpression expr -> print_function_call ppf "some" [expr]
  | SWIR.ListExpression exprs -> print_list ppf exprs
  | SWIR.IsNone expr -> print_function_call ppf "is-none" [expr]
  | SWIR.IsSome expr -> print_function_call ppf "is-some" [expr]
  | SWIR.IsErr expr -> print_function_call ppf "is-err" [expr]
  | SWIR.IsOk expr -> print_function_call ppf "is-ok" [expr]
  | SWIR.DefaultTo (def, opt) ->
    fprintf ppf "(%a ?? %a)" print_expression opt print_expression def
  | SWIR.VarGet var -> fprintf ppf "state.%s" var
  | SWIR.VarSet (var, val') -> fprintf ppf "state.%s = %a" var print_expression val'
  | SWIR.Err expr -> fprintf ppf "result = clarity.err(%a)" print_expression expr
  | SWIR.Ok expr -> fprintf ppf "result = clarity.ok(%a)" print_expression expr
  | SWIR.Not expr -> fprintf ppf "(!%a)" print_expression expr
  | SWIR.And exprs -> print_operation ppf "&&" exprs
  | SWIR.Or exprs -> print_operation ppf "||" exprs
  | SWIR.Eq exprs -> print_function_call ppf "is-eq" exprs
  | SWIR.Lt (a, b) -> print_operation ppf "<" [a; b]
  | SWIR.Le (a, b) -> print_operation ppf "<=" [a; b]
  | SWIR.Gt (a, b) -> print_operation ppf ">" [a; b]
  | SWIR.Ge (a, b) -> print_operation ppf ">=" [a; b]
  | SWIR.Add exprs -> print_operation ppf "+" exprs
  | SWIR.Sub exprs -> print_operation ppf "-" exprs
  | SWIR.Mul exprs -> print_operation ppf "*" exprs
  | SWIR.Div exprs -> print_operation ppf "/" exprs
  | SWIR.Mod (a, b) -> print_operation ppf "%" [a; b]
  | SWIR.Pow (a, b) -> print_operation ppf "**" [a; b]
  | SWIR.Xor (a, b) -> print_operation ppf "^" [a; b]
  | SWIR.Len expr -> fprintf ppf "%a.length" print_expression expr
  | SWIR.ToInt expr -> print_function_call ppf "to-int" [expr]
  | SWIR.ToUint expr -> print_function_call ppf "to-uint" [expr]
  | SWIR.FunctionCall (name, args) -> print_function_call ppf name args
  | SWIR.Try input -> print_function_call ppf "try!" [input]
  | SWIR.Unwrap (input, thrown) -> print_function_call ppf "unwrap!" [input; thrown]
  | SWIR.UnwrapPanic input -> print_function_call ppf "unwrap-panic" [input]
  | SWIR.UnwrapErr (input, thrown) -> print_function_call ppf "unwrap-err!" [input; thrown]
  | SWIR.UnwrapErrPanic input -> print_function_call ppf "unwrap-err-panic" [input]
  | SWIR.If (cond, then', else') ->
    fprintf ppf "(%a ? (%a) : (%a))"
      print_expression cond
      print_expression then'
      print_expression else'

and print_list ppf exprs =
  let print_comma ppf () = Format.fprintf ppf ",@ " in
  fprintf ppf "[@[<h>%a@]]"
    (Format.pp_print_list ~pp_sep:print_comma print_expression) exprs

and print_function_call ppf name args =
  let is_primitive = Clarity.is_primitive name in
  let name = mangle_name name in
  let name = if is_primitive then Printf.sprintf "clarity.%s" name else name in
  let print_comma ppf () = Format.fprintf ppf ",@ " in
  fprintf ppf "%s(@[<h>%a@])" name
    (Format.pp_print_list ~pp_sep:print_comma print_expression) args

and print_operation ppf op exprs =
  let print_operator ppf () = fprintf ppf "@ %s@ " op in
  fprintf ppf "(@[<h>%a@])"
    (Format.pp_print_list ~pp_sep:print_operator print_expression) exprs

and print_literal ppf = function
  | SWIR.NoneLiteral -> fprintf ppf "null"
  | SWIR.BoolLiteral b -> fprintf ppf "%s" (if b then "true" else "false")
  | SWIR.I64Literal n -> fprintf ppf "%Ld" n
  | SWIR.U64Literal n -> fprintf ppf "%Lu" n
  | SWIR.I128Literal z | SWIR.U128Literal z ->
    fprintf ppf "%s" (Big_int.string_of_big_int z)
  | SWIR.StringLiteral s -> fprintf ppf "\"%s\"" s  (* TODO: escaping *)

and mangle_name = function
  | "try!" -> "tryUnwrap"
  | name ->
    let filtered_chars = Str.regexp "[/?!]" in
    let name = Str.global_replace filtered_chars "" name in
    let words = String.split_on_char '-' name in
    let words = List.map String.capitalize_ascii words in
    String.uncapitalize_ascii (String.concat "" words)
