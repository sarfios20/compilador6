
.data
  nuevaLinea: .asciiz "\n"
  cero_f: .float 0.0
  variable0: .float 10.000000
  variable1: .float 1.000000

.text
  lwc1 $f31, cero_f

  lwc1 $f0, variable0
  li  $t0, 1
  li  $t1, 10
  etiq0:
  lwc1 $f2, variable1
  add.s $f3, $f0, $f2
  mov.s $f3, $f3
  li $v0, 2
  add.s $f12, $f31, $f3
  syscall
  li $v0, 4
  la $a0, nuevaLinea
  syscall
  addi $t0, $t0, 3
  slt $t2, $t0, $t1
  beq $t0, $t1, etiq0
  beq $t2, $zero, etiq1
  beq $t2, 1, etiq0
  etiq1:
