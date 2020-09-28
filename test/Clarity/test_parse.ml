(* This is free and unencumbered software released into the public domain. *)

open Clarity

let eq_expression a b = match (a, b) with
  | (Literal (IntLiteral a), Literal (IntLiteral b)) -> Big_int.eq_big_int a b
  | (Literal (UintLiteral a), Literal (UintLiteral b)) -> Big_int.eq_big_int a b
  | (Literal a, Literal b) -> a = b
  | _ -> failwith "unreachable"

let check_expression input output =
  let expression = Alcotest.testable Clarity.print_expression eq_expression in
  let lexbuf = Lexing.from_string input in
  match Clarity.expression Clarity.read_token lexbuf with
  | None -> failwith "unreachable"
  | Some program -> Alcotest.(check expression) "" output program

let check_literal input output =
  check_expression input (Literal output)

let literals () =
  check_literal "none" (NoneLiteral);
  check_literal "false" (BoolLiteral false);
  check_literal "true" (BoolLiteral true);
  check_literal "42" (IntLiteral (Big_int.big_int_of_int 42));
  check_literal "u42" (UintLiteral (Big_int.big_int_of_int 42));
  check_literal "0xabcd" (BuffLiteral "\xab\xcd");
  check_literal "0xABCD" (BuffLiteral "\xab\xcd")

let () =
  Alcotest.run "Clarity" [
    "parse", [
      "literals", `Quick, literals;
    ];
  ]
