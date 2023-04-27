%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#define CAPACITY 1024
int yylex();
int yyerror();
int yywrap();
int addIdentifier(char*, char, char, char*, void*, int, float, char*);

typedef struct _identifier {
    char* name;
    char* type;

    union _value {
        char b; 
        char c; 
        char* s; 
        void* n;
        int i;
        float f;
    } value;
} identifier;
%}


%union {
    char* _string;
    int _int;
    float _float;
    char _char;
    char _bool;
    void* _null;

    union _any {
        char b; 
        char c; 
        char* s; 
        void* n;
        int i;
        float f;
    } any;
};

%token <_string> BOOL CHAR INT REAL STRING
%token INTPTR CHARPTR REALPTR
%token <_null> NULLLIT
%token <_string> STRINGLIT
%token <_char> CHARLIT
%token <_bool> BOOLLIT
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
%type <any> LIT


%%
S: | LINES ;
LINES: LINES LINE | LINE ;
LINE: STMT ;
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
OP: INTLIT { $$ = $1; } 
    | ID { $$ = $1; }
    | OP '+' OP {printf("R: %d\n", $1 + $3); } 
    | OP '-' OP {printf("R: %d\n", $1 - $3); } 
    | OP '*' OP {printf("R: %d\n", $1 * $3); } 
    | OP '/' OP {printf("R: %d\n", $1 / $3); } 
;
LIT: INTLIT { $$.i = $1; }
    | REALLIT { $$.f = $1; }
    | BOOLLIT { $$.b = $1; }
    | CHARLIT { $$.c = $1; }
    | STRINGLIT { $$.s = strdup($1); }
    | NULLLIT { $$.n = NULL; }
;

VARDECL: VAR VARLIST ;
VARLIST: ID ':' TYPE
    | ID '=' LIT ':' TYPE { 
        addIdentifier($1, $3.b, $3.c, $3.s, $3.n, $3.i, $3.f, $5); 
    }
    | ID '=' ID ':' TYPE
    | ID ',' VARLIST 
    | ID '=' LIT ',' VARLIST
;

FUNCDECL: FUNCTION ID '(' PARAMS ')' ':' TYPE '{' BLOCK '}'
        | FUNCTION ID '(' PARAMS ')' ':' VOID '{' BLOCK '}'
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
PARAMS: PARAMS ';' PARAMGR | PARAMGR | ;
PARAMGR: PARAMGRH VARLIST ;
%%


#include "lex.yy.c"
int main() { return yyparse();}
int yyerror() { printf("Error parsing LINE\n");  return 0; }

identifier* idpool[CAPACITY];
static int size = 0;

int addIdentifier(char* idname, char b, char c, char* s, void* n, int i, float f, char* typename) {
    for(int i = 0; i < size; i++) {
        if(strcmp(idpool[i]->name, idname) == 0) {
            printf(">>> VAR: [%s] IS ALREADY DECLARED\n", idname);
            yyerror();
            exit(1);
        }    
    }

    identifier* newId = (identifier*)malloc(sizeof(identifier));
    newId->name = strdup(idname);
    newId->type = strdup(typename);

    if(strcmp(typename, "INT") == 0) {
        newId->value.i = i;
    } else if (strcmp(typename, "REAL") == 0) {
        newId->value.f = f;
    } else if (strcmp(typename, "BOOL") == 0) {
        newId->value.b = b;
    } else if (strcmp(typename, "CHAR") == 0) {
        newId->value.c = c;
    } else if (strcmp(typename, "STRING") == 0) {
        newId->value.s = strdup(s);
    } else {
        newId->value.n = NULL; // OR 0
    }

    idpool[size++] = newId;

    return 0;
}

int yywrap(){
    for(int i = 0; i < size; i++) {
        printf("FREEING [%s] [%s] \n", idpool[i]->name, idpool[i]->type);
        char* typename = strdup(idpool[i]->type);

        if(strcmp(typename, "INT") == 0) {
            printf("[%d]\n", idpool[i]->value.i);
        } else if (strcmp(typename, "REAL") == 0) {
            printf("[%f]\n", idpool[i]->value.f);
        } else if (strcmp(typename, "BOOL") == 0) {
            printf("[%d]\n", idpool[i]->value.b);
        } else if (strcmp(typename, "CHAR") == 0) {
            printf("[%d]\n", idpool[i]->value.c);
        } else if (strcmp(typename, "STRING") == 0) {
            printf("[%s]\n", idpool[i]->value.s);
        } else {
            printf("NULL\n");
        }
        
        free(idpool[i]);
    }
}