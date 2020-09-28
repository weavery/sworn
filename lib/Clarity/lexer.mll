(* This is free and unencumbered software released into the public domain. *)

{
(*open Lexing*)

exception SyntaxError of string

let drop_prefix n input =
  String.sub input n ((String.length input) - n)

let decode_buffer input =
  let length = String.length input in
  let buffer = Buffer.create (length / 2) in
  let rec decode_loop index =
    if length - index < 2 then ()
    else begin
      let hex = String.sub input index 2 in
      let byte = Scanf.sscanf hex "%x%!" (fun x -> Char.chr x) in
      Buffer.add_char buffer byte;
      decode_loop (index + 2)
    end
  in
  decode_loop 0;
  Buffer.contents buffer
}

let whitespace = [' ' '\t']+
let newline = '\r' | '\n' | "\r\n"
let int = '-'? ['0'-'9'] ['0'-'9']*
let uint = 'u' ['0'-'9'] ['0'-'9']*
let buff = "0x" ['0'-'9' 'a'-'f' 'A'-'F']+

rule read_token = parse
  | whitespace { read_token lexbuf }
  | newline { read_token lexbuf }
  | '(' { LPAREN }
  | ')' { RPAREN }
  | int { INT (Big_int.big_int_of_string (Lexing.lexeme lexbuf)) }
  | uint { UINT (Big_int.big_int_of_string (drop_prefix 1 (Lexing.lexeme lexbuf))) }
  | buff  { BUFF (decode_buffer (drop_prefix 2 (Lexing.lexeme lexbuf))) }
  | "none" { NONE }
  | "false" { FALSE }
  | "true" { TRUE }
  | _ { raise (SyntaxError ("Unexpected character: " ^ Lexing.lexeme lexbuf)) }
  | eof { EOF }
