(* This is free and unencumbered software released into the public domain. *)

open Cmdliner

let verbose =
  let doc = "Be verbose." in
  Arg.(value & flag & info ["v"; "verbose"] ~doc)

let files =
  Arg.(value & pos_all non_dir_file ["/dev/stdin"] & info [] ~docv:"FILE")

let output =
  let doc = "Specify the output file." in
  Arg.(value & opt (some string) None & info ["o"; "output"] ~docv:"OUTPUT" ~doc)

let target =
  let output_format =
    let parse = Target.of_string in
    let print ppf p = Target.to_string p |> Format.fprintf ppf "%s" in
    Arg.conv ~docv:"TARGET" (parse, print)
  in
  let doc = "Specify the output format: `auto', `js', `wasm', `wat'." in
  Arg.(value & opt output_format Target.Auto & info ["t"; "target"] ~docv:"TARGET" ~doc)

let optimize =
  let doc = "Specify the optimization level to use." in
  Arg.(value & opt int 0 & info ["O"; "optimize"] ~docv:"LEVEL" ~doc)
