%{
#include "def.h"
#include "ast.h"

using namespace std;
extern int yylineno;
extern char* yytext;
extern int yylex();
void yyerror(char *);
%}

%union {
    TreeNode* m_node;
    char* m_str;
    char m_char;
    int m_int;
}

%token <m_str> INT 
%token <m_str> STRING 
%token <m_char> CHAR
%token <m_str> ID

%token IF ELSE FOR RETURN BREAK CONT STRUCT
%token <m_str> TYPE
%token WRITE READ
%token ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN 
%token AND_ASSIGN XOR_ASSIGN OR_ASSIGN RSH_ASSIGN LSH_ASSIGN

%type <m_node> PROGRAM EXTDEFS EXTDEF SEXTVARS EXTVARS STSPEC FUNC PARAS STMTBLOCK STMTS
%type <m_node> STMT DEFS SDEFS SDECS DECS VAR INIT EXP EXPS ARRS ARGS UNARYOP

%nonassoc  IFX
%nonassoc ELSE

%right '=' ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN AND_ASSIGN XOR_ASSIGN OR_ASSIGN RSH_ASSIGN LSH_ASSIGN

%left  OR
%left  AND
%left '|'
%left '^'
%left '&'
%left EQ NEQ GEQ LEQ '<' '>'
%left LSH RSH
%left '+' '-'
%left '*' '/' '%'
%right INC DEC UNARY
%left  '.' '[' '('

%%

PROGRAM: 
  EXTDEFS {treeroot = $$ = create_node(yylineno,_PROGRAM,"program",1,$1);}
;

EXTDEFS: 
  EXTDEF EXTDEFS {$$ = create_node(yylineno,_EXTDEFS,"extdefs",2,$1,$2);}
| {$$ = create_node(yylineno,_NULL, "null", 0);}
;

EXTDEF: 
  TYPE EXTVARS ';' { $$ = create_node(yylineno,_EXTDEF, "extdef1", 2, create_node(yylineno,_TYPE, $1, 0),$2); }
| STSPEC SEXTVARS ';' { $$ = create_node(yylineno,_EXTDEF, "extdef2", 2, $1,$2); }
| TYPE FUNC STMTBLOCK { $$ = create_node(yylineno,_EXTDEF, "extdef func", 3, create_node(yylineno,_TYPE, $1, 0),$2,$3); }
;

SEXTVARS: ID { $$ = create_node(yylineno,_SEXTVARS, "sextvars",1,create_node(yylineno,_ID,$1,0)); }
| ID ',' SEXTVARS { $$ = create_node(yylineno,_SEXTVARS, "sextvars", 2, create_node(yylineno,_ID, $1, 0),$3); }
| {$$ = create_node(yylineno,_NULL, "null", 0);}
;

EXTVARS: 
  VAR { $$ = create_node(yylineno,_EXTVARS, "extvars", 1, $1); }
| VAR ',' EXTVARS { $$ = create_node(yylineno,_EXTVARS, "extvars", 2, $1,$3); }
| VAR '=' INIT { $$ = create_node(yylineno,_EXTVARS, "extvars", 3, $1,create_node(yylineno,_OPERATOR,"=",0),$3); }
| VAR '=' INIT ',' EXTVARS { $$ = create_node(yylineno,_EXTVARS, "extvars", 4, $1,create_node(yylineno,_OPERATOR,"=",0),$3,$5); }
| {$$ = create_node(yylineno,_NULL, "null", 0);}
;

STSPEC: 
  STRUCT ID '{' SDEFS '}' { $$ = create_node(yylineno,_STSPEC, "stspec identifier {}", 3, create_node(yylineno,_OPERATOR,"stuct",0),create_node(yylineno,_ID, $2, 0),$4); }
| STRUCT '{' SDEFS '}' { $$ = create_node(yylineno,_STSPEC, "stspec {}", 2, create_node(yylineno,_OPERATOR,"stuct",0),$3); }
| STRUCT ID { $$ = create_node(yylineno,_STSPEC, "stspec", 2, create_node(yylineno,_OPERATOR,"struct",0),create_node(yylineno,_ID, $2, 0)); }
;

FUNC: 
  ID '(' PARAS ')' { $$ = create_node(yylineno,_FUNC, "func ()", 2, create_node(yylineno,_ID, $1, 0),$3); }
;

PARAS: 
  TYPE ID ',' PARAS { $$ = create_node(yylineno,_PARAS, "paras", 2, create_node(yylineno,_ID, $2, 0),$4); }
| TYPE ID { $$ = create_node(yylineno,_PARAS, "paras", 1,create_node(yylineno,_ID, $2, 0)); }
| {$$ = create_node(yylineno,_NULL, "null", 0);}
;

STMTBLOCK: 
  '{' DEFS STMTS '}' { $$ = create_node(yylineno,_STMTBLOCK, "stmtblock {}", 2, $2,$3); }
;

STMTS: 
  STMT STMTS { $$ = create_node(yylineno,_STMTS, "stmts", 2, $1,$2); }
