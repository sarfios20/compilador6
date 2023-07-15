#include <math.h>
#include <stdbool.h> //Para usar booleanos

extern FILE *yyout;

extern int table_size;
extern symbol table[100];

// Etiqueta para los if o while
int numEtiqueta = 0;

// Array que almacena que registros $tn están disponibles. TRUE es disponible y FALSE es ocupado
// Hay 10 registros T, desde el 0 hasta el 9
bool array_registros_t[10] = {true, true, true, true, true, true, true, true, true, true};

// Hay 32 registros F, desde el 0 hasta el 31
// El registro 32 está reservado por defecto para imprimir por pantalla
bool array_registros_f[31] = {true, true, true, true, true, true, true, true, true, true, true, true, false, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true};
// bool array_registros_f[31] = {true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false};

// Usamos un array de 32 posiciones para almacenar las variables de .data
float array_variables[32][3];        // En 0 el dato y en 1 el nombre de la variable y en el 2 si esta ocupado
int siguienteVariableDisponible = 0; // Apunta al siguiente número disponible para declarar una variable en .data

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


// Recibe un nodo y libera el registro que usa tanto si es real como float
liberarRegistro(struct nodo *a)
{
  array_registros_f[a->registro] = true;
}

// Nodo NO HOJA
struct nodo *new_node(int nodetype, struct nodo *l, struct nodo *r)
{                                               //, char* tipo_
  struct nodo *a = malloc(sizeof(struct nodo)); // Crea un nuevo nodo
  if (!a)
  {
    exit(0); // Si el nuevo nodo es NULL significa que hay un error de memoria insuficiente
  }
  // Le asigna al nuevo nodo sus características
  a->nodetype = nodetype;
  a->l = l;
  a->r = r;
  // a->tipo = tipo_;

  // Asignar registro para float
  a->registro = buscarRegistroLibreF();
  printf("Se ha reservado el registro $f%d para almancear el resultado de una operacion\n\n", a->registro);

  return a;
}

// Nodo HOJA
struct nodo *new_leaf_num(double value)
{                                               //, char* tipo_
  struct nodo *a = malloc(sizeof(struct nodo)); // Asigna la dirección de memoria para un nuevo nodo del tipo struct
  if (!a)
  {
    exit(0); // Si el nuevo nodo es NULL significa que hay un error de memoria insuficiente
  }
  a->nodetype = 'L'; // L de Leaf
  a->l = NULL;
  a->r = NULL;
  a->value = value;
  // a->tipo = tipo_;

  // Asignar registro para float
  a->registro = buscarRegistroLibreF();

  // Guardar como se llama la variable de .data
  a->variableNum = siguienteVariableDisponible;
  siguienteVariableDisponible++; // Se incrementa

  printf("La variable%d almacena el valor %f en el registro $f%d \n", a->variableNum, a->value, a->registro);

  // Registrar una nueva variable en .data con el valor
  // Guarda en la misma posición que registro utiliza: Para $f14 usa la posición 14
  array_variables[a->registro][0] = a->value;
  array_variables[a->registro][1] = a->variableNum;
  array_variables[a->registro][2] = 1; // ocupado

  return a;
}

// Nodo HOJA que es una variable definida anteriormente que ya cuenta con un registro asignado
struct nodo *new_var_leaf_num(double value, int registro_)
{                                               //, char* tipo_
  struct nodo *a = malloc(sizeof(struct nodo)); // Asigna la dirección de memoria para un nuevo nodo del tipo struct
  if (!a)
  {
    exit(0); // Si el nuevo nodo es NULL significa que hay un error de memoria insuficiente
  }
  a->nodetype = 'V'; // V de Variable
  a->l = NULL;
  a->r = NULL;
  a->value = value;
  // a->tipo = tipo_;

  // Asignar registro para float
  a->registro = registro_;
  printf("El identificador estaba almacenado en el registro f%d \n", a->registro);

  /**
    //Guardar como se llama la variable de .data
    a->variableNum=siguienteVariableDisponible;
    printf("%f se almacena en la 'variable%d'\n",a->value,a->variableNum);
    siguienteVariableDisponible++; //Se incrementa
    */
  return a;
}

