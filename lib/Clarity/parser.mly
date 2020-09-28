(* This is free and unencumbered software released into the public domain. *)

%{
open Sexp
%}

%token NONE
%token FALSE
%token TRUE
%token <Big_int.big_int> INT
%token <Big_int.big_int> UINT
%token <string> BUFF
%token <string> STRING
%token <string> ID
%token LPAREN
%token RPAREN
%token EOF

%start <Sexp.t list> parse
%start <Sexp.t> expression
%start <literal> literal

%%

parse:
  | list(expression) EOF { $1 }
  ;

expression:
  | LPAREN list(expression) RPAREN { List $2 }
  | literal { Atom $1 }
  | identifier { Atom (StringLiteral $1) }  /* TODO */
  ;

literal:
  | NONE { NoneLiteral }
  | FALSE { BoolLiteral false }
  | TRUE { BoolLiteral true }
  | INT { IntLiteral $1 }
  | UINT { UintLiteral $1 }
  | BUFF { BuffLiteral $1 }
  | STRING { StringLiteral $1 }
  ;

identifier:
  | ID { $1 }
  ;
