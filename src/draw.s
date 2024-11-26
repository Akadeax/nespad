.proc redraw_current_page_T2
	jsr ppu_off
	; accessing VRAM is now safe

	jsr redraw_screen

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

	; if the nametable_ptr after incrementing is $2283, we are at the end of the current page.
	; don't draw any further to not override the decoration, and correct the nametable ptr manually
	lda current_nametable_ptr_hi
	cmp #>$2282 ; $2283 is the wrong last character position
	bne not_last
	lda current_nametable_ptr_lo
	cmp #<$2282
	bne not_last
		; nametable_ptr is $2283
		lda #$5D ; $225E is the correct last character position
		sta current_nametable_ptr_lo
		jmp endloop

not_last:

	inc zp_temp_0 ; only need to increment low
	inx
	jmp loop

endloop:

	lda current_text_index
	beq first

	inc current_text_index
	jsr increment_nametable_ptr
first:

	lda #0
	sta zp_temp_0
	lda current_wram_text_ptr_hi
	sta zp_temp_1



	ldy #0
	lda (zp_temp_0),y
	beq end
		lda current_text_index
		bne end
			inc current_text_index
			jsr increment_nametable_ptr
			inc current_wram_text_ptr_lo
		
end:
	rts
.endproc

.proc type_current_key
	lda current_text_index
	cmp #PAGE_TEXT_SIZE
	bne :+
	rts
:
	cmp #(PAGE_TEXT_SIZE + 1)
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

.proc draw_indicator_T1
	jsr clear_indicator_T1
	jsr keyboard_idx_to_nametable_pos_T2
	jsr convert_nametable_index_to_XY_T2
	lda KEYBOARD_IDX_NEXT_PAGE
	cpx #screen_keyboard_index
	bne :+ 
		jsr draw_spacebar_Indicator
		jmp endProc
:
	lda KEYBOARD_IDX_SPACEBAR
	cpx #screen_keyboard_index
	bne :+ 
		jsr draw_arrow_indicator
		jmp endProc
:
	lda KEYBOARD_IDX_PREV_PAGE
	cpx #screen_keyboard_index
	bne :+ 
		jsr draw_arrow_indicator
		jmp endProc
:
	lda zp_temp_0
	sta CPU_OAM_PTR
	ldy #1
	lda #$08 ;basic sprite
	sta CPU_OAM_PTR, y
	ldy #3
	lda zp_temp_1
	sta CPU_OAM_PTR, y

endProc:
	rts
.endproc

.proc draw_spacebar_Indicator

	rts
.endproc

.proc draw_arrow_indicator

	rts
.endproc

.proc clear_indicator_T1
	
	ldy #0
	lda #<CPU_OAM_PTR
	sta zp_temp_0
	lda #>CPU_OAM_PTR
	sta zp_temp_1
	lda #0
	clear_loop:
		sta (zp_temp_0), y
		iny
		cpy #20
		bne clear_loop
	rts
.endproc