%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <stdbool.h>
#include "symbol_table.h"
#include "ast.h"


FILE *archivo_salida;
FILE* yyin;

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
%token OPERADOR_SUMA OPERADOR_RESTA OPERADOR_MULTIPLICACION OPERADOR_DIVISION PARENTESIS_APERTURA PARENTESIS_CIERRE CONCATENAR COMILLA OPERADOR_ASIGNACION SI OSI SINO MIENTRAS FIN OPERADOR_AND OPERADOR_OR IMPRIMIR
%token OPERADOR_NEGACION OPERADOR_MAYOR OPERADOR_MENOR MODULO EXPONENTE OPERADOR_MAYOR_IGUAL OPERADOR_IGUAL OPERADOR_MENOR_IGUAL
%token PUNTOCOMA PARA EN RANGO COMA OPERADOR_DIFERENTE

/* Los no terminales hacen uso de la estructura */
%type <tr> statement_list factor statement asignacion_statement si_statement osi_list osi mientras_statement imprimir_statement
%type <tr> condicion_list condicion para_statement
%type <tr> exp term


%token <intVal> ENTERO
%token <floatVal> REAL
%token <stringVal> TEXTO
%token <stringVal> IDENTIFICADOR
%token <intVal> BOOL

%left OPERADOR_MAYOR OPERADOR_MENOR OPERADOR_MAYOR_IGUAL OPERADOR_MENOR_IGUAL OPERADOR_IGUAL
%left OPERADOR_SUMA OPERADOR_RESTA CONCATENAR
%left OPERADOR_MULTIPLICACION OPERADOR_DIVISION  
%left OPERADOR_ASIGNACION PUNTOCOMA
%right OPERADOR_NEGACION



%start program

%%

program:
    statement_list  {
        printf("------------------------\n");
        printf("SENTENCIA RECONOCIDA\n");
        if(error_compilacion>=1){
            printf("\nHa habido %d error(es) de compilacion\n",error_compilacion);
        }
        printf("CREANDO CODIGO .ASM\n");
        printf("------------------------\n");
        double valor = escribir_mips($1.a); 
        printf("------------------------\n");
        printf("COMPILACION TERMINADA\n");
            
    }
    ;

//Varias cosas encadenadas
statement_list:
    statement {
        printf("-> STATEMENT\n");
        $$.a=$1.a;
    }
    | statement_list statement {
        printf("-> STATEMENT LIST\n");
        $$.a = nuevo_nodo('SL', $1.a, $2.a);
        if($$.a->registro==-1){
                error_compilacion++;
                printf("ERROR LINEA %d: No quedan registros disponibles para almacenar la lista de statements\n", yylineno);
            }
    }
    ;

//Una signación, IF o WHILE
statement:
    asignacion_statement {
        $$.a=$1.a;
    }
    | si_statement {
        $$.a=$1.a;
    }
    | mientras_statement {
    }
    | para_statement {
    }
    | imprimir_statement {
        $$.a=$1.a;
    }
    ;

imprimir_statement: 
    IMPRIMIR PARENTESIS_APERTURA exp PARENTESIS_CIERRE{ 
            printf("-> IMPRIMIR\n");
            $$.a = nuevo_nodo('P',$3.a, nodo_vacio());
            if($$.a->registro==-1){
                error_compilacion++;
                printf("ERROR LINEA %d: No quedan registros disponibles para realizar la operacion imprimir\n", yylineno);
            }
            
        }
    ;

asignacion_statement:
    IDENTIFICADOR OPERADOR_ASIGNACION exp {
        printf("-> ASIGNACION\n");
        int i = lookup($1,table_size,table);
        if (i == -1) {  
            create_or_update_variable($1, $3.tipo, $3, table_size);
            table_size++;

            $$.a=nuevo_nodo('A',$3.a, nodo_vacio());
            if($$.a->registro==-1){
                error_compilacion++;
                printf("ERROR LINEA %d: No quedan registros disponibles para realizar la operacion asignacion\n", yylineno);
            }
        } else {  
            printf("# Sobreescribir la varible -%s-, que se encuentra en el registro  $f%d\n",table[i].name ,table[i].registro); 
            create_or_update_variable($1, $3.tipo, $3, i);

            $$.a=nuevo_nodo('R',$3.a, nodo_con_info_para_asignacion(table[i].registro));
            if($$.a->registro==-1){
                error_compilacion++;
                printf("ERROR LINEA %d: No quedan registros disponibles para realizar la operacion asignacion\n", yylineno);
            }            
        }
    }
    ;

