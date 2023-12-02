#include "bytecode.h"

.section .text

@local variable allocations:
@ 0,1: return addresses
@ 2: input array reference
@ 3: output array reference
@ 4: sum
@ 5: first digit
@ 8: if we found a null instead of a newline, this stores it
@ 9,10: temporary whatever
@ 11: index into the input array
@ 12: are we doing part 2?

@ solves AoC :D
.global solve_bytecode
solve_bytecode:
	@ We are passed two arrays in the stack: one for the input file and one for the output ints
	astore_2
	astore_3

	iconst_0
	istore 12
do_it_again:
	iconst_0
	istore 4
	iconst_0
	istore 8
	iconst_0
	istore 11

lines_loop:
first_digit_loop:
	jsr num_check
	iinc 11, 1
	iload 9
	ifeq first_digit_loop

	iload 9
	bipush 10
	imul
	istore 5
	goto find_newline_loop

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
last_digit_loop:
	iinc 11, -1
	jsr num_check
	iload 9
	ifeq last_digit_loop
	istore 11

	iload 4
	iload 5
	iload 9
	iadd
	iadd
	istore 4

	iload 8
	ifne lines_loop
lines_loop_break:

	aload_3
	iload 12
	iload 4
	iastore

	iload 12
	ifne all_done
	iinc 12, 1
	goto do_it_again

all_done:
	iconst_0
	ireturn

@ returns parsed number or 0 on failure in 9
@ clobbers: uhh idk
num_check:
	@ store return address
	astore_0

	aload_2
	iload 11
	baload
	istore 13

	@ null terminator check
	iload 13
	ifeq lines_loop_break

	iload 13
	bipush '0'
	if_icmplt no_numeral
	iload 13
	bipush '9'
	if_icmpgt no_numeral

	iload 13
	bipush '0'
	isub
	istore 9
	ret 0

no_numeral:
	iload 12
	ifne num_part2
	iconst_0
	istore 9
	ret 0

	@ hold on tight this is gonna get janky
num_part2:
	@ get our own address
	jsr num_part2_selfcall
num_part2_selfcall:
	@ add to it the difference from here to arrays_fakearray to get that address
	bipush arrays_fakearray - num_part2_selfcall
	iadd
	@ now we have the address of arrays_fakearray
	astore 15

	@ work backwards comparing strings from the array just to make the logic easier
	bipush 9
	istore 9

num_strings_loop:
	iconst_0
	istore 10

	aload 15
	iload 9
	aaload
	astore 14

num_string_loop:
	aload 14
	iload 10
	baload
	aload_2
	iload 10
	iload 11
	iadd
	baload
	if_icmpne num_string_break
	iinc 10, 1
	iload 10
	aload 14
	arraylength
	if_icmplt num_string_loop
	ret 0
num_string_break:

	iinc 9, -1
	iload 9
	ifne num_strings_loop
	ret 0

.balign 4
arrays_fakearray:
	.word (arrays_end - arrays) >> 2
arrays:
	.word 0
	.word one_fakearray
	.word two_fakearray
	.word three_fakearray
	.word four_fakearray
	.word five_fakearray
	.word six_fakearray
	.word seven_fakearray
	.word eight_fakearray
	.word nine_fakearray
arrays_end:

#define str_fakearray(text) \
	.balign 4; \
	text##_fakearray:; \
	.word text##_end - text; \
	text:; \
	.ascii #text; \
	text##_end:

str_fakearray(one)
str_fakearray(two)
str_fakearray(three)
str_fakearray(four)
str_fakearray(five)
str_fakearray(six)
str_fakearray(seven)
str_fakearray(eight)
str_fakearray(nine)
