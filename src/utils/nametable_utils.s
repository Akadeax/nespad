.macro set_carry_if_eol text_index
	lda text_index

	cmp #DISPLAY_LINE1_END
	beq :+
	cmp #DISPLAY_LINE2_END
	beq :+
	cmp #DISPLAY_LINE3_END
	beq :+
	cmp #DISPLAY_LINE4_END
	beq :+
	cmp #DISPLAY_LINE5_END
	beq :+
	cmp #DISPLAY_LINE6_END
	beq :+
	cmp #DISPLAY_LINE7_END
	beq :+
	cmp #DISPLAY_LINE8_END
	beq :+
	; Is this used? Absolutely Not. Our text index value never even gets close to 255.
	; Want to remove this check? Any line after the 8th breaks. Wish I could tell you why. Pray to your gods.
	cmp #255
	beq :+
:
.endmacro


.macro set_carry_if_sol text_index ; set carry if start of line
	lda text_index

	cmp #DISPLAY_LINE2_START
	beq :+
	cmp #DISPLAY_LINE3_START
	beq :+
	cmp #DISPLAY_LINE4_START
	beq :+
	cmp #DISPLAY_LINE5_START
	beq :+
	cmp #DISPLAY_LINE6_START
	beq :+
	cmp #DISPLAY_LINE7_START
	beq :+
	cmp #DISPLAY_LINE8_START
	beq :+
	cmp #DISPLAY_LINE9_START
	beq :+
:
.endmacro

.proc increment_nametable_ptr
	set_carry_if_eol current_text_index

	bcc single_increase

    increment_zp_16 #(DISPLAY_SCREEN_WIDTH + DISPLAY_SIDE_MARGIN * 2 + 1), current_nametable_ptr_lo, current_nametable_ptr_hi
	jmp inc_end
single_increase:
    increment_zp_16 #1, current_nametable_ptr_lo, current_nametable_ptr_hi

inc_end:
	rts
.endproc

.proc decrement_nametable_ptr_T0
	lda current_text_index
	sta zp_temp_0
	dec zp_temp_0

	set_carry_if_eol zp_temp_0

	bcc single_increase

    decrement_zp_16 #(DISPLAY_SCREEN_WIDTH + DISPLAY_SIDE_MARGIN * 2 + 1), current_nametable_ptr_lo, current_nametable_ptr_hi
	jmp inc_end
single_increase:
    decrement_zp_16 #1, current_nametable_ptr_lo, current_nametable_ptr_hi

inc_end:
	rts
.endproc

.macro reset_current_nametable_ptr
	lda #<DISPLAY_NAMETABLE_BASE_OFFSET
	sta current_nametable_ptr_lo
	lda #>DISPLAY_NAMETABLE_BASE_OFFSET
	sta current_nametable_ptr_hi
.endmacro


.proc set_pointers_to_last_character_of_current_page
	lda #0
	sta current_wram_text_ptr_lo
	sta current_text_index
	; text_index and wram_lo are now on first character of page

	lda #>WRAM_START
	clc
	adc current_page
	sta current_wram_text_ptr_hi
	; current_wram_text_ptr_hi now holds the hi of the current page in WRAM

find_first_empty_loop:
	; check if there is a character at current index
	ldy #0
	lda (current_wram_text_ptr_lo),y

	beq empty_char_found

	jsr increment_nametable_ptr
	inc current_text_index
	inc current_wram_text_ptr_lo
	
	lda current_text_index
	cmp #PAGE_TEXT_SIZE
	beq empty_char_found ; if page is full, return last char

	jmp find_first_empty_loop

empty_char_found:


end_func:
	rts
.endproc


; Function to convert nametable index to x,y position
.proc convert_nametable_index_to_XY_T2
    
    lda zp_temp_1
    ; Calculate X position (lowest 5 bits of index)
    and #%00011111 
	asl ;multiply by 8 to get the x pos
	asl 
	asl        
    sta zp_temp_0    ;store x in temp 0

    ;shift higher bits down to make room for the high byte
    lda zp_temp_1
    lsr         
    lsr             
    lsr
    lsr
    lsr
	sta zp_temp_1
	;prepare high byte to be merged with low byte
	lda zp_temp_2
	asl
	asl
	asl
    ora zp_temp_1   ; Combine with high byte of index
	asl ;multiply by 8 to get the y pos
	asl
	asl
    sta zp_temp_1   ;store y in temp 1

    rts              
