.macro poll_gamepad OutAddr
	; strobe the gamepad to latch current button state
	lda #1
	sta JOYPAD1
	lda #0
	sta JOYPAD1
	; read 8 bytes from the interface at $4016
	ldx #8
poll_loop:
	pha
	lda JOYPAD1
	; combine low two bits and store in carry bit
	and #%00000011
	cmp #%00000001
	pla
	; rotate carry into gamepad variable
	ror
	dex
	bne poll_loop

	sta OutAddr
.endmacro

.proc handle_down_button_press
	lda screen_keyboard_index
	;if the idx is lower than  33, add 11 and skip
	cmp #KEYBOARD_IDX_R
	bpl :+
		clc
		adc #11
		sta screen_keyboard_index
		rts
	:
	;if its lower than 44, go to 44 and skip
	cmp #KEYBOARD_IDX_SPACEBAR
	bpl :+
		lda #KEYBOARD_IDX_SPACEBAR
		sta screen_keyboard_index
		rts
	:
	;if its 44, skip
	cmp #KEYBOARD_IDX_SPACEBAR
	bne :+
		rts
	:
	;if its 48, skip
	cmp #KEYBOARD_IDX_PREV_PAGE
	bne :+
		rts
	:
	;if its 49, skip
	cmp #KEYBOARD_IDX_SHIFT
	bne :+
		rts
	:
	;if its lower than 48, add 2 and skip
	cmp #KEYBOARD_IDX_PREV_PAGE
	bpl :+
		clc
		adc #2
		sta screen_keyboard_index
		rts
	:
	rts
.endproc

.proc handle_up_button_press
	lda screen_keyboard_index
	;if the current idx is lower than 12, skip
	cmp #KEYBOARD_IDX_A
	bpl :+
		rts
	:
	;if the current idx is 45 skip
	cmp #KEYBOARD_IDX_ITALIC
	bne :+
		rts
	:
	;if the current idx is 46 skip
	cmp #KEYBOARD_IDX_NEXT_PAGE
	bne :+
		rts
	:
	;if its lower than 44 subtract by 11, then skip
	cmp #KEYBOARD_IDX_UNDERSCORE+1
	bpl :+
		clc
		sbc #10
		sta screen_keyboard_index
		rts
	:
	;if its 44, make it 40 then skip
	cmp #KEYBOARD_IDX_SPACEBAR
	bne :+
		lda #38
		sta screen_keyboard_index
		rts
	:
	;if its lower than 49, subtract by 2
	cmp #KEYBOARD_IDX_SHIFT + 1
	bpl :+
		sec
		sbc #2
		sta screen_keyboard_index
		rts
	:
	rts
.endproc

.proc handle_right_button_press
	;if current idx is 44, skip
	lda screen_keyboard_index
	cmp #KEYBOARD_IDX_SPACEBAR
	bne :+
		rts
	:
	;if its 48, skip
	cmp #KEYBOARD_IDX_NEXT_PAGE
	bne :+
		rts
	:
	;if its 46, skip
	cmp #KEYBOARD_IDX_PREV_PAGE
	bne :+
		rts
	:
	;special cases for control characters 

	;if its 10, go to 45, then skip
	cmp #KEYBOARD_IDX_EXCLAMATION
	bne :+
		lda #KEYBOARD_IDX_ITALIC
		sta screen_keyboard_index
		rts
	:
	;if its 21, go to 47, then skip
	cmp #KEYBOARD_IDX_PERIOD
	bne :+
		lda #KEYBOARD_IDX_BOLD
		sta screen_keyboard_index
		rts
	:
	;if its 32, go to 49, then skip
	cmp #KEYBOARD_IDX_COLON
	bne :+
		lda #KEYBOARD_IDX_SHIFT
		sta screen_keyboard_index
		rts
	:
	;if its 43, go to 49, then skip
	cmp #KEYBOARD_IDX_UNDERSCORE
	bne :+
		lda #KEYBOARD_IDX_SHIFT
		sta screen_keyboard_index
		rts
	:

	;if its 45, go to 46, then skip
	cmp #KEYBOARD_IDX_ITALIC
	bne :+
		lda #KEYBOARD_IDX_NEXT_PAGE
		sta screen_keyboard_index
		rts
	:
	;if its 47, go to 48, then skip
	cmp #KEYBOARD_IDX_BOLD
	bne :+
		lda #KEYBOARD_IDX_PREV_PAGE
		sta screen_keyboard_index
		rts
	:
	;if its 49, go to 48, then skip
	cmp #KEYBOARD_IDX_SHIFT
	bne :+
		lda #KEYBOARD_IDX_PREV_PAGE
		sta screen_keyboard_index
		rts
	:

	;otherwise, increase it by 1, and skip
	tax
	inx
	txa
	sta screen_keyboard_index
	rts
.endproc

