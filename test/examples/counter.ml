(* This is free and unencumbered software released into the public domain. *)

let fprintf = Format.fprintf

let read_file path =
  let channel = open_in path in
  let contents = really_input_string channel (in_channel_length channel) in
  close_in channel;
  contents

let () =
  let output_formatter = Format.formatter_of_out_channel stdout in
  let input = read_file "counter.clar" in
  let program = Clarity.parse_program input in
  let program' = SWIR.compile_program program in
  fprintf output_formatter "// Generated by Sworn@\n@\n";
  fprintf output_formatter "clarity.requireVersion(\"%s\")@\n@\n" "0.0";
  fprintf output_formatter "@[<v>%a@]@?" JavaScript.print_program program'
