(* This is free and unencumbered software released into the public domain. *)

let sprintf = Printf.sprintf
let fprintf = Format.fprintf

let rec print_program ppf program =
  Format.pp_print_list ~pp_sep:Format.pp_print_cut print_definition ppf program

and print_definition ppf = function
  | Const (name, type', value) ->
    fprintf ppf "@[<v 2>(define %s (const %s %a))@]@,"
      name (type_to_string type') print_expression value
  | Global (name, type', None) ->
    fprintf ppf "@[<v 2>(define %s (global %s))@]@,"
      name (type_to_string type')
  | Global (name, type', Some value) ->
    fprintf ppf "@[<v 2>(define %s (global %s %a))@]@,"
      name (type_to_string type') print_expression value
  | Function (name, params, body) ->
    fprintf ppf "@[<v 2>(define %s@,@[<v 2>(function (@[<h>%a@])@,%a))@]@]@,"
      name print_parameters params print_expressions body

and print_parameters ppf params =
  Format.pp_print_list ~pp_sep:Format.pp_print_space print_parameter ppf params

and print_parameter ppf = function
  | (name, None) -> fprintf ppf "%s" name
  | (name, Some type') -> fprintf ppf "(%s %s)" name (type_to_string type')

and print_expressions ppf = function
  | [expr] -> fprintf ppf "%a" print_expression expr
  | exprs ->
    fprintf ppf "@[<v 2>(begin@,%a)@]"
      (Format.pp_print_list ~pp_sep:Format.pp_print_cut print_expression) exprs

and print_expression ppf = function
  | Literal lit -> print_literal ppf lit
  | VarGet var -> fprintf ppf "(var-get %s)" var
  | VarSet (var, val') -> fprintf ppf "(var-set %s %a)" var print_expression val'
  | Ok expr -> fprintf ppf "(ok %a)" print_expression expr
  | Add (a, b) -> fprintf ppf "(+ %a %a)" print_expression a print_expression b
  | Sub (a, b) -> fprintf ppf "(- %a %a)" print_expression a print_expression b

and print_literal ppf = function
  | BoolLiteral b -> fprintf ppf "%s" (if b then "true" else "false")
  | I64Literal z -> fprintf ppf "%Ld" z
  | U64Literal n -> fprintf ppf "%Lu" n
  | I128Literal z -> fprintf ppf "%s" (Big_int.string_of_big_int z)
  | U128Literal n -> fprintf ppf "%s" (Big_int.string_of_big_int n)
  | StringLiteral s -> fprintf ppf "\"%s\"" s  (* TODO: escaping *)

and print_type ppf type' =
  fprintf ppf "%s" (type_to_string type')

and type_to_string = function
  | Bool -> "bool"
  | I64 -> "i64"
  | U64 -> "u64"
  | I128 -> "i128"
  | U128 -> "u128"
  | Optional t -> sprintf "(optional %s)" (type_to_string t)
  | String len -> sprintf "(string %d)" len
  | List (len, t) -> sprintf "(list %d %s)" len (type_to_string t)
  | Map (k, v) -> sprintf "(map %s %s)" (type_to_string k) (type_to_string v)
