.proc keyboard_idx_to_pattern_idx_T1 ;outputs to the A register
	lda screen_keyboard_index
	cmp #127
	bcc :+
		jsr symbol_keyboard_idx_to_pattern_idx
		rts
	:
	sta zp_temp_0
 ;check if keyboardIdx is 11-18, 22-30, 33-41
	ldx #10
	cpx zp_temp_0
	bpl betweenJmp ;check if temp_1 is smaller than 11
	ldx #18
	cpx zp_temp_0
	bmi :++ ;check if temp_1 is 18 or smaller
		clc
		adc #7 ; add the amount of special characters left to come
		sta zp_temp_1 ; store a in temp to do binary logic
		lda notepad_state
		and #%00000100 ; check if the capitilisation bit is set
		beq :+
			lda zp_temp_1
			clc
			adc #26
			sta zp_temp_1
		:
		lda zp_temp_1
		jmp endProc
 :
	;check if keyboardIdx = 19-21
	ldx #21
	cpx zp_temp_0
	bmi :+ ;check if temp_1 is 21 or smaller
		clc
		sbc #7 ;remove the letters that have already been on the keyboard
		jmp endProc
 :
	jmp skipJmp
 betweenJmp: ;error range error mimimimimimimi
	jmp endProc
 skipJmp:
	;check if a = 22-30
	ldx #30
	cpx zp_temp_0
	bmi :++ ;check if temp_1 is 30 or smaller
		clc
		adc #4 ; add the amount of special characters left to come
		sta zp_temp_1 ; store a in temp to do binary logic
		lda notepad_state
		and #%00000100 ; check if the capitilisation bit is set
		beq :+
			lda zp_temp_1
			clc
			adc #26
			sta zp_temp_1
		:
		lda zp_temp_1
		jmp endProc
 :
	;check if keyboardIdx = 31-32
	ldx #32
	cpx zp_temp_0
	bmi :+ ;check if temp_1 is 21 or smaller
		clc
		sbc #16 ;remove the letters that have already been on the keyboard
		jmp endProc
 :
	;check if a = 33-41
	ldx #41
	cpx zp_temp_0
	bmi :++ ;check if temp_1 is 30 or smaller
		clc
		adc #2 ; add the amount of special characters left to come
		sta zp_temp_1 ; store a in temp to do binary logic
		lda notepad_state
		and #%00000100 ; check if the capitilisation bit is set
		beq :+
			lda zp_temp_1
			clc
			adc #26
			sta zp_temp_1
		:
		lda zp_temp_1
		jmp endProc
 :
	;check if keyboardIdx = 42-43
	ldx #43
	cpx zp_temp_0
	bmi :+ ;check if temp_1 is 21 or smaller
		clc
		sbc #25 ;remove the letters that have already been on the keyboard
		jmp endProc
 :
	ldx #44
	cpx zp_temp_0
	bne :+ ;if keyboardIdx = 44(spaceBar)
		lda #SPACEBAR_SUBSTITUTE ; spacebar is treated as $FF so it's not the same as "no character"
		rts
 :
	;space for code for the special characters i guess, didnt know how to incorporate it with the current layout
 endProc:
	clc
	adc #1 ;offset for the empty character
	;add current text type offset(first 2 bits of TextInfo)
	sta zp_temp_1 ;store a in zp_temp_1 for bitwise logic
	lda notepad_state
	and #%00000011
	cmp #KEYBOARD_INFO_BOLD
	bne :+ ; if its bold
		lda zp_temp_1
		clc
		adc #70
		rts
 :
	cmp #KEYBOARD_INFO_ITALIC
	bne :+ ;if its italic
		lda zp_temp_1
		clc
		adc #140
		rts
 :
	lda zp_temp_1
	rts
.endproc

.proc symbol_keyboard_idx_to_pattern_idx
	lda screen_keyboard_index
	cmp #KEYBOARD_IDX_LINE_COUNTER
	bne :+
		lda #0
		rts
	:
	cmp #KEYBOARD_IDX_COLOR_DISP
	bne :+
		lda #0
		rts
	:
	cmp #KEYBOARD_IDX_ITALIC_SYMBOL
	bne :+
		lda #$C1 ;capitalized I in italic font 
		rts
	:
	sec
	sbc #130
	clc
	adc #211
	rts
.endproc

.proc keyboard_idx_to_nametable_pos_T2 ;assumes A is keyboard index returns via lo byte zp_temp_1 and hi byte zp_temp_2
	lda screen_keyboard_index
	cmp #127
	bcc :+
		jsr symbol_keyboard_idx_to_nametable_pos_T2
		rts
	:
	sta zp_temp_0
	lda #<KEYBOARD_NAMETABLE_BEGIN_OFFSET
	sta zp_temp_1
	lda #>KEYBOARD_NAMETABLE_BEGIN_OFFSET
	sta zp_temp_2
	; every standard key is offset by 2, so add the keyboard index multiplied by 2
	increment_zp_16 zp_temp_0, zp_temp_1, zp_temp_2
	increment_zp_16 zp_temp_0, zp_temp_1, zp_temp_2
	;if zp_temp_0 is greater than 10, add offset
	lda #10
	cmp zp_temp_0
	bpl endProc
		increment_zp_16 #KEYBOARD_NAMETABLE_NEXTLINE_OFFSET, zp_temp_1, zp_temp_2
		;if zp_temp_0 is greater than 21, add offset
		lda #21
		cmp zp_temp_0
		bpl endProc
			increment_zp_16 #KEYBOARD_NAMETABLE_NEXTLINE_OFFSET, zp_temp_1, zp_temp_2
			;if zp_temp_0 is greater than 32, add offset
			lda #32
			cmp zp_temp_0
			bpl endProc
				increment_zp_16 #KEYBOARD_NAMETABLE_NEXTLINE_OFFSET, zp_temp_1, zp_temp_2
				jmp endProc
 endProc:
	lda #KEYBOARD_IDX_SPACEBAR
	cmp zp_temp_0
	bne :+
		lda #<KEYBOARD_NAMETABLE_SPACEBAR_POS_OFFSET
		sta zp_temp_1
		lda #>KEYBOARD_NAMETABLE_SPACEBAR_POS_OFFSET
		sta zp_temp_2
		rts
 :
	lda #KEYBOARD_IDX_SHIFT
	cmp zp_temp_0
	bne :+
		lda #<KEYBOARD_NAMETABLE_SHIFT_POS_OFFSET
		sta zp_temp_1
		lda #>KEYBOARD_NAMETABLE_SHIFT_POS_OFFSET
		sta zp_temp_2
		rts
 :
	lda #KEYBOARD_IDX_BOLD
	cmp zp_temp_0
	bne :+
		lda #<KEYBOARD_NAMETABLE_BOLD_POS_OFFSET
		sta zp_temp_1
		lda #>KEYBOARD_NAMETABLE_BOLD_POS_OFFSET
		sta zp_temp_2
		rts
 :
	lda #KEYBOARD_IDX_ITALIC
	cmp zp_temp_0
	bne :+
		lda #<KEYBOARD_NAMETABLE_ITALIC_POS_OFFSET
		sta zp_temp_1
		lda #>KEYBOARD_NAMETABLE_ITALIC_POS_OFFSET
		sta zp_temp_2
		rts
 :
	lda #KEYBOARD_IDX_NEXT_PAGE
	cmp zp_temp_0
	bne :+
		lda #<KEYBOARD_NAMETABLE_NEXT_PAGE_POS_OFFSET
		sta zp_temp_1
		lda #>KEYBOARD_NAMETABLE_NEXT_PAGE_POS_OFFSET
		sta zp_temp_2
		rts
 :
	lda #KEYBOARD_IDX_PREV_PAGE
	cmp zp_temp_0
	bne :+
		lda #<KEYBOARD_NAMETABLE_PREV_PAGE_POS_OFFSET
		sta zp_temp_1
		lda #>KEYBOARD_NAMETABLE_PREV_PAGE_POS_OFFSET
		sta zp_temp_2
		rts
 :
	rts