.endproc



.proc get_current_nametable_pointer_XY_T2 ;outputs x to zp_temp_0, and y to zp_temp_1
	lda current_nametable_ptr_lo
	sta zp_temp_1
	lda current_nametable_ptr_hi
	sta zp_temp_2
	jsr convert_nametable_index_to_XY_T2
	rts
.endproc


; only call while ppu is off!
.proc draw_current_page_attribute_T5 ;LINTEXCLUDE
	lda #0
	sta zp_temp_6 ; 6 is our attribute row loop index

	lda PPU_STATUS
	lda #>ATTR_TABLE_1
	sta PPU_ADDR
	lda #<ATTR_TABLE_1
	sta PPU_ADDR

loop:
	lda zp_temp_6
	sta zp_temp_0
	jsr attribute_row_to_color_T5

	lda zp_temp_0
	and #%11001100
	sta PPU_DATA
	lda zp_temp_0
	sta PPU_DATA
	sta PPU_DATA
	sta PPU_DATA
	sta PPU_DATA
	sta PPU_DATA
	sta PPU_DATA
	lda zp_temp_0
	and #%00110011
	sta PPU_DATA

	inc zp_temp_6

	lda zp_temp_6
	cmp #5
	bne loop

loop_end:

	; write color of last line to rest of the screen
	lda zp_temp_0
	and #%11110000
	sta zp_temp_6
	lsr 
	lsr 
	lsr 
	lsr 
	ora zp_temp_6

	ldx #24

keyboard_color_loop:
	sta PPU_DATA
	dex
	bne keyboard_color_loop

	rts
.endproc


; take zp_temp_0 as attribute table row; return correct color byte for the entire attribute line in zp_temp_0
.proc attribute_row_to_color_T5 ;LINTEXCLUDE
	ldx zp_temp_0
	; x now holds attribute table row

	lda #$FF
	sta zp_temp_3 ; temp4 stores line number to fetch color for

loop:
	cpx #0
	beq loop_end

	dex
	inc zp_temp_3
	inc zp_temp_3
	jmp loop

loop_end:
	; this attribute chunk consists of:
	; top row: line number zp_temp_3
	; bottom row: line number zp_temp_3 + 1
	; for attribute row 0, this will be FF & 0 due to the top row of the first attribute row not having text.
	; attribute row 1 will be 1 & 2, row 2 will be 3 & 4, etc.
	; based on zp_temp_3, we can now fetch the color from those stored line numbers

	lda zp_temp_3
	cmp #$FF
	bne :+
		; zp_temp_3 is $FF, make exception for top half of first row
		lda #0
		sta zp_temp_4
		jmp :++
:
	; if it's not $FF, just fetch the color from end-of-page memory
	lda zp_temp_3
	sta zp_temp_0
	jsr get_color_from_line_T2
	lda zp_temp_0
	sta zp_temp_4

:
	; the color for the top row of this chunk is now in zp_temp_4

	lda zp_temp_3
	clc
	adc #1
	sta zp_temp_0
	jsr get_color_from_line_T2
	lda zp_temp_0
	sta zp_temp_5
	; the color for the bottom row of this chunk is now in zp_temp_5

	; now we can replicate the bits to fill our output
	lda zp_temp_4
	sta zp_temp_0
	jsr replicate_bits_01_to_0123_T0
	lda zp_temp_0
	sta zp_temp_4
	; zp_temp_4 now holds the color byte for the top row

	lda zp_temp_5
	sta zp_temp_0
	jsr replicate_bits_01_to_4567_T0
	lda zp_temp_0
	sta zp_temp_5
	; zp_temp_5 now holds the color byte for the top row

	; we can combine top & bottom to get the full attribute chunk byte
	lda zp_temp_5
	ora zp_temp_4
	sta zp_temp_0
	; zp_temp_0 now holds the combined attribute data
	rts
.endproc


.proc replicate_bits_01_to_4567_T0
	jsr replicate_bits_01_to_0123_T0
	lda zp_temp_0
	asl 
	asl 
	asl 
	asl 
	sta zp_temp_0
	; now zp_temp_0 is xyxy0000
	rts
.endproc

.proc replicate_bits_01_to_0123_T0
	lda zp_temp_0
	asl 
	asl 
	ora zp_temp_0
	sta zp_temp_0
	; now zp_temp_0 is 0000xyxy
	rts
.endproc