| {$$ = create_node(yylineno,_NULL, "null", 0);}
;

STMT: 
  EXP ';' { $$ = create_node(yylineno,_STMT, "stmt: exp;", 1, $1); }
| STMTBLOCK { $$ = create_node(yylineno,_STMT, "stmt", 1, $1); }
| RETURN EXPS ';' { $$ = create_node(yylineno,_STMT, "return stmt", 2, create_node(yylineno,_KEYWORDS, "return", 0),$2); }
| IF '(' EXPS ')' STMT %prec IFX { $$ = create_node(yylineno,_STMT, "if stmt", 2, $3,$5); }
| IF '(' EXPS ')' STMT ELSE STMT %prec ELSE { $$ = create_node(yylineno,_STMT, "if stmt", 3, $3,$5,$7);}
| FOR '(' EXP ';'  EXP ';'  EXP ')' STMT { $$ = create_node(yylineno,_STMT, "for stmt", 4, $3,$5,$7,$9); }
| CONT ';'  { $$ = create_node(yylineno,_STMT, "cont stmt", 1, create_node(yylineno,_KEYWORDS, "continue", 0)); }
| BREAK ';'  { $$ = create_node(yylineno,_STMT, "break stmt", 1, create_node(yylineno,_KEYWORDS, "break", 0)); }
| READ '(' EXPS ')' ';' {$$ = create_node(yylineno,_STMT,"read stmt",1, $3);}
| WRITE '(' EXPS ')' ';' {$$ = create_node(yylineno,_STMT,"write stmt",1, $3);}
;

DEFS: 
  TYPE DECS ';'  DEFS { $$ = create_node(yylineno,_DEFS, "defs1", 3, create_node(yylineno,_TYPE, $1, 0),$2,$4); }
| STSPEC SDECS ';'  DEFS { $$ = create_node(yylineno,_DEFS, "defs2", 3, $1,$2,$4); }
| {$$ = create_node(yylineno,_NULL, "null", 0);}
;

SDEFS: 
  TYPE SDECS ';'  SDEFS { $$ = create_node(yylineno,_SDEFS, "sdefs", 3, create_node(yylineno,_TYPE, $1, 0),$2,$4); }
| {$$ = create_node(yylineno,_NULL, "null", 0);}
;

SDECS: 
  ID ',' SDECS { $$ = create_node(yylineno,_SDECS, "sdecs", 2, create_node(yylineno,_ID, $1, 0),$3); }
| ID { $$ = create_node(yylineno,_SDECS, "sdecs", 1,create_node(yylineno,_ID,$1,0)); }
;

DECS: 
  VAR { $$ = create_node(yylineno,_DECS, "decs", 1, $1); }
| VAR ',' DECS { $$ = create_node(yylineno,_DECS, "decs", 2, $1,$3); }
| VAR '=' INIT ',' DECS { $$ = create_node(yylineno,_DECS, "assign decs", 4, $1,create_node(yylineno,_OPERATOR, "=", 0),$3,$5); }
| VAR '=' INIT { $$ = create_node(yylineno,_DECS, "assign decs", 3, $1,create_node(yylineno,_OPERATOR, "=", 0),$3); }
;

VAR:
  ID { $$ = create_node(yylineno,_VAR, "var", 1,create_node(yylineno,_ID, $1, 0)); }
| VAR '[' INT ']' { $$ = create_node(yylineno,_VAR, "var []", 2, $1,create_node(yylineno,_INT, $3, 0)); }
;

INIT: 
  EXPS { $$ = create_node(yylineno,_INIT, "init", 1, $1); }
| '{' ARGS '}' { $$ = create_node(yylineno,_INIT, "init {}", 1, $2); }
; 

EXP: 
  EXPS { $$ = create_node(yylineno,_EXP, "exp", 1, $1); }
| {$$ = create_node(yylineno,_NULL, "null", 0);}
;

EXPS: 
  EXPS '=' EXPS { $$ = create_node(yylineno,_EXPS, "=", 2, $1,$3); }
