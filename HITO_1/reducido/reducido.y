%{
#include <ctype.h>
#include <stdio.h>
#include <string.h>
#include "simbol_table.h"

int numero_errores = 0;
int linea = 1;

symbol table[100];
int table_size = 0;

%}

%union {
  int intVal;
  float floatVal;
  char* stringVal;
  int boolVal;
  struct atributos{
    float real;
    int entero;
    char* texto;
    char* tipo;
    int booleano;
  } tr;
}

%type <tr> exp term factor asignacion

%token <intVal> ENTERO
%token OPERADOR_SUMA OPERADOR_RESTA OPERADOR_MULTIPLICACION OPERADOR_DIVISION
%token OPERADOR_IGUAL OPERADOR_DISTINTO OPERADOR_MAYOR OPERADOR_MENOR
%token OPERADOR_MAYOR_IGUAL OPERADOR_MENOR_IGUAL OPERADOR_ASIGNACION
%token PARENTESIS_APERTURA PARENTESIS_CIERRE PUNTOCOMA CONCAT COMILLA
%token OPERADOR_NEGACION OPERADOR_AND OPERADOR_OR

%token <stringVal> TEXTO
%token <stringVal> IDENTIFICADOR
%token <floatVal> REAL 
%token <intVal> BOOL 
%start command

%left OPERADOR_SUMA OPERADOR_RESTA
%left OPERADOR_MULTIPLICACION OPERADOR_DIVISION  
%left OPERADOR_AND
%left OPERADOR_OR
%nonassoc OPERADOR_NEGACION
%nonassoc OPERADOR_IGUAL OPERADOR_DISTINTO OPERADOR_MAYOR OPERADOR_MENOR OPERADOR_MAYOR_IGUAL OPERADOR_MENOR_IGUAL

%%

command: exp { if (numero_errores >= 1) {
                  printf("\nHa habido %d error(es) de compilacion", numero_errores);
               } else {
                  if (strcmp($1.tipo, "entero") == 0) {
                        printf(" El resultado entero es %d\n", $1.entero);
                  } else {
                        printf(" ERROR: LA variable no tiene tipo");
                  }
               }
            }
            | asignacion {  if(numero_errores >= 1){
                    printf("\nHa habido %d error(es) de compilacion", numero_errores);
                }else{
                    printf("***********\n");
                    if(strcmp($1.tipo, "entero")==0){printf(" El resultado entero es %d\n", $1.entero); }
                    else {printf(" ERROR: LA variable no tiene tipo");}  
                }
            }
         ;

asignacion: TEXTO OPERADOR_ASIGNACION exp PUNTOCOMA{
    printf("Asignacion\n");
        int i = lookup($1,table_size,table);
        if (i == -1) { // Si el símbolo no está en la tabla, se agrega
        printf("-> Se crea\n");
            if(strcmp($3.tipo, "entero")==0){
                table[table_size].name = $1;
                table[table_size].entero = $3.entero;
                table[table_size].tipo = "entero";
                table_size++;
                $$.tipo = "entero";
                $$.entero = $3.entero;
            }
            else if(strcmp($3.tipo, "texto")==0){
                table[table_size].name = $1;
                table[table_size].texto = $3.texto;
                table[table_size].tipo = "texto";
                table_size++;
                $$.tipo = "texto";
                $$.texto = $3.texto;
            }
            else{
                printf("ERROR: El tipo de variable a asignar no se reconoce");
            }

        } else { // Si el símbolo ya está en la tabla, se actualiza su valor
        printf("-> Se actualiza\n");
            table[i].entero = $3.entero;
        }
}
;

exp: exp OPERADOR_SUMA term {
        $$.entero = $1.entero + $3.entero;
        printf("suma = %d\n", $$.entero);
    }
    | exp OPERADOR_RESTA term {
        $$.entero = $1.entero - $3.entero;
        printf("resta = %d\n", $$.entero);
    }
    | term {
        $$ = $1; // Copy
    }
    ;

term: term OPERADOR_MULTIPLICACION factor {
        $$.entero = $1.entero * $3.entero;
        printf("multiplicacion = %d\n", $$.entero);
    }
    | term OPERADOR_DIVISION factor {
        $$.entero = $1.entero / $3.entero;
        printf("division = %d\n", $$.entero);
    }
    | factor {
        $$ = $1; // Copy
    }
    ;

factor: ENTERO {
        $$.entero = $1;
        $$.tipo = "entero";
        printf("ENTERO %d\n", $$.entero);
    }
    | OPERADOR_SUMA ENTERO {
        $$.entero = $2;
        $$.tipo = "entero";
        printf("ENTERO POSITIVO %d\n", $$.entero);
    }
    | OPERADOR_RESTA ENTERO {
        $$.entero = -$2;
        $$.tipo = "entero";
        printf("ENTERO NEGATIVO %d\n", $$.entero);
    }
    | PARENTESIS_APERTURA exp PARENTESIS_CIERRE {
        $$ = $2; // Copy
        $$.tipo = "entero";
        printf("PARENTESIS \n");
    }
    | COMILLA TEXTO COMILLA {
        $$.texto = $2;
        $$.tipo = "texto";
        printf("TEXTO %s\n", $$.texto);
    }
    ;

%%

int main(void) {
    return yyparse();
}

void yyerror(const char* s) {
    printf("Error en la linea %d: %s\n", linea, s);
}
