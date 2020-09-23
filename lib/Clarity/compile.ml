(* This is free and unencumbered software released into the public domain. *)

let rec compile_program program =
  List.map compile_definition program

and compile_definition = function
  | Constant (name, value) ->
    SWIR.Const (name, SWIR.I128, compile_expression value)  (* FIXME: type *)
  | DataVar (name, type', value) ->
    SWIR.Global (name, compile_type type', Some (compile_expression value))
  | Map (name, (_, key_type), (_, val_type)) ->
    SWIR.Global (name, SWIR.Map (compile_type key_type, compile_type val_type), None)
  | PublicFunction func -> SWIR.Function (compile_function SWIR.Public func)
  | PublicReadOnlyFunction func -> SWIR.Function (compile_function SWIR.PublicPure func)
  | PrivateFunction func -> SWIR.Function (compile_function SWIR.Private func)

and compile_function modifier (name, params, body) =
  (modifier, name, List.map compile_parameter params, List.map compile_expression body)

and compile_parameter = function
  | (name, type') -> (name, Some (compile_type type'))

and compile_expression = function
  | Literal lit -> SWIR.Literal (compile_literal lit)
  | SomeExpression expr -> SWIR.SomeExpression (compile_expression expr)
  | ListExpression exprs -> SWIR.ListExpression (List.map compile_expression exprs)
  | IsNone expr -> SWIR.IsNone (compile_expression expr)
  | IsSome expr -> SWIR.IsSome (compile_expression expr)
  | IsErr expr -> SWIR.IsErr (compile_expression expr)
  | IsOk expr -> SWIR.IsOk (compile_expression expr)
  | DefaultTo (def, opt) -> SWIR.DefaultTo (compile_expression def, compile_expression opt)
  | VarGet (var) -> SWIR.VarGet var
  | VarSet (var, val') -> SWIR.VarSet (var, compile_expression val')
  | Err expr -> SWIR.Err (compile_expression expr)
  | Ok expr -> SWIR.Ok (compile_expression expr)
  | Not expr -> SWIR.Not (compile_expression expr)
  | And exprs -> SWIR.And (List.map compile_expression exprs)
  | Or exprs -> SWIR.Or (List.map compile_expression exprs)
  | Eq exprs -> SWIR.Eq (List.map compile_expression exprs)
  | Lt (a, b) -> SWIR.Lt (compile_expression a, compile_expression b)
  | Le (a, b) -> SWIR.Le (compile_expression a, compile_expression b)
  | Gt (a, b) -> SWIR.Gt (compile_expression a, compile_expression b)
  | Ge (a, b) -> SWIR.Ge (compile_expression a, compile_expression b)
  | Add exprs -> SWIR.Add (List.map compile_expression exprs)
  | Sub exprs -> SWIR.Sub (List.map compile_expression exprs)
  | Mul exprs -> SWIR.Mul (List.map compile_expression exprs)
  | Div exprs -> SWIR.Div (List.map compile_expression exprs)
  | Mod (a, b) -> SWIR.Mod (compile_expression a, compile_expression b)
  | Pow (a, b) -> SWIR.Pow (compile_expression a, compile_expression b)
  | Xor (a, b) -> SWIR.Xor (compile_expression a, compile_expression b)
  | Len expr -> SWIR.Len (compile_expression expr)
  | FunctionCall (name, args) -> SWIR.FunctionCall (name, List.map compile_expression args)
  | Print expr -> SWIR.Print (compile_expression expr)
  | Try input -> SWIR.Try (compile_expression input)
  | Unwrap (input, thrown) -> SWIR.Unwrap (compile_expression input, compile_expression thrown)
  | UnwrapPanic input -> SWIR.UnwrapPanic (compile_expression input)
  | UnwrapErr (input, thrown) -> SWIR.UnwrapErr (compile_expression input, compile_expression thrown)
  | UnwrapErrPanic input -> SWIR.UnwrapErrPanic (compile_expression input)
  | If (cond, then', else') ->
    SWIR.If (compile_expression cond, compile_expression then', compile_expression else')

and compile_literal = function
  | NoneLiteral -> SWIR.NoneLiteral
  | BoolLiteral b -> SWIR.BoolLiteral b
  | IntLiteral z -> SWIR.I128Literal z
  | UintLiteral n -> SWIR.U128Literal n
  | StringLiteral s -> SWIR.StringLiteral s

and compile_type = function
  | Principal -> SWIR.Principal
  | Bool -> SWIR.Bool
  | Int -> SWIR.I128
  | Uint -> SWIR.U128
  | Optional t -> SWIR.Optional (compile_type t)
  | Response (ok, err) -> SWIR.Response (compile_type ok, compile_type err)
  | Buff (len) -> SWIR.Buff len
  | String (len, _) -> SWIR.String len
  | List (len, t) -> SWIR.List (len, compile_type t)
  | Tuple fields -> SWIR.Record (List.map compile_tuple_field fields)

and compile_tuple_field (name, type') =
  (name, compile_type type')