//Si
si_statement: 
    SI PARENTESIS_APERTURA condicion_list PARENTESIS_CIERRE statement_list osi_list FIN  {printf("Bucle SI con cadena de OSI\n");}
    | SI PARENTESIS_APERTURA condicion_list PARENTESIS_CIERRE statement_list FIN {
        printf("-> SI\n");
        $$.a = nuevo_nodo('S',$3.a, $5.a);
        if($$.a->registro==-1){
            error_compilacion++;
            printf("ERROR LINEA %d: No quedan registros disponibles para realizar la sentencia SI\n", yylineno);
        }
        }
    | SI PARENTESIS_APERTURA condicion_list PARENTESIS_CIERRE statement_list SINO statement_list FIN {
        printf("-> SI con SINO\n");
        $$.a = nuevo_nodo_sino($3.a,$5.a, $7.a);
        if($$.a->registro==-1){
            error_compilacion++;
            printf("ERROR LINEA %d: No quedan registros disponibles para realizar la sentencia SI\n", yylineno);
        }
    }
    ;

osi_list:
    osi    {printf("UN OSI\n");}
    | osi_list osi  {printf("VARIOS OSI\n");}
    ;

osi: OSI PARENTESIS_APERTURA condicion_list PARENTESIS_CIERRE statement_list {printf("OSI\n");}
    ;


mientras_statement:
    MIENTRAS PARENTESIS_APERTURA condicion_list PARENTESIS_CIERRE statement_list FIN {
        printf("-> MIENTRAS\n");
        $$.a = nuevo_nodo('M',$3.a,$5.a);
        if($$.a->registro==-1){
            error_compilacion++;
            printf("ERROR LINEA %d: No quedan registros disponibles para realizar la sentencia MIENTRAS\n", yylineno);
        }
    }
    ;

para_statement:
    PARA IDENTIFICADOR EN RANGO PARENTESIS_APERTURA ENTERO COMA ENTERO PARENTESIS_CIERRE statement_list FIN {
        printf("-> PARA\n");
        $$.a = nuevo_nodo_para(strdup($2), $6, $8, $10.a);
        if($$.a->registro==-1){
            error_compilacion++;
            printf("ERROR LINEA %d: No quedan registros disponibles para realizar la condicion\n", yylineno);
        }
    }
    |PARA IDENTIFICADOR EN RANGO PARENTESIS_APERTURA ENTERO PARENTESIS_CIERRE statement_list FIN {
        printf("-> PARA2\n");
        $$.a = nuevo_nodo_para2(strdup($2), $6, $8.a);
        if($$.a->registro==-1){
            error_compilacion++;
            printf("ERROR LINEA %d: No quedan registros disponibles para realizar la condicion\n", yylineno);
        }
    }
    | PARA IDENTIFICADOR EN RANGO PARENTESIS_APERTURA ENTERO COMA ENTERO COMA ENTERO PARENTESIS_CIERRE statement_list FIN {
        printf("-> PARA3\n");
        $$.a = nuevo_nodo_para3(strdup($2), $6, $8, $10, $12.a);
        if($$.a->registro==-1){
            error_compilacion++;
            printf("ERROR LINEA %d: No quedan registros disponibles para realizar la condicion\n", yylineno);
        }
    }
    ;

//Lista de condiciones
condicion_list: condicion_list OPERADOR_AND  condicion {printf("Condicion && condicion\n");}
    | condicion_list OPERADOR_OR condicion {printf("Condicion || condicion\n");}
    | condicion {
        $$.a = $1.a;
        printf("-> CONDICION\n");
        $$.a = nuevo_nodo('C',$1.a, nodo_vacio());
        if($$.a->registro==-1){
            error_compilacion++;
            printf("ERROR LINEA %d: No quedan registros disponibles para realizar la condicion\n", yylineno);
        }

    }

