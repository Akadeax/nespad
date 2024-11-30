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
	jsr redraw_pointer
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



.proc type_letter_key
	lda current_text_index
	cmp #PAGE_TEXT_SIZE
	bne :+
	rts
:
	cmp #(PAGE_TEXT_SIZE + 1)
	bne :+
	rts
:
	jsr keyboard_idx_to_pattern_idx_T1
	ldy #0
	sta (current_wram_text_ptr_lo), y

	jsr increment_nametable_ptr

	inc current_wram_text_ptr_lo
	inc current_text_index

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



.proc draw_indicator_T1 ;LINTEXCLUDE
	jsr clear_indicator_T1
	jsr keyboard_idx_to_nametable_pos_T2
	jsr convert_nametable_index_to_XY_T2
	lda #KEYBOARD_IDX_SPACEBAR
	cmp screen_keyboard_index
	bne :+ 
		jsr draw_spacebar_Indicator
		rts
:
	lda #KEYBOARD_IDX_NEXT_PAGE
	cmp screen_keyboard_index
	bne :+ 
		jsr draw_arrow_indicator
		rts
:
	lda #KEYBOARD_IDX_PREV_PAGE
	cmp screen_keyboard_index
	bne :+ 
		jsr draw_arrow_indicator
		rts
:
	
	;	x var,x offset, is x subtracting, y var, y offset, is y subtracting, sprite, index
	draw_sprite_at_location_T2 zp_temp_0 ,#07 ,#01 ,zp_temp_1 ,#07 ,#00 ,#$06 ,#8
	draw_sprite_at_location_T2 zp_temp_0 ,#07 ,#01 ,zp_temp_1 ,#00 ,#01 ,#$04 ,#1
	draw_sprite_at_location_T2 zp_temp_0 ,#07 ,#01 ,zp_temp_1 ,#08 ,#01 ,#$01 ,#2
	draw_sprite_at_location_T2 zp_temp_0 ,#00 ,#00 ,zp_temp_1 ,#08 ,#01 ,#$02 ,#3
	draw_sprite_at_location_T2 zp_temp_0 ,#08 ,#00 ,zp_temp_1 ,#08 ,#01 ,#$03 ,#4
	draw_sprite_at_location_T2 zp_temp_0 ,#00 ,#00 ,zp_temp_1 ,#07 ,#00 ,#$07 ,#5
	draw_sprite_at_location_T2 zp_temp_0 ,#08 ,#00 ,zp_temp_1 ,#07 ,#00 ,#$08 ,#6
	draw_sprite_at_location_T2 zp_temp_0 ,#08 ,#00 ,zp_temp_1 ,#00 ,#01 ,#$05 ,#7

endProc:
	rts
.endproc



.proc draw_spacebar_Indicator ;LINTEXCLUDE
	;	x var,x offset, is x subtracting, y var, y offset, is y subtracting, sprite, index
	draw_sprite_at_location_T2 zp_temp_0 ,#07 ,#01 ,zp_temp_1 ,#07 ,#00 ,#$06 ,#18
	draw_sprite_at_location_T2 zp_temp_0 ,#07 ,#01 ,zp_temp_1 ,#00 ,#01 ,#$04 ,#1
	draw_sprite_at_location_T2 zp_temp_0 ,#07 ,#01 ,zp_temp_1 ,#08 ,#01 ,#$01 ,#2
	draw_sprite_at_location_T2 zp_temp_0 ,#72 ,#00 ,zp_temp_1 ,#08 ,#01 ,#$03 ,#4
	draw_sprite_at_location_T2 zp_temp_0 ,#72 ,#00 ,zp_temp_1 ,#07 ,#00 ,#$08 ,#6
	draw_sprite_at_location_T2 zp_temp_0 ,#72 ,#00 ,zp_temp_1 ,#00 ,#01 ,#$05 ,#7

	draw_sprite_at_location_T2 zp_temp_0 ,#00 ,#00 ,zp_temp_1 ,#08 ,#01 ,#$02 ,#3
	draw_sprite_at_location_T2 zp_temp_0 ,#00 ,#00 ,zp_temp_1 ,#07 ,#00 ,#$07 ,#5
	draw_sprite_at_location_T2 zp_temp_0 ,#08 ,#00 ,zp_temp_1 ,#08 ,#01 ,#$02 ,#8
	draw_sprite_at_location_T2 zp_temp_0 ,#08 ,#00 ,zp_temp_1 ,#07 ,#00 ,#$07 ,#9
	draw_sprite_at_location_T2 zp_temp_0 ,#16 ,#00 ,zp_temp_1 ,#08 ,#01 ,#$02 ,#10
	draw_sprite_at_location_T2 zp_temp_0 ,#16 ,#00 ,zp_temp_1 ,#07 ,#00 ,#$07 ,#11
	draw_sprite_at_location_T2 zp_temp_0 ,#48 ,#00 ,zp_temp_1 ,#08 ,#01 ,#$02 ,#12
	draw_sprite_at_location_T2 zp_temp_0 ,#48 ,#00 ,zp_temp_1 ,#07 ,#00 ,#$07 ,#13
	draw_sprite_at_location_T2 zp_temp_0 ,#56 ,#00 ,zp_temp_1 ,#08 ,#01 ,#$02 ,#14
	draw_sprite_at_location_T2 zp_temp_0 ,#56 ,#00 ,zp_temp_1 ,#07 ,#00 ,#$07 ,#15
	draw_sprite_at_location_T2 zp_temp_0 ,#64 ,#00 ,zp_temp_1 ,#08 ,#01 ,#$02 ,#16
	draw_sprite_at_location_T2 zp_temp_0 ,#64 ,#00 ,zp_temp_1 ,#07 ,#00 ,#$07 ,#17
	rts
