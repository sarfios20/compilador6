

 
.data #Variables
  newLine: .asciiz "\n"
  var1: .word 3
  var2: .word 2

.text #Operaciones
  li $v0, 4
  la $a0, newLine
  lwc1 $f0, variable0
  lwc1 $f2, variable1
  sub.s $f3, $f0, $f2
  li $v0, 2
  add.s $f12, $f31, $f0
  syscall
  li $v0, 4
  la $a0, newLine
  syscall
