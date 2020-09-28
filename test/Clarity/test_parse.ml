(* This is free and unencumbered software released into the public domain. *)

open Clarity

let eq_expression a b = match (a, b) with
  | (Literal (IntLiteral a), Literal (IntLiteral b)) -> Big_int.eq_big_int a b
  | (Literal (UintLiteral a), Literal (UintLiteral b)) -> Big_int.eq_big_int a b
  | (a, b) -> a = b

let check_expressions input output =
  let expression = Alcotest.testable Clarity.print_expression eq_expression in
  let lexbuf = Lexing.from_string input in
  let program = Clarity.parse Clarity.read_token lexbuf in
  Alcotest.(check (list expression)) "" output program

let check_expression input output =
  let expression = Alcotest.testable Clarity.print_expression eq_expression in
  let lexbuf = Lexing.from_string input in
  let program = Clarity.expression Clarity.read_token lexbuf in
  Alcotest.(check expression) "" output program

let check_literal input output =
  check_expression input (Literal output)

let literal () =
  check_literal "none" (NoneLiteral);
  check_literal "false" (BoolLiteral false);
  check_literal "true" (BoolLiteral true);
  check_literal "42" (IntLiteral (Big_int.big_int_of_int 42));
  check_literal "u42" (UintLiteral (Big_int.big_int_of_int 42));
  check_literal "0xabcd" (BuffLiteral "\xab\xcd");
  check_literal "0xABCD" (BuffLiteral "\xab\xcd")

let expression () =
  check_expression "()" (ListExpression [])

let expressions () =
  check_expressions "" [];
  check_expressions "none" [Literal NoneLiteral];
  check_expressions "true false" [Literal (BoolLiteral true); Literal (BoolLiteral false)];
  check_expressions "()" [ListExpression []];
  check_expressions "(none)" [ListExpression [Literal NoneLiteral]];
  check_expressions "(true false)" [ListExpression [Literal (BoolLiteral true); Literal (BoolLiteral false)]]

let () =
  Alcotest.run "Clarity" [
    "parse", [
      "literal", `Quick, literal;
      "expression", `Quick, expression;
      "expressions", `Quick, expressions;
    ];
  ]
