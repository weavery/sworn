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
  | ListExpression of expression list
  | IsNone of expression
  | IsSome of expression
  | IsErr of expression
  | IsOk of expression
  | DefaultTo of expression * expression
  | VarGet of identifier
  | VarSet of identifier * expression
  | Err of expression
  | Ok of expression
  | Not of expression
  | And of expression list
  | Or of expression list
  | Eq of expression list
  | Lt of expression * expression
  | Le of expression * expression
  | Gt of expression * expression
  | Ge of expression * expression
  | Add of expression list
  | Sub of expression list
  | Mul of expression list
  | Div of expression list
  | Mod of expression * expression
  | Pow of expression * expression
  | Xor of expression * expression
  | Len of expression
  | FunctionCall of identifier * expression list
  | Print of expression
  | Try of expression
  | Unwrap of expression * expression
  | UnwrapPanic of expression
  | UnwrapErr of expression * expression
  | UnwrapErrPanic of expression
  | If of expression * expression * expression

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
  | Principal
  | Bool
  | I64
  | U64
  | I128
  | U128
  | Optional of type'
  | Response of type' * type'
  | Buff of int
  | String of int
  | List of int * type'
  | Map of type' * type'
  | Record of record_field list

and record_field = identifier * type'
