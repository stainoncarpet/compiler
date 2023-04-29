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
void addChildParentNode(char*, char*, int);
void addSiblingNode(char* nodeType, char* id, int);
void printTree();

typedef struct node {
	struct node *next;
	struct node *prev;
	int lvl;
	struct node *parent;
    struct node *child;
	char *token;
	char *content;
    } treenode;
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
%token EQ NOTEQ GR GREQ LE LEEQ AND OR VARINCR VARDECR SQBROPN SQBRCLS
%left '+' '-'
%left '*' '/'
%type <_int> OP
%type <_string> TYPE
%type <any> LIT



%%
s: | lines ;
lines: lines stmt | stmt ;
stmt: if_stmt
    | while_loop | for_loop | do_loop
    | vardecl ';' | funcdecl 
    | assign ';'
    | RETURN ID ';'
    | RETURN LIT ';' { /*addChildParentNode("RET!!", ""); */}
;
if_stmt: IF '(' cond ')' open block close ELSE open block close
        | IF '(' cond ')' open block close
;
while_loop: WHILE '(' cond ')' open block close ;
for_loop: FOR '(' vardecl ';' cond ';' iter ')' open block close ;
do_loop: DO SQBROPN block close WHILE '(' cond ')' ';' ;
cond: ID LE ID 
    | ID GR ID 
    | ID EQ ID 
    | ID GR LIT 
    | ID LE LIT 
    | ID EQ LIT
    | BOOLLIT
;
iter: assign | VARINCR | VARDECR;
block: block stmt | stmt ;
assign: ID '=' OP ;
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

vardecl: VAR varlist ;
varlist: ID ':' TYPE
    | ID '=' LIT ':' TYPE
    | ID '=' ID ':' TYPE
    | ID ',' varlist 
    | ID '=' LIT ',' varlist
;

funcdecl: FUNCTION ID '(' params ')' ':' TYPE open block close { 
        // addItemToList("func", "", 1); 
        addChildParentNode("FUNCTION", "", 1);
        addChildParentNode("ID", $2, 1);
        addSiblingNode("params", "ARG", 0);
        addSiblingNode("RETURN ", $7, 0);
        addSiblingNode("block ", "", 1);

    }
        | FUNCTION ID '(' params ')' ':' VOID open block close
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
open: SQBROPN ;
close: SQBRCLS ;
%%



#include "lex.yy.c"
treenode *treehead;
treenode* currentParent;
int lvl = 0;

int main() {
	treehead = (treenode *)malloc(sizeof(treenode));
    treehead->prev = NULL;
	treehead->next = NULL;
    treehead->lvl = 0;
    treehead->parent = NULL;
    treehead->child = NULL;
    treehead->token = strdup("CODE");
	treehead->content = NULL;
    currentParent = treehead;

	return yyparse();
}

int yyerror() { printf("Error parsing LINE\n");  return 0; }

int yywrap() {
    //printList();
    printTree();
    return 1;
}

void addChildParentNode(char* nodeType, char* id, int lvlStep) {
    if(strlen(id) > 0) {
        printf("###Adding node: [%s] with value: [%s]\n", nodeType, id);
    } else {
        printf("###Adding node: [%s]\n", nodeType);
    }

    lvl = lvl + lvlStep;
    
    treenode* newNode = (treenode *)malloc(sizeof(treenode));

    newNode->lvl = currentParent->lvl + 1;
    newNode->token = strdup(nodeType);
    newNode->content = strdup(id);
    currentParent->child = newNode;
    newNode->parent = currentParent;
    currentParent = newNode;
}

void addSiblingNode(char* nodeType, char* id, int lvlStep) {
    printf("###Adding sibling: [%s] to %s\n", nodeType, currentParent->token);
    treenode* newNode = (treenode *)malloc(sizeof(treenode));

    currentParent->next = newNode;
    newNode->prev = currentParent;
    newNode->next = NULL;
    newNode->lvl = currentParent->lvl;
    newNode->parent = currentParent->parent;
    newNode->child = NULL;
    newNode->token = strdup(nodeType);
    newNode->content = strdup(id);
    //currentParent = newNode;
}

void printTree() {
    printf("#Printing tree\n");
    treenode* iterator = treehead;


    while(iterator != NULL) {
        //printf("@iterator %s %s lvl:%d \n", iterator->token, iterator->content, iterator->lvl);

        iterator = iterator->child;
    }
    
    iterator = currentParent->next;

    while(iterator != NULL) {
        //printf("@iterator %s %s lvl:%d \n", iterator->token, iterator->content, iterator->lvl);

        iterator = iterator->child;
    }
}

void addItemToList(char* token, char* content, int lvlchange) {
	treenode *prev = treehead;
		treenode *iterator = treehead;
		while(treehead->next != NULL) {
			prev = iterator;
			iterator = treehead->next;
		}

		treenode *newElement = (treenode *)malloc(sizeof(treenode));
		newElement->prev = prev;
		newElement->next = NULL;
		lvl = lvl + lvlchange;
		newElement->lvl = lvl;
		newElement->token = strdup(token);
		newElement->content = strdup(content);
}

void printList(){
	int templvl = 0;
	treenode *iterator = treehead;
	int j = 0;
	while(iterator->next != NULL) {
		if (templvl < iterator->lvl){printf(")\n");}
		iterator = treehead->next;
		//{printf("%*s%s\n", level*2, "", entry->d_name);}
		printf("%*s%s %s", iterator->lvl*2, "",iterator->token, iterator->content);
		templvl = iterator->lvl;
		iterator = iterator->next;
		j++;
	}
}