| EXPS ADD_ASSIGN EXPS { $$ = create_node(yylineno,_EXPS, "+=", 2, $1,$3); }
| EXPS SUB_ASSIGN EXPS { $$ = create_node(yylineno,_EXPS, "-=", 2, $1,$3); }
| EXPS MUL_ASSIGN EXPS { $$ = create_node(yylineno,_EXPS, "*=", 2, $1,$3); }
| EXPS DIV_ASSIGN EXPS { $$ = create_node(yylineno,_EXPS, "/=", 2, $1,$3); }
| EXPS AND_ASSIGN EXPS { $$ = create_node(yylineno,_EXPS, "$=", 2, $1,$3); }
| EXPS XOR_ASSIGN EXPS { $$ = create_node(yylineno,_EXPS, "^=", 2, $1,$3); }
| EXPS OR_ASSIGN  EXPS { $$ = create_node(yylineno,_EXPS, "|=", 2, $1,$3); }
| EXPS RSH_ASSIGN EXPS { $$ = create_node(yylineno,_EXPS, ">>=", 2, $1,$3); }
| EXPS LSH_ASSIGN EXPS { $$ = create_node(yylineno,_EXPS, "<<=", 2, $1,$3); }
| EXPS RSH EXPS { $$ = create_node(yylineno,_OPERATOR, ">>", 2, $1,$3); }
| EXPS LSH EXPS { $$ = create_node(yylineno,_OPERATOR, "<<", 2, $1,$3); }
| EXPS AND EXPS { $$ = create_node(yylineno,_OPERATOR, "&&", 2, $1,$3); }
| EXPS OR  EXPS { $$ = create_node(yylineno,_OPERATOR, "||", 2, $1,$3); }
| EXPS LEQ EXPS { $$ = create_node(yylineno,_OPERATOR, "<=", 2, $1,$3); }
| EXPS GEQ EXPS { $$ = create_node(yylineno,_OPERATOR, ">=", 2, $1,$3); }
| EXPS EQ  EXPS { $$ = create_node(yylineno,_OPERATOR, "==", 2, $1,$3); }
| EXPS NEQ EXPS { $$ = create_node(yylineno,_OPERATOR, "!=", 2, $1,$3); }
| EXPS '+' EXPS { $$ = create_node(yylineno,_OPERATOR, "+", 2, $1,$3); }
| EXPS '-' EXPS { $$ = create_node(yylineno,_OPERATOR, "-", 2, $1,$3); }
| EXPS '&' EXPS { $$ = create_node(yylineno,_OPERATOR, "&", 2, $1,$3); }
| EXPS '*' EXPS { $$ = create_node(yylineno,_OPERATOR, "*", 2, $1,$3); }
| EXPS '/' EXPS { $$ = create_node(yylineno,_OPERATOR, "/", 2, $1,$3); }
| EXPS '%' EXPS { $$ = create_node(yylineno,_OPERATOR, "%", 2, $1,$3); }
| EXPS '<' EXPS { $$ = create_node(yylineno,_OPERATOR, "<", 2, $1,$3); }
| EXPS '>' EXPS { $$ = create_node(yylineno,_OPERATOR, ">", 2, $1,$3); }
| EXPS '^' EXPS { $$ = create_node(yylineno,_OPERATOR, "^", 2, $1,$3); }
| EXPS '|' EXPS { $$ = create_node(yylineno,_OPERATOR, "|", 2, $1,$3); }
| UNARYOP EXPS %prec UNARY { $$ = create_node(yylineno,_EXPS, "exps unary", 2, $1,$2); }
| '(' EXPS ')' { $$ = create_node(yylineno,_EXPS, "exps ()", 1, $2); }
| ID '(' ARGS ')' { $$ = create_node(yylineno,_EXPS, "exps f()", 2, create_node(yylineno,_ID, $1, 0),$3); }
| ID ARRS { $$ = create_node(yylineno,_EXPS, "exps arr", 2, create_node(yylineno,_ID, $1, 0),$2); }
| ID '.' ID { $$ = create_node(yylineno,_EXPS, "exps struct", 3, create_node(yylineno,_ID, $1, 0),create_node(yylineno,_OPERATOR, ".", 0),create_node(yylineno,_ID, $3, 0)); }
| INT { $$ = create_node(yylineno,_INT, $1, 0); }
;

ARRS: 
  '[' EXP ']' ARRS { $$ = create_node(yylineno,_ARRS, "arrs []", 2, $2,$4); }
|   {$$ = create_node(yylineno,_NULL, "null", 0);}
;


ARGS:
  EXP ',' ARGS { $$ = create_node(yylineno,_ARGS, "args", 2, $1,$3); }
| EXP { $$ = create_node(yylineno,_ARGS, "args", 1, $1); }
;

UNARYOP:
 '+' {$$ = create_node(yylineno,_UNARYOP, "+", 0);}
|'-' {$$ = create_node(yylineno,_UNARYOP, "-", 0);}
|'~' {$$ = create_node(yylineno,_UNARYOP, "~", 0);}
|'!' {$$ = create_node(yylineno,_UNARYOP, "!", 0);}
|INC {$$ = create_node(yylineno,_UNARYOP, "--", 0);}
|DEC {$$ = create_node(yylineno,_UNARYOP, "++", 0);}
;



%%
#include "semantics.h"
#include "translate.h"
#include "interpret.h"
extern TreeNode* treeroot;

void yyerror(char *s)
{
	fflush(stdout);
	fprintf(stderr,"%d :%s %s\n",yylineno,s,yytext);
}

int main(int argc, char *argv[])
{
	freopen(argv[1], "r", stdin);
	// freopen("testcase/main.c", "r", stdin);
	freopen("mips.s", "w", stdout);
	if(!yyparse()){
		fprintf(stderr,"Parsing complete.\n");
	} else {
    print_ast(treeroot,0);
		printf("Parsing failed.\n");
		return 1;
	}

	semantic_check(treeroot);
	generateIR();
	optimize();
	generateMIPS();
	return 0;
}

int yywrap()
{
	return 1;
}



