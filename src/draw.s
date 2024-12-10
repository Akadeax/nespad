.proc redraw_current_page_T5 ;LINTEXCLUDE
	jsr ppu_off
	; accessing VRAM is now safe
	jsr redraw_screen
	reset_current_nametable_ptr
	jsr set_pointers_to_last_character_of_current_page

	push_pointers
	
	lda current_text_index
	beq draw_finished

draw_loop:
	jsr decrement_nametable_ptr_T0
	dec current_text_index
	dec current_wram_text_ptr_lo

	lda PPU_STATUS
	lda current_nametable_ptr_hi
	sta PPU_ADDR
	lda current_nametable_ptr_lo
	sta PPU_ADDR

	ldy #0
	lda (current_wram_text_ptr_lo),y

	cmp #SPACEBAR_SUBSTITUTE ; replace spacebar indicator ($E7) with empty render
	bne :+
		; current char is $E7
		lda #0
:

	sta PPU_DATA

	lda current_text_index
	bne draw_loop

draw_finished:

	pop_pointers

	jsr draw_current_page_attribute_T5

	jsr redraw_pointer
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
	draw_sprite_at_location_T2 zp_temp_0 ,#07 ,#01 ,zp_temp_1 ,#07 ,#00 ,#$06 ,#8 ,#0
	draw_sprite_at_location_T2 zp_temp_0 ,#07 ,#01 ,zp_temp_1 ,#00 ,#01 ,#$04 ,#1 ,#0
	draw_sprite_at_location_T2 zp_temp_0 ,#07 ,#01 ,zp_temp_1 ,#08 ,#01 ,#$01 ,#2 ,#0
	draw_sprite_at_location_T2 zp_temp_0 ,#00 ,#00 ,zp_temp_1 ,#08 ,#01 ,#$02 ,#3 ,#0
	draw_sprite_at_location_T2 zp_temp_0 ,#08 ,#00 ,zp_temp_1 ,#08 ,#01 ,#$03 ,#4 ,#0
	draw_sprite_at_location_T2 zp_temp_0 ,#00 ,#00 ,zp_temp_1 ,#07 ,#00 ,#$07 ,#5 ,#0
	draw_sprite_at_location_T2 zp_temp_0 ,#08 ,#00 ,zp_temp_1 ,#07 ,#00 ,#$08 ,#6 ,#0
	draw_sprite_at_location_T2 zp_temp_0 ,#08 ,#00 ,zp_temp_1 ,#00 ,#01 ,#$05 ,#7 ,#0

 endProc:
	rts
.endproc

.proc draw_spacebar_Indicator ;LINTEXCLUDE
	;	x var,x offset, is x subtracting, y var, y offset, is y subtracting, sprite, index
	draw_sprite_at_location_T2 zp_temp_0 ,#07 ,#01 ,zp_temp_1 ,#07 ,#00 ,#$06 ,#18 ,#0
	draw_sprite_at_location_T2 zp_temp_0 ,#07 ,#01 ,zp_temp_1 ,#00 ,#01 ,#$04 ,#1  ,#0
	draw_sprite_at_location_T2 zp_temp_0 ,#07 ,#01 ,zp_temp_1 ,#08 ,#01 ,#$01 ,#2  ,#0
	draw_sprite_at_location_T2 zp_temp_0 ,#40 ,#00 ,zp_temp_1 ,#08 ,#01 ,#$03 ,#4  ,#0
	draw_sprite_at_location_T2 zp_temp_0 ,#40 ,#00 ,zp_temp_1 ,#07 ,#00 ,#$08 ,#6  ,#0
	draw_sprite_at_location_T2 zp_temp_0 ,#40 ,#00 ,zp_temp_1 ,#00 ,#01 ,#$05 ,#7  ,#0
 
	draw_sprite_at_location_T2 zp_temp_0 ,#00 ,#00 ,zp_temp_1 ,#08 ,#01 ,#$02 ,#3  ,#0
	draw_sprite_at_location_T2 zp_temp_0 ,#00 ,#00 ,zp_temp_1 ,#07 ,#00 ,#$07 ,#5  ,#0
	draw_sprite_at_location_T2 zp_temp_0 ,#08 ,#00 ,zp_temp_1 ,#08 ,#01 ,#$02 ,#8  ,#0
	draw_sprite_at_location_T2 zp_temp_0 ,#08 ,#00 ,zp_temp_1 ,#07 ,#00 ,#$07 ,#9  ,#0
	draw_sprite_at_location_T2 zp_temp_0 ,#16 ,#00 ,zp_temp_1 ,#08 ,#01 ,#$02 ,#10 ,#0
	draw_sprite_at_location_T2 zp_temp_0 ,#16 ,#00 ,zp_temp_1 ,#07 ,#00 ,#$07 ,#11 ,#0
	draw_sprite_at_location_T2 zp_temp_0 ,#24 ,#00 ,zp_temp_1 ,#08 ,#01 ,#$02 ,#12 ,#0
	draw_sprite_at_location_T2 zp_temp_0 ,#24 ,#00 ,zp_temp_1 ,#07 ,#00 ,#$07 ,#13 ,#0
	draw_sprite_at_location_T2 zp_temp_0 ,#32 ,#00 ,zp_temp_1 ,#08 ,#01 ,#$02 ,#14 ,#0
	draw_sprite_at_location_T2 zp_temp_0 ,#32 ,#00 ,zp_temp_1 ,#07 ,#00 ,#$07 ,#15 ,#0
	rts