//Condiciones
condicion: 
    exp OPERADOR_MAYOR exp {
        printf("exp OPERADOR_MAYOR exp\n");
        compare_expression(">", $1.tipo, $3.tipo, $1, $3, &$$);
    }
    | exp OPERADOR_MENOR exp {
        printf("exp OPERADOR_MENOR exp\n");
        compare_expression("<", $1.tipo, $3.tipo, $1, $3, &$$);
    }
    | exp OPERADOR_MAYOR_IGUAL exp {
        printf("exp OPERADOR_MAYOR_IGUAL exp\n");
        compare_expression(">=", $1.tipo, $3.tipo, $1, $3, &$$);
    }
    | exp OPERADOR_MENOR_IGUAL exp {
        printf("exp OPERADOR_MENOR_IGUAL exp\n");
        compare_expression("<=", $1.tipo, $3.tipo, $1, $3, &$$);
    }
    | exp OPERADOR_IGUAL exp {
        printf("exp OPERADOR_IGUAL exp\n");
        compare_expression("==", $1.tipo, $3.tipo, $1, $3, &$$);
    }
    | exp OPERADOR_DIFERENTE exp {
        printf("exp OPERADOR_DIFERENTE exp\n");
        compare_expression("!=", $1.tipo, $3.tipo, $1, $3, &$$);
    }
    | exp OPERADOR_AND exp {
        printf("exp OPERADOR_AND exp\n");
        compare_expression("&&", $1.tipo, $3.tipo, $1, $3, &$$);
    }
    | exp OPERADOR_OR exp {
        printf("exp OPERADOR_OR exp\n");
        compare_expression("||", $1.tipo, $3.tipo, $1, $3, &$$);
    }
    ;
  
exp: OPERADOR_NEGACION exp {
        if (strcmp($2.tipo, "booleano")==0) {
            $$.booleano = !$2.booleano; 
            $$.tipo = "booleano";
            printf("-> NEGACION booleano\n");
        } else {
            printf("ERROR LINEA %d: \n", yylineno);
            error_compilacion++;
        }
    }
    |
    exp OPERADOR_SUMA term {
        if (strcmp($1.tipo, "entero")==0 && strcmp($3.tipo, "entero")==0) { //Si ambos son enteros
            $$.a = nuevo_nodo('+', $1.a,$3.a); 
            if($$.a->registro==-1){
                error_compilacion++;
                printf("ERROR LINEA %d: No quedan registros disponibles para realizar la operacion suma\n", yylineno);
            }
            $$.tipo="entero";
            $$.entero=$1.entero+$3.entero;
            printf("-> SUMA entero+entero\n");  
        }
        else if (strcmp($1.tipo, "real")==0 && strcmp($3.tipo, "real")==0){  //Si los dos son float
            $$.a = nuevo_nodo('+', $1.a,$3.a);
            if($$.a->registro==-1){
                error_compilacion++;
                printf("ERROR LINEA %d: No quedan registros disponibles para realizar la operacion suma\n", yylineno);
            }
            $$.tipo="real";
            $$.real=$1.real+$3.real;
            printf("-> SUMA real+real\n");
        }
        else if (strcmp($1.tipo, "entero")==0 && strcmp($3.tipo, "real")==0){  // Entero y real
            $$.a = nuevo_nodo('+', $1.a,$3.a);
            if($$.a->registro==-1){
                error_compilacion++;
                printf("ERROR LINEA %d: No quedan registros disponibles para realizar la operacion suma\n", yylineno);
            }
            $$.tipo="real";
            $$.real=$1.entero+$3.real;
            printf("-> SUMA entero+real\n");
        }
        else if (strcmp($1.tipo, "real")==0 && strcmp($3.tipo, "entero")==0){  // Real y entero
            $$.a = nuevo_nodo('+', $1.a,$3.a);
            if($$.a->registro==-1){
                error_compilacion++;
                printf("ERROR LINEA %d: No quedan registros disponibles para realizar la operacion suma\n", yylineno);
            }
            $$.tipo="real";
            $$.real=$1.real+$3.entero;
            printf("-> SUMA real+entero\n");
        }
        else{
            error_compilacion++;
            printf("ERROR LINEA %d: No se puede operar en línea\n", yylineno);
        }
    }
    | exp OPERADOR_RESTA term {
        if (strcmp($1.tipo, "entero")==0 && strcmp($3.tipo, "entero")==0) { //Si ambos son enteros
            $$.a = nuevo_nodo('-', $1.a,$3.a);
            if($$.a->registro==-1){
                error_compilacion++;
                printf("ERROR LINEA %d: No quedan registros disponibles para realizar la operacion resta\n", yylineno);
            }
            $$.tipo="entero";
            $$.entero=$1.entero-$3.entero;
            printf("-> RESTA entero-entero\n");
        }
        else if (strcmp($1.tipo, "real")==0 && strcmp($3.tipo, "real")==0){  //Si los dos son float
            $$.a = nuevo_nodo('-', $1.a,$3.a);
            if($$.a->registro==-1){
                error_compilacion++;
                printf("ERROR LINEA %d: No quedan registros disponibles para realizar la operacion suma\n", yylineno);
            }
            $$.tipo="real";
            $$.real=$1.real-$3.real;
            printf("-> RESTA real-real\n");
        }
        else if (strcmp($1.tipo, "entero")==0 && strcmp($3.tipo, "real")==0){  // Entero y real
            $$.a = nuevo_nodo('-', $1.a,$3.a);
            if($$.a->registro==-1){
                error_compilacion++;
                printf("ERROR LINEA %d: No quedan registros disponibles para realizar la operacion suma\n", yylineno);
            }
            $$.tipo="real";
            $$.real=$1.entero-$3.real;
            printf("-> RESTA entero-real\n");
        }
        else if (strcmp($1.tipo, "real")==0 && strcmp($3.tipo, "entero")==0){  // Real y entero
            $$.a = nuevo_nodo('-', $1.a,$3.a);
            if($$.a->registro==-1){
                error_compilacion++;
                printf("ERROR LINEA %d: No quedan registros disponibles para realizar la operacion suma\n", yylineno);
            }
            $$.tipo="real";
            $$.real=$1.real-$3.entero;
            printf("-> RESTA real-entero\n");
        }
        else{
                error_compilacion++;
                printf( "ERROR: No se puede operar\n");
        }
    }
    | exp CONCATENAR term {
        if (strcmp($1.tipo, "texto")==0 && strcmp($3.tipo, "texto")==0){
            $$.texto = strcat($1.texto, $3.texto);
            $$.tipo="texto";
            printf( "Concatenado -> %s\n",$$.texto);
        }
        else{
            error_compilacion++;
            printf( "ERROR LINEA %d: No se puede concatenar algo que no sean cadenas de texto\n", yylineno);
        }
    }
    | term {
        $$ = $1; }   //Se hace una copia
    ;

