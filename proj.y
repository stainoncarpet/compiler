%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
int yylex();
int yyerror();
int yywrap();
typedef struct TreeNode {
    char* token;
    struct TreeNode* left;
    struct TreeNode* middle;
    struct TreeNode* right;
} TreeNode;
void printTree(TreeNode*, int);
TreeNode* makeNode(char*, TreeNode*, TreeNode*, TreeNode*);
TreeNode* TREE;
%}


%union {
    char* rawTokenValue;
    struct TreeNode* node;
}

%type <node> program statement statement_list if_statement vardecl id cond block block_context expr expr_eq init_assign finish_assign assign LIT type while_loop for_setting for_loop do_loop iter varincr vardecr expr_lt expr_subt expr_mult expr_add expr_div expr_or expr_and expr_noteq expr_leeq expr_gt expr_greq action_signature actiondecl params varlist paramgr return_statement actioncall args varlist_initable arrlist_initiable arrdecl arrentry intlit expr_lengthof expr_deref expr_ref expr_enslosed expr_flipped
%token BLOCK_START BLOCK_END BOOL CHAR INT REAL STRING EQ NOTEQ GT GREQ LT LEEQ AND OR RETURN VOID VAR PARAMGRH IF ELSE DO WHILE FOR FUNCTION INTPTR CHARPTR REALPTR
%token <rawTokenValue> INTLIT REALLIT BOOLLIT CHARLIT STRINGLIT NULLLIT ID
%type expr_lengthof
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


%%
program: statement_list { TREE = makeNode("program", $1, NULL, NULL); }
statement_list: statement_list statement { $$ = makeNode("statement_list", $1, $2, NULL); }
            | statement { $$ = $1; }
;
statement: block_context { $$ = $1; }
        | vardecl ';' { $$ = makeNode("statement", $1, NULL, NULL); }
        | arrdecl ';' { $$ = makeNode("statement", $1, NULL, NULL); }
        | assign ';' { $$ = makeNode("statement", $1, NULL, NULL); }
        | return_statement ';' { $$ = makeNode("statement", $1, NULL, NULL); }
        | expr ';' { $$ = makeNode("statement", $1, NULL, NULL); }
;
return_statement: RETURN expr {$$ = makeNode("return", $2, NULL, NULL); }
block_context: if_statement {$$ = $1; }
            | while_loop {$$ = $1; }
            | for_loop { $$ = $1; }
            | do_loop { $$ = $1; }
            | actiondecl { $$ = $1; }
            | start_block block end_block { $$ = makeNode("block", $2, NULL, NULL); }
;
if_statement: IF '(' cond ')' statement ELSE statement { 
                TreeNode* elseSection = makeNode("ELSE", $7, NULL, NULL);
                TreeNode* ifSection = makeNode("IF", $5, NULL, NULL);
                $$ = makeNode("if_statement", $3, ifSection, elseSection); 
            }
            | IF '(' cond ')' statement { 
                TreeNode* ifSection = makeNode("IF", $5, NULL, NULL);
                $$ = makeNode("if_statement", $3, ifSection, NULL); 
            }
;
while_loop: WHILE '(' cond ')' statement { $$ = makeNode("while_loop", $3, $5, NULL); } ;
for_loop: FOR for_setting block_context { 
        $$ = makeNode("for_loop", $2, $3, NULL); 
    }
;
for_setting: '(' assign ';' cond ';' iter ')' { $$ = makeNode("for_setting", $2, $4, $6); };
do_loop: DO block_context WHILE '(' cond ')' ';' { 
        $$ = makeNode("do_loop", $2, $5, NULL); 
    }
;
cond: expr { $$ = makeNode("condition", $1, NULL, NULL); };
iter: assign {$$ = $1; } 
    | varincr { $$ = makeNode("varincr", $1, NULL, NULL); } 
    | vardecr { $$ = makeNode("verdecr", $1, NULL, NULL); } 
;
varincr: id '+' '+' ;
vardecr: id '-' '-' ;
block:  statement_list { $$ = $1; } | { $$ = NULL; } ;
start_block: BLOCK_START  {};
end_block: BLOCK_END;
assign: init_assign '=' finish_assign  { $$ = makeNode("assign", $1, $3, NULL); }
;
init_assign: id { $$ = $1; }
        | id '[' expr ']' { $$ = makeNode("array_member", $1, $3, NULL); }
        | expr_deref { $$ = $1; }
