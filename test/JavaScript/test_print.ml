(* This is free and unencumbered software released into the public domain. *)

let check_expression input output =
  let lexbuf = Lexing.from_string input in
  let sexp = Clarity.expression Clarity.read_token lexbuf in
  let clarity = Clarity.parse_expression sexp in
  let swir = SWIR.compile_expression clarity in
  let ppf = Format.str_formatter in
  let _ = Format.fprintf ppf "@[<h>%a@]" JavaScript.print_expression swir in
  let actual = Format.flush_str_formatter () in
  Alcotest.(check string) "" output actual

let boolean_logic () =
  check_expression "false" "false";
  check_expression "true" "true";
  check_expression "(not true)" "(!true)";
  check_expression "(and true false)" "(true && false)";
  check_expression "(or true false)" "(true || false)"

let relational_operators () =
  check_expression "(is-eq 1 2 3)" "clarity.isEq(1, 2, 3)";
  check_expression "(< 1 2)" "(1 < 2)";
  check_expression "(<= 1 2)" "(1 <= 2)";
  check_expression "(> 1 2)" "(1 > 2)";
  check_expression "(>= 1 2)" "(1 >= 2)"

let integer_arithmetic () =
  check_expression "-123" "-123";
  check_expression "123" "123";
  check_expression "(+ 1 2 3)" "(1 + 2 + 3)";
  check_expression "(- 1 2 3)" "(1 - 2 - 3)";
  check_expression "(* 1 2 3)" "(1 * 2 * 3)";
  check_expression "(/ 1 2 3)" "(1 / 2 / 3)";
  check_expression "(mod 2 3)" "(2 % 3)";
  check_expression "(pow 2 3)" "(2 ** 3)";
  check_expression "(xor 1 2)" "(1 ^ 2)"

let optional_values () =
  check_expression "none" "null";
  check_expression "(some 1)" "clarity.some(1)";
  check_expression "(is-none 1)" "clarity.isNone(1)";
  check_expression "(is-some 1)" "clarity.isSome(1)";
  check_expression "(default-to 0 (some 1))" "(clarity.some(1) ?? 0)"

let sequence_operations () =
  check_expression "(list 1 2 3)" "[1, 2, 3]";
  check_expression "(len \"foobar\")" "\"foobar\".length"

let () =
  Alcotest.run "JavaScript" [
    "print", [
      "boolean logic", `Quick, boolean_logic;
      "relational operators", `Quick, relational_operators;
      "integer arithmetic", `Quick, integer_arithmetic;
      "optional values", `Quick, optional_values;
      "sequence operations", `Quick, sequence_operations;
    ];
  ]
