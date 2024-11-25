.proc redraw_current_page_T2
	jsr ppu_off
	; accessing VRAM is now safe

	jsr clear_nametable

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
	inc zp_temp_0 ; only need to increment low
	inx
	jmp loop

endloop:
	rts
.endproc

; TODO bug: writing on a newly acquired page overrides last character (check current_text_index, why is it behaving weirdly in edgecases?)
.proc type_current_key
	lda current_text_index
	cmp #PAGE_TEXT_SIZE
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
