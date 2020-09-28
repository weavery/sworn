(* This is free and unencumbered software released into the public domain. *)

open Clarity

let check_expression input output =
  let expression = Alcotest.testable Clarity.print_expression (=) in
  let lexbuf = Lexing.from_string input in
  match Clarity.expression Clarity.read_token lexbuf with
  | None -> failwith "unreachable"
  | Some program -> Alcotest.(check expression) "" output program

let booleans () =
  check_expression "true" (Literal (BoolLiteral true));
  check_expression "false" (Literal (BoolLiteral false))

let () =
  Alcotest.run "Clarity" [
    "parse", [
      "booleans", `Quick, booleans;
    ];
  ]