term: 
    term OPERADOR_MULTIPLICACION factor {
        if (strcmp($1.tipo, "entero")==0 && strcmp($3.tipo, "entero")==0) { //Si ambos son enteros
            $$.a = nuevo_nodo('*', $1.a,$3.a);
            if($$.a->registro==-1){
                error_compilacion++;
                printf("ERROR LINEA %d: No quedan registros disponibles para realizar la operacion multiplicar\n", yylineno);
            }
            $$.tipo="entero";
            $$.entero=$1.entero*$3.entero;
            printf( "-> MULTIPLICACION entero*entero\n");
        }
        else if (strcmp($1.tipo, "real")==0 && strcmp($3.tipo, "real")==0){  //Si los dos son float
            $$.a = nuevo_nodo('*', $1.a,$3.a);
            if($$.a->registro==-1){
                error_compilacion++;
                printf("ERROR LINEA %d: No quedan registros disponibles para realizar la operacion multiplicar\n", yylineno);
            }
            $$.tipo="real";
            $$.real=$1.real*$3.real;
            printf( "-> MULTIPLICACION real*real\n");
        }
        else if (strcmp($1.tipo, "entero")==0 && strcmp($3.tipo, "real")==0){  // Entero y real
            $$.a = nuevo_nodo('*', $1.a,$3.a);
            if($$.a->registro==-1){
                error_compilacion++;
                printf("ERROR LINEA %d: No quedan registros disponibles para realizar la operacion multiplicar\n", yylineno);
            }
            $$.tipo="real";
            $$.real=$1.entero*$3.real;
            printf( "-> MULTIPLICACION entero*real\n");
        }
        else if (strcmp($1.tipo, "real")==0 && strcmp($3.tipo, "entero")==0){  // Real y entero
            $$.a = nuevo_nodo('*', $1.a,$3.a);
            if($$.a->registro==-1){
                error_compilacion++;
                printf("ERROR LINEA %d: No quedan registros disponibles para realizar la operacion multiplicar\n", yylineno);
            }
            $$.tipo="real";
            $$.real=$1.real*$3.entero;
            printf( "-> MULTIPLICACION real*entero\n");
        }
        else{
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
            $$.a = nuevo_nodo('/', $1.a,$3.a);
            if($$.a->registro==-1){
                error_compilacion++;
                printf("ERROR LINEA %d: No quedan registros disponibles para realizar la operacion dividir\n", yylineno);
            } 
            $$.tipo="entero";
            $$.entero=$1.entero/$3.entero;
            printf( "-> DIVISION entero/entero\n");
        }
        else if (strcmp($1.tipo, "real")==0 && strcmp($3.tipo, "real")==0){  //Si los dos son float
            if ($3.real == 0.0) {
                error_compilacion++;
                printf("ERROR LINEA %d: Division por cero no permitida\n", yylineno);
                return;
            }
            $$.a = nuevo_nodo('/', $1.a,$3.a); 
            if($$.a->registro==-1){
                error_compilacion++;
                printf("ERROR LINEA %d: No quedan registros disponibles para realizar la operacion dividir\n", yylineno);
            } 
            $$.tipo="real";
            $$.real=$1.real/$3.real;
            printf( "-> DIVISION real/real\n");
        }
        else if (strcmp($1.tipo, "entero")==0 && strcmp($3.tipo, "real")==0){  // Entero y real
            if ($3.real == 0.0) {
                error_compilacion++;
                printf("ERROR LINEA %d: Division por cero no permitida\n", yylineno);
                return;
            }
            $$.a = nuevo_nodo('/', $1.a,$3.a); 
            if($$.a->registro==-1){
                error_compilacion++;
                printf("ERROR LINEA %d: No quedan registros disponibles para realizar la operacion dividir\n", yylineno);
            } 
            $$.tipo="real";
            $$.real=$1.entero/$3.real;
            printf( "-> DIVISION entero/real\n");
        }
        else if (strcmp($1.tipo, "real")==0 && strcmp($3.tipo, "entero")==0){  // Real y entero
            if ($3.entero == 0) {
                error_compilacion++;
                printf("ERROR LINEA %d: Division por cero no permitida\n", yylineno);
                return;
            }
            $$.a = nuevo_nodo('/', $1.a,$3.a); 
            if($$.a->registro==-1){
                error_compilacion++;
                printf("ERROR LINEA %d: No quedan registros disponibles para realizar la operacion dividir\n", yylineno);
            } 
            $$.tipo="real";
            $$.real=$1.real/$3.entero;
            printf( "-> DIVISION real/entero\n");
        }
        else{
            error_compilacion++;
            printf( "ERROR LINEA %d: No se puede realizar la operacion dividir con estos operandos", yylineno);
        }
    }
    | term MODULO factor { //solo se puede hacer con enteros
        printf("-> MODULO\n");
        if (strcmp($1.tipo, "entero")==0 && strcmp($3.tipo, "entero")==0) { //Si ambos son enteros
            $$.a = nuevo_nodo('%', $1.a,$3.a); 
            if($$.a->registro==-1){
                error_compilacion++;
                printf("ERROR LINEA %d: No quedan registros disponibles para realizar la operacion modulo\n", yylineno);
            } 
            $$.tipo="entero";
            printf( "-> MODULO entero %% entero \n");
        } else{
             error_compilacion++;
             printf( "ERROR LINEA %d: No se puede operar con operadores no enteros\n", yylineno);
        }   
    }
    | term EXPONENTE factor { //solo se puede hacer con enteros
        if (strcmp($1.tipo, "entero")==0 && strcmp($3.tipo, "entero")==0) { //Si ambos son enteros
            $$.a = nuevo_nodo('^', $1.a,$3.a);
            if($$.a->registro==-1){
                error_compilacion++;
                printf("ERROR LINEA %d: No quedan registros disponibles para realizar la operacion exponente\n", yylineno);
            } 
            $$.tipo="entero";
            printf( "-> EXPONENTE entero^entero\n");
        } else{
             error_compilacion++;
             printf( "ERROR: No se puede operar\n");
        }
    }
    | factor {
        $$ = $1;}
    |IDENTIFICADOR{
            printf("->IDENTIFICADOR%s\n",$1);
            //printf("Hemos encontrado un identificador");
            //Hemos encontrado un identificador, hay que ver si está en la tabla para recogerlo y sino devolver un error
            int i = lookup($1,table_size,table); //lo buscamos
            if(i == -1){
                printf( "ERROR LINEA %d: Se usa una variable que no ha sido definida anteriormente", yylineno);
            }
            else{
                //Controlamos de que tipo es
                if(table[i].tipo=="entero"){
                    $$.tipo = table[i].tipo;
                    $$.entero=table[i].entero;
                    //Crear nodo hoja con números
                    $$.a = nuevo_variable_hoja_numero(table[i].entero,table[i].registro);    
                }
                else if(table[i].tipo=="real"){
                    $$.tipo = table[i].tipo;      
                    $$.real=table[i].real;
                    //Crear nodo hoja con números
                    $$.a = nuevo_variable_hoja_numero(table[i].real,table[i].registro);        
                }
                else if(table[i].tipo=="boolean"){
                    $$.tipo = table[i].tipo;
                    $$.booleano=table[i].booleano;
                    //Crear nodo hoja con booleanos
                    $$.a = nuevo_variable_hoja_numero(table[i].booleano,table[i].registro);

                }
                else if(table[i].tipo=="texto"){
                    $$.tipo = table[i].tipo;
                    $$.texto=table[i].texto;
                    //Crear nodo hoja con texto
                    $$.a = nuevo_hoja_texto(table[i].texto);

            //CREAR NODO TEXTO             
                }
                else{printf("ERROR LINEA %d: Variable de tipo desconocido", yylineno);}

            }
        }
    ;

