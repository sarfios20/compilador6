%{
#include <ctype.h>
#include <stdio.h>
#include <string.h> //Esta librería de C nos permite comparar los tipos con la funcion strcmp()
#include "simbol_table.h"

int numero_errores = 0;
int linea = 1;

//Variables de la tabla de símbolos
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
                  printf("%d", numero_errores);
                  if (strcmp($1.tipo, "entero") == 0) {
                        printf(" El resultado entero es %d\n", $1.entero);
                  } else if (strcmp($1.tipo, "real") == 0) {
                        printf(" El resultado real es %f\n", $1.real);
                  } else if (strcmp($1.tipo, "texto") == 0) {
                        printf(" El resultado texto es %s\n", $1.texto);
                  } else if (strcmp($1.tipo, "booleano") == 0) {
                        printf(" El resultado booleano es %d\n", $1.booleano);
                  } else {
                        printf(" ERROR: LA variable no tiene tipo");
                  }
               }
            }
            | asignacion PUNTOCOMA {  if(numero_errores >= 1){
                    printf("\nHa habido %d error(es) de compilacion",numero_errores);
                }else{
                    printf("%d", numero_errores);
                    if(strcmp($1.tipo, "entero")==0){printf(" El resultado entero es %d\n", $1.entero); }
                    else if (strcmp($1.tipo, "real")==0){printf(" El resultado real es %f\n", $1.real); }
                    else if (strcmp($1.tipo, "texto")==0){printf(" El resultado texto es %s\n", $1.texto); }  
                    else if (strcmp($1.tipo, "booleano")==0){printf(" El resultado booleano es %d\n", $1.booleano); }    
                    else {printf(" ERROR: LA variable no tiene tipo");}  
                }
            }
         ;

