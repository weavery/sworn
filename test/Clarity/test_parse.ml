(* This is free and unencumbered software released into the public domain. *)

open Clarity

let check_parse input output =
  let lexbuf = Lexing.from_string input in
  let program = Clarity.parse Clarity.read_token lexbuf in
  let parse = Alcotest.testable Sexp.print Sexp.equal in
  Alcotest.(check (list parse)) "" output program

let check_literal input output =
  let lexbuf = Lexing.from_string input in
  let program = Clarity.literal Clarity.read_token lexbuf in
  let literal = Alcotest.testable Clarity.print_literal Clarity.equal_literal in
  Alcotest.(check literal) "" output program

let literal () =
  check_literal "none" (NoneLiteral);
  check_literal "false" (BoolLiteral false);
  check_literal "true" (BoolLiteral true);
  check_literal "42" (IntLiteral (Big_int.big_int_of_int 42));
  check_literal "u42" (UintLiteral (Big_int.big_int_of_int 42));
  check_literal "0xabcd" (BuffLiteral "\xab\xcd");
  check_literal "0xABCD" (BuffLiteral "\xab\xcd")

let expressions () =
  check_parse "" [];
  check_parse "()"  [Sexp.List []];
  check_parse "(42)"  [Sexp.List [Sexp.Atom (IntLiteral (Big_int.big_int_of_int 42))]];
  check_parse "((43))"  [Sexp.List [Sexp.List [Sexp.Atom (IntLiteral (Big_int.big_int_of_int 42))]]]

let () =
  Alcotest.run "Clarity" [
    "parse", [
      "literal", `Quick, literal;
      "expressions", `Quick, expressions;
    ];
  ]
