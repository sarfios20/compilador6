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
     ENTERO = 258,
     OPERADOR_SUMA = 259,
     OPERADOR_RESTA = 260,
     OPERADOR_MULTIPLICACION = 261,
     OPERADOR_DIVISION = 262,
     OPERADOR_IGUAL = 263,
     OPERADOR_DISTINTO = 264,
     OPERADOR_MAYOR = 265,
     OPERADOR_MENOR = 266,
     OPERADOR_MAYOR_IGUAL = 267,
     OPERADOR_MENOR_IGUAL = 268,
     OPERADOR_ASIGNACION = 269,
     PARENTESIS_APERTURA = 270,
     PARENTESIS_CIERRE = 271,
     PUNTOCOMA = 272,
     CONCAT = 273,
     COMILLA = 274,
     OPERADOR_NEGACION = 275,
     OPERADOR_AND = 276,
     OPERADOR_OR = 277,
     TEXTO = 278,
     IDENTIFICADOR = 279,
     REAL = 280,
     BOOL = 281
   };
#endif
/* Tokens.  */
#define ENTERO 258
#define OPERADOR_SUMA 259
#define OPERADOR_RESTA 260
#define OPERADOR_MULTIPLICACION 261
#define OPERADOR_DIVISION 262
#define OPERADOR_IGUAL 263
#define OPERADOR_DISTINTO 264
#define OPERADOR_MAYOR 265
#define OPERADOR_MENOR 266
#define OPERADOR_MAYOR_IGUAL 267
#define OPERADOR_MENOR_IGUAL 268
#define OPERADOR_ASIGNACION 269
#define PARENTESIS_APERTURA 270
#define PARENTESIS_CIERRE 271
#define PUNTOCOMA 272
#define CONCAT 273
#define COMILLA 274
#define OPERADOR_NEGACION 275
#define OPERADOR_AND 276
#define OPERADOR_OR 277
#define TEXTO 278
#define IDENTIFICADOR 279
#define REAL 280
#define BOOL 281




#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
{

/* Line 1685 of yacc.c  */
#line 15 ".\\reducido.y"

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



/* Line 1685 of yacc.c  */
#line 119 "y.tab.h"
} YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
#endif

extern YYSTYPE yylval;


