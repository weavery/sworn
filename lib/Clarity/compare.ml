(* This is free and unencumbered software released into the public domain. *)

let rec equal_expression a b = match (a, b) with
  | (Literal a, Literal b) -> equal_literal a b
  | (a, b) -> a = b

and equal_literal a b = match (a, b) with
  | IntLiteral a, IntLiteral b -> Big_int.eq_big_int a b
  | UintLiteral a, UintLiteral b -> Big_int.eq_big_int a b
  | (a, b) -> a = b
