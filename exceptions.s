	.section	.reset, "ax"

	movia	r2, _start
	jmp		r2						# branch to main program


	.section	.exceptions, "ax"
	.global EXCEPTION_HANDLER

EXCEPTION_HANDLER:
	subi sp, sp, 20
	stw ra, 16(sp)
	stw fp, 12(sp)
	stw et, 8(sp)
	stw r22, 4(sp)
	stw r23, 0(sp)
	rdctl et, ctl4		#Read whether the interrupt is external or not (it is)
	subi ea, ea, 4		#Must decrement ea for external ISR (In this project, all interrupts are external)

	# Determine what interrupt occured
	movi r22, 0b1		# Flag bit for the timer
	movi r23, 0b10		# Flag bit for buttons
	beq et, r22, CALL_TIMER_ISR
	beq et, r23, CALL_BUTTON_ISR

CALL_TIMER_ISR:
	call TIMER_ISR
	br END_ISR

CALL_BUTTON_ISR:
	call BUTTON_ISR
	br END_ISR
	
END_ISR:
	ldw r23, 0(sp)
	ldw r22, 4(sp)
	ldw et, 8(sp)
	ldw fp, 12(sp)
	ldw ra, 16(sp)
	addi sp, sp, 20
	eret
	.end
