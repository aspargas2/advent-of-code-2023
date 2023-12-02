#include "bytecode.h"

.section .text

@local variable allocations: (kinda wrong but oh well can't be bothered to fix them)
@ 0,1: return addresses
@ 2: input array reference
@ 3: output array reference
@ 4: part 1 sum
@ 9: temporary whatever
@ 10: debugging nonsense
@ 11: index into the input array

@ solves AoC :D
.global solve_bytecode
solve_bytecode:
	@ We are passed two arrays in the stack: one for the input file and one for the output ints
	astore_2
	astore_3

	iconst_0
	istore 4
	iconst_0
	istore 8
	iconst_0
	istore 11
	iconst_0
	istore 12

lines_loop:
first_digit_loop:
	aload_2
	iload 11
	iinc 11, 1
	baload
	istore 9

	iload 9
	ifeq lines_loop_break;
	iload 9
	bipush '0'
	if_icmplt first_digit_loop
	iload 9
	bipush '9'
	if_icmpgt first_digit_loop

	iload 9
	bipush '0'
	isub
	bipush 10
	imul
	istore 5

find_newline_loop:
	aload_2
	iload 11
	iinc 11, 1
	baload
	istore 8

	iload 8
	ifeq find_newline_break
	iload 8
	bipush '\n'
	if_icmpeq find_newline_break
	goto find_newline_loop
find_newline_break:

	iload 11
	istore 10
last_digit_loop:
	iinc 10, -1
	aload_2
	iload 10
	baload
	istore 9

	iload 9
	bipush '0'
	if_icmplt last_digit_loop
	iload 9
	bipush '9'
	if_icmpgt last_digit_loop

	iload 4
	iload 5
	iload 9
	bipush '0'
	isub
	iadd
	iadd
	istore 4

	iload 8
	ifne lines_loop
lines_loop_break:

	aload_3
	iconst_0
	iload 4
	iastore

	iconst_0
	ireturn

