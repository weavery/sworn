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
  | List [Atom "define-data-var"; Atom name; Atom type'; value] ->
    DataVar (name, parse_type type', parse_expression value)
  | List [Atom "define-map"; Atom name;
      List [List [Atom key_name; Atom key_type]];
      List [List [Atom val_name; Atom val_type]]] ->
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
  | List [Atom name; Atom typename] -> (name, parse_type typename)
  | _ -> failwith "invalid Clarity function parameter"

and parse_type = function
  | "principal" -> Principal
  | "bool" -> Bool
  | "int" -> Int
  | "uint" -> Uint
  | "string" -> String
  | _ -> failwith "invalid Clarity type"

and parse_function_body sexp =
  let open Sexplib.Sexp in
  match sexp with
  | List ((Atom "begin") :: exprs) -> List.map parse_expression exprs
  | sexp -> [parse_expression sexp]

and parse_expression sexp =
  let open Sexplib.Sexp in
  match sexp with
  | Atom s -> Literal (match Big_int.big_int_of_string_opt s with Some n -> IntLiteral n | None -> StringLiteral s)
  | List [Atom "var-get"; Atom var] -> VarGet var
  | List [Atom "var-set"; Atom var; val'] -> VarSet (var, parse_expression val')
  | List [Atom "ok"; expr] -> Ok (parse_expression expr)
  | List [Atom "+"; a; b] -> Add (parse_expression a, parse_expression b)
  | List [Atom "-"; a; b] -> Sub (parse_expression a, parse_expression b)
  | _ -> failwith "TODO: parse_expression"  (* TODO *)
