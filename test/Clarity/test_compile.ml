(* This is free and unencumbered software released into the public domain. *)

let check_type input output =
  let input = Sexplib.Sexp.of_string input in
  let clarity = Clarity.parse_type input in
  let swir = Clarity.compile_type clarity in
  let actual = SWIR.type_to_string swir in
  Alcotest.(check string) "" output actual

let check_expression input output =
  let input = Sexplib.Sexp.of_string input in
  let clarity = Clarity.parse_expression input in
  let swir = Clarity.compile_expression clarity in
  let ppf = Format.str_formatter in
  let _ = Format.fprintf ppf "@[<h>%a@]" SWIR.print_expression swir in
  let actual = Format.flush_str_formatter () in
  Alcotest.(check string) "" output actual

let check_definition ~input ~output =
  let input = Sexplib.Sexp.of_string input in
  let clarity = Clarity.parse_definition input in
  let swir = Clarity.compile_definition clarity in
  let ppf = Format.str_formatter in
  let _ = Format.fprintf ppf "@[<h>%a@]" SWIR.print_definition swir in
  let actual = Format.flush_str_formatter () in
  Alcotest.(check string) "" output actual

let types () =
  check_type "bool" "bool";
  check_type "int" "i128";
  check_type "uint" "u128";
  (* TODO: principal *)
  check_type "(optional int)" "(optional i128)";
  check_type "(string-ascii 10)" "(string 10)";
  check_type "(string-utf8 10)" "(string 10)";
  check_type "(list 10 int)" "(list 10 i128)"

let boolean_logic () =
  check_expression "false" "false";
  check_expression "true" "true";
  check_expression "(not true)" "(not true)";
  check_expression "(and true false)" "(and true false)";
  check_expression "(or true false)" "(or true false)"

let relational_operators () =
  check_expression "(is-eq 1 2 3)" "(= 1 2 3)";
  check_expression "(< 1 2)" "(< 1 2)";
  check_expression "(<= 1 2)" "(<= 1 2)";
  check_expression "(> 1 2)" "(> 1 2)";
  check_expression "(>= 1 2)" "(>= 1 2)"

let integer_arithmetic () =
  check_expression "-123" "-123";
  check_expression "123" "123";
  check_expression "(+ 1 2 3)" "(+ 1 2 3)";
  check_expression "(- 1 2 3)" "(- 1 2 3)";
  check_expression "(* 1 2 3)" "(* 1 2 3)";
  check_expression "(/ 1 2 3)" "(/ 1 2 3)";
  check_expression "(mod 2 3)" "(mod 2 3)";
  check_expression "(pow 2 3)" "(pow 2 3)";
  check_expression "(xor 1 2)" "(xor 1 2)"

let optional_values () =
  check_expression "none" "none";
  check_expression "(some 1)" "(some 1)";
  check_expression "(is-none 1)" "(is-none 1)";
  check_expression "(is-some 1)" "(is-some 1)";
  check_expression "(default-to 0 (some 1))" "(default-to 0 (some 1))"

let sequence_operations () =
  check_expression "(list 1 2 3)" "(list 1 2 3)";
  check_expression "(len \"foobar\")" "(len \"foobar\")"

let define_constant () =
  check_definition
    ~input:"(define-constant answer 42)"
    ~output:"(define answer (const i128 42))"

let define_data_var () =
  check_definition
    ~input:"(define-data-var counter int 0)"
    ~output:"(define counter (global i128 0))"

let define_map () =
  check_definition
    ~input:"(define-map squares ((x int)) ((square int)))"
    ~output:"(define squares (global (map i128 i128)))"

let define_read_only () =
  check_definition
    ~input:"(define-read-only (get-counter) (var-get counter))"
    ~output:"(define get-counter\n  (function () @public @pure\n    (var-get counter)))"

let hello_world () =
  check_definition
    ~input:{|(define-public (say-hi) (ok "hello world"))|}
    ~output:"(define say-hi\n  (function () @public\n    (ok \"hello world\")))";
  check_definition
    ~input:{|(define-public (echo-number (val int)) (ok val))|}
    ~output:"(define echo-number\n  (function ((val i128)) @public\n    (ok \"val\")))"  (* TODO *)

let () =
  Alcotest.run "Clarity" [
    "compile", [
      "types", `Quick, types;
      "boolean logic", `Quick, boolean_logic;
      "relational operators", `Quick, relational_operators;
      "integer arithmetic", `Quick, integer_arithmetic;
      "optional values", `Quick, optional_values;
      "sequence operations", `Quick, sequence_operations;
      "define-constant", `Quick, define_constant;
      "define-data-var", `Quick, define_data_var;
      "define-map", `Quick, define_map;
      "define-read-only", `Quick, define_read_only;
      "hello-world", `Quick, hello_world;
    ];
  ]
