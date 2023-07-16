#include <math.h>
#include <stdbool.h>

extern FILE *yyout;
extern int table_size;
extern symbol table[100];

// Etiqueta para los if o while
extern int numEtiqueta;

// Array que almacena que registros $tn están disponibles. TRUE es disponible y FALSE es ocupado
extern bool array_registros_t[10];

// Hay 32 registros F, desde el 0 hasta el 31
extern bool array_registros_f[31];

// Usamos un array de 32 posiciones para almacenar las variables de .data
extern float array_variables[32][3];
extern int siguienteVariableDisponible;

// Definimos una estructura para nuestro nodo del AST
struct nodo
{
  int nodetype; // Puede ser L,+,-,*,/...
  char *tipo;   // El tipo de dato que almacena: real, entero o string
  double value;
  char *string;
  struct nodo *l;  // Nodo izquierdo
  struct nodo *r;  // Nodo derecho
  struct nodo *x;  // Nodo EXTRA para si nodo específico del SI SINO
  int registro;    // Registro donde está el resultado
  int registroIni; //inicio del for
  int registroFin; //fin del for
  int variableNum; // Indica el nombre de la variable "variableN" que se usa para declarar
  char *id;        // Identificador del para
  int inicio;      // Valor inicial del para
  int fin;         // Valor final del para
  int incremento;  // Valor para incrementar el for
  int registroInc; // Valor para comparaciones del for
};

int buscarRegistroLibreT();
int buscarRegistroLibreF();
void liberarRegistro(struct nodo *a);
struct nodo *new_node(int nodetype, struct nodo *l, struct nodo *r);
struct nodo *new_leaf_num(double value);
struct nodo *new_var_leaf_num(double value, int registro_);
struct nodo *new_leaf_comment();
struct nodo *new_node_sino(struct nodo *l, struct nodo *r, struct nodo *x);
struct nodo *new_node_para(char *id, int inicio, int fin, struct nodo *r);
struct nodo *new_node_para2(char *id, int fin, struct nodo *r);
struct nodo *new_node_para3(char *id, int inicio, int fin, int incremento, struct nodo *r);
struct nodo *new_leaf_text(char *string);
struct nodo *nodo_vacio();
struct nodo *nodo_con_info_para_asignacion(int registro);
double eval(struct nodo *a);
double iniciar_evaluacion(struct nodo *a);
void imprimir(struct nodo *a);
void si_statement(struct nodo *a, int numEtiqueta);
void si_sino_statement(struct nodo *a, int numEtiqueta);
void mientras_statement(struct nodo *a, int numEtiqueta);