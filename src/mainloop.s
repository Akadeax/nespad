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

	lda current_input
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




.proc on_a_pressed
	ldx 0 ; x is treated as 'offset' off of screen_keyboard_index (for caps, bold, etc.)

	lda screen_keyboard_index
	cmp #KEYBOARD_CHARACTER_KEY_AMOUNT
	bpl NOT_CHARACTER_KEY
		; keyboard is on character key (non-control key)

		lda screen_keyboard_index

		; ldy #0
		; sta (wram_text_ptr_lo), y

		; increment_zp_16 1, wram_text_ptr_lo, wram_text_ptr_hi

	NOT_CHARACTER_KEY:
	rts
.endproc


.proc on_page_loaded
	;;; Step 1: setup initial variables
	lda #<WRAM_START
	sta current_wram_text_ptr_lo
	lda #<WRAM_START
	sta current_wram_text_ptr_hi

	ldx current_page
loop: ; this loop jumps 256 bytes per page to get to start of current page
	cpx #0
	beq loop_end

	dex
	inc sixteen_bit_temp_hi ; jump 256, 1 page
	jmp loop

loop_end:
	; current_wram_text_ptr now holds the start of the current page in WRAM

	;;; Step 2: find last non-space character, or 0 otherwise; set that to text_index
	; TODO IMPLEMENT

	rts
.endproc