;
finish_assign: expr { $$ = $1; }
           | expr LIT { 
                char stickyChar = $2->left->token[0];
                char sanitizedStr[32];

                if(stickyChar == '-') {
                        strncpy(sanitizedStr, $2->left->token + 1, 32);
                        $2->left->token = strdup(sanitizedStr);
                        $$ = makeNode("SUB", $1, $2, NULL);
                } else if(stickyChar == '+') {
                        strncpy(sanitizedStr, $2->left->token + 1, 32);
                        $2->left->token = strdup(sanitizedStr);
                        $$ = makeNode("ADD", $1, $2, NULL);
                } else if(stickyChar == '*') {
                        strncpy(sanitizedStr, $2->left->token + 1, 32);
                        $2->left->token = strdup(sanitizedStr);
                        $$ = makeNode("MULT", $1, $2, NULL);
                } else if(stickyChar == '/') {
                        strncpy(sanitizedStr, $2->left->token + 1, 32);
                        $2->left->token = strdup(sanitizedStr);
                        $$ = makeNode("DIV", $1, $2, NULL);
                }
            };
           | '&' arrentry { $$ = makeNode("referenced", $2, NULL, NULL); }
;
expr: LIT { $$ = $1; }
    | actioncall { $$ = $1; }
    | id { $$ = $1; }
    | expr_lengthof { $$ = $1; }
    | expr_subt { $$ = $1; }
    | expr_mult { $$ = $1; }
    | expr_add { $$ = $1; }
    | expr_div { $$ = $1; }
    | expr_or { $$ = $1; }
    | expr_and { $$ = $1; }
    | expr_eq { $$ = $1; }
    | expr_noteq { $$ = $1; }
    | expr_lt { $$ = $1; }
    | expr_leeq { $$ = $1; }
    | expr_gt { $$ = $1; }
    | expr_greq { $$ = $1; }
    | expr_enslosed {}
    | expr_deref { $$ = $1; }
    | expr_flipped { $$ = $1; }
    | expr_ref {}
    | error '\t' { 
        yyerrok;
        printf("\nERROR PARSING EXPRESSION HERE: ->_%c\n", yychar);
    }
;
expr_greq: expr GREQ expr { $$ = makeNode("GREQ", $1, $3, NULL); };
expr_gt: expr GT expr { $$ = makeNode("GT", $1, $3, NULL); };
expr_leeq: expr LEEQ expr { $$ = makeNode("LEEQ", $1, $3, NULL); };
expr_lt: expr LT expr { $$ = makeNode("LT", $1, $3, NULL); };
expr_noteq: expr NOTEQ expr { $$ = makeNode("NOTEQ", $1, $3, NULL); };
expr_eq: expr EQ expr { $$ = makeNode("EQ", $1, $3, NULL); };
expr_or: expr OR expr { $$ = makeNode("OR", $1, $3, NULL); };
expr_and: expr AND expr { $$ = makeNode("AND", $1, $3, NULL); };
expr_add: expr '+' expr { $$ = makeNode("ADD", $1, $3, NULL); };
expr_subt: expr '-' expr { $$ = makeNode("SUB", $1, $3, NULL); };
expr_mult: expr '*' expr { $$ = makeNode("MULT", $1, $3, NULL); };
expr_div: expr '/' expr { $$ = makeNode("DIV", $1, $3, NULL); };
expr_enslosed: '(' expr ')' { $$ = makeNode("enclosed", $2, NULL, NULL); };
expr_deref: '*' id { $$ = makeNode("dereferenced", $2, NULL, NULL); } 
        | '*' expr_enslosed { $$ = makeNode("dereferenced", $2, NULL, NULL); } 
;
expr_flipped: '!' expr { $$ = makeNode("flipped", $2, NULL, NULL); } ;
expr_ref: '&' id { $$ = makeNode("referenced", $2, NULL, NULL); } ;
expr_lengthof: '|' id '|' { $$ = makeNode("LENGTHOF", $2, NULL, NULL); };
LIT: intlit { $$ = $1; }
    | REALLIT { 
        TreeNode* value = makeNode($1, NULL, NULL, NULL); 
        $$ = makeNode("REALLIT", value, NULL, NULL); 
    }
    | BOOLLIT { 
        TreeNode* value = makeNode($1, NULL, NULL, NULL); 
        $$ = makeNode("BOOLLIT", value, NULL, NULL); 
    }
    | CHARLIT { 
        TreeNode* value = makeNode($1, NULL, NULL, NULL); 
        $$ = makeNode("CHARLIT", value, NULL, NULL); 
    }
    | STRINGLIT { 
        TreeNode* value = makeNode($1, NULL, NULL, NULL); 
        $$ = makeNode("STRINGLIT", value, NULL, NULL); 
    }
    | NULLLIT { 
        TreeNode* value = makeNode($1, NULL, NULL, NULL); 
        $$ = makeNode("NULLLIT", value, NULL, NULL); 
    }
;
intlit: INTLIT { 
        TreeNode* value = makeNode($1, NULL, NULL, NULL); 
        $$ = makeNode("INTLIT", value, NULL, NULL); 
    }
vardecl: VAR varlist_initable ':' type { $$ = makeNode("vardecl", $2, $4, NULL); };
varlist: id { $$ = makeNode("varlist", $1, NULL, NULL); } 
    | id ',' varlist { $$ = makeNode("varlist", $1, $3, NULL); }
