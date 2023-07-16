#include "ast.h"

int numero_etiqueta = 0;
bool registros_t[10] = {true, true, true, true, true, true, true, true, true, true};
bool registros_f[31] = {true, true, true, true, true, true, true, true, true, true, true, true, false, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true};
float variables_array[32][3];
int siguiente_variable_disponible = 0;

int buscar_registro_libre_t() {
    int i = 0;
    for (size_t i = 0; i <= 9; i++) {
        if (registros_t[i] == true) {
            registros_t[i] = false;
            return i;
        }
    }
    return -1;
}

int buscar_registro_libre_f() {
    int i = 0;
    for (size_t i = 0; i <= 30; i++) {
        if (registros_f[i] == true) {
            registros_f[i] = false;
            return i;
        }
    }
    return -1;
}

void liberar_registro(struct nodo *a) {
    registros_f[a->registro] = true;
}

struct nodo *nuevo_nodo(int tipo_nodo, struct nodo *nodo_izq, struct nodo *nodo_dch) {
    struct nodo *a = malloc(sizeof(struct nodo));
    if (!a) {
        exit(0);
    }
    a->tipo_nodo = tipo_nodo;
    a->nodo_izq = nodo_izq;
    a->nodo_dch = nodo_dch;
    a->registro = buscar_registro_libre_f();
    printf("Se ha reservado el registro $f%d para almancear el resultado de una operacion\n\n", a->registro);
    return a;
}

struct nodo *nuevo_hoja_numero(double valor) {
    struct nodo *a = malloc(sizeof(struct nodo));
    if (!a) {
        exit(0);
    }
    a->tipo_nodo = 'L';
    a->nodo_izq = NULL;
    a->nodo_dch = NULL;
    a->valor = valor;
    a->registro = buscar_registro_libre_f();
    a->numero_variable = siguiente_variable_disponible;
    siguiente_variable_disponible++;
    printf("La variable%d almacena el valor %f en el registro $f%d \n", a->numero_variable, a->valor, a->registro);
    variables_array[a->registro][0] = a->valor;
    variables_array[a->registro][1] = a->numero_variable;
    variables_array[a->registro][2] = 1;
    return a;
}

struct nodo *nuevo_variable_hoja_numero(double valor, int registro_) {
    struct nodo *a = malloc(sizeof(struct nodo));
    if (!a) {
        exit(0);
    }
    a->tipo_nodo = 'V';
    a->nodo_izq = NULL;
    a->nodo_dch = NULL;
    a->valor = valor;
    a->registro = registro_;
    printf("El identificador estaba almacenado en el registro f%d \n", a->registro);
    return a;
}

struct nodo *nuevo_nodo_sino(struct nodo *nodo_izq, struct nodo *nodo_dch, struct nodo *nodo_extra) {
    struct nodo *a = malloc(sizeof(struct nodo));
    if (!a) {
        exit(0);
    }
    a->tipo_nodo = 'SN';
    a->nodo_izq = nodo_izq;
    a->nodo_dch = nodo_dch;
    a->nodo_extra = nodo_extra;
    a->registro = buscar_registro_libre_f();
    printf("Se ha reservado el registro $f%d para almancear el SI con un SINO\n\n", a->registro);
    return a;
}

struct nodo *nuevo_nodo_para(char *id, int inicio, int fin, struct nodo *nodo_dch) {
    struct nodo *a = malloc(sizeof(struct nodo));
    if (!a) {
        exit(0);
    }
    a->tipo_nodo = 'PARA';
    a->id = id;
    a->inicio = inicio;
    a->fin = fin;
    a->nodo_dch = nodo_dch;
    a->registro_inicio = buscar_registro_libre_t();
    a->registro_final = buscar_registro_libre_t();
    a->registro_incremento = buscar_registro_libre_t();
    return a;
}

struct nodo *nuevo_nodo_para2(char *id, int fin, struct nodo *nodo_dch) {
    struct nodo *a = malloc(sizeof(struct nodo));
    if (!a) {
        exit(0);
    }
    a->tipo_nodo = 'PARA2';
    a->id = id;
    a->fin = fin;
    a->nodo_dch = nodo_dch;
    a->registro_inicio = buscar_registro_libre_t();
    a->registro_final = buscar_registro_libre_t();
    a->registro_incremento = buscar_registro_libre_t();
    return a;
}

