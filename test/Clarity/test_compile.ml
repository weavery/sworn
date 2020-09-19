(* This is free and unencumbered software released into the public domain. *)

let check ~input ~output =
  let input = Sexplib.Sexp.of_string input in
  let clarity = Clarity.parse_definition input in
  let swir = Clarity.compile_definition clarity in
  let ppf = Format.str_formatter in
  let _ = Format.fprintf ppf "@[<h>%a@]" SWIR.print_definition swir in
  let actual = Format.flush_str_formatter () in
  Alcotest.(check string) "" output actual

let define_constant () = check
  ~input:"(define-constant answer 42)"
  ~output:"(define answer (const i128 42))"

let define_data_var () = check
  ~input:"(define-data-var counter int 0)"
  ~output:"(define counter (global i128 0))"

let define_map () = check
  ~input:"(define-map squares ((x int)) ((square int)))"
  ~output:"(define squares (global (map i128 i128)))"

let define_read_only () = check
  ~input:"(define-read-only (get-counter) (var-get counter))"
  ~output:"(define get-counter\n  (function ()\n    (var-get counter)))"

let () =
  Alcotest.run "Clarity" [
    "compile", [
      "define-constant", `Quick, define_constant;
      "define-data-var", `Quick, define_data_var;
      "define-map", `Quick, define_map;
      "define-read-only", `Quick, define_read_only;
    ];
  ]