;
varlist_initable: id '=' expr { $$ = makeNode("varlist", $1, $3, NULL); } 
    | id '=' expr ',' varlist_initable { $$ = makeNode("varlist", $1, $3, $5); }
    | id { $$ = makeNode("varlist", $1, NULL, NULL); } 
    | id ',' varlist_initable { $$ = makeNode("varlist", $1, $3, NULL); }
;
id: ID {
        TreeNode* idName = makeNode($1, NULL, NULL, NULL); 
        $$ = makeNode("id", idName, NULL, NULL); 
    }
;
arrdecl: type arrlist_initiable { $$ = makeNode("arrdecl", $1, $2, NULL);} ;
arrentry: id '[' intlit ']' { $$ = makeNode("arrentry", $1, $3, NULL); } ;
arrlist_initiable: arrentry '=' expr { $$ = makeNode("arrentry_init", $1, $3, NULL); } 
                | arrentry '=' expr ',' arrlist_initiable { $$ = makeNode("arrentry_init", $1, $3, $5); } 
                | arrentry { $$ = makeNode("arrentry_init", $1, NULL, NULL); } 
                | arrentry ',' arrlist_initiable { $$ = makeNode("arrentry_init", $1, $3, NULL); } 
;
actiondecl: FUNCTION action_signature block_context {
    $$ = makeNode("funcdecl", $2, $3, NULL);
}
;
action_signature: id '(' params ')' ':' type { $$ = makeNode("action_signature", $1, $3, $6); };
actioncall: id '(' args ')' { $$ = makeNode("actioncall", $1, $3, NULL); };
type: BOOL {
        TreeNode* value = makeNode("BOOL", NULL, NULL, NULL); 
        $$ = makeNode("TYPE", value, NULL, NULL); 
    }
    | CHAR {
        TreeNode* value = makeNode("CHAR", NULL, NULL, NULL); 
        $$ = makeNode("TYPE", value, NULL, NULL); 
    }
    | INT {
        TreeNode* value = makeNode("INT", NULL, NULL, NULL); 
        $$ = makeNode("TYPE", value, NULL, NULL); 
    }
    | REAL {
        TreeNode* value = makeNode("REAL", NULL, NULL, NULL); 
        $$ = makeNode("TYPE", value, NULL, NULL); 
    }
    | STRING {
        TreeNode* value = makeNode("STRING", NULL, NULL, NULL); 
        $$ = makeNode("TYPE", value, NULL, NULL); 
    }
    | INTPTR {
        TreeNode* value = makeNode("INTPTR", NULL, NULL, NULL); 
        $$ = makeNode("TYPE", value, NULL, NULL); 
    }
    | CHARPTR {
        TreeNode* value = makeNode("CHARPTR", NULL, NULL, NULL); 
        $$ = makeNode("TYPE", value, NULL, NULL); 
    }
    | REALPTR {
        TreeNode* value = makeNode("REALPTR", NULL, NULL, NULL); 
        $$ = makeNode("TYPE", value, NULL, NULL); 
    }
    | VOID {
        TreeNode* value = makeNode("VOID", NULL, NULL, NULL); 
        $$ = makeNode("TYPE", value, NULL, NULL); 
    }
;
params: paramgr { $$ = makeNode("params", $1, NULL, NULL); }
        | paramgr ';' params { $$ = makeNode("params", $1, $3, NULL); }
        | { $$ = makeNode("params", NULL, NULL, NULL); }
;
paramgr: PARAMGRH varlist ':' type { $$ = makeNode("paramgroup", $2, $4, NULL); };
args: id { $$ = makeNode("args", $1, NULL, NULL); }
    | id ',' args { $$ = makeNode("args", $1, $3, NULL); }
    | LIT { $$ = makeNode("args", $1, NULL, NULL); }
    | LIT ',' args { $$ = makeNode("args", $1, $3, NULL); }
    | { $$ = makeNode("args", NULL, NULL, NULL); }
;
%%

#include "lex.yy.c"

int main() {
    int res = yyparse();

    printTree(TREE, 0);


	return res;
}

extern int yylineno;
int yyerror(char* msg) { 
    printf("############# Error parsing LINE %d msg: [%s] \n", yylineno, msg);  
    return 0; 
}

int yywrap() {
    return 1;
}

void printTree(TreeNode *tree, int space) {
    int i;

    if (tree) {
        for (i = 0; i < space; i++) { printf("\t"); }
            
        printf("%s\n", tree->token);
        printTree(tree->left, space + 1);
        printTree(tree->middle, space + 1);
        printTree(tree->right, space + 1);
    }
}

TreeNode* makeNode(char *token, TreeNode *left, TreeNode *middle, TreeNode *right){
    TreeNode *newnode = (TreeNode *)malloc(sizeof(TreeNode));
    char *newtoken = (char *)malloc(sizeof(token) + 1);
    strcpy(newtoken, token);
    newnode->token = newtoken;
    newnode->left = left;
    newnode->right = right;
    newnode->middle = middle;
    return newnode;
}