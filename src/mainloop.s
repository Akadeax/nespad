 mainloop:
 	; skip reading controls if and change has not been drawn
 	lda nmi_ready
 	cmp #0
 	bne mainloop

 	; ensure our changes are rendered
 	lda #1
 	sta nmi_ready

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

	lda input_pressed_this_frame
	and #PAD_B
	beq NOT_PAD_B
		; B pressed
		jsr on_b_pressed_T2

	NOT_PAD_B:

 	lda current_input
    sta last_frame_input

 	jmp mainloop


.proc on_b_pressed_T2
	jsr ppu_off
	; accessing VRAM is now safe

	jsr clear_nametable

	lda #$00
	sta zp_temp_0
	lda current_wram_text_ptr_hi
	sta zp_temp_1
	; zp_temp_0&1 hold start of current page in WRAM text

	jsr set_pointers_to_last_character_of_current_page
	; wram_text_ptr and text_index are now at the position we need to draw text until

	lda current_text_index
	sta zp_temp_2
	inc zp_temp_2
	; zp_temp_2 now holds our target text_index

	lda #0
	sta current_text_index

	reset_current_nametable_ptr

	ldx #0
loop:
	increment_nametable_ptr


	lda PPU_STATUS
	lda current_nametable_ptr_hi
	sta PPU_ADDR
	lda current_nametable_ptr_lo
	sta PPU_ADDR

	ldy #0
	lda (zp_temp_0),y

	sta PPU_DATA

	inc current_text_index
	increment_zp_16 #1, zp_temp_0, zp_temp_1
	inx

	cpx zp_temp_2
	bne loop


	rts
.endproc


.proc on_a_pressed
	lda current_text_index
	cmp #PAGE_TEXT_SIZE
	bne :+
	rts
:

	lda screen_keyboard_index
	cmp #(KEYBOARD_CHARACTER_KEY_AMOUNT + 1)
	bmi :+
	rts
:

	; keyboard is on character key (non-control key)
	lda screen_keyboard_index
	sta (current_wram_text_ptr_lo), y

	increment_nametable_ptr

	increment_zp_16 #1, current_wram_text_ptr_lo, current_wram_text_ptr_hi
	inc current_text_index

	rts
.endproc


.proc set_pointers_to_last_character_of_current_page
	lda #<WRAM_START
	sta current_wram_text_ptr_lo
	lda #>WRAM_START
	clc
	adc current_page
	sta current_wram_text_ptr_hi
	; current_wram_text_ptr now holds the start of the current page in WRAM

	;;; Step 2: find last non-space character, or 0 otherwise; set that to text_index
	lda #(PAGE_TEXT_SIZE - 1)
	sta current_text_index

	lda current_wram_text_ptr_lo
	clc
	adc current_text_index
	sta current_wram_text_ptr_lo
	; increment wram_text_ptr by current_text_index so we can decrement it until we find something

first_empty_char_loop:
	ldx current_text_index
	beq	non_empty_char_found ; if text_index is 0, just take it; no character on thsi page

	ldy #0
	lda (current_wram_text_ptr_lo), y
	bne non_empty_char_found ; if current_wram_text_ptr is not spacebar ($00), we found what we were looking for

	dec current_text_index
	decrement_zp_16 #1, current_wram_text_ptr_lo, current_wram_text_ptr_hi
	jmp first_empty_char_loop

non_empty_char_found:
	; decremented current_text_index & wram_text_ptr until first non-space was found

	rts
.endproc
