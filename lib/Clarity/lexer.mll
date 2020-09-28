(* This is free and unencumbered software released into the public domain. *)

{
  (*open Lexing*)

  exception SyntaxError of string
}

let whitespace = [' ' '\t']+
let newline = '\r' | '\n' | "\r\n"
let int = '-'? ['0'-'9'] ['0'-'9']*

rule read_token = parse
  | whitespace { read_token lexbuf }
  | newline  { read_token lexbuf }
  | int      { INT (Big_int.big_int_of_string (Lexing.lexeme lexbuf)) }
  | "true" { TRUE }
  | "false" { FALSE }
  | "none" { NONE }
  | _ { raise (SyntaxError ("Unexpected character: " ^ Lexing.lexeme lexbuf)) }
  | eof { EOF }
