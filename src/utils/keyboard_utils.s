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
		lda #$FF ; spacebar is treated as $FF so it's not the same as "no character"
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