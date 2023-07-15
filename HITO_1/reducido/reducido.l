%option noyywrap

%{
#include "y.tab.h"

extern YYSTYPE yylval;
%}

digito           [0-9]
cadena           [A-Za-z][A-Za-z0-9]*
identificador    {cadena}(\.{cadena})?
cierto (cierto)|(verdadero)

%%
\n	return(0);
"+"              { return OPERADOR_SUMA; }
"-"              { return OPERADOR_RESTA; }
"*"              { return OPERADOR_MULTIPLICACION; }
"/"              { return OPERADOR_DIVISION; }
"("              { return PARENTESIS_APERTURA; }
")"              { return PARENTESIS_CIERRE; }
"=="             { return OPERADOR_IGUAL; }
"!="             { return OPERADOR_DISTINTO; }
">"              { return OPERADOR_MAYOR; }
"<"              { return OPERADOR_MENOR; }
">="             { return OPERADOR_MAYOR_IGUAL; }
"<="             { return OPERADOR_MENOR_IGUAL; }
"="              { return OPERADOR_ASIGNACION; }
";"              { return PUNTOCOMA; }
".."             { return CONCAT; }
\"	             { return COMILLA;}
"!"              { return OPERADOR_NEGACION; }
"&&"             { return OPERADOR_AND; }
"||"             { return OPERADOR_OR; }

{cierto}         { yylval.intVal = 1; return BOOL; }
falso            { yylval.intVal = 0; return BOOL; }
{digito}+        { yylval.intVal = atoi(yytext); return ENTERO; }
{digito}+"."{digito}+ { yylval.floatVal = atof(yytext); return REAL; }
{cadena}         { yylval.stringVal = strdup(yytext); return TEXTO; }
[a-zA-Z]+		{yylval.stringVal=strdup(yytext); printf( yytext);return TEXTO ;}
{identificador}  { yylval.stringVal = strdup(yytext); return IDENTIFICADOR; }
[ \t\n]          ; // Ignore whitespace characters
.                ; // Ignore unrecognized characters

%%