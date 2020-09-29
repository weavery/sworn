(* This is free and unencumbered software released into the public domain. *)

let fprintf = Format.fprintf

let rec print_program ppf program =
  Format.pp_print_list ~pp_sep:Format.pp_print_cut print_definition ppf program

and print_definition ppf = function
  | Constant (name, value) ->
    fprintf ppf "@[<v 2>(define-constant %s %a)@]@,"
      name print_expression value
  | DataVar (name, type', value) ->
    fprintf ppf "@[<v 2>(define-data-var %s %s %a)@]@,"
      name (type_to_string type') print_expression value
  | Map (name, (key_name, key_type), (val_name, val_type)) ->
    fprintf ppf "@[<v 2>(define-map %s ((%s %s)) ((%s %s)))@]@,"
      name key_name (type_to_string key_type) val_name (type_to_string val_type)
  | PublicFunction (name, params, body) ->
    fprintf ppf "@[<v 2>(define-public (%s @[<h>%a@])@,%a)@]@,"
      name print_parameters params print_expressions body
  | PublicReadOnlyFunction (name, params, body) ->
    fprintf ppf "@[<v 2>(define-read-only (%s @[<h>%a@])@,%a)@]@,"
      name print_parameters params print_expressions body
  | PrivateFunction (name, params, body) ->
    fprintf ppf "@[<v 2>(define-private (%s @[<h>%a@])@,%a)@]@,"
      name print_parameters params print_expressions body

and print_parameters ppf params =
  Format.pp_print_list ~pp_sep:Format.pp_print_space print_parameter ppf params

and print_parameter ppf = function
  | (name, type') -> fprintf ppf "(%s %s)" name (type_to_string type')

and print_expressions ppf = function
  | [expr] -> fprintf ppf "%a" print_expression expr
  | exprs ->
    fprintf ppf "@[<v 2>(begin@,%a)@]"
      (Format.pp_print_list ~pp_sep:Format.pp_print_cut print_expression) exprs

and print_expression ppf = function
  | Identifier id -> fprintf ppf "%s" id
  | Literal lit -> print_literal ppf lit
  | SomeExpression expr -> fprintf ppf "(some %a)" print_expression expr
  | ListExpression exprs -> print_operation ppf "list" exprs
  | IsNone expr -> fprintf ppf "(is-none %a)" print_expression expr
  | IsSome expr -> fprintf ppf "(is-some %a)" print_expression expr
  | IsErr expr -> fprintf ppf "(is-err %a)" print_expression expr
  | IsOk expr -> fprintf ppf "(is-ok %a)" print_expression expr
  | DefaultTo (def, opt) -> fprintf ppf "(default-to %a %a)" print_expression def print_expression opt
  | VarGet var -> fprintf ppf "(var-get %s)" var
  | VarSet (var, val') -> fprintf ppf "(var-set %s %a)" var print_expression val'
  | Err expr -> fprintf ppf "(err %a)" print_expression expr
  | Ok expr -> fprintf ppf "(ok %a)" print_expression expr
  | Not expr -> fprintf ppf "(not %a)" print_expression expr
  | And exprs -> print_operation ppf "and" exprs
  | Or exprs -> print_operation ppf "or" exprs
  | Eq exprs -> print_operation ppf "is-eq" exprs
  | Lt (a, b) -> print_operation ppf "<" [a; b]
  | Le (a, b) -> print_operation ppf "<=" [a; b]
  | Gt (a, b) -> print_operation ppf ">" [a; b]
  | Ge (a, b) -> print_operation ppf ">=" [a; b]
  | Add exprs -> print_operation ppf "+" exprs
  | Sub exprs -> print_operation ppf "-" exprs
  | Mul exprs -> print_operation ppf "*" exprs
  | Div exprs -> print_operation ppf "/" exprs
  | Mod (a, b) -> print_operation ppf "mod" [a; b]
  | Pow (a, b) -> print_operation ppf "pow" [a; b]
  | Xor (a, b) -> print_operation ppf "xor" [a; b]
  | Len expr -> fprintf ppf "(len %a)" print_expression expr
  | ToInt expr -> print_operation ppf "to-int" [expr]
  | ToUint expr -> print_operation ppf "to-uint" [expr]
  | FunctionCall (name, args) -> print_operation ppf name args
  | Try input -> print_operation ppf "try!" [input]
  | Unwrap (input, thrown) -> print_operation ppf "unwrap!" [input; thrown]
  | UnwrapPanic input -> print_operation ppf "unwrap-panic" [input]
  | UnwrapErr (input, thrown) -> print_operation ppf "unwrap-err!" [input; thrown]
  | UnwrapErrPanic input -> print_operation ppf "unwrap-err-panic" [input]
  | If (cond, then', else') -> print_operation ppf "if" [cond; then'; else']

and print_operation ppf op exprs =
  fprintf ppf "(%s @[<h>%a@])" op
    (Format.pp_print_list ~pp_sep:Format.pp_print_space print_expression) exprs

and print_literal ppf = function
  | NoneLiteral -> fprintf ppf "none"
  | BoolLiteral b -> fprintf ppf "%s" (if b then "true" else "false")
  | IntLiteral z -> fprintf ppf "%s" (Integer.to_string z)
  | UintLiteral n -> fprintf ppf "%s" (Integer.to_string n)
  | BuffLiteral s -> fprintf ppf "0x%s" s  (* TODO *)
  | StringLiteral s -> fprintf ppf "\"%s\"" s  (* TODO: escaping *)
  | TupleLiteral (k, v) -> fprintf ppf "{ %s: %a }" k print_literal v

and type_to_string = function
  | Principal -> "principal"
  | Bool -> "bool"
  | Int -> "int"
  | Uint -> "uint"
  | Optional _ -> "optional"  (* TODO *)
  | Response _ -> "response"  (* TODO *)
  | Buff _ -> "buff"  (* TODO *)
  | String _ -> "string"  (* TODO *)
  | List _ -> "list"  (* TODO *)
  | Tuple _ -> "tuple"  (* TODO *)
