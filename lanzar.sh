#!/bin/bash
flex prueba.l
bison -dy prueba.y
gcc lex.yy.c y.tab.c -o programa.exe