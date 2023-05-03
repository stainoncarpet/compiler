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
%token <_null> NULLLIT
%token <_string> STRINGLIT
%token <_char> CHARLIT
%token <_bool> BOOLLIT
%token <_int> INTLIT
%token <_float> REALLIT
%token <_string> ID LENGTHOF
%token EQ NOTEQ GT GREQ LT LEEQ AND OR VARINCR VARDECR RETURN VOID VAR PARAMGRH IF ELSE DO WHILE FOR FUNCTION INTPTR CHARPTR REALPTR
%left OR
%left AND
%left EQ NOTEQ
%left LT LEEQ GT GREQ
%left '+' '-'
%left '*' '/'
%left '!' '&'
%left '='
%left '(' ')'
%left ELSE
%type <_string> TYPE
%type <any> LIT


%%
program: statement_list ;
statement_list: statement_list statement | statement ;
statement: if_statement
    | while_loop 
    | for_loop 
    | do_loop
    | vardecl ';'
    | arrdecl ';'
    | funcdecl 
    | funccall ';'
    | assign ';'
    | RETURN expr ';'
    | expr
    | '{' block '}'
;
if_statement: IF '(' cond ')' statement ELSE statement
        | IF '(' cond ')' statement
;
while_loop: WHILE '(' cond ')' statement;
for_loop: FOR '(' ID '=' expr ';' cond ';' iter ')' '{' block '}' ;
do_loop: DO '{' block '}' WHILE '(' cond ')' ';' ;
cond: expr ;
;
iter: assign | VARINCR | VARDECR;
block:  statement_list | ;
assign: ID '=' expr 
        | ID '[' expr ']' '=' expr
        | '*' ID '=' expr
        | ID '=' expr LIT
        | ID '=' '&' ID '[' INTLIT ']' 
;
expr: LIT
    | funccall
    | ID
    | LENGTHOF
    | expr_subt
    | expr_mult
    | expr_add
    | expr_div
    | expr_or
    | expr_and
    | expr_eq
    | expr_noteq
    | expr_lt
    | expr_leeq
    | expr_gt
    | expr_greq
    | expr_enslosed
    | expr_deref
    | expr_flipped
    | expr_ref

;
expr_greq: expr GREQ expr;
expr_gt: expr GT expr;
expr_leeq: expr LEEQ expr;
expr_lt: expr LT expr;
expr_noteq: expr NOTEQ expr;
expr_eq: expr EQ expr;
expr_or: expr OR expr;
expr_and: expr AND expr;
expr_add: expr '+' expr ;
expr_subt: expr '-' expr;
expr_mult: expr '*' expr;
expr_div: expr '/' expr;
expr_enslosed: '(' expr ')' ;
expr_deref: '*' ID | '*' expr_enslosed;
expr_flipped: '!' expr;
expr_ref: '&' ID ;
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
funcdecl: FUNCTION ID '(' params ')' ':' TYPE '{' block '}' { }
        | FUNCTION ID '(' params ')' ':' VOID '{' block '}'
;
funccall: ID '(' args ')';
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
args: ID | ID ',' args | LIT | LIT ',' args | ;
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