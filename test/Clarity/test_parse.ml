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
  check_literal "42" (int_literal 42);
  check_literal "u42" (uint_literal 42);
  check_literal "0xabcd" (BuffLiteral "\xab\xcd");
  check_literal "0xABCD" (BuffLiteral "\xab\xcd");
  check_literal {|"Hello"|} (StringLiteral "Hello");
  check_literal {|"\t\r\n"|} (StringLiteral "\t\r\n");
  check_literal "{ id: 1337 }" (TupleLiteral ("id", int_literal 1337));
  check_literal "{ name: \"blockstack\" }" (TupleLiteral ("name", StringLiteral "blockstack"))

let expressions () =
  let open Sexp in
  check_parse "" [];
  check_parse "()"  [List []];
  check_parse "(foobar)"  [List [Sym "foobar"]];
  check_parse "(42)"  [List [Lit (int_literal 42)]];
  check_parse "(1 2)" [List [Lit (int_literal 1); Lit (int_literal 2)]];
  check_parse "((42))"  [List [List [Lit (int_literal 42)]]]

let () =
  Alcotest.run "Clarity" [
    "parse", [
      "literal", `Quick, literal;
      "expressions", `Quick, expressions;
    ];
  ]
