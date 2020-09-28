(* This is free and unencumbered software released into the public domain. *)

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

%start <expression list> parse
%start <expression> expression
%start <literal> literal

%%

parse:
  | list(expression) EOF { $1 }
  ;

expression:
  | list_ { $1 }
  | atom { $1 }
  ;

list_:
  | LPAREN list(expression) RPAREN  { ListExpression $2 }
  ;

atom:
  | literal { Literal $1 }
  | identifier { Literal (StringLiteral $1) }  /* TODO */
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
