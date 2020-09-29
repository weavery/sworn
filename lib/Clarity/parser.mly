(* This is free and unencumbered software released into the public domain. *)

%{
open Sexp
%}

%token NONE
%token FALSE
%token TRUE
%token <Integer.t> INT
%token <Integer.t> UINT
%token <string> BUFF
%token <string> STRING
%token <string> ID
%token LPAREN
%token RPAREN
%token LBRACE
%token RBRACE
%token COLON
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
  | ID { Sym $1 }
  | literal { Lit $1 }
  ;

literal:
  | NONE { NoneLiteral }
  | FALSE { BoolLiteral false }
  | TRUE { BoolLiteral true }
  | INT { IntLiteral $1 }
  | UINT { UintLiteral $1 }
  | BUFF { BuffLiteral $1 }
  | STRING { StringLiteral $1 }
  | LBRACE ID COLON literal RBRACE { TupleLiteral ($2, $4) }
  ;