.endproc

.proc symbol_keyboard_idx_to_nametable_pos_T2
	lda screen_keyboard_index
	sec
	sbc #130
	sta zp_temp_0
	lda #<SPECIAL_KEYBOARD_NAMETABLE_BEGIN_OFFSET
	sta zp_temp_1
	lda #>SPECIAL_KEYBOARD_NAMETABLE_BEGIN_OFFSET
	sta zp_temp_2

	increment_zp_16 zp_temp_0, zp_temp_1, zp_temp_2
	increment_zp_16 zp_temp_0, zp_temp_1, zp_temp_2
		;if zp_temp_0 is greater than 10, add offset
	lda #8
	cmp zp_temp_0
	bpl endProc
		increment_zp_16 #SPECIAL_KEYBOARD_NAMETABLE_NEXTLINE_OFFSET, zp_temp_1, zp_temp_2
		;if zp_temp_0 is greater than 21, add offset
		lda #17
		cmp zp_temp_0
		bpl endProc
			increment_zp_16 #SPECIAL_KEYBOARD_NAMETABLE_NEXTLINE_OFFSET, zp_temp_1, zp_temp_2
			;if zp_temp_0 is greater than 32, add offset
			lda #26
			cmp zp_temp_0
			bpl endProc
				increment_zp_16 #SPECIAL_KEYBOARD_NAMETABLE_NEXTLINE_OFFSET, zp_temp_1, zp_temp_2
					lda #35
					cmp zp_temp_0
					bpl endProc
						increment_zp_16 #SPECIAL_KEYBOARD_NAMETABLE_NEXTLINE_OFFSET, zp_temp_1, zp_temp_2
						jmp endProc
	endProc:
		lda screen_keyboard_index
		cmp #KEYBOARD_IDX_LINE_COUNTER
		bne :+
			lda #<SPECIAL_KEYBOARD_NAMETABLE_LINE_DISP_OFFSET
			sta zp_temp_1
			lda #>SPECIAL_KEYBOARD_NAMETABLE_LINE_DISP_OFFSET
			sta zp_temp_2
			rts
	:
		cmp #KEYBOARD_IDX_COLOR_DISP
		bne :+
			lda #<SPECIAL_KEYBOARD_NAMETABLE_COLOR_OFFSET
			sta zp_temp_1
			lda #>SPECIAL_KEYBOARD_NAMETABLE_COLOR_OFFSET
			sta zp_temp_2
			rts
	:
	rts
.endproc

.proc get_selected_line_T0
	lda notepad_state
	and #%11110000
	lsr
	lsr
	lsr
	lsr
	sta zp_temp_0
	rts
.endproc

.proc increment_selected_line_T0
	jsr get_selected_line_T0
	lda #8
	cmp zp_temp_0
	beq endProc
	inc zp_temp_0
	lda zp_temp_0
	asl
	asl
	asl
	asl
	sta zp_temp_0
	lda notepad_state
	and #%00001111
	ora zp_temp_0
	sta notepad_state
 endProc:
	rts
.endproc

.proc decrement_selected_line_T0
	jsr get_selected_line_T0
	lda #0
	cmp zp_temp_0
	beq endProc
	dec zp_temp_0
	lda zp_temp_0
	asl
	asl
	asl
	asl
	sta zp_temp_0
	lda notepad_state
	and #%00001111
	ora zp_temp_0
	sta notepad_state
 endProc:
	rts
.endproc

.proc get_color_from_selected_line_T2 ;LINTEXCLUDE
	jsr get_selected_line_T0

	jsr get_color_from_line_T2
	rts
.endproc

