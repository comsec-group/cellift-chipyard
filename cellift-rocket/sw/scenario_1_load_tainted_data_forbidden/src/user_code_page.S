.section ".user_code_page_base","ax",@progbits
.global user_code_page_base
user_code_page_base:
	# la t0, user_data_page_base # This works because it gets user_data_page_base relative to this place in the code.

	# # Jump to FORBIDDEN_KERNEL_ADDR
	li t0, 1
	slli t0, t0, 63
	srai t0, t0, 42
	addi t0, t0, 256
	ld t0, (t0) # Load at (virtual) address 0xFFFFFFFFFFE00000 + 256
	ld t0, (t0) # Load in the reload buffer.
user_code_infinite_loop:
	j user_code_infinite_loop
