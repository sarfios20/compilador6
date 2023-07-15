%option noyywrap yylineno

%{
#include "y.tab.h"
%}

digito [0-9]
letra [a-zA-Z]
cierto (cierto)|(verdadero)

comentario \/\/.*|#.*|\/\*.*\*\/
cadena \"(\\.|[^"\\])*\"|\'(\\.|[^'\\])*\'
comentario_multiple \/\*([^\*]|[\r\n]|(\*+([^*\/]|[\r\n])))*\*+\/
identificador {letra}({letra}|{digito})*

%%

{comentario} ;
{comentario_multiple} ;

\+	return OPERADOR_SUMA;
\-	return OPERADOR_RESTA;
\*	return OPERADOR_MULTIPLICACION;
\/	return OPERADOR_DIVISION;
\(	return PARENTESIS_APERTURA;
\)	return PARENTESIS_CIERRE;


{digito}+          {yylval.intVal = atoi(yytext); return ENTERO;}

%%