.endproc

.proc draw_arrow_indicator ;LINTEXCLUDE
	;	x var,x offset, is x subtracting, y var, y offset, is y subtracting, sprite, index
	draw_sprite_at_location_T2 zp_temp_0 ,#07 ,#01 ,zp_temp_1 ,#07 ,#00 ,#$06 ,#12 ,#0 
	draw_sprite_at_location_T2 zp_temp_0 ,#07 ,#01 ,zp_temp_1 ,#16 ,#01 ,#$01 ,#11 ,#0 
	draw_sprite_at_location_T2 zp_temp_0 ,#16 ,#00 ,zp_temp_1 ,#16 ,#01 ,#$03 ,#10 ,#0 
	draw_sprite_at_location_T2 zp_temp_0 ,#07 ,#01 ,zp_temp_1 ,#00 ,#01 ,#$04 ,#1  ,#0
	draw_sprite_at_location_T2 zp_temp_0 ,#07 ,#01 ,zp_temp_1 ,#08 ,#01 ,#$04 ,#2  ,#0
	draw_sprite_at_location_T2 zp_temp_0 ,#00 ,#00 ,zp_temp_1 ,#16 ,#01 ,#$02 ,#3  ,#0
	draw_sprite_at_location_T2 zp_temp_0 ,#08 ,#00 ,zp_temp_1 ,#16 ,#01 ,#$02 ,#9  ,#0
	draw_sprite_at_location_T2 zp_temp_0 ,#00 ,#00 ,zp_temp_1 ,#07 ,#00 ,#$07 ,#5  ,#0
	draw_sprite_at_location_T2 zp_temp_0 ,#08 ,#00 ,zp_temp_1 ,#07 ,#00 ,#$07 ,#6  ,#0
	draw_sprite_at_location_T2 zp_temp_0 ,#16 ,#00 ,zp_temp_1 ,#07 ,#00 ,#$08 ,#8  ,#0
	draw_sprite_at_location_T2 zp_temp_0 ,#16 ,#00 ,zp_temp_1 ,#08 ,#01 ,#$05 ,#4  ,#0
	draw_sprite_at_location_T2 zp_temp_0 ,#16 ,#00 ,zp_temp_1 ,#00 ,#01 ,#$05 ,#7  ,#0
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

	jsr redraw_current_page_T5
 end_func:
	rts
.endproc



.proc remove_last_character_on_page_without_reload
	lda current_text_index
	beq end_func
	
	jsr decrement_nametable_ptr_T0
	dec current_wram_text_ptr_lo
	dec current_text_index

	lda #0
	ldy #0
	sta (current_wram_text_ptr_lo),y

	jsr redraw_pointer

	lda #1
	sta key_delete_flag

 end_func:
	rts
.endproc

.proc redraw_pointer ;LINTEXCLUDE
	jsr get_current_nametable_pointer_XY_T2
	draw_sprite_at_location_T2 zp_temp_0 ,#00 ,#00 ,zp_temp_1 ,#00 ,#00 ,#$0A ,#0,#0
	rts
.endproc

.proc draw_color_indicator_T5
	lda #<SPECIAL_KEYBOARD_NAMETABLE_COLOR_OFFSET
	sta zp_temp_1
	lda #>SPECIAL_KEYBOARD_NAMETABLE_COLOR_OFFSET
	sta zp_temp_2
	jsr convert_nametable_index_to_XY_T2
	lda zp_temp_0
	sta zp_temp_5
	
	dec zp_temp_1 ;center it a bit more
	lda zp_temp_1
	ldy #84
	sta CPU_OAM_PTR, y
	
	iny	
	lda #$0b 
	sta CPU_OAM_PTR, y

	jsr get_color_from_selected_line_T2
	ldy #86
	lda zp_temp_0
	sta CPU_OAM_PTR, y
	iny
	lda zp_temp_5
	sta CPU_OAM_PTR, y
	rts
.endproc

.proc clear_color_indicator
	lda #0
	ldy #84
	sta CPU_OAM_PTR, y
	
	iny	
	lda #0 
	sta CPU_OAM_PTR, y

	iny
	lda #0
	sta CPU_OAM_PTR, y
	iny
	lda #0
	sta CPU_OAM_PTR, y
	rts
.endproc

