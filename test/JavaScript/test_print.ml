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

let operators () =
  check_expression "(append (list 1 2 3 4) 5)" "clarity.append([1, 2, 3, 4], 5)";

  check_expression "(as-max-len? (list 2 2 2) u3)" "clarity.asMaxLen([2, 2, 2], 3)";
  check_expression "(as-max-len? (list 1 2 3) u2)" "clarity.asMaxLen([1, 2, 3], 2)";

  check_expression "(asserts! (is-eq 1 1) (err 1))"
    "if (!clarity.isEq(1, 1)) return result = clarity.err(1)";  (* FIXME *)

  check_expression "block-height" "clarity.blockHeight()";

  check_expression "(concat \"hello \" \"world\")" "clarity.concat(\"hello \", \"world\")";

  check_expression "contract-caller" "clarity.contractCaller()";
  check_expression "(default-to 0 (some 1))" "(clarity.some(1) ?? 0)";

  check_expression "(get id (tuple (name \"blockstack\") (id 1337)))"
    "clarity.get(\"id\", clarity.tuple([\"name\", \"blockstack\"], [\"id\", 1337]))";

  check_expression "(is-eq 1 1)" "clarity.isEq(1, 1)";

  (* FIXME: check_expression "(is-err (ok 1))" "clarity.isErr(clarity.ok(1))"; *)
  (* FIXME: check_expression "(is-err (err 1))" "clarity.isErr(clarity.err(1))"; *)

  check_expression "(is-none 1)" "clarity.isNone(1)";

  (* FIXME: check_expression "(is-ok (ok 1))" "clarity.isOk(clarity.ok(1))"; *)
  (* FIXME: check_expression "(is-ok (err 1))" "clarity.isOk(clarity.err(1))"; *)

  check_expression "(is-some 1)" "clarity.isSome(1)";

  check_expression "(len \"blockstack\")" "\"blockstack\".length";
  check_expression "(len (list 1 2 3 4 5))" "[1, 2, 3, 4, 5].length";

  check_expression "(let ((x 42)) x)"
    "(() => { const x = 42; return x })()";
  check_expression "(let ((a 1) (b 2)) a b)"
    "(() => { const a = 1; const b = 2; a; return b })()";

  check_expression "(list 1 2 3)" "[1, 2, 3]";

  check_expression "none" "null";

  check_expression "(some 1)" "clarity.some(1)";

  check_expression "(tuple (name \"blockstack\") (id 1337))"
    "clarity.tuple([\"name\", \"blockstack\"], [\"id\", 1337])";

  check_expression "tx-sender" "clarity.txSender()"

let () =
  Alcotest.run "JavaScript" [
    "print", [
      "boolean logic", `Quick, boolean_logic;
      "relational operators", `Quick, relational_operators;
      "integer arithmetic", `Quick, integer_arithmetic;
      "operators", `Quick, operators;
    ];
  ]
