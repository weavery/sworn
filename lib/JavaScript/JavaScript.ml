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
  fprintf ppf "const input = action.input;@,";
  fprintf ppf "%a@]@,}@." print_handle_function program

and print_constant ppf = function
  | SWIR.Const (name, _, value) -> fprintf ppf "const %s = %a;@," name print_expression value
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
  fprintf ppf "@,return {state};"

and print_handle_clause ppf = function
  | Function (PublicPure, id, _, _) ->
    let js_name = mangle_name id in
    fprintf ppf "@[<v 2>if (input.function === '%s') {@,return {result: %s(state)};@]@,}" js_name js_name
  | Function (Public, id, _, _) ->
    let js_name = mangle_name id in
    fprintf ppf "@[<v 2>if (input.function === '%s') {@,return %s(state);@]@,}" js_name js_name
  | _ -> failwith "unreachable"

and print_function ppf = function
  | SWIR.Function (modifier, name, params, body) ->
    let params = ("state", None) :: params in
    fprintf ppf "@[<v 2>function %s(@[<h>%a@]) {@,%a@]@,}@,"
      (mangle_name name)
      print_parameters params
      (print_function_body modifier) body
  | _ -> failwith "unreachable"

and print_function_body modifier ppf = function
  | [] -> begin match modifier with
      | Public -> fprintf ppf "return {state, result: clarity.none};"
      | _ -> fprintf ppf "return clarity.none;"
    end
  | [expr] -> begin match modifier with
      | Public -> fprintf ppf "return {state, result: %a};" print_expression expr
      | _ -> fprintf ppf "return %a;" print_expression expr
    end
  | head :: tail -> begin
      fprintf ppf "%a;@," print_expression head;
      print_function_body modifier ppf tail
    end

and print_parameters ppf params =
  Format.pp_print_list ~pp_sep:print_comma print_parameter ppf params

and print_parameter ppf = function
  | (name, _) -> fprintf ppf "%s" (mangle_name name)