factor: 
   ENTERO{$$.entero = $1;
            $$.a = nuevo_hoja_numero($1);
            if($$.a->registro==-1){
                error_compilacion++;
                printf("ERROR LINEA %d: No quedan registros disponibles para asignar el entero %ld\n",  yylineno,$$.entero);
            }  
            $$.tipo="entero"; 
            printf( "-> ENTERO: %ld\n", $$.entero);}   
    | OPERADOR_RESTA ENTERO{$$.entero = -$2;
            $$.a = nuevo_hoja_numero(-$2);
            if($$.a->registro==-1){
                error_compilacion++;
                printf("ERROR LINEA %d: No quedan registros disponibles para asignar el entero %ld\n",  yylineno, $$.entero);
            }
            $$.tipo="entero";
            printf( "-> ENTERO NEGATIVO: %ld\n", $$.entero);}
    | REAL {$$.real = $1;
            $$.a = nuevo_hoja_numero($1);
            if($$.a->registro==-1){
                error_compilacion++;
                printf("ERROR LINEA %d: No quedan registros disponibles para asignar el real %f\n", yylineno, $$.real);
            }
            $$.tipo="real";
            printf( "-> REAL: %f\n", $$.real);}
    | OPERADOR_RESTA REAL {$$.real = -$2;
            $$.a = nuevo_hoja_numero(-$2);
            if($$.a->registro==-1){
                error_compilacion++;
                printf("ERROR LINEA %d: No quedan registros disponibles para asignar el real %f\n", yylineno,  $$.real);
            }
            $$.tipo="real";
            printf( "-> REAL NEGATIVO: %f\n", $$.real);}
    | PARENTESIS_APERTURA exp PARENTESIS_CIERRE {
            $$ = $2;
            printf("PARENTESIS\n");}
    | TEXTO  {
            $$.texto = $1;
            $$.tipo="texto";
            printf("Variable de tipo TEXTO: %s\n", $$.texto);}
    | BOOL {
            $$.booleano = $1;
            $$.tipo="booleano";
            printf("Variable de tipo BOOLEANO: %s\n", $$.booleano);}
    ;

