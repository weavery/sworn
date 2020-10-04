(* This is free and unencumbered software released into the public domain. *)

let rec compile_program program =
  List.map compile_definition program

and compile_definition = function
  | Clarity.Constant (name, value) ->
    Const (name, I128, compile_expression value)  (* FIXME: type *)
  | DataVar (name, type', value) ->
    Global (name, compile_type type', Some (compile_expression value))
  | Map (name, (_, key_type), (_, val_type)) ->
    Global (name, Map (compile_type key_type, compile_type val_type), None)
  | PublicFunction func -> Function (compile_function Public func)
  | PublicReadOnlyFunction func -> Function (compile_function PublicPure func)
  | PrivateFunction func -> Function (compile_function Private func)

and compile_function modifier (name, params, body) =
  (modifier, name, List.map compile_parameter params, List.map compile_expression body)

and compile_parameter = function
  | (name, type') -> (name, Some (compile_type type'))

and compile_expression = function
  | Clarity.Keyword id -> compile_keyword id
  | Identifier id -> Identifier id
  | Literal lit -> Literal (compile_literal lit)
  | SomeExpression expr -> SomeExpression (compile_expression expr)
  | ListExpression exprs -> ListExpression (List.map compile_expression exprs)
  | IsNone expr -> IsNone (compile_expression expr)
  | IsSome expr -> IsSome (compile_expression expr)
  | IsErr expr -> IsErr (compile_expression expr)
  | IsOk expr -> IsOk (compile_expression expr)
  | DefaultTo (def, opt) -> DefaultTo (compile_expression def, compile_expression opt)
  | VarGet (var) -> VarGet var
  | VarSet (var, val') -> VarSet (var, compile_expression val')
  | Err expr -> Err (compile_expression expr)
  | Ok expr -> Ok (compile_expression expr)
  | Not expr -> Not (compile_expression expr)
  | And exprs -> And (List.map compile_expression exprs)
  | Or exprs -> Or (List.map compile_expression exprs)
  | Eq exprs -> Eq (List.map compile_expression exprs)
  | Lt (a, b) -> Lt (compile_expression a, compile_expression b)
  | Le (a, b) -> Le (compile_expression a, compile_expression b)
  | Gt (a, b) -> Gt (compile_expression a, compile_expression b)
  | Ge (a, b) -> Ge (compile_expression a, compile_expression b)
  | Add exprs -> Add (List.map compile_expression exprs)
  | Sub exprs -> Sub (List.map compile_expression exprs)
  | Mul exprs -> Mul (List.map compile_expression exprs)
  | Div exprs -> Div (List.map compile_expression exprs)
  | Mod (a, b) -> Mod (compile_expression a, compile_expression b)
  | Pow (a, b) -> Pow (compile_expression a, compile_expression b)
  | Xor (a, b) -> Xor (compile_expression a, compile_expression b)
  | Len expr -> Len (compile_expression expr)
  | ToInt expr -> ToInt (compile_expression expr)
  | ToUint expr -> ToUint (compile_expression expr)
  | FunctionCall (name, args) -> compile_function_call name args
  | Try input -> Try (compile_expression input)
  | Unwrap (input, thrown) -> Unwrap (compile_expression input, compile_expression thrown)
  | UnwrapPanic input -> UnwrapPanic (compile_expression input)
  | UnwrapErr (input, thrown) -> UnwrapErr (compile_expression input, compile_expression thrown)
  | UnwrapErrPanic input -> UnwrapErrPanic (compile_expression input)
  | If (cond, then', else') ->
    If (compile_expression cond, compile_expression then', compile_expression else')

and compile_function_call name args = match name with
  | "at-block"
  | "contract-call?"
  | "contract-of"
  | "define-trait"
  | "get-block-info?"
  | "impl-trait"
  | "stx-burn?"
  | "stx-get-balance"
  | "stx-transfer?"
  | "use-trait" -> failwith (sprintf "%s is not supported on SmartWeave" name)
  | "asserts!" -> begin match args with
      | [cond; thrown] -> Assert (compile_expression cond, compile_expression thrown)
      | _ -> failwith "invalid asserts! operation"
    end
  | _ -> FunctionCall (name, List.map compile_expression args)

and compile_keyword = function
  | id -> FunctionCall (id, [])

and compile_literal = function
  | Clarity.NoneLiteral -> NoneLiteral
  | BoolLiteral b -> BoolLiteral b
  | IntLiteral z -> I128Literal z
  | UintLiteral n -> U128Literal n
  | BuffLiteral s -> BufferLiteral s
  | StringLiteral s -> StringLiteral s
  | TupleLiteral (k, v) -> RecordLiteral (k, compile_literal v)

and compile_type = function
  | Clarity.Principal -> Principal
  | Bool -> Bool
  | Int -> I128
  | Uint -> U128
  | Optional t -> Optional (compile_type t)
  | Response (ok, err) -> Response (compile_type ok, compile_type err)
  | Buff (len) -> Buff len
  | String (len, _) -> String len
  | List (len, t) -> List (len, compile_type t)
  | Tuple fields -> Record (List.map compile_tuple_field fields)

and compile_tuple_field (name, type') =
  (name, compile_type type')
