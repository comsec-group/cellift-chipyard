
  .section ".text.init","ax",@progbits
  .globl _start
  .align 2
_start:
    # la x1, soc_ctrl_addr
    # li x2, 0
    # .rept 40
    # nop # Taint must be injected here
    # .endr
    # sw x2, (x1)
infinite_loop:
    .rep 100
    nop
    .endr
    j infinite_loop
