(* This is free and unencumbered software released into the public domain. *)

open Sexplib

let rec parse_program input =
  let program = Sexp.of_string input in
  let open Sexplib.Sexp in
  match program with
  | List ((Atom "clarity") :: definitions) -> List.map parse_definition definitions
  | _ -> failwith "invalid Clarity program"

and parse_definition sexp =
  let open Sexplib.Sexp in
  match sexp with
  | List [Atom "define-constant"; Atom name; value] ->
    Constant (name, parse_expression value)
  | List [Atom "define-data-var"; Atom name; type'; value] ->
    DataVar (name, parse_type type', parse_expression value)
  | List [Atom "define-map"; Atom name;
      List [List [Atom key_name; key_type]];
      List [List [Atom val_name; val_type]]] ->
    Map (name, (key_name, parse_type key_type), (val_name, parse_type val_type))
  | List [Atom "define-private"; head; body] ->
    let (name, params) = parse_function_head head in
    let body = parse_function_body body in
    PrivateFunction (name, params, body)
  | List [Atom "define-public"; head; body] ->
    let (name, params) = parse_function_head head in
    let body = parse_function_body body in
    PublicFunction (name, params, body)
  | List [Atom "define-read-only"; head; body] ->
    let (name, params) = parse_function_head head in
    let body = parse_function_body body in
    PublicReadOnlyFunction (name, params, body)
  | List (Atom "define-fungible-token" :: Atom _name :: _) ->
    failwith "define-fungible-token not implemented yet"  (* TODO *)
  | List (Atom "define-non-fungible-token" :: Atom _name :: _) ->
    failwith "define-non-fungible-token not implemented yet"  (* TODO *)
  | List (Atom "define-trait" :: Atom _name :: _) ->
    failwith "define-trait not implemented yet"  (* TODO *)
  | _ -> failwith "invalid Clarity definition"

and parse_function_head sexp =
  let open Sexplib.Sexp in
  match sexp with
  | List ((Atom name) :: params) -> (name, List.map parse_parameter params)
  | _ -> failwith "invalid Clarity function head"

and parse_parameter sexp =
  let open Sexplib.Sexp in
  match sexp with
  | List [Atom name; type'] -> (name, parse_type type')
  | _ -> failwith "invalid Clarity function parameter"

and parse_function_body sexp =
  let open Sexplib.Sexp in
  match sexp with
  | List ((Atom "begin") :: exprs) -> List.map parse_expression exprs
  | sexp -> [parse_expression sexp]

and parse_expression sexp =
  let open Sexplib.Sexp in
  match sexp with
  | Atom token -> parse_literal token
  | List [Atom "some"; expr] -> SomeExpression (parse_expression expr)
  | List (Atom "list" :: exprs) -> ListExpression (List.map parse_expression exprs)
  | List [Atom "is-none"; expr] -> IsNone (parse_expression expr)
  | List [Atom "is-some"; expr] -> IsSome (parse_expression expr)
  | List [Atom "default-to"; def; opt] -> DefaultTo ((parse_expression def), (parse_expression opt))
  | List [Atom "var-get"; Atom var] -> VarGet var
  | List [Atom "var-set"; Atom var; val'] -> VarSet (var, parse_expression val')
  | List [Atom "ok"; expr] -> Ok (parse_expression expr)
  | List [Atom "not"; expr] -> Not (parse_expression expr)
  | List (Atom "and" :: exprs) -> And (List.map parse_expression exprs)
  | List (Atom "or" :: exprs) -> Or (List.map parse_expression exprs)
  | List (Atom "is-eq" :: exprs) -> Eq (List.map parse_expression exprs)
  | List [Atom "<"; a; b] -> Lt (parse_expression a, parse_expression b)
  | List [Atom "<="; a; b] -> Le (parse_expression a, parse_expression b)
  | List [Atom ">"; a; b] -> Gt (parse_expression a, parse_expression b)
  | List [Atom ">="; a; b] -> Ge (parse_expression a, parse_expression b)
  | List (Atom "+" :: exprs) -> Add (List.map parse_expression exprs)
  | List (Atom "-" :: exprs) -> Sub (List.map parse_expression exprs)
  | List (Atom "*" :: exprs) -> Mul (List.map parse_expression exprs)
  | List (Atom "/" :: exprs) -> Div (List.map parse_expression exprs)
  | List [Atom "mod"; a; b] -> Mod (parse_expression a, parse_expression b)
  | List [Atom "pow"; a; b] -> Pow (parse_expression a, parse_expression b)
  | List [Atom "xor"; a; b] -> Xor (parse_expression a, parse_expression b)
  | List [Atom "len"; expr] -> Len (parse_expression expr)
  | List [Atom "print"; expr] -> Print (parse_expression expr)
  | List (Atom name :: args) -> FunctionCall (name, (List.map parse_expression args))
  | _ -> failwith "invalid Clarity expression"

and parse_literal = function
  | "none" -> Literal NoneLiteral
  | "false" -> Literal (BoolLiteral false)
  | "true" -> Literal (BoolLiteral true)
  | token ->
    let literal =
      match Big_int.big_int_of_string_opt token with
      | Some n -> IntLiteral n
      | None -> StringLiteral token
    in
    Literal literal

and parse_type = function
  | Atom "principal" -> Principal
  | Atom "bool" -> Bool
  | Atom "int" -> Int
  | Atom "uint" -> Uint
  | List [Atom "optional"; t] -> Optional (parse_type t)
  | List [Atom "response"; ok; err] -> Response (parse_type ok, parse_type err)
  | List [Atom "buff"; Atom len] -> Buff (int_of_string len)
  | List [Atom "string-ascii"; Atom len] -> String (int_of_string len, ASCII)
  | List [Atom "string-utf8"; Atom len] -> String (int_of_string len, UTF8)
  | List [Atom "list"; Atom len; t] -> List (int_of_string len, parse_type t)
  | List (Atom "tuple" :: _) -> Tuple [] (* TODO: tuple *)
  | _ -> failwith "invalid Clarity type"