asignacion: TEXTO OPERADOR_ASIGNACION exp{
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
            else if(strcmp($3.tipo, "real")==0){
                table[table_size].name = $1;
                table[table_size].real = $3.real;
                table[table_size].tipo = "real";
                table_size++;
                $$.tipo = "real";
                $$.real = $3.real;
            }
            else if(strcmp($3.tipo, "texto")==0){
                table[table_size].name = $1;
                table[table_size].texto = $3.texto;
                table[table_size].tipo = "texto";
                table_size++;
                $$.tipo = "texto";
                  $$.texto = $3.texto;
            }
            else if(strcmp($3.tipo, "booleano")==0){
                table[table_size].name = $1;
                table[table_size].booleano = $3.booleano;
                table[table_size].tipo = "booleano";
                table_size++;
                $$.tipo = "booleano";
                  $$.booleano = $3.booleano;
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
        if (strcmp($1.tipo, "entero") == 0 && strcmp($3.tipo, "entero") == 0) {
            $$.entero = $1.entero + $3.entero;
            $$.tipo = "entero";
            printf("entero+entero = %d\n", $$.entero);
        } else if (strcmp($1.tipo, "real") == 0 && strcmp($3.tipo, "real") == 0) {
            $$.real = $1.real + $3.real;
            $$.tipo = "real";
            printf("real+real = %f\n", $$.real);
        } else if (strcmp($1.tipo, "entero") == 0 && strcmp($3.tipo, "real") == 0) {
            $$.real = $1.entero + $3.real;
            $$.tipo = "real";
            printf("entero+real = %f\n", $$.real);
        } else if (strcmp($1.tipo, "real") == 0 && strcmp($3.tipo, "entero") == 0) {
            $$.real = $1.real + $3.entero;
            $$.tipo = "real";
            printf("real+entero = %f\n", $$.real);
        } else {
            numero_errores++;
            printf("ERROR: No se puede operar en línea %d", linea);
        }
    }
    | exp OPERADOR_RESTA term {
        if (strcmp($1.tipo, "entero") == 0 && strcmp($3.tipo, "entero") == 0) {
            $$.entero = $1.entero - $3.entero;
            $$.tipo = "entero";
            printf("entero-entero = %d\n", $$.entero);
        } else if (strcmp($1.tipo, "real") == 0 && strcmp($3.tipo, "real") == 0) {
            $$.real = $1.real - $3.real;
            $$.tipo = "real";
            printf("real-real = %f\n", $$.real);
        } else if (strcmp($1.tipo, "entero") == 0 && strcmp($3.tipo, "real") == 0) {
            $$.real = $1.entero - $3.real;
            $$.tipo = "real";
            printf("entero-real = %f\n", $$.real);
        } else if (strcmp($1.tipo, "real") == 0 && strcmp($3.tipo, "entero") == 0) {
            $$.real = $1.real - $3.entero;
            $$.tipo = "real";
            printf("real-entero = %f\n", $$.real);
        } else {
            numero_errores++;
            printf("ERROR: No se puede operar");
        }
    }
    | exp OPERADOR_AND term {
        if (strcmp($1.tipo, "booleano") == 0) {
            if (strcmp($3.tipo, "booleano") == 0) {
                $$.booleano = $1.booleano && $3.booleano;
                $$.tipo = "booleano";
                printf("booleano AND booleano = %d\n", $$.booleano);
            } else if (strcmp($3.tipo, "entero") == 0) {
                $$.booleano = $1.booleano && ($3.entero != 0);
                $$.tipo = "booleano";
                printf("booleano AND entero = %d\n", $$.booleano);
            } else if (strcmp($3.tipo, "real") == 0) {
                $$.booleano = $1.booleano && ($3.real != 0.0);
                $$.tipo = "booleano";
                printf("booleano AND real = %d\n", $$.booleano);
            } else if (strcmp($3.tipo, "texto") == 0) {
                $$.booleano = $1.booleano && (strcmp($3.texto, "") != 0);
                $$.tipo = "booleano";
                printf("booleano AND texto = %d\n", $$.booleano);
            } else {
                numero_errores++;
                printf("ERROR: No se puede operar");
            }
        } else if (strcmp($1.tipo, "entero") == 0) {
            if (strcmp($3.tipo, "booleano") == 0) {
                $$.booleano = ($1.entero != 0) && $3.booleano;
                $$.tipo = "booleano";
                printf("entero AND booleano = %d\n", $$.booleano);
            } else {
                numero_errores++;
                printf("ERROR: No se puede operar");
            }
        } else if (strcmp($1.tipo, "real") == 0) {
            if (strcmp($3.tipo, "booleano") == 0) {
                $$.booleano = ($1.real != 0.0) && $3.booleano;
                $$.tipo = "booleano";
                printf("real AND booleano = %d\n", $$.booleano);
            } else {
                numero_errores++;
                printf("ERROR: No se puede operar");
            }
        } else if (strcmp($1.tipo, "texto") == 0) {
            if (strcmp($3.tipo, "booleano") == 0) {
                $$.booleano = (strcmp($1.texto, "") != 0) && $3.booleano;
                $$.tipo = "booleano";
                printf("texto AND booleano = %d\n", $$.booleano);
            } else {
                numero_errores++;
                printf("ERROR: No se puede operar");
            }
        } else {
            numero_errores++;
            printf("ERROR: No se puede operar");
        }
    }
    | exp OPERADOR_OR term {
        if (strcmp($1.tipo, "booleano") == 0) {
            if (strcmp($3.tipo, "booleano") == 0) {
                $$.booleano = $1.booleano || $3.booleano;
                $$.tipo = "booleano";
                printf("booleano OR booleano = %d\n", $$.booleano);
            } else if (strcmp($3.tipo, "entero") == 0) {
                $$.booleano = $1.booleano || ($3.entero != 0);
                $$.tipo = "booleano";
                printf("booleano OR entero = %d\n", $$.booleano);
            } else if (strcmp($3.tipo, "real") == 0) {
                $$.booleano = $1.booleano || ($3.real != 0.0);
                $$.tipo = "booleano";
                printf("booleano OR real = %d\n", $$.booleano);
            } else if (strcmp($3.tipo, "texto") == 0) {
                $$.booleano = $1.booleano || (strcmp($3.texto, "") != 0);
                $$.tipo = "booleano";
                printf("booleano OR texto = %d\n", $$.booleano);
            } else {
                numero_errores++;
                printf("ERROR: No se puede operar");
            }
        } else if (strcmp($1.tipo, "entero") == 0) {
            if (strcmp($3.tipo, "booleano") == 0) {
                $$.booleano = ($1.entero != 0) || $3.booleano;
                $$.tipo = "booleano";
                printf("entero OR booleano = %d\n", $$.booleano);
            } else {
                numero_errores++;
                printf("ERROR: No se puede operar");
            }
        } else if (strcmp($1.tipo, "real") == 0) {
            if (strcmp($3.tipo, "booleano") == 0) {
                $$.booleano = ($1.real != 0.0) || $3.booleano;
                $$.tipo = "booleano";
                printf("real OR booleano = %d\n", $$.booleano);
            } else {
                numero_errores++;
                printf("ERROR: No se puede operar");
            }
        } else if (strcmp($1.tipo, "texto") == 0) {
            if (strcmp($3.tipo, "booleano") == 0) {
                $$.booleano = (strcmp($1.texto, "") != 0) || $3.booleano;
                $$.tipo = "booleano";
                printf("texto OR booleano = %d\n", $$.booleano);
            } else {
                numero_errores++;
                printf("ERROR: No se puede operar");
            }
        } else {
            numero_errores++;
            printf("ERROR: No se puede operar");
        }
    }
    | exp OPERADOR_IGUAL term {
        if (strcmp($1.tipo, $3.tipo) == 0) {
            if (strcmp($1.tipo, "entero") == 0) {
                $$.booleano = ($1.entero == $3.entero);
                $$.tipo = "booleano";
                printf("entero == entero = %d\n", $$.booleano);
            } else if (strcmp($1.tipo, "real") == 0) {
                $$.booleano = ($1.real == $3.real);
                $$.tipo = "booleano";
                printf("real == real = %d\n", $$.booleano);
            } else if (strcmp($1.tipo, "texto") == 0) {
                $$.booleano = (strcmp($1.texto, $3.texto) == 0);
                $$.tipo = "booleano";
                printf("texto == texto = %d\n", $$.booleano);
            } else if (strcmp($1.tipo, "booleano") == 0) {
                $$.booleano = ($1.booleano == $3.booleano);
                $$.tipo = "booleano";
                printf("booleano == booleano = %d\n", $$.booleano);
            }
        } else {
            numero_errores++;
            printf("ERROR: No se puede operar");
        }
    }
    | exp OPERADOR_DISTINTO term {
        if (strcmp($1.tipo, $3.tipo) == 0) {
            if (strcmp($1.tipo, "entero") == 0) {
                $$.booleano = ($1.entero != $3.entero);
                $$.tipo = "booleano";
                printf("entero != entero = %d\n", $$.booleano);
            } else if (strcmp($1.tipo, "real") == 0) {
                $$.booleano = ($1.real != $3.real);
                $$.tipo = "booleano";
                printf("real != real = %d\n", $$.booleano);
            } else if (strcmp($1.tipo, "texto") == 0) {
                $$.booleano = (strcmp($1.texto, $3.texto) != 0);
                $$.tipo = "booleano";
                printf("texto != texto = %d\n", $$.booleano);
            } else if (strcmp($1.tipo, "booleano") == 0) {
                $$.booleano = ($1.booleano != $3.booleano);
                $$.tipo = "booleano";
                printf("booleano != booleano = %d\n", $$.booleano);
            }
        } else {
            numero_errores++;
            printf("ERROR: No se puede operar");
        }
    }
    | exp OPERADOR_MAYOR term {
        if (strcmp($1.tipo, "entero") == 0 && strcmp($3.tipo, "entero") == 0) {
            $$.booleano = ($1.entero > $3.entero);
            $$.tipo = "booleano";
            printf("entero > entero = %d\n", $$.booleano);
        } else if (strcmp($1.tipo, "real") == 0 && strcmp($3.tipo, "real") == 0) {
            $$.booleano = ($1.real > $3.real);
            $$.tipo = "booleano";
            printf("real > real = %d\n", $$.booleano);
        } else {
            numero_errores++;
            printf("ERROR: No se puede operar");
        }
    }
    | exp OPERADOR_MENOR term {
        if (strcmp($1.tipo, "entero") == 0 && strcmp($3.tipo, "entero") == 0) {
            $$.booleano = ($1.entero < $3.entero);
            $$.tipo = "booleano";
            printf("entero < entero = %d\n", $$.booleano);
        } else if (strcmp($1.tipo, "real") == 0 && strcmp($3.tipo, "real") == 0) {
            $$.booleano = ($1.real < $3.real);
            $$.tipo = "booleano";
            printf("real < real = %d\n", $$.booleano);
        } else {
            numero_errores++;
            printf("ERROR: No se puede operar");
        }
    }
    | exp OPERADOR_MAYOR_IGUAL term {
        if (strcmp($1.tipo, "entero") == 0 && strcmp($3.tipo, "entero") == 0) {
            $$.booleano = ($1.entero >= $3.entero);
            $$.tipo = "booleano";
            printf("entero >= entero = %d\n", $$.booleano);
        } else if (strcmp($1.tipo, "real") == 0 && strcmp($3.tipo, "real") == 0) {
            $$.booleano = ($1.real >= $3.real);
            $$.tipo = "booleano";
            printf("real >= real = %d\n", $$.booleano);
        } else {
            numero_errores++;
            printf("ERROR: No se puede operar");
        }
    }
    | exp OPERADOR_MENOR_IGUAL term {
        if (strcmp($1.tipo, "entero") == 0 && strcmp($3.tipo, "entero") == 0) {
            $$.booleano = ($1.entero <= $3.entero);
            $$.tipo = "booleano";
            printf("entero <= entero = %d\n", $$.booleano);
        } else if (strcmp($1.tipo, "real") == 0 && strcmp($3.tipo, "real") == 0) {
            $$.booleano = ($1.real <= $3.real);
            $$.tipo = "booleano";
            printf("real <= real = %d\n", $$.booleano);
        } else {
            numero_errores++;
            printf("ERROR: No se puede operar");
        }
    }
    | term {
        $$ = $1; //Se hace una copia
    }
    ;

term: term OPERADOR_MULTIPLICACION factor {
        if (strcmp($1.tipo, "entero") == 0 && strcmp($3.tipo, "entero") == 0) {
            $$.entero = $1.entero * $3.entero;
            $$.tipo = "entero";
            printf("entero*entero = %d\n", $$.entero);
        } else if (strcmp($1.tipo, "real") == 0 && strcmp($3.tipo, "real") == 0) {
            $$.real = $1.real * $3.real;
            $$.tipo = "real";
            printf("real*real = %f\n", $$.real);
        } else if (strcmp($1.tipo, "entero") == 0 && strcmp($3.tipo, "real") == 0) {
            $$.real = $1.entero * $3.real;
            $$.tipo = "real";
            printf("entero*real = %f\n", $$.real);
        } else if (strcmp($1.tipo, "real") == 0 && strcmp($3.tipo, "entero") == 0) {
            $$.real = $1.real * $3.entero;
            $$.tipo = "real";
            printf("real*entero = %f\n", $$.real);
        } else {
            numero_errores++;
            printf("ERROR: No se puede operar");
        }
    }
    | term OPERADOR_DIVISION factor {
        if (strcmp($1.tipo, "entero") == 0 && strcmp($3.tipo, "entero") == 0) {
            $$.entero = $1.entero / $3.entero;
            $$.tipo = "entero";
            printf("entero/entero = %d\n", $$.entero);
        } else if (strcmp($1.tipo, "real") == 0 && strcmp($3.tipo, "real") == 0) {
            $$.real = $1.real / $3.real;
            $$.tipo = "real";
            printf("real/real = %f\n", $$.real);
        } else if (strcmp($1.tipo, "entero") == 0 && strcmp($3.tipo, "real") == 0) {
            $$.real = $1.entero / $3.real;
            $$.tipo = "real";
            printf("entero/real = %f\n", $$.real);
        } else if (strcmp($1.tipo, "real") == 0 && strcmp($3.tipo, "entero") == 0) {
            $$.real = $1.real / $3.entero;
            $$.tipo = "real";
            printf("real/entero = %f\n", $$.real);
        } else {
            numero_errores++;
            printf("ERROR: No se puede operar");
        }
    }
    | factor {
        $$ = $1; //Se hace una copia
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
    | REAL {
        $$.real = $1;
        $$.tipo = "real";
        printf("REAL  %f\n", $$.real);
    }
    | OPERADOR_SUMA REAL {
        $$.real = $2;
        $$.tipo = "real";
        printf("REAL POSITIVO %f\n", $$.real);
    }
    | OPERADOR_RESTA REAL {
        $$.real = -$2;
        $$.tipo = "real";
        printf("REAL NEGATIVO %f\n", $$.real);
    }
    | PARENTESIS_APERTURA exp PARENTESIS_CIERRE {
        $$ = $2; //Se hace una copia
        printf("PARENTESIS \n");
    }
    | COMILLA TEXTO COMILLA {
        $$.texto = $2;
        $$.tipo = "texto";
        printf("TEXTO %s\n", $$.texto);
    }
    | BOOL {
        $$.booleano = $1;
        $$.tipo = "booleano";
        printf("BOOLEAN %d\n", $$.booleano);
    }
    | OPERADOR_NEGACION BOOL {
        $$.booleano = !$2;
        $$.tipo = "booleano";
        printf("BOOLEAN NEGACION %d\n", $$.booleano);
    }
    ;


%%

int main(void) {
    return yyparse();
}

void yyerror(const char* s) {

}
