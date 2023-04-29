%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#define CAPACITY 1024
int yylex();
int yyerror();
int yywrap();
void addItemToList(char*, char*, int);
void printList();

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

typedef struct node {
	struct node *next;
	struct node *prev;
	int lvl;
	struct node *parent;
	char *token;
	char *content;
    } list;
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
}

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
STMT: IF_STMT {  }
    | WHILE_LOOP | FOR_LOOP | DO_LOOP
    | VARDECL ';' | FUNCDECL 
    | ASSIGN ';'
    | RETURN ID ';'
    | RETURN LIT ';' { ;}
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
    | CHARLIT { $$.c = $1; printf("parsed CHARLIT: %c\n", $1); }
    | STRINGLIT { $$.s = strdup($1); }
    | NULLLIT { $$.n = NULL; }
;

VARDECL: VAR VARLIST ;
VARLIST: ID ':' TYPE
    | ID '=' LIT ':' TYPE
    | ID '=' ID ':' TYPE
    | ID ',' VARLIST 
    | ID '=' LIT ',' VARLIST
;

FUNCDECL: FUNCTION ID '(' PARAMS ')' ':' TYPE '{' BLOCK '}' {addItemToList("func", "", 1);}
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
list *first;
int lvl = 0;

int main() {
	first = (list *)malloc(sizeof(list));
	return yyparse();
}

int yyerror() { printf("Error parsing LINE\n");  return 0; }

int yywrap() {
    printList();
    return 1;
}

void addItemToList(char* token, char* content, int lvlchange) {
	printf("!!!!!!!!!!! - %s", first->token);
	if (first->token == NULL) {
	 first->token = strdup(token);
	 first->content = strdup(content);
	 first->prev = NULL;
	 first->next = NULL;
	 //printf("!!!!!!!!!!! - %s", first->next);
	}
	else {
		list *prev = first;
		list *iterator = first;
		while(first->next != NULL) {
			prev = iterator;
			iterator = first->next;
		}

		list *newElement = (list *)malloc(sizeof(list));
		newElement->prev = prev;
		newElement->next = NULL;
		if(lvlchange = 1) {lvl++;}
		else {lvl--;}
		newElement->lvl = lvl;
		newElement->token = strdup(token);
		newElement->content = strdup(content);
	}
}

void printList(){
	printf("!!!!!!!!!!!!!\n");
	printf("(%s %s", first->token, first->content);

	int templvl = 0;
	list *iterator = first;
	int j = 0;
	while(iterator->next != NULL && j<5) {
		if (templvl < iterator->lvl){printf(")\n");}
		iterator = first->next;
		//{printf("%*s%s\n", level*2, "", entry->d_name);}
		printf("%*s%s %s", iterator->lvl*2, "",iterator->token, iterator->content);
		templvl = iterator->lvl;
		iterator = iterator->next;
		j++;
	}
}