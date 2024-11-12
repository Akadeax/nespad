.proc nmi
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


; 	;;; we wanna check if text_ptr is $6000 (cuz then we don't wanna draw)
; 	;;; branch to update_text_finished if wram_text_ptr is $6000 exactly

; 	ldx #0 ; if x becomes FF, text_ptr is not $6000

; 	lda wram_text_ptr_hi
; 	cmp #$60
; 	beq is_not_equal1
; 		ldx #$FF
; 	is_not_equal1:

; 	lda wram_text_ptr_lo
; 	cmp #$00
; 	beq is_not_equal2
; 		ldx #$FF
; 	is_not_equal2:

; 	cpx #$FF
; 	bne update_text_finished


; update_text:
; 	; load character index we need from text_ptr
; 	lda wram_text_ptr_hi
; 	sta sixteen_bit_temp_hi

; 	lda wram_text_ptr_lo
; 	sec
; 	sbc #1 ; decrement our temp lo
; 	cmp #$FF
; 	bne no_underflow ; if our temp lo underflowed, decrement our temp hi
; 		dec sixteen_bit_temp_hi

; 	no_underflow:

; 	sta sixteen_bit_temp_lo
; 	; now our target wram_text location is in 16 bit temp

; 	ldy #0
; 	lda (sixteen_bit_temp_lo),y
; 	tax
; 	; now the value we wanna put into the nametable is in x

; 	lda sixteen_bit_temp_hi
; 	and #%10111111
; 	sta sixteen_bit_temp_hi
; 	; now our target location in the nametable is in our 16bit temp (target is: text_ptr - $4000)

; 	lda PPU_STATUS
; 	lda sixteen_bit_temp_hi
; 	sta PPU_ADDR
; 	lda sixteen_bit_temp_lo
; 	sta PPU_ADDR

; 	stx PPU_DATA ; put x into nametable target

; update_text_finished:

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