.proc get_color_from_line_T2 ;takes zp_temp_0 as input of line
	lda #4-1;is the color in the first byte
	cmp zp_temp_0
	bcc :+++
		lda current_wram_text_ptr_hi
		sta zp_temp_2
		lda #252
		sta zp_temp_1
		ldy #0
		lda (zp_temp_1),y
		ldx zp_temp_0
		beq :++
		:
			lsr
			lsr 
			dex
			cpx #0
			bne :-
		:
		and #%00000011
		jmp endProc
	:
	lda #8-1; is the color in the second byte
	cmp zp_temp_0
	bcc :+++
		dec zp_temp_0
		dec zp_temp_0
		dec zp_temp_0
		dec zp_temp_0
		lda current_wram_text_ptr_hi
		sta zp_temp_2
		lda #253
		sta zp_temp_1
		ldy #0
		lda (zp_temp_1),y
		ldx zp_temp_0
		beq :++
		:
			lsr
			lsr 
			dex
			cpx #0
			bne :-
		:
		and #%00000011
		jmp endProc
	:
	lda current_wram_text_ptr_hi
	sta zp_temp_2
	lda #254
	sta zp_temp_1
	ldy #0
	lda (zp_temp_1),y
	and #%00000011
	endProc:
	sta zp_temp_0
	rts
.endproc

.proc set_color_from_selected_line_T4 ;LINTEXCLUDE
	lda zp_temp_0
	sta zp_temp_1
	jsr get_selected_line_T0
	jsr set_color_from_line_T4
	rts
.endproc

.proc set_color_from_line_T4
	lda zp_temp_0 ; line you are writing to
	sta zp_temp_3
	lda zp_temp_1 ;color ur writing
	sta zp_temp_0
	lda #%11111100 ; binary and helper
	sta zp_temp_4
	lda #4-1;is the color in the first byte(-1 for > instead of >=)
	cmp zp_temp_3
	bcc :+++
		ldx zp_temp_3
		beq :++
		:
			lda zp_temp_0
			asl
			asl
			sta zp_temp_0 
			lda zp_temp_4
			sec
			rol
			rol
			sta zp_temp_4
			dex
			cpx #0
			bne :-
		:
		lda current_wram_text_ptr_hi
		sta zp_temp_2
		lda #252
		sta zp_temp_1
		ldy #0
		lda (zp_temp_1),y
		and zp_temp_4
		eor zp_temp_0
		sta (zp_temp_1),y
		rts
	:
	lda #8-1; is the color in the second byte(-1 for > instead of >=)
	cmp zp_temp_3
	bcc endProc
		dec zp_temp_3
		dec zp_temp_3
		dec zp_temp_3
		dec zp_temp_3
		ldx zp_temp_3
		beq :++
		:
			lda zp_temp_0
			asl
			asl
			sta zp_temp_0 
			lda zp_temp_4
			sec
			rol
			rol
			sta zp_temp_4
			dex
			cpx #0
			bne :-
		:
		lda current_wram_text_ptr_hi
		sta zp_temp_2
		lda #253
		sta zp_temp_1
		ldy #0
		lda (zp_temp_1),y
		and zp_temp_4
		eor zp_temp_0
		sta (zp_temp_1),y
		rts
	endProc:
	lda current_wram_text_ptr_hi
	sta zp_temp_2
	lda #254
	sta zp_temp_1
	ldy #0
	lda (zp_temp_1),y
	and zp_temp_4
	eor zp_temp_0
	sta (zp_temp_1),y
	rts

.endproc
.proc increment_color_T0
	jsr get_color_from_selected_line_T2
	lda zp_temp_0
	cmp #3
	beq max
		inc zp_temp_0
		jmp endProc	
	max:
	lda #0
	sta zp_temp_0
	endProc:
	jsr set_color_from_selected_line_T4
	jsr draw_color_indicator_T5
	rts
.endproc 

.proc decrement_color_T0
	jsr get_color_from_selected_line_T2
	lda zp_temp_0
	beq min
		dec zp_temp_0
		jmp endProc	
	min:
	lda #3
	sta zp_temp_0
	endProc:
	jsr set_color_from_selected_line_T4
	jsr draw_color_indicator_T5
	rts
.endproc 