(* This is free and unencumbered software released into the public domain. *)

(* See: https://solidity.readthedocs.io/en/develop/yul.html#specification-of-yul *)

type t = block

and block = statement list

and statement =
  | Block of block
  | FunctionDefinition of function_definition
  | VariableDeclaration of variable_declaration
  | Assignment of assignment
  | If of if_statement
  | Expression of expression
  | Switch of switch_statement
  | ForLoop of for_loop
  | Break
  | Continue
  | Leave

and function_definition = identifier * typed_identifier list * typed_identifier list * block

and variable_declaration = typed_identifier list * expression option

and assignment = identifier list * expression

and expression =
  | FunctionCall of function_call
  | Identifier of identifier
  | Literal of literal

and if_statement = expression * block

and switch_statement = expression * switch_case list * switch_default option

and switch_case = literal * block

and switch_default = block

and for_loop = block * expression * block * block

and function_call = identifier * expression list

and identifier = string

and type_name = identifier

and typed_identifier = identifier * type_name option

and literal =
  | NumberLiteral of float
  | StringLiteral of string
  | BooleanLiteral of bool
