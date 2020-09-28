(* This is free and unencumbered software released into the public domain. *)

let rec parse_program input =
  let lexbuf = Lexing.from_string input in
  let program = parse read_token lexbuf in
  List.map parse_definition program

and parse_definition sexp =
  let open Sexp in
  match sexp with
  | List [Sym "define-constant"; Sym name; value] ->
    Constant (name, parse_expression value)
  | List [Sym "define-data-var"; Sym name; type'; value] ->
    DataVar (name, parse_type type', parse_expression value)
  | List [Sym "define-map"; Sym name;
      List [List [Sym key_name; key_type]];
      List [List [Sym val_name; val_type]]] ->
    Map (name, (key_name, parse_type key_type), (val_name, parse_type val_type))
  | List [Sym "define-private"; head; body] ->
    let (name, params) = parse_function_head head in
    let body = parse_function_body body in
    PrivateFunction (name, params, body)
  | List [Sym "define-public"; head; body] ->
    let (name, params) = parse_function_head head in
    let body = parse_function_body body in
    PublicFunction (name, params, body)
  | List [Sym "define-read-only"; head; body] ->
    let (name, params) = parse_function_head head in
    let body = parse_function_body body in
    PublicReadOnlyFunction (name, params, body)
  | List (Sym "define-fungible-token" :: Sym _name :: _) ->
    failwith "define-fungible-token not implemented yet"  (* TODO *)
  | List (Sym "define-non-fungible-token" :: Sym _name :: _) ->
    failwith "define-non-fungible-token not implemented yet"  (* TODO *)
  | List (Sym "define-trait" :: Sym _name :: _) ->
    failwith "define-trait not implemented yet"  (* TODO *)
  | _ -> failwith "invalid Clarity definition"

and parse_function_head sexp =
  let open Sexp in
  match sexp with
  | List ((Sym name) :: params) -> (name, List.map parse_parameter params)
  | _ -> failwith "invalid Clarity function head"

and parse_parameter sexp =
  let open Sexp in
  match sexp with
  | List [Sym name; type'] -> (name, parse_type type')
  | _ -> failwith "invalid Clarity function parameter"

and parse_function_body sexp =
  let open Sexp in
  match sexp with
  | List ((Sym "begin") :: exprs) -> List.map parse_expression exprs
  | sexp -> [parse_expression sexp]

and parse_expression sexp =
  let open Sexp in
  match sexp with
  | Sym id -> Identifier id
  | Lit lit -> Literal lit
  | List [Sym "some"; expr] -> SomeExpression (parse_expression expr)
  | List (Sym "list" :: exprs) -> ListExpression (List.map parse_expression exprs)
  | List [Sym "is-none"; expr] -> IsNone (parse_expression expr)
  | List [Sym "is-some"; expr] -> IsSome (parse_expression expr)
  | List [Sym "is-err"; expr] -> IsErr (parse_expression expr)
  | List [Sym "is-ok"; expr] -> IsOk (parse_expression expr)
  | List [Sym "default-to"; def; opt] -> DefaultTo ((parse_expression def), (parse_expression opt))
  | List [Sym "var-get"; Sym var] -> VarGet var
  | List [Sym "var-set"; Sym var; val'] -> VarSet (var, parse_expression val')
  | List [Sym "err"; expr] -> Err (parse_expression expr)
  | List [Sym "ok"; expr] -> Ok (parse_expression expr)
  | List [Sym "not"; expr] -> Not (parse_expression expr)
  | List (Sym "and" :: exprs) -> And (List.map parse_expression exprs)
  | List (Sym "or" :: exprs) -> Or (List.map parse_expression exprs)
  | List (Sym "is-eq" :: exprs) -> Eq (List.map parse_expression exprs)
  | List [Sym "<"; a; b] -> Lt (parse_expression a, parse_expression b)
  | List [Sym "<="; a; b] -> Le (parse_expression a, parse_expression b)
  | List [Sym ">"; a; b] -> Gt (parse_expression a, parse_expression b)
  | List [Sym ">="; a; b] -> Ge (parse_expression a, parse_expression b)
  | List (Sym "+" :: exprs) -> Add (List.map parse_expression exprs)
  | List (Sym "-" :: exprs) -> Sub (List.map parse_expression exprs)
  | List (Sym "*" :: exprs) -> Mul (List.map parse_expression exprs)
  | List (Sym "/" :: exprs) -> Div (List.map parse_expression exprs)
  | List [Sym "mod"; a; b] -> Mod (parse_expression a, parse_expression b)
  | List [Sym "pow"; a; b] -> Pow (parse_expression a, parse_expression b)
  | List [Sym "xor"; a; b] -> Xor (parse_expression a, parse_expression b)
  | List [Sym "len"; expr] -> Len (parse_expression expr)
  | List [Sym "try!"; input] -> Try (parse_expression input)
  | List [Sym "unwrap!"; input; thrown] -> Unwrap ((parse_expression input), (parse_expression thrown))
  | List [Sym "unwrap-panic"; input] -> UnwrapPanic (parse_expression input)
  | List [Sym "unwrap-err!"; input; thrown] -> UnwrapErr ((parse_expression input), (parse_expression thrown))
  | List [Sym "unwrap-err-panic"; input] -> UnwrapErrPanic (parse_expression input)
  | List [Sym "if"; cond; then'; else'] -> If ((parse_expression cond), (parse_expression then'), (parse_expression else'))
  | List [Sym "to-int"; expr] -> ToInt (parse_expression expr)
  | List [Sym "to-uint"; expr] -> ToUint (parse_expression expr)
  | List (Sym name :: args) -> FunctionCall (name, (List.map parse_expression args))
  | List _ -> failwith "invalid Clarity expression"

and parse_type = function
  | Sym "principal" -> Principal
  | Sym "bool" -> Bool
  | Sym "int" -> Int
  | Sym "uint" -> Uint
  | List [Sym "optional"; t] -> Optional (parse_type t)
  | List [Sym "response"; ok; err] -> Response (parse_type ok, parse_type err)
  | List [Sym "buff"; Lit (IntLiteral len)] -> Buff (Integer.to_int len)
  | List [Sym "string-ascii"; Lit (IntLiteral len)] -> String (Integer.to_int len, ASCII)
  | List [Sym "string-utf8"; Lit (IntLiteral len)] -> String (Integer.to_int len, UTF8)
  | List [Sym "list"; Lit (IntLiteral len); t] -> List (Integer.to_int len, parse_type t)
  | List (Sym "tuple" :: _) -> Tuple []  (* TODO: tuple *)
  | _ -> failwith "invalid Clarity type"
