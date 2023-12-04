.arm
.section .text

.global solve
.type solve, %function
solve:
	push {r4-r11, lr}

	mov r12, r0
	mov r11, #0

	@ First, find the length of one line to get dimension of the square
find_newline:
	add r11, #1
	ldrb r0, [r12, r11]
	cmp r0, #'\n'
	bne find_newline

	mov r5, #-1
	mov r9, #0
lines_loop:
	add r5, #1
	cmp r5, r11
	beq lines_break
	mov r4, #-1
	mov r6, #0
	mov r8, #0
line_loop:
	add r4, #1
	cmp r4, r11
	bgt lines_loop @ intentionally let the newline or null run through the loop
	mov r0, r4
	mov r1, r5
	bl get_2d
	cmp r3, #'0'
	blt main_not_digit
	cmp r3, #'9'
	bgt main_not_digit
	mov r0, #10
	mul r6, r0, r6
	sub r3, #'0'
	add r6, r3
	cmp r8, #0
	bne line_loop
	bl has_adjacent
	mov r8, r0
	b line_loop
main_not_digit:
	cmp r8, #0
	addne r9, r6
	movne r8, #0
	mov r6, #0
	b line_loop
lines_break:

	ldr r1, =outbuf
	adr r6, part_str
	ldmia r6!, {r2, r3, r4, r5}
	stmia r1!, {r2, r3}
	mov r0, r9
	bl itoa
	mov r2, #'\n'
	strb r2, [r1], #1
	strb r0, [r1], #1

	ldr r0, =outbuf
	pop {r4-r11, pc}

.ltorg

.balign 4
part_str:
.ascii "Part 1: Part 2: "

get_2d:
	add r3, r11, #1
	mul r3, r1, r3
	add r3, r0
	ldrb r3, [r12, r3]
	bx lr


itoa:
	cmp r0, #0
	bne itoa_not_0
	mov r6, #'0'
	strb r6, [r1], #1
	bx lr
itoa_not_0:
	adr r2, pows_10
itoa_pre_loop:
	ldr r3, [r2], #4
	cmp r0, r3
	blo itoa_pre_loop
itoa_loop:
	mov r6, #'0'
	mov r7, r3
itoa_inner_loop:
	cmp r0, r7
	blo itoa_inner_break
	add r7, r3
	add r6, #1
	b itoa_inner_loop
itoa_inner_break:
	strb r6, [r1], #1
	sub r7, r3
	sub r0, r7
	ldr r3, [r2], #4
	cmp r3, #0
	bne itoa_loop
	bx lr

pows_10:
	.word 1000000000
	.word 100000000
	.word 10000000
	.word 1000000
	.word 100000
	.word 10000
	.word 1000
	.word 100
	.word 10
	.word 1
	.word 0

has_adjacent:
	mov r10, lr
	adr r2, offset_array
has_adjacent_loop:
	ldmia r2!, {r0, r1}
	cmp r1, #0xED
	bxeq r10
	adds r0, r4
	bmi has_adjacent_loop
	cmp r0, r11
	beq has_adjacent_loop
	adds r1, r5
	bmi has_adjacent_loop
	cmp r1, r11
	beq has_adjacent_loop
	bl get_2d
	cmp r3, #'0'
	blt hasadj_not_digit
	cmp r3, #'9'
	ble has_adjacent_loop
hasadj_not_digit:
	cmp r3, #'.'
	beq has_adjacent_loop
	movs r0, #1
	bx r10

offset_array:
	.word 1, 0
	.word 1, 1
	.word 0, 1
	.word -1, 1
	.word -1, 0
	.word -1, -1
	.word 0, -1
	.word 1, -1
	.word 0, 0xED

.ltorg

.section .bss

.balign 4
outbuf:
.skip 64