struct nodo *nuevo_nodo_para3(char *id, int inicio, int fin, int incremento, struct nodo *nodo_dch) {
    struct nodo *a = malloc(sizeof(struct nodo));
    if (!a) {
        exit(0);
    }
    a->tipo_nodo = 'PARA3';
    a->id = id;
    a->inicio = inicio;
    a->fin = fin;
    a->incremento = incremento;
    a->nodo_dch = nodo_dch;
    a->registro_inicio = buscar_registro_libre_t();
    a->registro_final = buscar_registro_libre_t();
    a->registro_incremento = buscar_registro_libre_t();
    return a;
}

struct nodo *nuevo_hoja_texto(char *cadena) {
    struct nodo *a = malloc(sizeof(struct nodo));
    if (!a) {
        exit(0);
    }
    a->tipo_nodo = 'S';
    a->nodo_izq = NULL;
    a->nodo_dch = NULL;
    a->cadena = cadena;
    return a;
}

struct nodo *nodo_vacio() {
    struct nodo *a = malloc(sizeof(struct nodo));
    if (!a) {
        exit(0);
    }
    a->tipo_nodo = NULL;
    a->nodo_izq = NULL;
    a->nodo_dch = NULL;
    return a;
}

struct nodo *nodo_con_info_para_asignacion(int registro) {
    struct nodo *a = malloc(sizeof(struct nodo));
    if (!a) {
        exit(0);
    }
    a->registro = registro;
    a->nodo_izq = NULL;
    a->nodo_dch = NULL;
    return a;
}


