.proc nmi ;LINTEXCLUDE
	; save registers
	pha
	txa
	pha
	tya
	pha

	lda nmi_ready
	bne :+ ; nmi_ready == 0 not ready to update PPU
		jmp ppu_update_end
	:
	cmp #2 ; nmi_ready == 2 turns rendering off
	bne cont_render
		lda #%00000000
		sta PPU_MASK
		ldx #0
		stx nmi_ready
		jmp ppu_update_end
cont_render:
	;***************
	; transfer sprite OAM data using DMA
	ldx #0
	stx PPU_OAMADDR
	lda #>oam
	sta PPU_OAMDMA

	;***************
	; transfer current palette to PPU
	;***************
	lda #%10001000 ; set horizontal nametable increment
	sta PPU_CONTROL
	lda PPU_STATUS
	lda #$3F ; set PPU address to $3F00
	sta PPU_ADDR
	stx PPU_ADDR
	ldx #0 ; transfer the 32 bytes to VRAM
loop:
	lda palette, x
	sta PPU_DATA
	inx
	cpx #32
	bcc loop

	; save pointers so we can do processing to them without damaging them
	push_pointers

	; if first char, only support deletion, not drawing
	lda current_text_index
	beq delete_next_char

	lda current_nametable_ptr_hi
	cmp #>$2282 ; $2282 is the wrong last character position
	bne not_last_char
	lda current_nametable_ptr_lo
	cmp #<$2282
	bne not_last_char

	jmp update_text_finished
not_last_char:

	lda current_wram_text_ptr_lo
	sta zp_temp_0
	dec zp_temp_0
	lda current_wram_text_ptr_hi
	sta zp_temp_1
	; wram_text_ptr - 1 is where we want to fetch text from;
	; it points to the next character we want to write to, so we want to draw the one *before* that



	jsr decrement_nametable_ptr_T0
	
	lda PPU_STATUS
	lda current_nametable_ptr_hi
	sta PPU_ADDR
	lda current_nametable_ptr_lo
	sta PPU_ADDR
	; same with nametable_ptr, it points to the next one to draw to

	
	ldy #0
	lda (zp_temp_0),y

	cmp #SPACEBAR_SUBSTITUTE ; E7 is spacebar
	bne not_spacebar
		lda #0 ; E7 is different on the nametable, but we want to just render it as empty
not_spacebar:
	sta PPU_DATA

delete_next_char:

	lda key_delete_flag
	beq update_text_finished

	lda #0
	sta key_delete_flag

	lda current_text_index
	cmp #PAGE_TEXT_SIZE
	beq update_text_finished

	lda current_text_index
	beq not_dec
		; text_index is not 0
		dec current_text_index
		jsr increment_nametable_ptr
not_dec:

	lda PPU_STATUS
	lda current_nametable_ptr_hi
	sta PPU_ADDR
	lda current_nametable_ptr_lo
	sta PPU_ADDR

	lda #0
	sta PPU_DATA

update_text_finished:
	; reset pointers after drawing
	pop_pointers

	; reset control & scroll
	lda #%10001000
	sta PPU_CONTROL

	lda PPU_STATUS
	lda #0
	sta PPU_SCROLL
	sta PPU_SCROLL

	; enable rendering
	lda #%00011110
	sta PPU_MASK
	; flag PPU update complete
	ldx #0
	stx nmi_ready
ppu_update_end:

	; restore registers and return
	pla
	tay
	pla
	tax
	pla
	rti
.endproc
