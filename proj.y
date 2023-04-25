%{
#include <stdio.h>
int yylex();
int yyerror();
%}


%token BOOL CHAR INT REAL STRING INTPTR CHARPTR REALPTR NULLPTR
%token INTLIT REALLIT BOOLLIT CHARLIT STRINGLIT
%token IF ELSE DO WHILE FOR FUNCTION
%token RETURN VOID
%token VAR ID PARAMGRH
%token EQ NOTEQ GR GREQ LE LEEQ AND OR
%left '+' '-'
%left '*' '/'


%%
S: | LINES ;
LINES: LINES LINE | LINE ;
LINE: EXPR ';' { printf("FINAL RESULT OF LINE: %d\n", $1); } | STMT ;
EXPR: EXPR '+' EXPR {$$ = $1 + $3; } 
    | EXPR '-' EXPR {$$ = $1 - $3; }
    | EXPR '*' EXPR {$$ = $1 * $3; } 
    | EXPR '/' EXPR {$$ = $1 / $3; } 
    | NUMLIT
;
STMT: IF_STMT | VARDECL | FUNCDECL | ASSIGN 
    | RETURN ID ';' | RETURN INTLIT ';' | RETURN REALLIT ';'
    | RETURN BOOLLIT ';' | RETURN CHARLIT ';' | RETURN STRINGLIT ';'
;
IF_STMT: IF '(' COND ')' '{' BLOCK '}' ELSE '{' BLOCK '}'
        | IF '(' COND ')' '{' BLOCK '}'
;
COND: ID '<' ID 
    | ID '>' ID 
    | ID EQ ID 
    | ID '>' NUMLIT 
    | ID '<' NUMLIT 
    | ID EQ NUMLIT 
;
BLOCK: BLOCK LINE | LINE ;
ASSIGN: ID '=' NUMLIT ';' 
        | ID '=' BOOLLIT ';'
        | ID '=' CHARLIT ';' 
        | ID '=' STRINGLIT ';'
        | ID '=' ID ';'
;
NUMLIT: INTLIT | REALLIT ;
VARDECL: VAR ID ':' TYPE ';'
        | VAR ID VARDECLADD ':' TYPE ';'
;
VARDECLADD: VARDECLADD ',' ID | ',' ID ;
FUNCDECL: FUNCTION ID '(' ')' ':' TYPE '{' BLOCK '}'
        | FUNCTION ID '(' PARAMS ')' ':' TYPE '{' BLOCK '}'
;
TYPE: BOOL | CHAR | INT | REAL | STRING | INTPTR | CHARPTR | REALPTR ;
PARAMS: PARAMGRH
%%


#include "lex.yy.c"
int main() { return yyparse();}
int yyerror() { printf("Error parsing LINE\n");  return 0; }