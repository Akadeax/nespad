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
	
	jmp find_first_empty_loop

empty_char_found:


end_func:
	rts
;  first_empty_char_loop:
; 	ldx current_text_index
; 	beq	no_chars_at_all ; if text_index is 0, just take it; no characters on this page

; 	ldy #0
; 	lda (current_wram_text_ptr_lo), y
; 	bne non_empty_char_found ; if current_wram_text_ptr is not spacebar ($00), we found what we were looking for

; 	dec current_text_index
; 	dec current_wram_text_ptr_lo
; 	jmp first_empty_char_loop

;  no_chars_at_all:
; 	lda #0
; 	sta current_text_index
; 	lda #$FF
; 	sta current_wram_text_ptr_lo

;  non_empty_char_found:
; 	; decremented current_text_index & wram_text_ptr until first non-space was found

; 	lda current_text_index
; 	cmp #(PAGE_TEXT_SIZE - 1)
; 	bne not_last_char
; 		; is last character
; 		inc current_text_index

;  not_last_char:

; 	inc current_wram_text_ptr_lo ; increment wram back by one so it's one ahead (-> it's the pointer to the next char)
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