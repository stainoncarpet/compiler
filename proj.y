%{
#include <stdio.h>
int yylex();
int yyerror();
%}


%token BOOL CHAR INT REAL STRING INTPTR CHARPTR REALPTR
%token INTLIT REALLIT BOOLLIT CHARLIT STRINGLIT NULLLIT
%token IF ELSE DO WHILE FOR FUNCTION
%token RETURN VOID
%token VAR ID PARAMGRH
%token EQ NOTEQ GR GREQ LE LEEQ AND OR VARINCR VARDECR
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
STMT: IF_STMT | WHILE_LOOP | FOR_LOOP | VARDECL ';' | FUNCDECL | ASSIGN ';'
    | RETURN ID ';' | RETURN INTLIT ';' | RETURN REALLIT ';'
    | RETURN BOOLLIT ';' | RETURN CHARLIT ';' | RETURN STRINGLIT ';'
;
IF_STMT: IF '(' COND ')' '{' BLOCK '}' ELSE '{' BLOCK '}'
        | IF '(' COND ')' '{' BLOCK '}'
;
WHILE_LOOP: WHILE '(' COND ')' '{' BLOCK '}' ;
FOR_LOOP: FOR '(' VARDECL ';' COND ';' ITER ')' '{' BLOCK '}' ;
COND: ID LE ID 
    | ID GR ID 
    | ID EQ ID 
    | ID GR LIT 
    | ID LE LIT 
    | ID EQ LIT 
;
ITER: ASSIGN | VARINCR | VARDECR;
BLOCK: BLOCK LINE | LINE ;
ASSIGN: ID '=' NUMLIT
        | ID '=' BOOLLIT
        | ID '=' CHARLIT
        | ID '=' STRINGLIT
        | ID '=' ID
;
LIT: NUMLIT | BOOLLIT | CHARLIT | STRINGLIT | NULLLIT;
NUMLIT: INTLIT | REALLIT ;
VARDECL: VAR VARLIST | VAR VARLIST IMASSIGN;
IMASSIGN: '=' LIT;
VARDECLADD: VARDECLADD ',' ID | ',' ID ;
VARLIST: ID ':' TYPE | ID VARDECLADD ':' TYPE ;
FUNCDECL: FUNCTION ID '(' PARAMS ')' ':' TYPE '{' BLOCK '}'
;
TYPE: BOOL | CHAR | INT | REAL | STRING | INTPTR | CHARPTR | REALPTR ;
PARAMS: PARAMS ';' PARAMGR | PARAMGR | ;
PARAMGR: PARAMGRH VARLIST ;
%%


#include "lex.yy.c"
int main() { return yyparse();}
int yyerror() { printf("Error parsing LINE\n");  return 0; }