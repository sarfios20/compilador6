#include "symbol_table.h"

int lookup(char *name, int table_index, symbol table[]) {
    for (int i = 0; i < table_index; i++) {
        if (strcmp(table[i].name, name) == 0) {
            return i; //Devuelve la posición de la lista
        } 
    }
    return -1;  //-1 si no está en la tabla
}