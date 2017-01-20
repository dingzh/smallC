%option noyywrap yylineno

%{
#include <cstdlib>
#include <cstdio>
#include "ast.h"

#include "smallc.tab.h"

void yyerror(char *);
%}

%x COMMENT
UCN (\\u[0-9a-fA-F]{4}|\\U[0-9a-fA-F]{8}) 


%%

  /* comments */ 
"/*" 				{ BEGIN(COMMENT); } 
<COMMENT>"*/" 		{ BEGIN(INITIAL); } 
<COMMENT>([^*]|\n)+|. { }
<COMMENT><<EOF>> 	{ printf("%d: Unterminated comment\n", yylineno); return 0; }

  /* C++ comment, a common extension */ 
"//".*\n 			{}

"(" |
")" |
"[" |
"]" |
"{" |
"}" |
"=" |
"&"	|
"^"	|
"|"	|
";" |
"," |
"." |
"-" |
"!" |
"~" |
"*" |
"/" |
"%" |
"+"	|
">" |
"<"  { return yytext[0];}

"==" { return EQ;}
"<=" { return LEQ;}
">=" { return GEQ;}
"!=" { return NEQ;}
"<<" { return LSH;}
">>" { return RSH;}
"++" { return INC;}
"--" { return DEC;}
"+=" { return ADD_ASSIGN;}
"-=" { return SUB_ASSIGN;}
"*=" { return MUL_ASSIGN;}
"/=" { return DIV_ASSIGN;}
"&=" { return AND_ASSIGN;}
"^=" { return XOR_ASSIGN;}
"|=" { return OR_ASSIGN;}
">>=" { return RSH_ASSIGN;}
"<<=" { return LSH_ASSIGN;}
"&&" { return AND;}
"||" { return OR;}

[ \t] {}

  /* integers */ 
0[0-7]*				|
[1-9][0-9]*			|
0[Xx][0-9a-fA-F]+ 	{  yylval.m_str = strdup(yytext); return INT;}
 /* yylval.m_int = strtol(yytext, NULL, 0); */

  /* char const */ 
\'([^'\\]|\\['"?\\abfnrtv]|\\[0-7]{1,3}|\\[Xx][0-9a-fA-F]+|{UCN})+\' { yylval.m_char = yytext[0]; return CHAR;}

  /* string literal */
L?\"([^"\\]|\\['"?\\abfnrtv]|\\[0-7]{1,3}|\\[Xx][0-9a-fA-F]+|{UCN})*\" { yylval.m_str = strdup(yytext); return STRING;}

  /* keywords */
if 			{ return IF;}
else		{ return ELSE;}
for			{ return FOR;}
break		{ return BREAK;}
continue	{ return CONT;}
return		{ return RETURN;}
struct		{ return STRUCT;}

  /* function */
read    	{ return READ;}
write   	{ return WRITE;}

  /* type */
int 		{ yylval.m_str = strdup(yytext); return TYPE;}

  /* identifier */ 
([_a-zA-Z]|{UCN})([_a-zA-Z0-9]|{UCN})* { yylval.m_str = strdup(yytext); return ID;}

. {yyerror("Error!");}
%%
