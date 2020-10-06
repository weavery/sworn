(* This is free and unencumbered software released into the public domain. *)

let fprintf = Format.fprintf

let read_file path =
  let channel = open_in path in
  let contents = really_input_string channel (in_channel_length channel) in
  close_in channel;
  contents

let compile_and_print path =
  let ppf = Format.formatter_of_out_channel stdout in
  let input = read_file path in
  let program = Clarity.parse_program input in
  let program' = SWIR.compile_program program in
  fprintf ppf "// Generated by Sworn@\n@\n";
  fprintf ppf "clarity.requireVersion(\"%s\")@\n@\n" "0.1";
  fprintf ppf "@[<v>%a@]@?" JavaScript.print_program program'
