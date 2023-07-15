%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "simbol_table.h"
#include "AST.h"
#include <stdbool.h>

FILE *yyout;
extern FILE* yyin;

//Variables
int error_compilacion=0;
extern int yylineno; 

//Variables de la tabla de símbolos
symbol table[100];
int table_size = 0;//Se usa para conocer el índice del array disponible para insertar el siguiente número

//int numEtiqueta=0;
//bool variableGlobalFaltaEtiqueta= false;

%}

/* declare type possibilities of symbols */
%union {
  int intVal;
  float floatVal;
  char* stringVal;
  struct atributos{
    struct nodo *a;  //El sctruct del AST para poder almacenar los nodos
    float real;
    int entero;
    int booleano;
    char* texto;
    char* tipo; //Cadena de caracteres que almacena textualmente el tipo del elemento para poder ofrecer controles semánticos sobre el mismo
  }tr;
}


/* Declarar tokens recogidos de FLEX*/
%token OPERADOR_SUMA OPERADOR_RESTA OPERADOR_MULTIPLICACION OPERADOR_DIVISION PARENTESIS_APERTURA PARENTESIS_CIERRE


/* Los no terminales hacen uso de la estructura */
%type <tr> factor 
%type <tr> exp term


%token <intVal> ENTERO


%left OPERADOR_SUMA OPERADOR_RESTA 
%left OPERADOR_MULTIPLICACION OPERADOR_DIVISION  




%start exp

%%
 
exp: exp OPERADOR_SUMA term {
        if (strcmp($1.tipo, "entero")==0 && strcmp($3.tipo, "entero")==0) { //Si ambos son enteros
            $$.a = new_node('+', $1.a,$3.a); 
            if($$.a->registro==-1){
                error_compilacion++;
                printf("ERROR LINEA %d: No quedan registros disponibles para realizar la operacion suma\n", yylineno);
            }
            $$.tipo="entero";
            $$.entero=$1.entero+$3.entero;
            printf("-> SUMA entero+entero\n");  
        } else {
                error_compilacion++;
                printf( "ERROR: No se puede operar\n");
        }
    }
    | exp OPERADOR_RESTA term {
        if (strcmp($1.tipo, "entero")==0 && strcmp($3.tipo, "entero")==0) { //Si ambos son enteros
            $$.a = new_node('+', $1.a,$3.a); 
            if($$.a->registro==-1){
                error_compilacion++;
                printf("ERROR LINEA %d: No quedan registros disponibles para realizar la operacion suma\n", yylineno);
            }
            $$.tipo="entero";
            $$.entero=$1.entero+$3.entero;
            printf("-> SUMA entero+entero\n");  
        } else {
            error_compilacion++;
            printf( "ERROR: No se puede operar\n");
        }
    }
    | term {
        //printf("Termino con tipo %s\n",$1.tipo);
        $$ = $1; }   //Se hace una copia
    ;

term: 
    term OPERADOR_MULTIPLICACION factor {
        if (strcmp($1.tipo, "entero")==0 && strcmp($3.tipo, "entero")==0) { //Si ambos son enteros
            $$.a = new_node('*', $1.a,$3.a);
            if($$.a->registro==-1){
                error_compilacion++;
                printf("ERROR LINEA %d: No quedan registros disponibles para realizar la operacion multiplicar\n", yylineno);
            }
            $$.tipo="entero";
            $$.entero=$1.entero*$3.entero;
            printf( "-> MULTIPLICACION entero*entero\n");
        } else {
             error_compilacion++;
             printf( "ERROR LINEA %d: No se puede realizar la operacion multiplicar con estos operandos");
        }
    }
    | term OPERADOR_DIVISION factor {
        if (strcmp($1.tipo, "entero")==0 && strcmp($3.tipo, "entero")==0) { //Si ambos son enteros
            if ($3.entero == 0) {
                error_compilacion++;
                printf("ERROR LINEA %d: Division por cero no permitida\n", yylineno);
                return;
            }
            $$.a = new_node('/', $1.a,$3.a);
            if($$.a->registro==-1){
                error_compilacion++;
                printf("ERROR LINEA %d: No quedan registros disponibles para realizar la operacion dividir\n", yylineno);
            } 
            $$.tipo="entero";
            $$.entero=$1.entero/$3.entero;
            printf( "-> DIVISION entero/entero\n");
        }
        else{
            error_compilacion++;
            printf( "ERROR LINEA %d: No se puede realizar la operacion dividir con estos operandos", yylineno);
        }
    }
    | factor {
        $$ = $1;
    }
    ;

factor: 
   ENTERO{$$.entero = $1;
            $$.a = new_leaf_num($1);
            if($$.a->registro==-1){
                error_compilacion++;
                printf("ERROR LINEA %d: No quedan registros disponibles para asignar el entero %ld\n",  yylineno,$$.entero);
            }  
            $$.tipo="entero"; 
            printf( "-> ENTERO: %ld\n", $$.entero);
    }   
    | OPERADOR_RESTA ENTERO{$$.entero = -$2;
            $$.a = new_leaf_num(-$2);
            if($$.a->registro==-1){
                error_compilacion++;
                printf("ERROR LINEA %d: No quedan registros disponibles para asignar el entero %ld\n",  yylineno, $$.entero);
            }
            $$.tipo="entero";
            printf( "-> ENTERO NEGATIVO: %ld\n", $$.entero);
    }
    | PARENTESIS_APERTURA exp PARENTESIS_CIERRE {
            $$ = $2;
            printf("PARENTESIS\n");
    }
    ;

%%

int main(int argc, char** argv) {
    if (argc < 2) {
        printf("Sin input. Introduce archivo input.\n");
        return 1;
    }
    yyin = fopen(argv[1], "rt");
    if (yyin == NULL) {
        printf("No se puedo leer el input.\n");
        return 1;
    }
    yyout = fopen( "./maquina.asm", "wt" );
	yyparse();
    fclose(yyin);
    return 0;
}

void yyerror(const char* s) {
    fprintf(stderr, "%s\n", s);
}

int yywrap() {
    return 1;
}