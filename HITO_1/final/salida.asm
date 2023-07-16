
.data #Variables
  nuevaLinea: .asciiz "\n"
  cero_f: .float 0.0
  variable0: .float 4.000000
  variable1: .float 6.000000
  variable2: .float 1.000000

.text #Operaciones
  lwc1 $f31, cero_f

  lwc1 $f0, variable0
  etiq0:
  bc1f etiq1
  lwc1 $f5, variable2
  add.s $f6, $f0, $f5
  mov.s $f6, $f6
  li $v0, 2
  add.s $f12, $f31, $f6
  syscall
  li $v0, 4
  la $a0, nuevaLinea
  syscall
  j etiq0
etiq1:
