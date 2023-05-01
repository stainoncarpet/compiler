%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#define CAPACITY 1024
int yylex();
int yyerror();
int yywrap();
void setHasMain(char);
typedef struct _node {
    char* token;
    struct node* left;
    struct node* right;
    // list of possible types + fields held by struct 
} node;
%}


%union {
    char* _string;
    int _int;
    float _float;
    char _char;
    char _bool;
    void* _null;
    node* nd;

    union _any {
        char b; 
        char c; 
        char* s; 
        void* n;
        int i;
        float f;
    } any;
}

%token <_string> BOOL CHAR INT REAL STRING
%token INTPTR CHARPTR REALPTR
%token <_null> NULLLIT
%token <_string> STRINGLIT
%token <_char> CHARLIT
%token <_bool> BOOLLIT
%token <_int> INTLIT
%token <_float> REALLIT
%token <_string> ID DEREFID
%token IF ELSE DO WHILE FOR FUNCTION
%token RETURN VOID
%token VAR PARAMGRH LENGTHOF
%token EQ NOTEQ GR GREQ LE LEEQ AND OR VARINCR VARDECR
%left '+' '-'
%left '*' '/'
%type <_int> LENGTHOF
%type <_string> TYPE
%type <any> LIT



%%
s: | stmts ;
stmts: stmts stmt | stmt ;
stmt: if_stmt
    | while_loop 
    | for_loop 
    | do_loop
    | vardecl ';'
    | arrdecl ';'
    | funcdecl 
    | funccall ';'
    | assign ';'
    | RETURN expr ';'
    | '{' block '}'
    | expr
;
if_stmt: IF '(' cond ')' '{' block '}' ELSE '{' block '}'
        | IF '(' cond ')' '{' block '}' ELSE stmt
        | IF '(' cond ')' '{' block '}'
        | IF '(' cond ')' stmt
;
while_loop: WHILE '(' cond ')' '{' block '}' | WHILE '(' cond ')' stmt;
for_loop: FOR '(' vardecl ';' cond ';' iter ')' '{' block '}' ;
do_loop: DO '{' block '}' WHILE '(' cond ')' ';' ;
cond: expr ;
;
iter: assign | VARINCR | VARDECR;
block: block stmt | stmt ;
assign: ID '=' expr 
        | ID '[' INTLIT ']' '=' expr
        | ID '[' expr ']' '=' expr
        | DEREFID '=' expr
;
expr: LIT
    | ID
    | LENGTHOF
    | expr '+' expr
    | expr '-' expr
    | expr '*' expr
    | expr '/' expr
    | funccall
    | expr OR expr
    | expr AND expr
    | expr EQ expr
    | expr NOTEQ expr
    | expr LE expr
    | expr GR expr
    | expr NOTEQ expr
    | '(' expr ')'
    | DEREFID
    | '*' expr
    | '!' BOOLLIT | BOOLLIT
    | '!' ID
;
LIT: INTLIT { $$.i = $1; }
    | REALLIT { $$.f = $1; }
    | BOOLLIT { $$.b = $1; }
    | CHARLIT { $$.c = $1; }
    | STRINGLIT { $$.s = strdup($1); }
    | NULLLIT { $$.n = NULL; }
;

vardecl: VAR varlist;
varlist: ID ':' TYPE
    | ID '=' LIT ':' TYPE
    | ID '=' ID ':' TYPE
    | ID ',' varlist 
    | ID '=' LIT ',' varlist
;
arrdecl: TYPE ID '[' INTLIT ']'
        | ',' ID '[' INTLIT ']'
        | TYPE ID '[' INTLIT ']' arrdecl
        | TYPE ID '[' INTLIT ']' '=' LIT
        | ',' ID '[' INTLIT ']' '=' LIT
;
funcdecl: FUNCTION ID '(' params ')' ':' TYPE '{' block '}' {
    if(strcmp($2, "main") == 0) { setHasMain(1); };
}
        | FUNCTION ID '(' params ')' ':' VOID '{' block '}'
;
funccall: ID '=' ID '(' ')' { ;} | ID '(' ')' { ;}
        | ID '=' ID '(' args ')' { ;} | ID '(' args ')' { ;}
;
TYPE: BOOL {$$ = "BOOL";}
    | CHAR {$$ = "CHAR";}
    | INT {$$ = "INT";}
    | REAL {$$ = "REAL";}
    | STRING {$$ = "STRING";}
    | INTPTR {$$ = "INTPTR";}
    | CHARPTR {$$ = "CHARPTR";}
    | REALPTR {$$ = "REALPTR";}
;
params: params ';' paramgr 
    | paramgr 
    | {};
paramgr: PARAMGRH varlist ;
args: ID | ID ',' args | LIT | LIT ',' args ;
%%



#include "lex.yy.c"

char hasMain = 0;

int main() {
	return yyparse();
}

int yyerror() { printf("Error parsing LINE\n");  return 0; }

int yywrap() {
    return 1;
}

void setHasMain(char hasMain) {
    hasMain = hasMain;
    printf("main function found\n");
}