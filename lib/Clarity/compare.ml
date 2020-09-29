(* This is free and unencumbered software released into the public domain. *)

let rec equal_expression a b = match (a, b) with
  | (Literal a, Literal b) -> equal_literal a b
  | (a, b) -> a = b

and equal_literal a b = match (a, b) with
  | IntLiteral a, IntLiteral b -> Integer.equal a b
  | UintLiteral a, UintLiteral b -> Integer.equal a b
  | TupleLiteral (ak, av), TupleLiteral (bk, bv) ->
    (ak = bk) && (equal_literal av bv)
  | (a, b) -> a = b