%%

void create_node_check_reg(struct atributos *dest, char* operator, struct atributos src1, struct atributos src2) {
    dest->a = nuevo_nodo(operator, src1.a, src2.a);
    if (dest->a->registro == -1) {
        error_compilacion++;
        printf("ERROR LINEA %d: No quedan registros disponibles para realizar la operacion\n", yylineno);
    }
}

void create_or_update_variable(char* name, char* type, struct atributos value, int table_index) {
    table[table_index].name = name;
    table[table_index].tipo = type;
    table[table_index].registro = value.a->registro;

    if(strcmp(type, "entero")==0){
        printf("Se asigna a la variable el resultado de la operacion con un %d\n",value.entero);
        table[table_index].entero = value.entero;
    }
    else if(strcmp(type, "real")==0){
        printf("Se asigna a la variable el resultado de la operacion con un %f\n",value.real);
        table[table_index].real = value.real;
    }
    else if(strcmp(type, "booleano")==0){
        printf("Se asigna a la variable el resultado de la operacion con un %d\n",value.booleano);
        table[table_index].booleano = value.booleano;
    }
    else if(strcmp(type, "texto")==0){
        printf("Se asigna a la variable el resultado de la operacion con un %s\n",value.texto);
        table[table_index].texto = value.texto;
    }
}

