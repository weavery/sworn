(* This is free and unencumbered software released into the public domain. *)

%token <Big_int.big_int> INT
%token TRUE
%token FALSE
%token NONE
%token EOF

%start <expression option> expression

%%

expression:
  | EOF { None }
  | lit = literal { Some (Literal lit) }
  ;

literal:
  | z = INT { IntLiteral z }
  | TRUE { BoolLiteral true }
  | FALSE { BoolLiteral false }
  | NONE { NoneLiteral }
  ;
