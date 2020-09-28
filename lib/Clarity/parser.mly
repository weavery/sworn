(* This is free and unencumbered software released into the public domain. *)

%token NONE
%token FALSE
%token TRUE
%token <Big_int.big_int> INT
%token <Big_int.big_int> UINT
%token <string> BUFF
%token LPAREN
%token RPAREN
%token EOF

%start <expression option> expression

%%

expression:
  | EOF { None }
  | lit = literal { Some (Literal lit) }
  ;

literal:
  | z = INT { IntLiteral z }
  | n = UINT { UintLiteral n }
  | s = BUFF { BuffLiteral s }
  | NONE { NoneLiteral }
  | TRUE { BoolLiteral true }
  | FALSE { BoolLiteral false }
  ;
