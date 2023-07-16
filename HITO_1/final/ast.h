
#ifndef AST_H
#define AST_H

#include <math.h>
#include <stdbool.h>
#include <stdio.h>
#include "symbol_table.h"

extern FILE *archivo_salida;
extern int tamano_tabla;
extern symbol tabla_simbolos[100];

// Etiqueta para los if o while
extern int numero_etiqueta;

// Array que almacena que registros $tn están disponibles. TRUE es disponible y FALSE es ocupado
extern bool registros_t[10];

// Hay 32 registros F, desde el 0 hasta el 31
extern bool registros_f[31];

// Usamos un array de 32 posiciones para almacenar las variables de .data
extern float variables_array[32][3];
extern int siguiente_variable_disponible;

// Definimos una estructura para nuestro nodo del AST
struct nodo
{
  int tipo_nodo; // Puede ser L,+,-,*,/...
  char *tipo_dato;   // El tipo de dato que almacena: real, entero o string
  double valor;
  char *cadena;
  struct nodo *nodo_izq;  // Nodo izquierdo
  struct nodo *nodo_dch;  // Nodo derecho
  struct nodo *nodo_extra;  // Nodo EXTRA para si nodo específico del SI SINO
  int registro;    // Registro donde está el resultado
  int registro_inicio; //inicio del for
  int registro_final; //fin del for
  int numero_variable; // Indica el nombre de la variable "variableN" que se usa para declarar
  char *id;        // Identificador del para
  int inicio;      // Valor inicial del para
  int fin;         // Valor final del para
  int incremento;  // Valor para incrementar el for
  int registro_incremento; // Valor para comparaciones del for
};

int buscar_registro_libre_t();
int buscar_registro_libre_f();
void liberar_registro(struct nodo *a);
struct nodo *nuevo_nodo(int tipo_nodo, struct nodo *nodo_izq, struct nodo *nodo_dch);
struct nodo *nuevo_hoja_numero(double valor);
struct nodo *nuevo_variable_hoja_numero(double valor, int registro_);
struct nodo *nuevo_nodo_sino(struct nodo *nodo_izq, struct nodo *nodo_dch, struct nodo *nodo_extra);
struct nodo *nuevo_nodo_para(char *id, int inicio, int fin, struct nodo *nodo_dch);
struct nodo *nuevo_nodo_para2(char *id, int fin, struct nodo *nodo_dch);
struct nodo *nuevo_nodo_para3(char *id, int inicio, int fin, int incremento, struct nodo *nodo_dch);
struct nodo *nuevo_hoja_texto(char *cadena);
struct nodo *nodo_vacio();
struct nodo *nodo_con_info_para_asignacion(int registro);
double evaluar(struct nodo *a);
double escribir_mips(struct nodo *a);
void imprimir(struct nodo *a);
void si_sentencia(struct nodo *a, int numero_etiqueta);
void si_sino_sentencia(struct nodo *a, int numero_etiqueta);
void mientras_sentencia(struct nodo *a, int numero_etiqueta);

#endif