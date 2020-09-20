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
  | Literal lit -> print_literal ppf lit
  | SomeExpression expr -> fprintf ppf "(some %a)" print_expression expr
  | ListExpression exprs -> print_operation ppf "list" exprs
  | IsNone expr -> fprintf ppf "(is-none %a)" print_expression expr
  | IsSome expr -> fprintf ppf "(is-some %a)" print_expression expr
  | DefaultTo (def, opt) -> fprintf ppf "(default-to %a %a)" print_expression def print_expression opt
  | VarGet var -> fprintf ppf "(var-get %s)" var
  | VarSet (var, val') -> fprintf ppf "(var-set %s %a)" var print_expression val'
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
  | Print expr -> fprintf ppf "(print %a)" print_expression expr

and print_operation ppf op exprs =
  fprintf ppf "(%s @[<h>%a@])" op
    (Format.pp_print_list ~pp_sep:Format.pp_print_space print_expression) exprs

and print_literal ppf = function
  | NoneLiteral -> fprintf ppf "none"
  | BoolLiteral b -> fprintf ppf "%s" (if b then "true" else "false")
  | IntLiteral z -> fprintf ppf "%s" (Big_int.string_of_big_int z)
  | UintLiteral n -> fprintf ppf "%s" (Big_int.string_of_big_int n)
  | StringLiteral s -> fprintf ppf "\"%s\"" s  (* TODO: escaping *)

and type_to_string = function
  | Bool -> "bool"
  | Int -> "int"
  | Uint -> "uint"
  | Principal -> "principal"
  | Optional _ -> "optional"  (* TODO *)
  | String _ -> "string"  (* TODO *)
  | List _ -> "list"  (* TODO *)
