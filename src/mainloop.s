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

	lda current_input
	eor #%11111111
	and last_frame_input
	sta input_released_this_frame

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
	beq NOT_PAD_A_PRESSED
		; A pressed
		jsr type_current_key
		lda #1
		sta a_held

	NOT_PAD_A_PRESSED:

	lda input_released_this_frame
	and #PAD_A
	beq NOT_PAD_A_RELEASED
		; A released
		lda #0
		sta a_held
		sta a_time_held

	NOT_PAD_A_RELEASED:

	lda current_input
	and #PAD_A
	beq NOT_PAD_A_HELD
		; A held
		lda a_time_held
		cmp #50
		bpl time_held_above_threshold ; if a_time_held > threshold, call type; otherwise just increment it

	time_held_below_threshold:
		inc a_time_held
		jmp NOT_PAD_A_HELD

	time_held_above_threshold:
		jsr type_current_key

	NOT_PAD_A_HELD:

	lda current_input

	lda input_pressed_this_frame
	and #PAD_SELECT
	beq NOT_PAD_SELECT
		; SELECT pressed
		lda current_page
		beq NOT_PAD_START ; if we're at first page, don't dec

		dec current_page
		jsr redraw_current_page_T2



	NOT_PAD_SELECT:

	lda input_pressed_this_frame
	and #PAD_START
	beq NOT_PAD_START
		; START pressed
		lda current_page
		cmp #(MAX_PAGE_AMOUNT - 1)
		beq NOT_PAD_START ; if we're at the last page, don't inc

		inc current_page
		jsr redraw_current_page_T2

	NOT_PAD_START:

	lda input_pressed_this_frame
	and #PAD_B
	beq NOT_PAD_B
		; B pressed
		jsr redraw_current_page_T2

	NOT_PAD_B:

 	lda current_input
    sta last_frame_input

 	jmp mainloop


.proc redraw_current_page_T2
	jsr ppu_off
	; accessing VRAM is now safe

	jsr clear_nametable

	lda #$00
	sta zp_temp_0
	lda #>WRAM_START
	clc
	adc current_page
	sta zp_temp_1
	; zp_temp_0&1 hold start of current page in WRAM text

	jsr set_pointers_to_last_character_of_current_page
	; wram_text_ptr and text_index are now at the position we need to draw text until

	lda current_text_index
	sta zp_temp_2
	; zp_temp_2 now holds our target text_index

	lda #0
	sta current_text_index

	reset_current_nametable_ptr

	ldx #0
loop:
	lda PPU_STATUS
	lda current_nametable_ptr_hi
	sta PPU_ADDR
	lda current_nametable_ptr_lo
	sta PPU_ADDR

	ldy #0
	lda (zp_temp_0),y

	sta PPU_DATA

	cpx zp_temp_2
	beq endloop

	inc current_text_index
	jsr increment_nametable_ptr
	inc zp_temp_0 ; only need to increment low
	inx
	jmp loop

endloop:
	rts
.endproc


.proc type_current_key
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

	lda screen_keyboard_index
	sta (current_wram_text_ptr_lo), y

	jsr increment_nametable_ptr

	inc current_wram_text_ptr_lo
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
	beq	no_chars_at_all ; if text_index is 0, just take it; no characters on this page

	ldy #0
	lda (current_wram_text_ptr_lo), y
	bne non_empty_char_found ; if current_wram_text_ptr is not spacebar ($00), we found what we were looking for

	dec current_text_index
	dec current_wram_text_ptr_lo
	jmp first_empty_char_loop

no_chars_at_all:
	lda #0
	sta current_text_index
	lda #$FF
	sta current_wram_text_ptr_lo

non_empty_char_found:
	; decremented current_text_index & wram_text_ptr until first non-space was found

	inc current_wram_text_ptr_lo ; increment wram back by one so it's one ahead (-> it's the pointer to the next char)

	rts
.endproc