// Nodo HOJA que es un comentario
struct nodo *new_leaf_comment()
{                                               //, char* tipo_
  struct nodo *a = malloc(sizeof(struct nodo)); // Asigna la dirección de memoria para un nuevo nodo del tipo struct
  if (!a)
  {
    exit(0); // Si el nuevo nodo es NULL significa que hay un error de memoria insuficiente
  }
  a->nodetype = 'CM';
  a->l = NULL;
  a->r = NULL;
  a->value = 1;
  return a;
}
// Nuevo nodo para un SI con un SINO
struct nodo *new_node_sino(struct nodo *l, struct nodo *r, struct nodo *x)
{                                               //, char* tipo_
  struct nodo *a = malloc(sizeof(struct nodo)); // Crea un nuevo nodo
  if (!a)
  {
    exit(0); // Si el nuevo nodo es NULL significa que hay un error de memoria insuficiente
  }
  // Le asigna al nuevo nodo sus características
  a->nodetype = 'SN';
  a->l = l;
  a->r = r;
  a->x = x;

  // Asignar registro para float
  a->registro = buscarRegistroLibreF();
  printf("Se ha reservado el registro $f%d para almancear el SI con un SINO\n\n", a->registro);

  return a;
}

struct nodo *new_node_para(char *id, int inicio, int fin, struct nodo *r)
{
  struct nodo *a = malloc(sizeof(struct nodo));
  if (!a)
  {
    exit(0); // Si el nuevo nodo es NULL significa que hay un error de memoria insuficiente
  }
  // Le asigna al nuevo nodo sus características
  a->nodetype = 'PARA';
  a->id = id;
  a->inicio = inicio;
  a->fin = fin;
  a->r = r;
  a->registroIni = buscarRegistroLibreT();
  a->registroFin = buscarRegistroLibreT();
  a->registroInc = buscarRegistroLibreT();

  return a;
}

struct nodo *new_node_para2(char *id, int fin, struct nodo *r)
{
  struct nodo *a = malloc(sizeof(struct nodo));
  if (!a)
  {
    exit(0); // Si el nuevo nodo es NULL significa que hay un error de memoria insuficiente
  }
  // Le asigna al nuevo nodo sus características
  a->nodetype = 'PARA2';
  a->id = id;
  a->fin = fin;
  a->r = r;
  a->registroIni = buscarRegistroLibreT();
  a->registroFin = buscarRegistroLibreT();
  a->registroInc = buscarRegistroLibreT();

  return a;
}

struct nodo *new_node_para3(char *id, int inicio, int fin, int incremento, struct nodo *r)
{
  struct nodo *a = malloc(sizeof(struct nodo));
  if (!a)
  {
    exit(0); // Si el nuevo nodo es NULL significa que hay un error de memoria insuficiente
  }
  // Le asigna al nuevo nodo sus características
  a->nodetype = 'PARA3';
  a->id = id;
  a->inicio = inicio;
  a->fin = fin;
  a->incremento = incremento;
  a->r = r;
  a->registroIni = buscarRegistroLibreT();
  a->registroFin = buscarRegistroLibreT();
  a->registroInc = buscarRegistroLibreT();

  return a;
}

// Nodo hoja con string
struct nodo *new_leaf_text(char *string)
{
  struct nodo *a = malloc(sizeof(struct nodo)); // Asigna la dirección de memoria para un nuevo nodo del tipo struct
  if (!a)
  {
    exit(0); // Si el nuevo nodo es NULL significa que hay un error de memoria insuficiente
  }
  a->nodetype = 'S'; // S de String
  a->l = NULL;
  a->r = NULL;
  // a->tipo = tipo_;
  a->string = string;
  return a;
}

// Devuelve un nodo vacío
struct nodo *nodo_vacio()
{
  struct nodo *a = malloc(sizeof(struct nodo)); // Asigna la dirección de memoria para un nuevo nodo del tipo struct
  if (!a)
  {
    exit(0); // Si el nuevo nodo es NULL significa que hay un error de memoria insuficiente
  }
  a->nodetype = NULL; // S de String
  a->l = NULL;
  a->r = NULL;
  return a;
}

// Devuelve un nodo vacío pero permite usar los campos nodetype y string para almacenar info para la asignación
struct nodo *nodo_con_info_para_asignacion(int registro)
{
  struct nodo *a = malloc(sizeof(struct nodo)); // Asigna la dirección de memoria para un nuevo nodo del tipo struct
  if (!a)
  {
    exit(0); // Si el nuevo nodo es NULL significa que hay un error de memoria insuficiente
  }
  a->registro = registro;
  a->l = NULL;
  a->r = NULL;
  return a;
}

