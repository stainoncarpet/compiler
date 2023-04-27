 #include <string.h>
%%
\/\*(.|\n)*?\*\/ {
    printf("comment: %s\n", yytext);
}
bool {
    printf("BOOL: %s\n", yytext);
    return BOOL;
}
char {
    printf("CHAR: %s\n", yytext);
    return CHAR;
}
int {
    printf("INT: %s\n", yytext);
    return INT;
}
real {
    printf("REAL: %s\n", yytext);
    return REAL;
}
string {
    printf("STRING: %s\n", yytext);
    return STRING;
}
int\* {
    printf("INTPTR: %s\n", yytext);
    return INTPTR;
}
char\* {
    printf("CHARPTR: %s\n", yytext);
    return CHARPTR;
}
real\* {
    printf("REALPTR: %s\n", yytext);
    return REALPTR;
}

while {
    printf("WHILE: %s\n", yytext);
    return WHILE;
}
for {
    printf("FOR: %s\n", yytext);
    return FOR;
}
var {
    printf("VAR: %s\n", yytext);
    return VAR;
}
(true)|(false) {
    printf("BOOLLIT: %s\n", yytext);
    yylval._bool = strcmp(yytext, "false") == 0 ? 0 : 1;
    return BOOLLIT;
}
arg-\> {
    printf("PARAMGRH: %s\n", yytext);
    return PARAMGRH;
}
function {
    printf("FUNCTION: %s\n", yytext);
    return FUNCTION;
}
return {
    printf("RETURN: %s\n", yytext);
    return RETURN;
}
null {
    printf("NULLLIT: %s\n", yytext);
    return NULLLIT;
}
void {
    printf("VOID: %s\n", yytext);
    return VOID;
}
do {
    printf("DO: %s\n", yytext);
    return DO;
}

if {
    printf("IF: %s\n", yytext);
    return IF;
}
else {
    printf("ELSE: %s\n", yytext);
    return ELSE;
}
"==" {
    printf("EQ: %s\n", yytext);
    return EQ;
}
"!=" {
    printf("NOTEQ: %s\n", yytext);
    return NOTEQ;
}
">" {
    printf("GR: %s\n", yytext);
    return GR;
}
">=" {
    printf("GREQ: %s\n", yytext);
    return GREQ;
}
"<" {
    printf("LE: %s\n", yytext);
    return LE;
}
"<=" {
    printf("LEEQ: %s\n", yytext);
    return LEEQ;
}
[a-zA-Z]+[a-zA-Z0-9_]* {
    printf("ID: %s\n", yytext);
    yylval._string = strdup(yytext);
    // YYSTYPE = yylval;
    return ID;
}
[a-zA-Z]+[a-zA-Z0-9_]*\+\+ {
    printf("VARINCR: %s\n", yytext);
    return VARINCR;
}
[a-zA-Z]+[a-zA-Z0-9_]*\-\- {
    printf("VARDECR: %s\n", yytext);
    return VARDECR;
}
\'.\' {
    printf("CHARLIT: %s\n", yytext);
    yylval._char = yytext[0];
    return CHARLIT;
}
\".*\" {
    printf("STRINGLIT: %s\n", yytext);
    yylval._string = strdup(yytext);
    return STRINGLIT;
}
"&&" {
    printf("AND: %s\n", yytext);
    return AND;
}
"||" {
    printf("OR: %s\n", yytext);
    return OR;
}
[0-9]+ {
    printf("INTLIT: %s\n", yytext);
    yylval._int = atoi(yytext);
    return INTLIT;
}
[0-9]+\.[0-9]+ {
    printf("REALLIT: %s\n", yytext);
    yylval._float = atof(yytext);
    return REALLIT;
}
[ \t\n]+ { ; }
. {
    printf("SYMBOL: %s\n", yytext);
    return yytext[0];
}
.|\n ;
%%