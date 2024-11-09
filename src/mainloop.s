 mainloop:
 	; skip reading controls if and change has not been drawn
 	lda nmi_ready
 	cmp #0
 	bne mainloop
 	; read the gamepad
 	poll_gamepad current_input

	lda last_frame_input
	eor #%11111111
	and current_input
	sta input_pressed_this_frame

    ; do input handling stuff here
	lda input_pressed_this_frame
	and #PAD_UP
	beq NOT_PAD_UP
		; up pressed
		
	NOT_PAD_UP:

	lda input_pressed_this_frame
	and #PAD_DOWN
	beq NOT_PAD_DOWN
		; down pressed

	NOT_PAD_DOWN:

	lda input_pressed_this_frame
	and #PAD_LEFT
	beq NOT_PAD_LEFT
		; left pressed
		dec screen_keyboard_index

	NOT_PAD_LEFT:

	lda input_pressed_this_frame
	and #PAD_RIGHT
	beq NOT_PAD_RIGHT
		; right pressed
		inc screen_keyboard_index

	NOT_PAD_RIGHT:

	lda input_pressed_this_frame
	and #PAD_A
	beq NOT_PAD_A
		; A pressed
		jsr on_a_pressed

	NOT_PAD_A:


 	lda current_input
    sta last_frame_input

 	; ensure our changes are rendered
 	lda #1
 	sta nmi_ready
 	jmp mainloop


.macro increment_text_ptr
	inc wram_text_ptr_lo
	bne no_hi_increment

	inc wram_text_ptr_hi
	
	no_hi_increment:
.endmacro

.proc on_a_pressed
	ldx 0 ; x is treated as 'offset' off of screen_keyboard_index (for caps, bold, etc.)
	
	lda screen_keyboard_index
	cmp #KEYBOARD_CHARACTER_KEY_AMOUNT
	bpl NOT_CHARACTER_KEY
		; keyboard is on character key (non-control key)

		lda screen_keyboard_index
		; store
		ldy #0
		sta (wram_text_ptr_lo), y

		increment_text_ptr

	NOT_CHARACTER_KEY:
	rts
.endproc