// Evaluar un nodo
double evaluar(struct nodo *a)
{
  double v;
  int etiqueta_temporal;

  switch (a->tipo_nodo)
  {

  // NODO HOJA
  case 'L':
    v = a->valor;
    printf("-> HOJA donde se asigna %f (variable%d) al registro $f%d\n", v, a->numero_variable, a->registro);
    // Cargar el valor en su registro asignado de tipo F
    fprintf(archivo_salida, "  lwc1 $f%d, variable%d\n", a->registro, a->numero_variable);

    break;

  // NODO HOJA que es una variable
  case 'V':
    v = a->valor;
    // No volvemos hay que hacer nada xq ya está en un registro

    break;

  // ASIGNACIÓN
  case 'A':
    // Asigna el resultado de la operación que se encuentra en el nodo a->nodo_izq al registro que tenia la variable originalmente
    v = evaluar(a->nodo_izq);

    printf("-> ASIGNACION y resolucion de una variable con un  $f%d\n", v);
    break;

  // ASIGNACIÓN y REEMPLAZAR
  case 'R':
    // Asigna el resultado de la operación que se encuentra en el nodo a->nodo_izq al registro que tenia la variable originalmente
    v = evaluar(a->nodo_izq);
    // Con la operación evaluada, se que en a->registro esta el registro con el resultado
    fprintf(archivo_salida, "  mov.s $f%d, $f%d\n", a->nodo_dch->registro, a->nodo_izq->registro);

    printf("-> SOBREESCRIBIR VARIABLE tras una operacion, moviendo el registro $f%d, a la posicion original: $f%d \n", a->nodo_izq->registro, a->nodo_dch->registro);
    break;

  // OPERACION SUMA
  case '+':
    v = evaluar(a->nodo_izq) + evaluar(a->nodo_dch);
    printf("-> SUMA (%f + %f) almacenada en $f%d y con resultado %f\n", a->nodo_izq->valor, a->nodo_dch->valor, a->registro, v);
    // Ahora usamos solo registros tipo F para sumar el float
    fprintf(archivo_salida, "  add.s $f%d, $f%d, $f%d\n", a->registro, a->nodo_izq->registro, a->nodo_dch->registro);

    // liberar los registros de los nodos nodo_izq y nodo_dch
    liberar_registro(a->nodo_izq);
    liberar_registro(a->nodo_dch);
    break;

  // OPERACIÓN RESTA
  case '-':
    v = evaluar(a->nodo_izq) - evaluar(a->nodo_dch);
    printf("-> RESTA (%f - %f) almacenada en $f%d y con resultado %f\n", a->nodo_izq->valor, a->nodo_dch->valor, a->registro, v);
    // Sentencia de la resta en ASM
    fprintf(archivo_salida, "  sub.s $f%d, $f%d, $f%d\n", a->registro, a->nodo_izq->registro, a->nodo_dch->registro);

    // liberar los registros de los nodos nodo_izq y nodo_dch
    liberar_registro(a->nodo_izq);
    liberar_registro(a->nodo_dch);
    break;
  case '*':
    v = evaluar(a->nodo_izq) * evaluar(a->nodo_dch);
    printf("-> MULTIPLICACION (%f * %f) almacenada en $f%d y con resultado %f\n", a->nodo_izq->valor, a->nodo_dch->valor, a->registro, v);
    // Sentencia de la multiplicación en ASM
    fprintf(archivo_salida, "  mul.s $f%d, $f%d, $f%d\n", a->registro, a->nodo_izq->registro, a->nodo_dch->registro);

    // liberar los registros de los nodos nodo_izq y nodo_dch
    liberar_registro(a->nodo_izq);
    liberar_registro(a->nodo_dch);
    break;
  case '/':
    v = evaluar(a->nodo_izq) / evaluar(a->nodo_dch); // base l expon r devuelve l^r
    printf("-> DIVISION (%f / %f) almacenada en $f%d y con resultado %f\n", a->nodo_izq->valor, a->nodo_dch->valor, a->registro, v);
    // Sentencia de la division en ASM
    fprintf(archivo_salida, "  div.s $f%d, $f%d, $f%d\n", a->registro, a->nodo_izq->registro, a->nodo_dch->registro);

    // liberar los registros de los nodos nodo_izq y nodo_dch
    liberar_registro(a->nodo_izq);
    liberar_registro(a->nodo_dch);
    break;
  case '%': // Statement List
    v = fmod(evaluar(a->nodo_izq), evaluar(a->nodo_dch));
    printf("-> MODULO (%f mod %f) almacenada en $f%d y con resultado %f\n", a->nodo_izq->valor, a->nodo_dch->valor, a->registro, v);
    // Sentencia de la operación de módulo en ASM
    fprintf(archivo_salida, "  cvt.w.s $f%d, $f%d\n", a->registro, a->nodo_izq->registro); // convertir valores
    fprintf(archivo_salida, "  cvt.w.s $f%d, $f%d\n", a->registro + 1, a->nodo_dch->registro);
    fprintf(archivo_salida, "  mfc1 $t%d, $f%d\n", a->registro, a->registro); // mover a registros t, con los f no se pueden hacer modulos
    fprintf(archivo_salida, "  mfc1 $t%d, $f%d\n", a->registro + 1, a->registro + 1);
    fprintf(archivo_salida, "  div $t%d, $t%d\n", a->registro, a->registro + 1);
    fprintf(archivo_salida, "  mfhi $t%d\n", a->registro); // obtenemos el residuo/modulo
    // el cociente se almacena en el registro especial LO Lower y el residuo se almacena en el registro especial HI Higher
    fprintf(archivo_salida, "  mtc1 $t%d, $f%d\n", a->registro, a->registro);    // reconvertimos
    fprintf(archivo_salida, "  cvt.s.w $f%d, $f%d\n", a->registro, a->registro); // reconvertimos

    // liberar los registros de los nodos nodo_izq y nodo_dch
    liberar_registro(a->nodo_izq);
    liberar_registro(a->nodo_dch);
    break;
  case '^':
    v = fmod(evaluar(a->nodo_izq), evaluar(a->nodo_dch));
    printf("-> EXPONENTE almacenada en $f%d y con resultado %f\n", a->registro, v);
    // Sentencia de la operación de exponente en ASM

    // liberar los registros de los nodos nodo_izq y nodo_dch
    liberar_registro(a->nodo_izq);
    liberar_registro(a->nodo_dch);
    break;
  case '>':
    v = evaluar(a->nodo_izq) > evaluar(a->nodo_dch);
    printf("-> MAYOR QUE (%f > %f) almacenada en $f%d y con resultado %f\n", a->nodo_izq->valor, a->nodo_dch->valor, a->registro, v);

    // Comparación de punto flotante de $f1 > $f2
    fprintf(archivo_salida, "  c.lt.s $f%d, $f%d\n", a->nodo_dch->registro, a->nodo_izq->registro);

    // Liberar los registros de los nodos nodo_izq y nodo_dch
    liberar_registro(a->nodo_izq);
    liberar_registro(a->nodo_dch);
    break;
  case '<':
    v = evaluar(a->nodo_izq) < evaluar(a->nodo_dch);
    printf("-> MENOR QUE (%f < %f) almacenada en $f%d y con resultado %f\n", a->nodo_izq->valor, a->nodo_dch->valor, a->registro, v);

    // Comparación de punto flotante de $f1 > $f2
    fprintf(archivo_salida, "  c.lt.s $f%d, $f%d\n", a->nodo_izq->registro, a->nodo_dch->registro); // MISMA OPERACIÓN QUE ARRIBA PERO INTERCAMBIADA PARA > --> <

    // Liberar los registros de los nodos nodo_izq y nodo_dch
    liberar_registro(a->nodo_izq);
    liberar_registro(a->nodo_dch);
    break;
  case '>=':
    v = evaluar(a->nodo_izq) >= evaluar(a->nodo_dch);
    printf("-> MAYOR IGUAL QUE (%f >= %f) almacenada en $f%d y con resultado %f\n", a->nodo_izq->valor, a->nodo_dch->valor, a->registro, v);

    // Comparación de punto flotante de $f1 > $f2
    fprintf(archivo_salida, "  c.le.s $f%d, $f%d\n", a->nodo_dch->registro, a->nodo_izq->registro);

    // Liberar los registros de los nodos nodo_izq y nodo_dch
    liberar_registro(a->nodo_izq);
    liberar_registro(a->nodo_dch);
    break;
  case '<=':
    v = evaluar(a->nodo_izq) <= evaluar(a->nodo_dch);
    printf("-> MENOR IGUAL QUE (%f <= %f) almacenada en $f%d y con resultado %f\n", a->nodo_izq->valor, a->nodo_dch->valor, a->registro, v);

    // Comparación de punto flotante de $f1 < $f2
    fprintf(archivo_salida, "  c.le.s $f%d, $f%d\n", a->nodo_izq->registro, a->nodo_dch->registro);

    // Liberar los registros de los nodos nodo_izq y nodo_dch
    liberar_registro(a->nodo_izq);
    liberar_registro(a->nodo_dch);
    break;
  case '==':
    v = evaluar(a->nodo_izq) == evaluar(a->nodo_dch);
    printf("-> IGUAL QUE (%f == %f) almacenada en $f%d y con resultado %f\n", a->nodo_izq->valor, a->nodo_dch->valor, a->registro, v);

    // Comparación de punto flotante de $f1 == $f2
    fprintf(archivo_salida, "  c.eq.s $f%d, $f%d\n", a->nodo_izq->registro, a->nodo_dch->registro);
    fprintf(archivo_salida, "  mov.s $f%d, $f%d\n", a->registro, a->nodo_izq->registro);

    // Liberar los registros de los nodos nodo_izq y nodo_dch
    liberar_registro(a->nodo_izq);
    liberar_registro(a->nodo_dch);
    break;
  case 'C': // condicion
    printf("-> CONDICION\n");
    v = evaluar(a->nodo_izq);
    break;
  case 'S': // SI statement
    etiqueta_temporal = numero_etiqueta;
    numero_etiqueta++;

    v = evaluar(a->nodo_izq); // condicion en a->nodo_izq
    printf("-> SI donde su condicion es %f\n", v);
    si_sentencia(a->nodo_izq, etiqueta_temporal);

    // Código del IF
    evaluar(a->nodo_dch); // el resto del codigo a->nodo_dch

    // Etiqueta que se usa para saltar al resto si condicion=FALSE
    fprintf(archivo_salida, "etiq%d:\n", etiqueta_temporal);

    break;

  case 'SN': // SI SINO statement
    etiqueta_temporal = numero_etiqueta;
    numero_etiqueta += 2; // Reservamos dos etiquetas
                      // etiqueta_temporal es la etiqueta del SINO
                      // etiqueta_temporal+1 es la etiqueta para ir fuera del SI y SINO

    v = evaluar(a->nodo_izq); // condicion en a->nodo_izq
    printf("-> SI con un SINO donde su condicion es %f\n", v);
    si_sino_sentencia(a->nodo_izq, etiqueta_temporal); // Le pasamos la etiqueta del sino, es decir, "si no se cumple la condicion vamos a.." (SINO)

    // Generar el código del SI
    evaluar(a->nodo_dch); // el resto del codigo a->nodo_dch

    // Si hemos recorrido el SI, saltar al final
    fprintf(archivo_salida, "  j etiq%d\n", etiqueta_temporal + 1);
    // Etiqueta que se usa para saltar al  SINO
    fprintf(archivo_salida, "etiq%d:\n", etiqueta_temporal);

    // Generar el código del ELSE
    evaluar(a->nodo_extra); // el resto del codigo a->nodo

    // Etiqueta que se usa para saltar al final del SI y SINO
    fprintf(archivo_salida, "etiq%d:\n", etiqueta_temporal + 1);

    break;

  case 'M': // Mientras statement

    etiqueta_temporal = numero_etiqueta;
    numero_etiqueta += 2;

    // Saltar a la etiqueta del comienzo del WHILE
    fprintf(archivo_salida, "  etiq%d:\n", etiqueta_temporal);
    v = evaluar(a->nodo_izq); // condicion en a->nodo_izq
    printf("-> MIENTRAS donde su condicion es %f\n", v);
    mientras_sentencia(a->nodo_izq, etiqueta_temporal + 1);

    // Código del IF
    evaluar(a->nodo_dch); // el resto del codigo a->nodo_dch

    // Saltar a la etiqueta del comienzo del WHILE
    fprintf(archivo_salida, "  j etiq%d\n", etiqueta_temporal);
    // Etiqueta que se usa para salir del WHILE
    fprintf(archivo_salida, "etiq%d:\n", etiqueta_temporal + 1);
    // Incrementar el número de etiqueta para usar una distinta más tarde

    break;

  case 'PARA':
    printf("-> PARA AST checkeo\n");

    etiqueta_temporal = numero_etiqueta;     //primera etiqueta
    numero_etiqueta += 2;                   //para la segunda etiqueta

    //declarar variables de inicio y fin
    fprintf(archivo_salida, "  li  $t%d, %d\n", a->registro_inicio, a->inicio);
    fprintf(archivo_salida, "  li  $t%d, %d\n", a->registro_final, a->fin);
    
    //Iniciar el bucle
    fprintf(archivo_salida, "  etiq%d:\n", etiqueta_temporal);

    //comparamos la condicion
    fprintf(archivo_salida, "  slt $t%d, $t%d, $t%d\n", a->registro_incremento, a->registro_final, a->registro_inicio);
    fprintf(archivo_salida, "  beq $t%d, 1, etiq%d\n", a->registro_incremento, etiqueta_temporal+1);
   
    //cuerpo del bucle
    evaluar(a->nodo_dch);

    //Incrementar el contador
    fprintf(archivo_salida, "  addi $t%d, $t%d, 1\n", a->registro_inicio, a->registro_inicio);
    fprintf(archivo_salida, "  j etiq%d\n", etiqueta_temporal);

    
    fprintf(archivo_salida, "  etiq%d:\n", etiqueta_temporal+1);

    break;

  case 'PARA2':
    printf("-> PARA2 AST checkeo\n");

    etiqueta_temporal = numero_etiqueta;     //primera etiqueta
    numero_etiqueta += 2;                   //para la segunda etiqueta

    //declarar variables de inicio y fin
    fprintf(archivo_salida, "  li  $t%d, 0\n", a->registro_inicio);
    fprintf(archivo_salida, "  li  $t%d, %d\n", a->registro_final, a->fin);

    //inicio bucle
    fprintf(archivo_salida, "  etiq%d:\n", etiqueta_temporal);
   
    //comparamos la condicion
    fprintf(archivo_salida, "  slt $t%d, $t%d, $t%d\n", a->registro_incremento, a->registro_final, a->registro_inicio);
    fprintf(archivo_salida, "  beq $t%d, 1, etiq%d\n", a->registro_incremento, etiqueta_temporal+1);

    //cuerpo del bucle
    evaluar(a->nodo_dch);

    //Incrementar el contador
    fprintf(archivo_salida, "  addi $t%d, $t%d, 1\n", a->registro_inicio, a->registro_inicio);

    fprintf(archivo_salida, "  j etiq%d\n", etiqueta_temporal);

    fprintf(archivo_salida, "  etiq%d:\n", etiqueta_temporal+1);

    break;

  case 'PARA3':
    printf("-> PARA3 AST checkeo\n");

    etiqueta_temporal = numero_etiqueta;     //primera etiqueta
    numero_etiqueta += 2;                   //para la segunda etiqueta

    //declarar variables de inicio y fin
    fprintf(archivo_salida, "  li  $t%d, %d\n", a->registro_inicio, a->inicio);
    fprintf(archivo_salida, "  li  $t%d, %d\n", a->registro_final, a->fin);

    //inicio bucle
    fprintf(archivo_salida, "  etiq%d:\n", etiqueta_temporal);

    //cuerpo del bucle
    evaluar(a->nodo_dch);

    //Incrementar el contador
    fprintf(archivo_salida, "  addi $t%d, $t%d, %d\n", a->registro_inicio, a->registro_inicio, a->incremento);   //incrementamos el contador
    
    //Comparacion para finalizar el bucle
    fprintf(archivo_salida, "  slt $t%d, $t%d, $t%d\n", a->registro_incremento, a->registro_inicio, a->registro_final);
    fprintf(archivo_salida, "  beq $t%d, $t%d, etiq%d\n", a->registro_inicio, a->registro_final, etiqueta_temporal);
    fprintf(archivo_salida, "  beq $t%d, $zero, etiq%d\n", a->registro_incremento, etiqueta_temporal+1);
    fprintf(archivo_salida, "  beq $t%d, 1, etiq%d\n", a->registro_incremento, etiqueta_temporal);

    fprintf(archivo_salida, "  etiq%d:\n", etiqueta_temporal+1);

    break;

  case 'P': // Imprimir

    evaluar(a->nodo_izq);
    imprimir(a->nodo_izq);
    break;

  case 'SL': // Statement List

    v = evaluar(a->nodo_izq);
    evaluar(a->nodo_dch);    
    break;
      
  default:
    printf("Error: Nodo desconocido %c\n", a->tipo_nodo);
  }
  return v;
}