.proc handle_left_button_press
	;if current idx is 44, skip
	lda screen_keyboard_index
	cmp #KEYBOARD_IDX_SPACEBAR
	bne :+
		rts
	:
	;if its 0, skip
	cmp #KEYBOARD_IDX_0
	bne :+
		rts
	:
	;if its 11, skip
	cmp #KEYBOARD_IDX_A
	bne :+
		rts
	:
	;if its 22, skip
	cmp #KEYBOARD_IDX_I
	bne :+
		rts
	:
	;if its 33, skip
	cmp #KEYBOARD_IDX_R
	bne :+
		rts
	:

	;special cases for control characters 

	;if its 45, go to 21, then skip
	cmp #KEYBOARD_IDX_ITALIC
	bne :+
		lda #KEYBOARD_IDX_PERIOD
		sta screen_keyboard_index
		rts
	:
	;if its 47, go to 32, then skip
	cmp #KEYBOARD_IDX_BOLD
	bne :+
		lda #KEYBOARD_IDX_COLON
		sta screen_keyboard_index
		rts
	:
	;if its 49, go to 43, then skip
	cmp #KEYBOARD_IDX_SHIFT
	bne :+
		lda #KEYBOARD_IDX_UNDERSCORE
		sta screen_keyboard_index
		rts
	:

	;if its 46, go to 45, then skip
	cmp #KEYBOARD_IDX_NEXT_PAGE
	bne :+
		lda #KEYBOARD_IDX_ITALIC
		sta screen_keyboard_index
		rts
	:
	;if its 48, go to 49, then skip
	cmp #KEYBOARD_IDX_PREV_PAGE
	bne :+
		lda #KEYBOARD_IDX_SHIFT
		sta screen_keyboard_index
		rts
	:
	;otherwise, decrease it by 1
	tax
	dex
	txa
	sta screen_keyboard_index
	rts
.endproc

.proc activate_selected_key
	lda screen_keyboard_index
	cmp #(KEYBOARD_CHARACTER_KEY_AMOUNT + 1) ; +1 because spacebar is also accounted for as letter key
	bpl not_letter_key
		; keyboard index is on letter key
		jsr type_letter_key
		jsr redraw_pointer
		jmp end_func
not_letter_key:

	jsr special_key_pressed

end_func:
	rts
.endproc

.proc special_key_pressed
	lda screen_keyboard_index
	cmp #KEYBOARD_IDX_ITALIC
	bne not_italic
		jsr italic_pressed
		jmp redraw
not_italic:

	lda screen_keyboard_index
	cmp #KEYBOARD_IDX_BOLD
	bne not_bold
		jsr bold_pressed
		jmp redraw
not_bold:

	lda screen_keyboard_index
	cmp #KEYBOARD_IDX_SHIFT
	bne not_capital
		jsr capital_pressed
		jmp redraw
not_capital:

	lda screen_keyboard_index
	cmp #KEYBOARD_IDX_NEXT_PAGE
	bne not_next_page
		; next page pressed
		lda current_page
		cmp #(MAX_PAGE_AMOUNT - 1)
		beq end_func ; if we're at the last page, don't inc or redraw

		inc current_page
		jmp redraw
not_next_page:

	lda screen_keyboard_index
	cmp #KEYBOARD_IDX_PREV_PAGE
	bne not_prev_page
		; prev page pressed
		lda current_page
		beq end_func ; if we're at first page, don't dec or redraw

		dec current_page
		jmp redraw
not_prev_page:

redraw:
	jsr redraw_current_page_T2
end_func:
	rts
.endproc


.proc italic_pressed
	lda zp_text_info
	and #%00000011 ; only care about the last 2 bits
	cmp #KEYBOARD_INFO_ITALIC ; check if current text mode is italic
	bne current_not_italic
		; current text mode is italic already; disable it
		lda zp_text_info
		and #%11111100
		sta zp_text_info
		jmp end_func

current_not_italic:
	; current text mode is not italic yet; set it to it
	lda zp_text_info
	and #%11111100 ; clear last 2 bits (otherwise it might not override e.g. 11)
	ora #KEYBOARD_INFO_ITALIC ; set the last 2 bits to italic
	sta zp_text_info

end_func:
	rts
.endproc



.proc bold_pressed
	lda zp_text_info
	and #%00000011 ; only care about the last 2 bits
	cmp #KEYBOARD_INFO_BOLD ; check if current text mode is bold
	bne current_not_bold
		; current text mode is bold already; disable it
		lda zp_text_info
		and #%11111100
		sta zp_text_info
		jmp end_func

current_not_bold:
	; current text mode is not bold yet; set it to it
	lda zp_text_info
	and #%11111100 ; clear last 2 bits (otherwise it might not override e.g. 11)
	ora #KEYBOARD_INFO_BOLD ; set the last 2 bits to bold
	sta zp_text_info

end_func:
	rts
.endproc



.proc capital_pressed
	lda zp_text_info
	and #%00000100
	beq current_not_capital
		; capital mode is currently already on; disable it
		lda zp_text_info
		and #%11111011 ; unset 3rd bit
		sta zp_text_info
		jmp end_func

current_not_capital:
	lda zp_text_info
	ora #%00000100 ; set 3rd bit
	sta zp_text_info

end_func:
	rts
.endproc