flex flex.l
bison -dy bison.y
gcc lex.yy.c y.tab.c -o x.exe
x.exe