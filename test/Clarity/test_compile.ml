(* This is free and unencumbered software released into the public domain. *)

let check_type input output =
  let input = Sexplib.Sexp.of_string input in
  let clarity = Clarity.parse_type input in
  let swir = Clarity.compile_type clarity in
  let actual = SWIR.type_to_string swir in
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
      "define-constant", `Quick, define_constant;
      "define-data-var", `Quick, define_data_var;
      "define-map", `Quick, define_map;
      "define-read-only", `Quick, define_read_only;
      "hello-world", `Quick, hello_world;
    ];
  ]
