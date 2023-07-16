
.data
  nuevaLinea: .asciiz "\n"
  cero_f: .float 0.0
  variable0: .float 80.000000
  variable1: .float 70.000000
  variable2: .float 5.000000
  variable3: .float 5.000000
  variable4: .float 10.000000
  variable5: .float 1.000000
  variable6: .float 10.000000

.text
  lwc1 $f31, cero_f

  bc1f etiq0
  lwc1 $f4, variable2
  bc1f etiq1
  lwc1 $f11, variable5
  add.s $f13, $f4, $f11
  mov.s $f13, $f13
etiq1:
  lwc1 $f17, variable6
  add.s $f18, $f13, $f17
  li $v0, 2
  add.s $f12, $f31, $f18
  syscall
  li $v0, 4
  la $a0, nuevaLinea
  syscall
etiq0:
