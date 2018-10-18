# Author: Michael Fruge
# Project: Project 2, part 2, Buttons
# Date: 10/19/18

# r2 is the address of the 7 segment displays
# r3 is the address of the buttons
# r4 is an indicator bit of which way is currently being shifted: 0=R->L, 1=L->R
# r5 and r6 are registers to check what state the shifter is in
# r5 is a 0
# r6 is a 1
# r7 is the ShiftRtoL store register
# r8 is the ShiftLtoR store register
# r9 is the shift register
# r10 is the current value of the buttons
# r11 is the buffer check register
# r12 is the count register for the shifts, once it hits 8 then reset the shift pattern
# r13 is 8, the count needed to reset the shift pattern
# r15 and r16 are the pattern addresses
# r20 is the counter value for when to switch

#Fix the error that happens when it lags


.text
.global _start

_start:
	movia r2, 0xFF200020 #Load address of HEX disp. into r2
	movia r3, 0xFF200050 #Address of the buttons
	movia r4, 0		#Shift values from Right to Left to start
	movia r5, 0
	movia r6, 1 
	movia r12, 0
	movia r15, R2L
	movia r16, L2R
	movia r18, 8
	movia r20, 10000000  # Value of wait time for counter to hit before the next change 10000000
	br WAIT
	
WAIT:
	ldw r10, 0(r3) #r10 is the value of the buttons
	addi r11, r10, 0 #r11 is the buffer check register
	bne r10, r0, BUFFER #Buffer Ensures 1 button press corresponds to 1 change of shift direction 
	addi r22, r22, 1
	bleu r20, r22, DECIDE
	br WAIT

BUFFER:
	ldw r10, 0(r3) #r10 is the value of the buttons
	bne r10, r11, CHANGE
	br BUFFER

DECIDE:
	beq r4, r5, SHIFTR2L
	beq r4, r6, SHIFTL2R

CHANGE:
	movia r12, 0
	movia r15, R2L
	movia r16, L2R
	movia r12, 0
	movia r22, 0
	beq r4, r5, ADD1
	beq r4, r6, SUB1

ADD1:
	addi r4, r5, 1
	br RESETSEVSEG

SUB1:
	addi r4, r6, -1
	br RESETSEVSEG

SHIFTR2L:
	movia r22, 0
	ldw r7, 0(r15)
	slli r9, r9, 8
	add r9, r9, r7
	stw r9, 0(r2)
	addi r15, r15, 4
	addi r12, r12, 1
	beq r12, r18, RESETCOUNT
	br WAIT

SHIFTL2R:
	movia r22, 0
	ldw r8, 0(r16)
	srli r9, r9, 8
	add r9, r9, r8
	stw r9, 0(r2)
	addi r16, r16, 4
	addi r12, r12, 1
	beq r12, r18, RESETCOUNT
	br WAIT

RESETSEVSEG:
	movia r9, 0
	stw r9, 0(r2)
	br WAIT

RESETCOUNT:
	movia r12, 0
	movia r15, R2L
	movia r16, L2R
	br WAIT

.data
R2L:
	.word 0x79, 0x49, 0x49, 0x49, 0x00, 0x00, 0x00, 0x00
L2R:
	.word 0x4F000000, 0x49000000, 0x49000000, 0x49000000, 0x00, 0x00, 0x00, 0x00