void compare_expression(char* operador, char* tipo1, char* tipo2, struct atributos exp1, struct atributos exp2, struct atributos* result) {
    printf("exp %s exp\n", operador);

    create_node_check_reg(result, operador, exp1, exp2);
    double val1, val2;

    if (strcmp(tipo1, "texto") == 0 && strcmp(tipo2, "texto") == 0) { // texto texto
        if (strcmp(operador, "==") == 0) {
            result->booleano = (strcmp(exp1.texto, exp2.texto) == 0);
        } else if (strcmp(operador, "!=") == 0) {
            result->booleano = (strcmp(exp1.texto, exp2.texto) != 0);
        } else {
            printf("ERROR: Operacion no reconocida para texto %s", operador);
            return;
        }
        result->tipo = "booleano";
        printf("texto %s texto = %d\n", operador, result->booleano);
        return;
    }

    if (strcmp(tipo1, "booleano") == 0) {
        val1 = exp1.booleano;
    } else if (strcmp(tipo1, "entero") == 0) {
        val1 = exp1.entero;
    } else if (strcmp(tipo1, "real") == 0) {
        val1 = exp1.real;
    } else {
        printf("ERROR: Tipo1 no reconocido %s", tipo1);
        return;
    }

    if (strcmp(tipo2, "booleano") == 0) {
        val2 = exp2.booleano;
    } else if (strcmp(tipo2, "entero") == 0) {
        val2 = exp2.entero;
    } else if (strcmp(tipo2, "real") == 0) {
        val2 = exp2.real;
    } else {
        printf("ERROR: Tipo2 no reconocido %s", tipo2);
        return;
    }

    if (strcmp(operador, ">") == 0) {
        result->booleano = (val1 > val2);
    } else if (strcmp(operador, "<") == 0) {
        result->booleano = (val1 < val2);
    } else if (strcmp(operador, ">=") == 0) {
        result->booleano = (val1 >= val2);
    } else if (strcmp(operador, "<=") == 0) {
        result->booleano = (val1 <= val2);
    } else if (strcmp(operador, "==") == 0) {
        result->booleano = (val1 == val2);
    } else if (strcmp(operador, "!=") == 0) {
        result->booleano = (val1 != val2);
    } else if (strcmp(operador, "&&") == 0) {
        result->booleano = (val1 && val2);
    } else if (strcmp(operador, "||") == 0) {
        result->booleano = (val1 || val2);
    } else {
        printf("ERROR: Operacion no reconocida %s", operador);
        return;
    }
    result->tipo = "booleano";
    printf("%s %s %s = %d\n", tipo1, operador, tipo2, result->booleano);
}



int main(int argc, char** argv) {
    if (argc != 3) {
        printf("ERROR: parametros incorrectos.\n");
        return 1;
    }
    
    yyin = fopen(argv[1], "rt");
    if (yyin == NULL) {
        printf("ERROR: no se puede abrir el fichero de entrada %s\n", argv[1]);
        return 1;
    }
    
    archivo_salida = fopen(argv[2], "wt");
    if (archivo_salida == NULL) {
        printf("ERROR: no se puede abrir el fichero de salida %s\n", argv[2]);
        fclose(yyin); 
        return 1;
    }
    
    yyparse();
    
    fclose(yyin);
    fclose(archivo_salida);
    return 0;
}

void yyerror(const char* s) {
    fprintf(stderr, "%s\n", s);
}

int yywrap() {
    return 1;
}