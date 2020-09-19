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
    fprintf ppf "@[<v 2>function %s(@[<h>%a@]) {@,%a"
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
  | SWIR.VarGet var -> fprintf ppf "state.%s" var
  | SWIR.VarSet (var, val') -> fprintf ppf "state.%s = %a" var print_expression val'
  | SWIR.Ok expr -> fprintf ppf "const result = %a" print_expression expr
  | SWIR.Add (a, b) ->
    fprintf ppf "(%a + %a)" print_expression a print_expression b
  | SWIR.Sub (a, b) ->
    fprintf ppf "(%a - %a)" print_expression a print_expression b

and print_literal ppf = function
  | SWIR.BoolLiteral b -> fprintf ppf "%s" (if b then "true" else "false")
  | SWIR.I64Literal n -> fprintf ppf "%Ld" n
  | SWIR.U64Literal n -> fprintf ppf "%Lu" n
  | SWIR.I128Literal z | SWIR.U128Literal z ->
    fprintf ppf "%s" (Big_int.string_of_big_int z)
  | SWIR.StringLiteral s -> fprintf ppf "\"%s\"" s  (* TODO: escaping *)

and mangle_name s = String.map (fun c -> if c = '-' then '_' else c) s
