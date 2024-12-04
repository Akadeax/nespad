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
	bcs :+
		clc
		adc #11
		sta screen_keyboard_index
		rts
	:
	;if its lower than 44, go to 44 and skip
	cmp #KEYBOARD_IDX_SPACEBAR
	bcs :+
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
	bcs :+
		clc
		adc #2
		sta screen_keyboard_index
		rts
	:
	;if its the line selection, try incrementing
	cmp #KEYBOARD_IDX_LINE_COUNTER
	bne :+
		jsr decrement_selected_line_T0
		jsr redraw_current_page_T2
		jsr draw_color_indicator_T5
		rts
	:
	cmp #KEYBOARD_IDX_COLOR_DISP
	bne :+
		jsr decrement_color_T0
		jsr redraw_current_page_T2
		rts
	:
	;if it is lower than symbol start, skip
	cmp #KEYBOARD_IDX_SYMBOL_START-1
	bne :+
		rts
	:
	;if it is lower than symbol end-9, add 9
	cmp #KEYBOARD_IDX_SYMBOL_END-9+1
	bcs :+
		clc
		adc #9
		sta screen_keyboard_index
		rts
	:
	rts 
.endproc

.proc handle_up_button_press
	lda screen_keyboard_index
	;if the current idx is lower than 12, skip
	cmp #KEYBOARD_IDX_A
	bcs :+
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
	bcs :+
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
	bcs :+
		sec
		sbc #2
		sta screen_keyboard_index
		rts
	:
	;if its the line selection, try incrementing
	cmp #KEYBOARD_IDX_LINE_COUNTER
	bne :+
		jsr increment_selected_line_T0
		jsr redraw_current_page_T2
		jsr draw_color_indicator_T5
		rts
	:
	cmp #KEYBOARD_IDX_COLOR_DISP
	bne :+
		jsr increment_color_T0
		jsr redraw_current_page_T2
		rts
	:
	;if its lower than 137, skip
	cmp #KEYBOARD_IDX_SYMBOL_START + 8 + 1
	bcs :+
		rts
	:
	;if its lower than 174, subtract by 9
	cmp #KEYBOARD_IDX_SYMBOL_END + 1
	bcs :+
		sec
		sbc #9
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
	;if its the end of the special keyboard skip
	cmp #KEYBOARD_IDX_SYMBOL_END
	bne :+
		rts
	:
	cmp #KEYBOARD_IDX_SYMBOL_END - 9
	bne :+
		rts
	:
	cmp #KEYBOARD_IDX_SYMBOL_END - 18
	bne :+
		rts
	:
	cmp #KEYBOARD_IDX_SYMBOL_END - 27
	bne :+
		rts
	:
	cmp #KEYBOARD_IDX_SYMBOL_END - 36
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
	;if you are on the color disp, go to the start of the middle line
	cmp #KEYBOARD_IDX_COLOR_DISP
	bne :+
		lda #KEYBOARD_IDX_SYMBOL_START + 18
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
	;if its the line indicator skip
	cmp #KEYBOARD_IDX_LINE_COUNTER
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
	;if its any of the left most symbols on the special keyboard, go to color input
	cmp #KEYBOARD_IDX_SYMBOL_START
	bne :+
		lda #KEYBOARD_IDX_COLOR_DISP
		sta screen_keyboard_index
		rts
	:
	cmp #KEYBOARD_IDX_SYMBOL_START + 9
	bne :+
		lda #KEYBOARD_IDX_COLOR_DISP
		sta screen_keyboard_index
		rts
	:
	cmp #KEYBOARD_IDX_SYMBOL_START + 18
	bne :+
		lda #KEYBOARD_IDX_COLOR_DISP
		sta screen_keyboard_index
		rts
	:
	cmp #KEYBOARD_IDX_SYMBOL_START + 27
	bne :+
		lda #KEYBOARD_IDX_COLOR_DISP
		sta screen_keyboard_index
		rts
	:
	cmp #KEYBOARD_IDX_SYMBOL_START + 36
	bne :+
		lda #KEYBOARD_IDX_COLOR_DISP
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
	cmp #KEYBOARD_IDX_SYMBOL_START
	bcc :+
		jsr type_letter_key
		jsr redraw_pointer
		jmp end_func
	:

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
	lda notepad_state
	and #%00000011 ; only care about the last 2 bits
	cmp #KEYBOARD_INFO_ITALIC ; check if current text mode is italic
	bne current_not_italic
		; current text mode is italic already; disable it
		lda notepad_state
		and #%11111100
		sta notepad_state
		jmp end_func

 current_not_italic:
	; current text mode is not italic yet; set it to it
	lda notepad_state
	and #%11111100 ; clear last 2 bits (otherwise it might not override e.g. 11)
	ora #KEYBOARD_INFO_ITALIC ; set the last 2 bits to italic
	sta notepad_state

 end_func:
	rts
.endproc



.proc bold_pressed
	lda notepad_state
	and #%00000011 ; only care about the last 2 bits
	cmp #KEYBOARD_INFO_BOLD ; check if current text mode is bold
	bne current_not_bold
		; current text mode is bold already; disable it
		lda notepad_state
		and #%11111100
		sta notepad_state
		jmp end_func

 current_not_bold:
	; current text mode is not bold yet; set it to it
	lda notepad_state
	and #%11111100 ; clear last 2 bits (otherwise it might not override e.g. 11)
	ora #KEYBOARD_INFO_BOLD ; set the last 2 bits to bold
	sta notepad_state

 end_func:
	rts
.endproc


.proc capital_pressed
	lda notepad_state
	and #%00000100
	beq current_not_capital
		; capital mode is currently already on; disable it
		lda notepad_state
		and #%11111011 ; unset 3rd bit
		sta notepad_state
		jmp end_func

 current_not_capital:
	lda notepad_state
	ora #%00000100 ; set 3rd bit
	sta notepad_state

 end_func:
	rts
.endproc

.proc select_pressed
	lda notepad_state
	eor #%00001000
	sta notepad_state
	and #%00001000
	beq :+
		jsr draw_color_indicator_T5
		lda #128
		jmp :++
	:
		jsr clear_color_indicator
		lda #0
	:
	sta screen_keyboard_index
	jsr redraw_current_page_T2 
	jsr draw_indicator_T1
	rts
.endproc