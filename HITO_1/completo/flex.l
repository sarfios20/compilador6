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

\&\& return OPERADOR_AND;
\|\| return OPERADOR_OR;
\! return OPERADOR_NEGACION;
\+	return OPERADOR_SUMA;
\-	return OPERADOR_RESTA;
\*	return OPERADOR_MULTIPLICACION;
\/	return OPERADOR_DIVISION;
\(	return PARENTESIS_APERTURA;
\)	return PARENTESIS_CIERRE;
\"	return COMILLA;
\=	return OPERADOR_ASIGNACION;
\!= return OPERADOR_DIFERENTE;
\>	return OPERADOR_MAYOR;
\<	return OPERADOR_MENOR;
\== return OPERADOR_IGUAL;
\>= return OPERADOR_MAYOR_IGUAL;
\<= return OPERADOR_MENOR_IGUAL;
\;	return PUNTOCOMA;
\.\. return CONCATENAR;
\%  return MODULO;
\^  return EXPONENTE;
si return SI;
osi return OSI;
sino return SINO;
mientras return MIENTRAS;
fin return FIN;
para return PARA;
en return EN;
rango return RANGO;
\, return COMA;
escribir|imprimir|poner return IMPRIMIR;

{cierto}            {yylval.intVal = 1; return BOOL;}
falso               {yylval.intVal = 0; return BOOL;}
{digito}+"."{digito}+ {yylval.floatVal = atof(yytext); return REAL;}
{digito}+          {yylval.intVal = atoi(yytext); return ENTERO;}
{cadena}            {yylval.stringVal = strdup(yytext); printf( yytext);return TEXTO ;}
{identificador}     {yylval.stringVal = strdup(yytext); printf( yytext);return IDENTIFICADOR ;}

%%
