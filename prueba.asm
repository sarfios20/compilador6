
.data #Variables
  newLine: .asciiz "\n"
  zero_f: .float 0.0
  variable0: .float 4.000000
  variable1: .float 3.000000

.text #Operaciones
  lwc1 $f31, zero_f

  lwc1 $f0, variable0
  lwc1 $f1, variable1
  add.s $f2, $f0, $f1
