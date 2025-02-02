.globl abs
.text

abs:
  lw t0 0(a0)
  blt zero, t0, done
  sub t0, x0, t0
  sw t0 0(a0)

done:
  jr ra