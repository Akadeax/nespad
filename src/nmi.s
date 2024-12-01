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

	; if first char, don't draw yet
	lda current_text_index
	beq update_text_finished

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

	; TODO: problem here, make decrement_nametable_ptr instead!
	lda PPU_STATUS
	lda current_nametable_ptr_hi
	sta PPU_ADDR
	lda current_nametable_ptr_lo
	sec
	sbc #1
	sta PPU_ADDR
	; same with nametable_ptr, it points to the next one to draw to

	ldy #0
	lda (zp_temp_0),y

	sta PPU_DATA

update_text_finished:

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