.endproc



.proc draw_arrow_indicator ;LINTEXCLUDE
	;	x var,x offset, is x subtracting, y var, y offset, is y subtracting, sprite, index
	draw_sprite_at_location_T2 zp_temp_0 ,#07 ,#01 ,zp_temp_1 ,#07 ,#00 ,#$06 ,#12
	draw_sprite_at_location_T2 zp_temp_0 ,#07 ,#01 ,zp_temp_1 ,#16 ,#01 ,#$01 ,#11
	draw_sprite_at_location_T2 zp_temp_0 ,#16 ,#00 ,zp_temp_1 ,#16 ,#01 ,#$03 ,#10
	draw_sprite_at_location_T2 zp_temp_0 ,#07 ,#01 ,zp_temp_1 ,#00 ,#01 ,#$04 ,#1
	draw_sprite_at_location_T2 zp_temp_0 ,#07 ,#01 ,zp_temp_1 ,#08 ,#01 ,#$04 ,#2
	draw_sprite_at_location_T2 zp_temp_0 ,#00 ,#00 ,zp_temp_1 ,#16 ,#01 ,#$02 ,#3
	draw_sprite_at_location_T2 zp_temp_0 ,#08 ,#00 ,zp_temp_1 ,#16 ,#01 ,#$02 ,#9
	draw_sprite_at_location_T2 zp_temp_0 ,#00 ,#00 ,zp_temp_1 ,#07 ,#00 ,#$07 ,#5
	draw_sprite_at_location_T2 zp_temp_0 ,#08 ,#00 ,zp_temp_1 ,#07 ,#00 ,#$07 ,#6
	draw_sprite_at_location_T2 zp_temp_0 ,#16 ,#00 ,zp_temp_1 ,#07 ,#00 ,#$08 ,#8
	draw_sprite_at_location_T2 zp_temp_0 ,#16 ,#00 ,zp_temp_1 ,#08 ,#01 ,#$05 ,#4
	draw_sprite_at_location_T2 zp_temp_0 ,#16 ,#00 ,zp_temp_1 ,#00 ,#01 ,#$05 ,#7
	rts
.endproc



.proc clear_indicator_T1
	
	ldy #4
	lda #<CPU_OAM_PTR
	sta zp_temp_0
	lda #>CPU_OAM_PTR
	sta zp_temp_1
	lda #0
	clear_loop:
		sta (zp_temp_0), y
		iny
		cpy #80
		bne clear_loop
	rts
.endproc



.proc remove_last_character_on_page_T1
	lda current_wram_text_ptr_lo
	sta zp_temp_0

	lda zp_temp_0
	beq end_func
	
	dec zp_temp_0

	lda current_wram_text_ptr_hi
	sta zp_temp_1

	lda #0
	ldy #0
	sta (zp_temp_0),y

	jsr redraw_current_page_T2
end_func:
	rts
.endproc

.proc redraw_pointer ;LINTEXCLUDE
	jsr get_current_nametable_pointer_XY_T2
	draw_sprite_at_location_T2 zp_temp_0 ,#00 ,#00 ,zp_temp_1 ,#00 ,#00 ,#$0A ,#0
	rts
.endproc