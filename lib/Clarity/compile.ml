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
  | PublicFunction func -> SWIR.Function (compile_function func)
  | PublicReadOnlyFunction func -> SWIR.Function (compile_function func)
  | PrivateFunction func -> SWIR.Function (compile_function func)

and compile_function (name, params, body) =
  (name, List.map compile_parameter params, List.map compile_expression body)

and compile_parameter = function
  | (name, type') -> (name, Some (compile_type type'))

and compile_expression = function
  | Literal lit -> SWIR.Literal (compile_literal lit)
  | VarGet (var) -> SWIR.VarGet var
  | VarSet (var, val') -> SWIR.VarSet (var, compile_expression val')
  | Ok expr -> SWIR.Ok (compile_expression expr)
  | Add (a, b) -> SWIR.Add (compile_expression a, compile_expression b)
  | Sub (a, b) -> SWIR.Sub (compile_expression a, compile_expression b)

and compile_literal = function
  | BoolLiteral b -> SWIR.BoolLiteral b
  | IntLiteral z -> SWIR.I128Literal z
  | UintLiteral n -> SWIR.U128Literal n
  | StringLiteral s -> SWIR.StringLiteral s

and compile_type = function
  | Principal -> failwith "TODO: compile_type"  (* TODO *)
  | Bool -> SWIR.Bool
  | Int -> SWIR.I128
  | Uint -> SWIR.U128
  | String -> SWIR.String