double escribir_mips(struct nodo *a)
{
  // Crea todas las variables necesarias en .data
  fprintf(archivo_salida, "\n.data\n");
  // Variable que SIEMPRE se imprime para el salto de línea
  fprintf(archivo_salida, "  nuevaLinea: .asciiz \"\\n\"\n");
  // Variable que SIEMPRE se imprime para tener un cero flotante
  fprintf(archivo_salida, "  cero_f: .float 0.0\n");
  // Recorremos el array de las variables que hay que definir
  for (int i = 0; i < 32; i++)
  {
    if (variables_array[i][2] == 1)
    {
      fprintf(archivo_salida, "  variable%d: .float %f\n", (int)variables_array[i][1], variables_array[i][0]);
      variables_array[i][2] = 0;
    }
  }
  // Crea el código MIPS
  fprintf(archivo_salida, "\n.text\n");
  fprintf(archivo_salida, "  lwc1 $f31, cero_f\n\n");

  return evaluar(a);
}

void imprimir(struct nodo *a)
{
  // Preparar para imprimir
  fprintf(archivo_salida, "  li $v0, 2\n");
  // Mover del registro n al registro 12
  fprintf(archivo_salida, "  add.s $f12, $f31, $f%d\n", a->registro);
  fprintf(archivo_salida, "  syscall\n");

  fprintf(archivo_salida, "  li $v0, 4\n");
  fprintf(archivo_salida, "  la $a0, nuevaLinea\n");
  fprintf(archivo_salida, "  syscall\n");
}

void si_sentencia(struct nodo *a, int numero_etiqueta)
{

  fprintf(archivo_salida, "  bc1f etiq%d\n", numero_etiqueta);

}

void si_sino_sentencia(struct nodo *a, int numero_etiqueta)
{

  fprintf(archivo_salida, "  bc1f etiq%d\n", numero_etiqueta);
}

void mientras_sentencia(struct nodo *a, int numero_etiqueta)
{
 
  fprintf(archivo_salida, "  bc1f etiq%d\n", numero_etiqueta);
}