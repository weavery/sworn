(* This is free and unencumbered software released into the public domain. *)

{
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
let identifier = ['a'-'z' 'A'-'Z' '0'-'9' '+' '-' '*' '/' '<' '>' '=' '!' '?']*  (* TODO *)

rule read_token = parse
  | whitespace { read_token lexbuf }
  | newline { Lexing.new_line lexbuf; read_token lexbuf }
  | (';' (_ # ['\r' '\n'])*) { read_token lexbuf }
  | '(' { LPAREN }
  | ')' { RPAREN }
  | '{' { LBRACE }
  | '}' { RBRACE }
  | ':' { COLON }
  | '"' { read_string (Buffer.create 16) lexbuf }
  | int { INT (Integer.of_string (Lexing.lexeme lexbuf)) }
  | uint { UINT (Integer.of_string (drop_prefix 1 (Lexing.lexeme lexbuf))) }
  | buff  { BUFF (decode_buffer (drop_prefix 2 (Lexing.lexeme lexbuf))) }
  | "none" { NONE }
  | "false" { FALSE }
  | "true" { TRUE }
  | identifier { ID (Lexing.lexeme lexbuf) }
  | _ { raise (SyntaxError ("Unexpected character: " ^ Lexing.lexeme lexbuf)) }
  | eof { EOF }

and read_string buffer = parse
  | '"' { STRING (Buffer.contents buffer) }
  | '\\' '\\' { Buffer.add_char buffer '\\'; read_string buffer lexbuf }
  | '\\' 'n' { Buffer.add_char buffer '\n'; read_string buffer lexbuf }
  | '\\' 'r' { Buffer.add_char buffer '\r'; read_string buffer lexbuf }
  | '\\' 't' { Buffer.add_char buffer '\t'; read_string buffer lexbuf }
  | [^ '"' '\\']+ { Buffer.add_string buffer (Lexing.lexeme lexbuf); read_string buffer lexbuf }
  | _ { raise (SyntaxError ("Illegal string characters")) }
  | eof { raise (SyntaxError ("Unterminated string")) }
