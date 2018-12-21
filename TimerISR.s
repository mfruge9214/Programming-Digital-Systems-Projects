	.include "address_map_nios2.s"
	.extern HELLO_BUFFS

	.global TIMER_ISR

TIMER_ISR:
	# Need to write the prologue to save the correct registers
	# Need to save ra and any registers used within the ISR and restore them by the time we return
	subi sp, sp, 28
	stw ra, 24(sp)
	stw fp, 20(sp)
	stw r5, 16(sp)
	stw r16, 12(sp)
	stw	r20, 8(sp)
	stw r17, 4(sp)
	stw r8, 0(sp)

	# Reconfigure the timer to run again
	movia r16, TIMER_BASE
	sthio r0, 0(r16)
	
	#Display the message
	movia r20, 0xFF200020	# HEX base address
	ldw r8, 0(r4) 			# Get the next word from the pattern array
	slli r19, r19, 8		#Shift the register 4 bits
	add r19, r19, r8		# Add the new pattern to the shifted register
	stw r19, 0(r20)			#Store the new pattern into the HEX Display
	addi r4, r4, 4
	beq r19, r0, RESET_POINTER
	br END_TIMER_ISR

RESET_POINTER:
	movia r4, HELLO_BUFFS

END_TIMER_ISR:
	#Deallocate the stack and restore all the memory
	ldw r16, 0(sp)
	ldw r17, 4(sp)
	ldw r20, 8(sp)
	ldw r8, 12(sp)
	ldw r5, 16(sp)
	ldw fp, 20(sp)
	ldw ra, 24(sp)
	addi sp, sp, 28
	ret
	.end
	