and print_expression ppf = function
  | SWIR.Assert (cond, thrown) ->
    fprintf ppf "if (!%a) return %a" print_expression cond print_expression thrown
  | SWIR.Identifier id -> fprintf ppf "%s" (mangle_name id)
  | SWIR.Literal lit -> print_literal ppf lit
  | SWIR.SomeExpression expr -> print_function_call ppf "some" [expr]
  | SWIR.ListExpression exprs -> print_list ppf exprs
  | SWIR.RecordExpression bindings -> print_record_expression ppf bindings
  | SWIR.IsNone expr -> print_function_call ppf "is-none" [expr]
  | SWIR.IsSome expr -> print_function_call ppf "is-some" [expr]
  | SWIR.IsErr expr -> print_function_call ppf "is-err" [expr]
  | SWIR.IsOk expr -> print_function_call ppf "is-ok" [expr]
  | SWIR.DefaultTo (def, opt) ->
    fprintf ppf "(%a ?? %a)" print_expression opt print_expression def
  | SWIR.VarGet var -> fprintf ppf "state.%s" var
  | SWIR.VarSet (var, val') -> fprintf ppf "state.%s = %a" var print_expression val'
  | SWIR.Err expr -> print_function_call ppf "err" [expr]
  | SWIR.Ok expr -> print_function_call ppf "ok" [expr]
  | SWIR.Not expr -> fprintf ppf "(!%a)" print_expression expr
  | SWIR.And exprs -> print_operation ppf "&&" exprs
  | SWIR.Or exprs -> print_operation ppf "||" exprs
  | SWIR.Eq exprs -> print_function_call ppf "is-eq" exprs
  | SWIR.Lt (a, b) -> print_function_call ppf "<" [a; b]
  | SWIR.Le (a, b) -> print_function_call ppf "<=" [a; b]
  | SWIR.Gt (a, b) -> print_function_call ppf ">" [a; b]
  | SWIR.Ge (a, b) -> print_function_call ppf ">=" [a; b]
  | SWIR.Add exprs -> print_function_call ppf "+" exprs
  | SWIR.Sub exprs -> print_function_call ppf "-" exprs
  | SWIR.Mul exprs -> print_function_call ppf "*" exprs
  | SWIR.Div exprs -> print_function_call ppf "/" exprs
  | SWIR.Mod (a, b) -> print_function_call ppf "mod" [a; b]
  | SWIR.Pow (a, b) -> print_function_call ppf "pow" [a; b]
  | SWIR.Xor (a, b) -> print_function_call ppf "xor" [a; b]
  | SWIR.Len expr -> fprintf ppf "%a.length" print_expression expr
  | SWIR.ToInt expr -> print_function_call ppf "to-int" [expr]
  | SWIR.ToUint expr -> print_function_call ppf "to-uint" [expr]
  | SWIR.FunctionRef name -> fprintf ppf "clarity.%s" (mangle_name name)
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
  | SWIR.Let (bindings, body) -> print_let_expression ppf bindings body
  | SWIR.Match (input, (ok_name, ok_expr), (err_name, err_expr)) ->
    fprintf ppf "clarity.match(%a, %s => %a, %s => %a)"
      print_expression input
      ok_name print_expression ok_expr
      err_name print_expression err_expr

and print_record_expression ppf =
  fprintf ppf "clarity.tuple(@[<h>%a@])"
    (Format.pp_print_list ~pp_sep:print_comma print_record_binding)

and print_record_binding ppf (k, v) = fprintf ppf "[\"%s\", %a]" k print_expression v

and print_let_expression ppf bindings body =
  fprintf ppf "(() => { @[<h>%a@]; %a })()"
    (Format.pp_print_list ~pp_sep:print_semicolon print_let_binding) bindings
    print_let_body body

and print_let_binding ppf (k, v) = fprintf ppf "const %s = %a" k print_expression v

and print_let_body ppf = function
  | [] -> fprintf ppf "return clarity.none"
  | [expr] -> fprintf ppf "return %a" print_expression expr
  | head :: tail -> begin
      fprintf ppf "%a;@ " print_expression head;
      print_let_body ppf tail
    end

and print_list ppf exprs =
  fprintf ppf "[@[<h>%a@]]"
    (Format.pp_print_list ~pp_sep:print_comma print_expression) exprs

and print_function_call ppf name args =
  let is_primitive = Clarity.is_primitive name in
  let name = mangle_name name in
  let name = if is_primitive then Printf.sprintf "clarity.%s" name else name in
  fprintf ppf "%s(@[<h>%a@])" name
    (Format.pp_print_list ~pp_sep:print_comma print_expression) args

and print_operation ppf op exprs =
  let print_operator ppf () = fprintf ppf "@ %s@ " op in
  fprintf ppf "(@[<h>%a@])"
    (Format.pp_print_list ~pp_sep:print_operator print_expression) exprs

and print_literal ppf = function
  | SWIR.NoneLiteral -> fprintf ppf "clarity.none"
  | SWIR.BoolLiteral b -> fprintf ppf "%s" (if b then "true" else "false")
  | SWIR.I64Literal n -> fprintf ppf "%Ld" n
  | SWIR.U64Literal n -> fprintf ppf "%Lu" n
  | SWIR.I128Literal z | SWIR.U128Literal z ->
    fprintf ppf "%s" (Clarity.Integer.to_string z)
  | SWIR.BufferLiteral s -> print_buffer ppf s
  | SWIR.StringLiteral s -> fprintf ppf "\"%s\"" s  (* TODO: escaping *)
  | SWIR.RecordLiteral (k, v) ->
    fprintf ppf "clarity.tuple([\"%s\", %a])" k print_literal v

and print_buffer ppf buffer =
  let print_byte ppf b = fprintf ppf "0x%x" (Char.code b) in
  let bytes = List.of_seq (String.to_seq buffer) in
  fprintf ppf "Uint8Array.of([@[<h>%a@]])"
    (Format.pp_print_list ~pp_sep:print_comma print_byte) bytes

and print_comma ppf () = Format.fprintf ppf ",@ "

and print_semicolon ppf () = Format.fprintf ppf ";@ "

and mangle_name = function
  | "*" -> "mul"
  | "+" -> "add"
  | "-" -> "sub"
  | "/" -> "div"
  | "<" -> "lt"
  | "<=" -> "le"
  | ">" -> "gt"
  | ">=" -> "ge"
  | "sha512/256" -> "sha512_256"
  | "try!" -> "tryUnwrap"
  | name ->
    let filtered_chars = Str.regexp "[/?!]" in
    let name = Str.global_replace filtered_chars "" name in
    let words = String.split_on_char '-' name in
    let words = List.map String.capitalize_ascii words in
    String.uncapitalize_ascii (String.concat "" words)