.proc draw_selected_line_indicator ;LINTEXCLUDE
	jsr get_color_from_selected_line_T2
	lda zp_temp_0
	sta zp_temp_3
	jsr get_selected_line_T0
	lda #<DISPLAY_NAMETABLE_BASE_OFFSET
	sta zp_temp_1
	lda #>DISPLAY_NAMETABLE_BASE_OFFSET
	sta zp_temp_2
	lda zp_temp_0
	beq :+++ ;seems like one to many, dw there is a label in the macro
	:
		increment_zp_16 #64,zp_temp_1, zp_temp_2
		dec zp_temp_0
		bne :--
	:
	jsr convert_nametable_index_to_XY_T2
	;	x var,x offset, is x subtracting, y var, y offset, is y subtracting, sprite, index
	draw_sprite_at_location_T2 zp_temp_0 ,#07 ,#01 ,zp_temp_1 ,#07 ,#00 ,#$06 ,#22 ,zp_temp_3
	draw_sprite_at_location_T2 zp_temp_0 ,#07 ,#01 ,zp_temp_1 ,#00 ,#01 ,#$04 ,#23 ,zp_temp_3
	draw_sprite_at_location_T2 zp_temp_0 ,#07 ,#01 ,zp_temp_1 ,#08 ,#01 ,#$01 ,#24 ,zp_temp_3
	draw_sprite_at_location_T2 zp_temp_0 ,#224 ,#00 ,zp_temp_1 ,#08 ,#01 ,#$03 ,#25 ,zp_temp_3
	draw_sprite_at_location_T2 zp_temp_0 ,#224 ,#00 ,zp_temp_1 ,#07 ,#00 ,#$08 ,#26 ,zp_temp_3
	draw_sprite_at_location_T2 zp_temp_0 ,#224 ,#00 ,zp_temp_1 ,#00 ,#01 ,#$05 ,#27 ,zp_temp_3
	draw_sprite_at_location_T2 zp_temp_0 ,#00 ,#00 ,zp_temp_1 ,#08 ,#01 ,#$02 ,#28 ,zp_temp_3
	draw_sprite_at_location_T2 zp_temp_0 ,#00 ,#00 ,zp_temp_1 ,#07 ,#00 ,#$07 ,#29 ,zp_temp_3
	draw_sprite_at_location_T2 zp_temp_0 ,#08 ,#00 ,zp_temp_1 ,#08 ,#01 ,#$02 ,#30 ,zp_temp_3
	draw_sprite_at_location_T2 zp_temp_0 ,#08 ,#00 ,zp_temp_1 ,#07 ,#00 ,#$07 ,#31 ,zp_temp_3
	draw_sprite_at_location_T2 zp_temp_0 ,#208 ,#00 ,zp_temp_1 ,#08 ,#01 ,#$02 ,#32 ,zp_temp_3
	draw_sprite_at_location_T2 zp_temp_0 ,#208 ,#00 ,zp_temp_1 ,#07 ,#00 ,#$07 ,#33 ,zp_temp_3
	draw_sprite_at_location_T2 zp_temp_0 ,#216 ,#00 ,zp_temp_1 ,#08 ,#01 ,#$02 ,#34 ,zp_temp_3
	draw_sprite_at_location_T2 zp_temp_0 ,#216 ,#00 ,zp_temp_1 ,#07 ,#00 ,#$07 ,#35 ,zp_temp_3
	rts

.endproc

.proc clear_line_indicator_T1
	
	ldy #88
	lda #<CPU_OAM_PTR
	sta zp_temp_0
	lda #>CPU_OAM_PTR
	sta zp_temp_1
	lda #0
	clear_loop:
		sta (zp_temp_0), y
		iny
		cpy #160
		bne clear_loop
	rts
.endproc

.proc draw_direction_arrows_T3
	lda #9
	sta zp_temp_0
	jsr get_color_from_line_T2
	lda zp_temp_0
	sta zp_temp_3

	lda #<KEYBOARD_NAMETABLE_ARROW_LEFT
	sta zp_temp_1
	lda #>KEYBOARD_NAMETABLE_ARROW_LEFT
	sta zp_temp_2
	jsr convert_nametable_index_to_XY_T2
	lda zp_temp_0
	draw_sprite_at_location_T2 zp_temp_0 ,#00 ,#00 ,zp_temp_1 ,#00 ,#00 ,#$0C ,#51 ,zp_temp_3

	lda #<KEYBOARD_NAMETABLE_ARROW_RIGHT
	sta zp_temp_1
	lda #>KEYBOARD_NAMETABLE_ARROW_RIGHT
	sta zp_temp_2
	jsr convert_nametable_index_to_XY_T2
	draw_sprite_at_location_T2 zp_temp_0 ,#00 ,#00 ,zp_temp_1 ,#00 ,#00 ,#$0D ,#50 ,zp_temp_3
	rts
.endproc

.proc clear_direction_arrows_T1
	ldy #200
	lda #<CPU_OAM_PTR
	sta zp_temp_0
	lda #>CPU_OAM_PTR
	sta zp_temp_1
	lda #0
	clear_loop:
		sta (zp_temp_0), y
		iny
		cpy #8
		bne clear_loop
	rts
.endProc
