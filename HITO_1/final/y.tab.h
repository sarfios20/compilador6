/* A Bison parser, made by GNU Bison 2.4.2.  */

/* Skeleton interface for Bison's Yacc-like parsers in C
   
      Copyright (C) 1984, 1989-1990, 2000-2006, 2009-2010 Free Software
   Foundation, Inc.
   
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.
   
   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */


/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     OPERADOR_SUMA = 258,
     OPERADOR_RESTA = 259,
     OPERADOR_MULTIPLICACION = 260,
     OPERADOR_DIVISION = 261,
     PARENTESIS_APERTURA = 262,
     PARENTESIS_CIERRE = 263,
     CONCATENAR = 264,
     COMILLA = 265,
     OPERADOR_ASIGNACION = 266,
     SI = 267,
     OSI = 268,
     SINO = 269,
     MIENTRAS = 270,
     FIN = 271,
     OPERADOR_AND = 272,
     OPERADOR_OR = 273,
     IMPRIMIR = 274,
     OPERADOR_NEGACION = 275,
     OPERADOR_MAYOR = 276,
     OPERADOR_MENOR = 277,
     MODULO = 278,
     EXPONENTE = 279,
     OPERADOR_MAYOR_IGUAL = 280,
     OPERADOR_IGUAL = 281,
     OPERADOR_MENOR_IGUAL = 282,
     PUNTOCOMA = 283,
     PARA = 284,
     EN = 285,
     RANGO = 286,
     COMA = 287,
     OPERADOR_DIFERENTE = 288,
     ENTERO = 289,
     REAL = 290,
     TEXTO = 291,
     IDENTIFICADOR = 292,
     BOOL = 293
   };
#endif
/* Tokens.  */
#define OPERADOR_SUMA 258
#define OPERADOR_RESTA 259
#define OPERADOR_MULTIPLICACION 260
#define OPERADOR_DIVISION 261
#define PARENTESIS_APERTURA 262
#define PARENTESIS_CIERRE 263
#define CONCATENAR 264
#define COMILLA 265
#define OPERADOR_ASIGNACION 266
#define SI 267
#define OSI 268
#define SINO 269
#define MIENTRAS 270
#define FIN 271
#define OPERADOR_AND 272
#define OPERADOR_OR 273
#define IMPRIMIR 274
#define OPERADOR_NEGACION 275
#define OPERADOR_MAYOR 276
#define OPERADOR_MENOR 277
#define MODULO 278
#define EXPONENTE 279
#define OPERADOR_MAYOR_IGUAL 280
#define OPERADOR_IGUAL 281
#define OPERADOR_MENOR_IGUAL 282
#define PUNTOCOMA 283
#define PARA 284
#define EN 285
#define RANGO 286
#define COMA 287
#define OPERADOR_DIFERENTE 288
#define ENTERO 289
#define REAL 290
#define TEXTO 291
#define IDENTIFICADOR 292
#define BOOL 293




#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
{

/* Line 1685 of yacc.c  */
#line 28 ".\\bison.y"

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



/* Line 1685 of yacc.c  */
#line 143 "y.tab.h"
} YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
#endif

extern YYSTYPE yylval;


