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

let literals () =
  check_expression "none" "null";
  check_expression "false" "false";
  check_expression "true" "true";
  check_expression "123" "123";
  check_expression "-123" "-123"

let operators () =
  check_expression "(* 1 2 3)" "(1 * 2 * 3)";

  check_expression "(+ 1 2 3)" "(1 + 2 + 3)";

  check_expression "(- 1 2 3)" "(1 - 2 - 3)";

  check_expression "(/ 1 2 3)" "(1 / 2 / 3)";

  check_expression "(< 1 2)" "(1 < 2)";

  check_expression "(<= 1 2)" "(1 <= 2)";

  check_expression "(> 1 2)" "(1 > 2)";

  check_expression "(>= 1 2)" "(1 >= 2)";

  check_expression "(and true false)" "(true && false)";

  check_expression "(append (list 1 2 3 4) 5)" "clarity.append([1, 2, 3, 4], 5)";

  check_expression "(as-contract tx-sender)" "clarity.asContract(clarity.txSender())";

  check_expression "(as-max-len? (list 2 2 2) u3)" "clarity.asMaxLen([2, 2, 2], 3)";
  check_expression "(as-max-len? (list 1 2 3) u2)" "clarity.asMaxLen([1, 2, 3], 2)";

  check_expression "(asserts! (is-eq 1 1) (err 1))"
    "if (!clarity.isEq(1, 1)) return clarity.err(1)";  (* FIXME: return *)

  (* TODO: at-block *)

  (* TODO: begin *)

  check_expression "block-height" "clarity.blockHeight()";

  check_expression "(concat \"hello \" \"world\")" "clarity.concat(\"hello \", \"world\")";

  (* TODO: contract-call? *)

  check_expression "contract-caller" "clarity.contractCaller()";

  (* TODO: contract-of *)

  check_expression "(default-to 0 (some 1))" "(clarity.some(1) ?? 0)";

  check_expression "(err true)" "clarity.err(true)";

  check_expression "false" "false";

  check_expression "(filter not (list true false true false))"
    "clarity.filter(clarity.not, [true, false, true, false])";

  check_expression "(fold * (list 2 2 2) 1)"
    "clarity.fold(clarity.mul, [2, 2, 2], 1)";

  (* TODO: ft-get-balance *)

  (* TODO: ft-mint? *)

  (* TODO: ft-transfer? *)

  check_expression "(get id (tuple (name \"blockstack\") (id 1337)))"
    "clarity.get(\"id\", clarity.tuple([\"name\", \"blockstack\"], [\"id\", 1337]))";

  (* TODO: get-block-info? *)

  check_expression "(hash160 0)" "clarity.hash160(0)";

  check_expression "(if true 1 2)" "(true ? (1) : (2))";

  (* TODO: impl-trait *)

  check_expression "(is-eq 1 1)" "clarity.isEq(1, 1)";
  check_expression "(is-eq 1 2 3)" "clarity.isEq(1, 2, 3)";

  check_expression "(is-err (ok 1))" "clarity.isErr(clarity.ok(1))";
  check_expression "(is-err (err 1))" "clarity.isErr(clarity.err(1))";

  check_expression "(is-none 1)" "clarity.isNone(1)";

  check_expression "(is-ok (ok 1))" "clarity.isOk(clarity.ok(1))";
  check_expression "(is-ok (err 1))" "clarity.isOk(clarity.err(1))";

  check_expression "(is-some 1)" "clarity.isSome(1)";

  check_expression "(keccak256 0)" "clarity.keccak256(0)";

  check_expression "(len \"blockstack\")" "\"blockstack\".length";
  check_expression "(len (list 1 2 3 4 5))" "[1, 2, 3, 4, 5].length";

  check_expression "(let ((x 42)) x)"
    "(() => { const x = 42; return x })()";
  check_expression "(let ((a 1) (b 2)) a b)"
    "(() => { const a = 1; const b = 2; a; return b })()";

  check_expression "(list 1 2 3)" "[1, 2, 3]";

  check_expression "(map not (list true false true false))"
    "clarity.map(clarity.not, [true, false, true, false])";

  check_expression "(map-delete names-map { name: \"blockstack\" })"
    "clarity.mapDelete(namesMap, clarity.tuple([\"name\", \"blockstack\"]))";  (* FIXME: namesMap *)

  check_expression "(map-get? names-map { name: \"blockstack\" })"
    "clarity.mapGet(namesMap, clarity.tuple([\"name\", \"blockstack\"]))";  (* FIXME: namesMap *)

  check_expression "(map-insert names-map { name: \"blockstack\" } { id: 1337 })"
    "clarity.mapInsert(namesMap, clarity.tuple([\"name\", \"blockstack\"]), clarity.tuple([\"id\", 1337]))";  (* FIXME: namesMap *)

  check_expression "(map-set names-map { name: \"blockstack\" } { id: 1337 })"
    "clarity.mapSet(namesMap, clarity.tuple([\"name\", \"blockstack\"]), clarity.tuple([\"id\", 1337]))";  (* FIXME: namesMap *)

  check_expression "(match x y y z z)" "clarity.match(x, y => y, z => z)";

  check_expression "(mod 2 3)" "(2 % 3)";

  (* TODO: nft-get-owner? *)

  (* TODO: nft-mint? *)

  (* TODO: nft-transfer? *)

  check_expression "none" "null";

  check_expression "(not true)" "(!true)";

  check_expression "(ok 1)" "clarity.ok(1)";

  check_expression "(or true false)" "(true || false)";

  check_expression "(pow 2 3)" "(2 ** 3)";

  check_expression "(print 42)" "clarity.print(42)";

  check_expression "(sha256 0)" "clarity.sha256(0)";

  check_expression "(sha512 1)" "clarity.sha512(1)";

  check_expression "(sha512/256 1)" "clarity.sha512_256(1)";

  check_expression "(some 1)" "clarity.some(1)";

  (* TODO: stx-* *)

  check_expression "(to-int u238)" "clarity.toInt(238)";

  check_expression "(to-uint 238)" "clarity.toUint(238)";

  check_expression "true" "true";

  check_expression "(try! (map-get? names-map { name: \"blockstack\" }))"
    "clarity.tryUnwrap(clarity.mapGet(namesMap, clarity.tuple([\"name\", \"blockstack\"])))";  (* FIXME: namesMap *)

  check_expression "(tuple (name \"blockstack\") (id 1337))"
    "clarity.tuple([\"name\", \"blockstack\"], [\"id\", 1337])";

  check_expression "tx-sender" "clarity.txSender()";

  (* TODO: unwrap! *)

  check_expression "(unwrap-err! (err 1) false)"
    "clarity.unwrapErr(clarity.err(1), false)";

  check_expression "(unwrap-err-panic (err 1))"
    "clarity.unwrapErrPanic(clarity.err(1))";

  check_expression "(unwrap-panic (map-get? names-map { name: \"blockstack\" }))"
    "clarity.unwrapPanic(clarity.mapGet(namesMap, clarity.tuple([\"name\", \"blockstack\"])))";  (* FIXME: namesMap *)

  (* TODO: use-trait *)

  check_expression "(var-get cursor)" "state.cursor";

  check_expression "(var-set cursor 0)" "state.cursor = 0";

  check_expression "(xor 1 2)" "(1 ^ 2)"

let () =
  Alcotest.run "JavaScript" [
    "print", [
      "literals", `Quick, literals;
      "operators", `Quick, operators;
    ];
  ]
