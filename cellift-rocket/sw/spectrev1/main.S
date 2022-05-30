
  .section ".text.init","ax",@progbits
  .globl _start
  .align 2
_start:
    la t0, arr_base
    la t1, arr_end
    la t5, arr_end
    addi t1, t1, 0x400# So that the BP does not learn during memset
# Memset the array to the program base
memset_loop:
    li t4, 0x80000000
    beq t0, t1, after_sd
    sd t4, (t0)
after_sd:
    addi t0, t0, 0x200
    bne t0, t5, memset_loop
# End of memset loop
    la t0, arr_base
spectre_loop_start:
    beq t0, t1, infinite_loop
    ld t2, (t0)
    ld t3, (t2)
    addi t0, t0, 0x200
    j spectre_loop_start
infinite_loop:
    j infinite_loop
