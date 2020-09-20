(* This is free and unencumbered software released into the public domain. *)

type program = definition list

and definition =
  | Const of identifier * type' * expression
  | Global of identifier * type' * expression option
  | Function of function'

and function' =
  modifier * identifier * parameter list * expression list

and modifier =
  | Private
  | Public
  | PublicPure

and parameter = string * type' option

and expression =
  | Literal of literal
  | SomeExpression of expression
  | IsNone of expression
  | IsSome of expression
  | VarGet of identifier
  | VarSet of identifier * expression
  | Ok of expression
  | Add of expression list
  | Sub of expression list
  | Mul of expression list
  | Div of expression list
  | Mod of expression * expression
  | Pow of expression * expression

and literal =
  | NoneLiteral
  | BoolLiteral of bool
  | I64Literal of int64
  | U64Literal of int64
  | I128Literal of Big_int.big_int
  | U128Literal of Big_int.big_int
  | StringLiteral of string

and identifier = string

and type' =
  | Bool
  | I64
  | U64
  | I128
  | U128
  | Optional of type'
  | String of int
  | List of int * type'
  | Map of type' * type'
