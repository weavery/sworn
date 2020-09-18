(* This is free and unencumbered software released into the public domain. *)

let fprintf = Format.fprintf

let rec print_program ppf program =
  let functions = SWIR.program_functions program in
  Format.pp_print_list ~pp_sep:Format.pp_print_cut print_function ppf functions;
  fprintf ppf "@,@[<v 2>export function handle(state, action) {@,%a@]@,}@." print_handle_function program

and print_handle_function ppf program =
  let functions = SWIR.program_functions program in
  Format.pp_print_list ~pp_sep:Format.pp_print_cut print_handle_clause ppf functions;
  fprintf ppf "@,return {state}"

and print_handle_clause ppf = function
  | Function (id, _, _) ->
    let js_name = mangle_name id in
    fprintf ppf "@[<v 2>if (action.input.function === '%s') {@,%s(state)@,return {state}@]@,}" js_name js_name
    | _ -> failwith "unreachable"

and print_function ppf = function
  | SWIR.Function (name, params, body) ->
    let params = ("state", None) :: params in
    fprintf ppf "@[<v 2>function %s(@[<h>%a@]) {@,%a@]@,}@,"
      (mangle_name name) print_parameters params print_expressions body
  | _ -> failwith "unreachable"

and print_parameters ppf params =
  Format.pp_print_list ~pp_sep:Format.pp_print_space print_parameter ppf params

and print_parameter ppf = function
  | (name, _) -> fprintf ppf "%s" name

and print_expressions ppf = function
  | [expr] -> fprintf ppf "%a" print_expression expr
  | exprs -> Format.pp_print_list ~pp_sep:Format.pp_print_cut print_expression ppf exprs

and print_expression ppf = function
  | SWIR.Literal lit -> print_literal ppf lit
  | SWIR.VarGet var -> fprintf ppf "state.%s" var
  | SWIR.VarSet (var, val') -> fprintf ppf "state.%s = %a" var print_expression val'
  | SWIR.Ok expr -> fprintf ppf "return %a" print_expression expr
  | SWIR.Add (a, b) -> fprintf ppf "(%a + %a)" print_expression a print_expression b
  | SWIR.Sub (a, b) -> fprintf ppf "(%a - %a)" print_expression a print_expression b

and print_literal ppf = function
  | SWIR.BoolLiteral b -> fprintf ppf "%s" (if b then "true" else "false")
  | SWIR.I64Literal n -> fprintf ppf "%Ld" n
  | SWIR.U64Literal n -> fprintf ppf "%Lu" n
  | SWIR.I128Literal n -> fprintf ppf "%Ld" n  (* TODO *)
  | SWIR.U128Literal n -> fprintf ppf "%Lu" n  (* TODO *)
  | SWIR.StringLiteral s -> fprintf ppf "\"%s\"" s  (* TODO: escaping *)

and mangle_name s = String.map (fun c -> if c = '-' then '_' else c) s
