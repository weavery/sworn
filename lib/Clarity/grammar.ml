(* This is free and unencumbered software released into the public domain. *)

type program = definition list

and definition =
  | Constant of identifier * expression
  | DataVar of identifier * type' * expression
  | Map of identifier * (identifier * type') * (identifier * type')
  | PublicFunction of function'
  | PublicReadOnlyFunction of function'
  | PrivateFunction of function'

and function' = identifier * parameter list * expression list

and parameter = string * type'

and expression =
  | Literal of literal
  | SomeExpression of expression
  | IsNone of expression
  | IsSome of expression
  | DefaultTo of expression * expression
  | VarGet of identifier
  | VarSet of identifier * expression
  | Ok of expression
  | Not of expression
  | And of expression list
  | Or of expression list
  | Add of expression list
  | Sub of expression list
  | Mul of expression list
  | Div of expression list
  | Mod of expression * expression
  | Pow of expression * expression
  | Xor of expression * expression

and literal =
  | NoneLiteral
  | BoolLiteral of bool
  | IntLiteral of Big_int.big_int
  | UintLiteral of Big_int.big_int
  | StringLiteral of string

and identifier = string

and type' =
  | Principal
  | Bool
  | Int
  | Uint
  | Optional of type'
  | String of int * string_encoding
  | List of int * type'

and string_encoding =
  | ASCII
  | UTF8
