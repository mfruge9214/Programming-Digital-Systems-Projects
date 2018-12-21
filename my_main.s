/* 	Author: Mike Fruge
	Project: Creating a Scrolling Message by implementing interrupts
	Date: 11/30/2018 */

	.include "address_map_nios2.s"


	.text
	.global _start
_start:
	movia r16, TIMER_BASE   # Move base address of timer into r16
	movia r17, KEY_BASE		# Move base address of keys into r17
	movia r4, HELLO_BUFFS	# Give the address of the first element of the pattern to the Timer_ISR 
	movia r5, SHIFT_TIME	# Address of the timer values
	movia r15, 0xFF200000 	# LED base
	movi r6, 0b1000			# Initialize the LED's to display the first scroll position
	stw r6, 0(r15)
	addi r5, r5, 12			# Start with the median amount of shift time
	ldw r12, 0(r5)			# Grab value from memory and store into the timer countdown register
	sthio r12, 8(r16)		# Store halfword into lo halfword timer register
	srli r12, r12, 16		# Shift hi halfword -> lo halfword
	sthio r12, 12(r16)		# Store halfword into hi halfword timer reg
	movia r18, 0xFF200020	# Hex address
	stw r0, 0(r18)			# Initialize the HEX Displays to be blank
	
	# Start timer and enable interrupts
	movi r15, 0b111
	sthio r15, 4(r16)
	
	#Enable mask register of pushbuttons
	movi r14, 0b11
	sthio r14, 8(r17)

	# Interval timer and Keys have mask bits 0 and 1 respectivley
	# Enable the processor to accept interrupts from Timer and Keys
	wrctl ienable, r14 # Enable interrupts by writing 0b11 into ienable
	movi r7, 1	
	wrctl status, r7  # Enables the processor to accept interrupts

IDLE:
	br IDLE  # Program stays Idle and then switches control to ISR


	.data
	.global HELLO_BUFFS
HELLO_BUFFS:
	.word 0x76, 0x79, 0x38, 0x38, 0x3F, 0x00, 0x7c, 0x3E, 0x71, 0x71, 0x6D, 0x40, 0x40, 0x40, 0x00, 0x00, 0x00, 0x00

	.global SHIFT_TIME
SHIFT_TIME:
	.word 100000000, 80000000, 60000000, 40000000, 25000000, 15000000, 10000000
	.end
