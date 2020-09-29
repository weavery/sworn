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
  | Identifier of string
  | Literal of literal
  | SomeExpression of expression
  | ListExpression of expression list
  (* TODO: TupleExpression *)
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
  | ToInt of expression
  | ToUint of expression
  | FunctionCall of identifier * expression list
  | Try of expression
  | Unwrap of expression * expression
  | UnwrapPanic of expression
  | UnwrapErr of expression * expression
  | UnwrapErrPanic of expression
  | If of expression * expression * expression

and literal =
  | NoneLiteral
  | BoolLiteral of bool
  | IntLiteral of Integer.t
  | UintLiteral of Integer.t
  | BuffLiteral of string
  | StringLiteral of string
  | TupleLiteral of string * literal

and identifier = string

and type' =
  | Principal
  | Bool
  | Int
  | Uint
  | Optional of type'
  | Response of type' * type'
  | Buff of int
  | String of int * string_encoding
  | List of int * type'
  | Tuple of tuple_field list

and tuple_field = identifier * type'

and string_encoding =
  | ASCII
  | UTF8
