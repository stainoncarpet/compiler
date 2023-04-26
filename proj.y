%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#define CAPACITY 1024
int yylex();
int yyerror();
int addIdentifier(char*, char*);

typedef struct identifier {
    char* name;
    char* type;
} identifier;
%}


%union {
    char* _string;
    int _int;
    float _float;
    char _char;
};

%token <_string> BOOL CHAR INT REAL STRING
%token INTPTR CHARPTR REALPTR
%token BOOLLIT CHARLIT STRINGLIT NULLLIT
%token <_int> INTLIT
%token <_float> REALLIT
%token <_string> ID
%token IF ELSE DO WHILE FOR FUNCTION
%token RETURN VOID
%token VAR PARAMGRH
%token EQ NOTEQ GR GREQ LE LEEQ AND OR VARINCR VARDECR

%left '+' '-'
%left '*' '/'

%type <_int> OP
%type <_string> TYPE


%%
S: | LINES ;
LINES: LINES LINE | LINE ;
LINE: EXPR ';' { ; } | STMT ;
EXPR: NUMLIT ;
STMT: IF_STMT 
    | WHILE_LOOP | FOR_LOOP | DO_LOOP
    | VARDECL ';' | FUNCDECL 
    | ASSIGN ';'
    | RETURN ID ';' | RETURN LIT ';'
;
IF_STMT: IF '(' COND ')' '{' BLOCK '}' ELSE '{' BLOCK '}'
        | IF '(' COND ')' '{' BLOCK '}'
;
WHILE_LOOP: WHILE '(' COND ')' '{' BLOCK '}' ;
FOR_LOOP: FOR '(' VARDECL ';' COND ';' ITER ')' '{' BLOCK '}' ;
DO_LOOP: DO '{' BLOCK '}' WHILE '(' COND ')' ';' ;
COND: ID LE ID 
    | ID GR ID 
    | ID EQ ID 
    | ID GR LIT 
    | ID LE LIT 
    | ID EQ LIT
    | BOOLLIT
;
ITER: ASSIGN | VARINCR | VARDECR;
BLOCK: BLOCK LINE | LINE ;
ASSIGN: ID '=' OP ;
OP: INTLIT | REALLIT
    | ID { $$ = $1; }
    | OP '+' OP {printf("R: %d\n", $1 + $3); } 
    | OP '-' OP {printf("R: %d\n", $1 - $3); } 
    | OP '*' OP {printf("R: %d\n", $1 * $3); } 
    | OP '/' OP {printf("R: %d\n", $1 / $3); } 
;
LIT: NUMLIT | BOOLLIT | CHARLIT | STRINGLIT | NULLLIT;
NUMLIT: INTLIT | REALLIT ;
VARDECL: VAR VARLIST | VAR VARLIST '=' LIT;

VARLIST: ID ':' TYPE { addIdentifier($1, $3); } | ID VARDECLADD ':' TYPE ;
VARDECLADD: ',' ID | VARDECLADD ',' ID ;

FUNCDECL: FUNCTION ID '(' PARAMS ')' ':' TYPE '{' BLOCK '}'
        | FUNCTION ID '(' PARAMS ')' ':' VOID '{' BLOCK '}'
;
TYPE: BOOL {$$ = "BOOL";}
    | CHAR {$$ = "CHAR";}
    | INT {$$ = "INT";}
    | REAL {$$ = "BOOL";}
    | STRING {$$ = "STRING";}
    | INTPTR {$$ = "INTPTR";}
    | CHARPTR {$$ = "CHARPTR";}
    | REALPTR {$$ = "REALPTR";}
;
PARAMS: PARAMS ';' PARAMGR | PARAMGR | ;
PARAMGR: PARAMGRH VARLIST ;
%%


#include "lex.yy.c"
int main() { return yyparse();}
int yyerror() { printf("Error parsing LINE\n");  return 0; }

identifier* idpool[CAPACITY];
static int size = 0;

int addIdentifier(char* idname, char* typename) {
    for(int i = 0; i < size; i++) {
        if(strcmp(idpool[i]->name, idname) == 0) {
            printf(">>> VAR: [%s] IS ALREADY DECLARED\n", idname);
            yyerror();
            exit(1);
        }    
    }

    printf(">>> adding to list: [%s] [%s]\n", idname, typename);

    // TODO: find where to free()
    identifier* newId = (identifier*)malloc(sizeof(identifier));
    newId->name = strdup(idname);
    newId->type = strdup(typename);
    idpool[size++] = newId;

    return 0;
}