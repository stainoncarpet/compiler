%%
\/\*(.|\n)*?\*\/ {
    printf("comment: %s\n", yytext);
}
bool {
    printf("token: %s\n", yytext);
    return BOOL;
}
char {
    printf("token: %s\n", yytext);
    return CHAR;
}
int {
    printf("token: %s\n", yytext);
    return INT;
}
real {
    printf("token: %s\n", yytext);
    return REAL;
}
string {
    printf("token: %s\n", yytext);
    return STRING;
}
int\* {
    printf("token: %s\n", yytext);
    return INTPTR;
}
char\* {
    printf("token: %s\n", yytext);
    return CHARPTR;
}
real\* {
    printf("token: %s\n", yytext);
    return REALPTR;
}

while {
    printf("token: %s\n", yytext);
    return WHILE;
}
for {
    printf("token: %s\n", yytext);
    return FOR;
}
var {
    printf("token: %s\n", yytext);
    return VAR;
}
(true)|(false) {
    printf("token: %s\n", yytext);
    return BOOLLIT;
}
arg->$ {
    printf("token: %s\n", yytext);
    return PARAMGRH;
}
function {
    printf("token: %s\n", yytext);
    return FUNCTION;
}
return {
    printf("token: %s\n", yytext);
    return RETURN;
}
null {
    printf("token: %s\n", yytext);
    return NULLPTR;
}
void {
    printf("token: %s\n", yytext);
    return VOID;
}
do {
    printf("token: %s\n", yytext);
    return DO;
}

if {
    printf("token: %s\n", yytext);
    return IF;
}
else {
    printf("token: %s\n", yytext);
    return ELSE;
}
"==" {
    printf("token: %s\n", yytext);
    return EQ;
}
"!=" {
    printf("token: %s\n", yytext);
    return NOTEQ;
}
">" {
    printf("token: %s\n", yytext);
    return GR;
}
">=" {
    printf("token: %s\n", yytext);
    return GREQ;
}
"<" {
    printf("token: %s\n", yytext);
    return LE;
}
"<=" {
    printf("token: %s\n", yytext);
    return LEEQ;
}
[a-zA-Z]+[a-zA-Z0-9_]* {
    printf("token: %s\n", yytext);
    return ID;
}
\'.\' {
    printf("token: %s\n", yytext);
    return CHARLIT;
}
\".*\" {
    printf("token: %s\n", yytext);
    return STRINGLIT;
}
"&&" {
    printf("token: %s\n", yytext);
    return AND;
}
"||" {
    printf("token: %s\n", yytext);
    return OR;
}
[0-9]+ {
    printf("token: %s\n", yytext);
    yylval = atoi(yytext);
    return INTLIT;
}
[0-9]+\.[0-9]+ {
    printf("token: %s\n", yytext);
    return REALLIT;
}
[ \t\n]+ {;}
. {
    printf("token: %s\n", yytext);
    return yytext[0];
}
.|\n ;
%%