// Evaluar un nodo
double eval(struct nodo *a)
{
  double v;
  int etiquetaTemporal;

  switch (a->nodetype)
  {

  // NODO HOJA
  case 'L':
    v = a->value;
    printf("-> HOJA donde se asigna %f (variable%d) al registro $f%d\n", v, a->variableNum, a->registro);
    // Cargar el valor en su registro asignado de tipo F
    fprintf(yyout, "  lwc1 $f%d, variable%d\n", a->registro, a->variableNum);

    break;

  // OPERACION SUMA
  case '+':
    // printf("-> suma\n");
    v = eval(a->l) + eval(a->r);
    printf("-> SUMA (%f + %f) almacenada en $f%d y con resultado %f\n", a->l->value, a->r->value, a->registro, v);
    // Ahora usamos solo registros tipo F para sumar el float
    fprintf(yyout, "  add.s $f%d, $f%d, $f%d\n", a->registro, a->l->registro, a->r->registro);

    // liberar los registros de los nodos L y R
    liberarRegistro(a->l);
    liberarRegistro(a->r);
    break;

  // OPERACIÓN RESTA
  case '-':
    // printf("-> resta\n");
    v = eval(a->l) - eval(a->r);
    printf("-> RESTA (%f - %f) almacenada en $f%d y con resultado %f\n", a->l->value, a->r->value, a->registro, v);
    // Sentencia de la resta en ASM
    fprintf(yyout, "  sub.s $f%d, $f%d, $f%d\n", a->registro, a->l->registro, a->r->registro);

    // liberar los registros de los nodos L y R
    liberarRegistro(a->l);
    liberarRegistro(a->r);
    break;
  case '*':
    // printf("-> multiplicacion\n");
    v = eval(a->l) * eval(a->r);
    printf("-> MULTIPLICACION (%f * %f) almacenada en $f%d y con resultado %f\n", a->l->value, a->r->value, a->registro, v);
    // Sentencia de la multiplicación en ASM
    fprintf(yyout, "  mul.s $f%d, $f%d, $f%d\n", a->registro, a->l->registro, a->r->registro);

    // liberar los registros de los nodos L y R
    liberarRegistro(a->l);
    liberarRegistro(a->r);
    break;
  case '/':
    // printf("-> division\n");
    v = eval(a->l) / eval(a->r); // base l expon r devuelve l^r
    printf("-> DIVISION (%f / %f) almacenada en $f%d y con resultado %f\n", a->l->value, a->r->value, a->registro, v);
    // Sentencia de la division en ASM
    fprintf(yyout, "  div.s $f%d, $f%d, $f%d\n", a->registro, a->l->registro, a->r->registro);

    // liberar los registros de los nodos L y R
    liberarRegistro(a->l);
    liberarRegistro(a->r);
    break;
  default:
    printf("Error: Nodo desconocido %c\n", a->nodetype);
  }
  return v;
}

double iniciar_evaluacion(struct nodo *a)
{
  // Crea todas las variables necesarias en .data
  fprintf(yyout, "\n.data #Variables\n");
  // Variable que SIEMPRE se imprime para el salto de línea
  fprintf(yyout, "  newLine: .asciiz \"\\n\"\n");
  // Variable que SIEMPRE se imprime para tener un zero float
  fprintf(yyout, "  zero_f: .float 0.0\n");
  // Recorremos el array de las variables que hay que definir
  for (int i = 0; i < 32; i++)
  {
    // Si el espacio del array tiene algo
    if (array_variables[i][2] == 1)
    {
      // printf("%d\n", array_variables[i][0]);
      //  Define la variable
      fprintf(yyout, "  variable%d: .float %f\n", (int)array_variables[i][1], array_variables[i][0]);
      // La elimina pues ya se ha declarado
      array_variables[i][2] = 0;
    }
  }

  fprintf(yyout, "\n.text #Operaciones\n");
  fprintf(yyout, "  lwc1 $f31, zero_f\n\n");

  return eval(a); // Con las variables ya definidas, comienza a evaluar la operación
}