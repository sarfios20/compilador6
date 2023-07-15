#include "ast.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

extern FILE *yyin;
extern FILE *yyout;

extern int yylineno;
void yyerror(const char *s);

// ast node management
struct ast *newast(int nodetype, struct ast *l, struct ast *r)
{
    struct ast *a = malloc(sizeof(struct ast));

    if(!a) {
        yyerror("out of space");
        exit(0);
    }
    a->nodetype = nodetype;
    a->l = l;
    a->r = r;
    return a;
}

struct ast *newnum(int d, char* indentificador)
{
    struct intval *a = malloc(sizeof(struct intval));

    if(!a) { // Comprueba si hay memoria disponible
        yyerror("out of space");
        exit(0);
    }

    a->nodetype = 'E';
    a->number = d;
    a->indentificador = indentificador;
    return (struct ast *)a;
}

struct ast *newreal(float d, char* indentificador)
{
    struct realval *a = malloc(sizeof(struct realval));

    if(!a) {
        yyerror("out of space");
        exit(0);
    }

    a->nodetype = 'F';
    a->number = d;
    a->indentificador = indentificador;
    return (struct ast *)a;
}

struct ast *newbool(int i, char* indentificador)
{
    struct boolval *a = malloc(sizeof(struct boolval));

    if(!a) {
        yyerror("out of space");
        exit(0);
    }

    a->nodetype = 'B';
    a->boolean = i;
    a->indentificador = indentificador;
    return (struct ast *)a;
}


float eval(struct ast *a)
{
    float v;
    if(!a) {
        yyerror("internal error, null eval");
        return 0.0;
    }
    switch(a->nodetype) {
        /* constant */
        case 'E':
          v = ((struct intval *)a)->number; 
          break;
        case 'F':
          v = ((struct realval *)a)->number;
          break;
        case 'B':
         v = ((struct boolval *)a)->boolean;
         break;
        case '+':
         v = eval(a->l) + eval(a->r);
          break;
        case '-':
         v = eval(a->l) - eval(a->r);
          break;
        case '*':
         v = eval(a->l) * eval(a->r);
          break;
        case '/':
         v = eval(a->l) / eval(a->r);
          break;
        case '^':
         v = pow(eval(a->l), eval(a->r));
          break;
        case '=':
         v = eval(a->l) == eval(a->r);
          break;
        case 'D':
         v = eval(a->l) != eval(a->r);
          break;
        case '<':
         v = eval(a->l) < eval(a->r);
          break;
        case '>':
         v = eval(a->l) > eval(a->r);
         break;
        case 'M':
         v = eval(a->l) <= eval(a->r);
         break;
        case 'G':
         v = eval(a->l) >= eval(a->r);
         break;
    }
    return v;
}


double iniciar_evaluacion(struct nodo *a)
{
  fprintf(yyout, "\n.data #Variables\n");
  fprintf(yyout, "  newLine: .asciiz \"\\n\"\n");
  
  for (int i = 0; i < table_size; i++)
  {
    if (strcmp(table[i].tipo, "real") == 0)
    {
      fprintf(yyout, "  %s: .float %f\n", table[i].name, table[i].real);
    }
    else if (strcmp(table[i].tipo, "entero") == 0)
    {
      fprintf(yyout, "  %s: .word %d\n", table[i].name, table[i].entero);
    }
    else if (strcmp(table[i].tipo, "booleano") == 0)
    {
      fprintf(yyout, "  %s: .word %d\n", table[i].name, table[i].booleano);
    }
    else if (strcmp(table[i].tipo, "texto") == 0)
    {
      fprintf(yyout, "  %s: .asciiz \"%s\"\n", table[i].name, table[i].texto);
    }
  }

  fprintf(yyout, "\n.text #Operaciones\n");
  fprintf(yyout, "  li $v0, 4\n");
  fprintf(yyout, "  la $a0, newLine\n");
  fprintf(yyout, "  syscall\n\n");

  return eval(a); // Evalua el arbol
}
void yyerror(const char *s)
{ 
    printf("Error en la linea %d: %s\n", yylineno, s); 
} 