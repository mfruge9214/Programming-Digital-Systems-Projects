	.include "address_map_nios2.s"
	.extern SHIFT_TIME

	.global BUTTON_ISR
BUTTON_ISR:
	subi sp, sp, 20
	stw ra, 16(sp)
	stw fp, 12(sp)
	stw r14, 8(sp)
	stw r10, 4(sp)
	stw r4, 0(sp)

	#Determine which button was pushed
	movia r15, 0xFF200000 	# LED base
	movia r16, TIMER_BASE
	movia r17, KEY_BASE
	movi r14, 0b1011		
	sthio r14, 4(r16)		# Stop the counter but keep CONT and ITO to 1
	
	ldw r10, 12(r17)		#Read the edgecapture register
	stw r10, 12(r17)		#Clear the interrupt by writing to the edgecapture register
	movi r7, 0b01			# Check for the first edge bit
	movi r8, 0b10			#Check for second edge bit
	movi r9, 0b11			#Check for both edge bits
	
	#Determine if a button has already been pressed 3 times sequentially
	movia r4, SHIFT_TIME	#The first value in the array; Cannot iterate lower than this
	addi r11, r4, 24		#The last value in the array; cannot iterate above this
	beq r5, r11, COMPARE_TIME
	beq r5, r4, COMPARE_TIME

	# If the PC gets to this point, then the timer speed can be changed unless both edge bits are 1
	beq r10, r7, SPEED_UP	
	beq r10, r8, SLOW_DOWN
	beq r10, r9, START_TIMER

# PC will only end up here if the current time is either the slowest or fastest time in the array
COMPARE_TIME:
	xor r20, r5, r11		#Check if the timer is going as fast as it can
	beq r20, r0, CHECK_DECREASE
				# Dont need to check if r5==r4 because if above check fails, that must be true and the corresponding branch is next

CHECK_INCREASE:
	beq r10, r7, SPEED_UP 	# If check passes, the timer is allowed to speed up
	br START_TIMER			# IF check fails, timer cannot change speed

CHECK_DECREASE:
	beq r10, r8, SLOW_DOWN	# If check passes, timer can slow down
	br START_TIMER			# If check fails, timer cannot change speed
	
SPEED_UP:
	addi r5, r5, 4			#Get the next fastest value for the timer
	ldw r7, 0(r5)
	srli r6, r6, 1			# Change the LED indicator to display the new scroll position
	stw r6, 0(r15)
	br WRITE_TIMER

SLOW_DOWN:
	subi r5, r5, 4			# Get the next slowest value for the timer
	ldw r7, 0(r5)
	slli r6, r6, 1
	stw r6, 0(r15)
	br WRITE_TIMER
	
WRITE_TIMER:
	sthio r7, 8(r16) 		#Store the new value in the timer countdown register
	srli r7, r7, 16			
	sthio r7, 12(r16)

START_TIMER:
	movi r14, 0b111
	sthio r14, 4(r16)		#Start the timer count with the new value

END_BUTTON_ISR:
	ldw ra, 16(sp)
	ldw fp, 12(sp)
	ldw r14, 8(sp)
	ldw r10, 4(sp)
	ldw r4, 0(sp)
	addi sp, sp, 20
	ret
	.end

	
	
	
