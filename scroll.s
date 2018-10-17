# Author: Michael Fruge
# Project: Project 2, part 1, Scroll
# Date: 10/19/18

# 	r2 is the address of hex displays
#	r3 & r7 is the shift register needed for Hello Buffs---___
#	r4 is the array of values to be shifted into the display register
#	r5 is the count of the shifts	
#	r10-r12 is the patterns needed
#	r15-17 is the amout of times pattern A, B, and C have shown
#	r20 is the count limit 
#	r22 is the counter timer


.text
.global _start

_start:
	movia r2, 0xFF200020 #Load address of HEX disp. into r2
	movia r20, 20000000  # Value of wait time for counter to hit before the next change
	movia r4, BUFFS		#r4 should contain the address of the array of letters needed to shift in to the register
	movia r5, 0			#r5 is counter for shifts needed
	movia r6, 18		#r6 is the limit for shifting
	movia r10, 0x49494949 #Pattern A encoded to HEX
	movia r11, 0x36363636 #Pattern B encoded to HEX
	movia r12, 0xFFFFFFFF #Pattern C
	movia r19, 3		# Number of times first half of patterns should be displayed
	stw r0, 0(r2) 		# Turn off 7 seg
WAIT:
	addi r22, r22, 1
	bleu r20, r22, DECIDE
	br WAIT

DECIDE:
	bge r5, r6, CYCLE1
	br SHIFT

SHIFT:
	movia r22, 0
	addi r5, r5, 1
	ldw r3, 0(r4)
	slli r7, r7, 8
	add r7, r7, r3
	stw r7, 0(r2)
	addi r4, r4, 4
	br WAIT

CYCLE1:
	movia r22, 0		#Reset the counter
	ldw r8, 0(r2) #r8 is the value of the HEX displays.
	beq	r16, r19, CYCLE2	# If count of B is 3, display the next cycle
	beq r8, r7, DISP_A
	beq r8, r11, DISP_A	#If r8 currently holds Pattern B or Pattern A, change which one it is displaying 
	beq r8, r10, DISP_B

CYCLE2:
	beq r18, r19, RESET
	beq r8, r11, LIT
	beq r8, r0, LIT
	beq r8, r12, OFF

LIT:
	stw r12, 0(r2)
	br WAIT

OFF:
	stw r0, 0(r2)
	addi r18, r18, 1
	br WAIT

RESET:
	movia r4, BUFFS
	movia r5, 0
	movia r16, 0
	movia r18, 0
	br WAIT

DISP_A:
	stw r10, 0(r2)
	br WAIT

DISP_B:
	stw r11, 0(r2)
	addi r16, r16, 1	#r16 is the amount of times B has been shown
	br WAIT

.data
BUFFS:
	.word 0x76, 0x79, 0x38, 0x38, 0x3F, 0x00, 0x7c, 0x3E, 0x71, 0x71, 0x6D, 0x40, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00
