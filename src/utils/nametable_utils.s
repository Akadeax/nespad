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
	cmp #DISPLAY_LINE9_END ; this is here for no reason but if it's gone it breaks
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


.macro get_nametable_pointer_T2 text_pointer ; dont call this often, it takes a lot of cycles (uses A,X and 16 bit temp)
    lda #<DISPLAY_NAMETABLE_BASE_OFFSET
    sta zp_temp_0
    lda #>DISPLAY_NAMETABLE_BASE_OFFSET
    sta zp_temp_1
	; nametable base offset is now in the 16 bit temp

    ldx #0 ; clear x; increment it towards the text_pointer
loop_nametable_inc:
    cpx text_pointer
    beq end_of_nametable_loop ; if x didnt reach text pointer yet, loop
    inx
    stx zp_temp_2
    set_carry_if_eol zp_temp_2 ; if the x register is at the end of a line, set the carry flag
    bcc skip_big_nametable_jump ;if the carry flag is not set, you dont need to go to the next line
    increment_zp_16 #35, zp_temp_0, zp_temp_1 ;increment the 16 bit temp by 35 to indicate going to the next line
skip_big_nametable_jump:
    increment_zp_16 #1, zp_temp_0, zp_temp_1 ; increment the 16 bit temp by 1 to indicate going to the next text location
    jmp loop_nametable_inc
end_of_nametable_loop:
    lda zp_temp_0 ; store the 16 bit temp in the display nametable pointer
    sta current_nametable_ptr_lo
    lda zp_temp_1
    sta current_nametable_ptr_hi
.endmacro

.macro reset_current_nametable_ptr
	lda #<DISPLAY_NAMETABLE_BASE_OFFSET
	sta current_nametable_ptr_lo
	lda #>DISPLAY_NAMETABLE_BASE_OFFSET
	sta current_nametable_ptr_hi
.endmacro


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

	lda current_text_index
	cmp #(PAGE_TEXT_SIZE - 1)
	bne not_last_char
		; is last character
		inc current_text_index

 not_last_char:

	inc current_wram_text_ptr_lo ; increment wram back by one so it's one ahead (-> it's the pointer to the next char)

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