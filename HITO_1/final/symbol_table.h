#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include <string.h>

// Declaración de la tabla de símbolos
typedef struct {
    char *name;
    char *tipo;
    float real;
    int entero;
    int booleano;
    char* texto;
    int registro;      //Registro donde está el resultado
} symbol;

// Función para buscar un símbolo en la tabla
int lookup(char *name, int table_index, symbol table[]);

#endif