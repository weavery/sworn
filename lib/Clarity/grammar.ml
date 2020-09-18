(* This is free and unencumbered software released into the public domain. *)

type program = definition list

and definition =
  | DataVar of identifier * type' * expression
  | PublicFunction of function'
  | PublicReadOnlyFunction of function'
  | PrivateFunction of function'

and function' = identifier * parameter list * expression list

and parameter = string * type'

and expression =
  | Literal of literal
  | VarGet of identifier
  | VarSet of identifier * expression
  | Ok of expression
  | Add of expression * expression
  | Sub of expression * expression

and literal =
  | BoolLiteral of bool
  | IntLiteral of int64
  | UintLiteral of int64
  | StringLiteral of string

and identifier = string

and type' =
  | Principal
  | Bool
  | Int
  | Uint
  | String