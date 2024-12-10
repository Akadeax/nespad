;*****************************************************************
; ppu_update: waits until next NMI, turns rendering on (if not already), uploads OAM, palette, and nametable update to PPU
;*****************************************************************
.proc ppu_update
	lda #1
	sta nmi_ready
	loop:
		lda nmi_ready
		bne loop
	rts
.endproc

;*****************************************************************
; ppu_off: waits until next NMI, turns rendering off (now safe to write PPU directly via PPU_DATA)
;*****************************************************************
.proc ppu_off
	lda #2
	sta nmi_ready
	loop:
		lda nmi_ready
		bne loop
	rts
.endproc

;*****************************************************************
; gamepad_poll: this reads the gamepad state into the variable labelled "gamepad"
; This only reads the first gamepad, and also if DPCM samples are played they can
; conflict with gamepad reading, which may give incorrect results.
;*****************************************************************



.macro increment_zp_16 amount, address_lo, address_hi
	lda address_lo
	clc
	adc amount
	sta address_lo

	bcc :+

	inc address_hi

	:
.endmacro


.macro decrement_zp_16 amount, address_lo, address_hi
	lda address_lo
	sec
	sbc amount
	sta address_lo

	bcs :+

	dec address_hi

	:
.endmacro


.proc clear_wram_p1
	lda #0
	ldx #0
clear_wram_p1:
	sta $6000,x
	inx
	bne clear_wram_p1
	
	rts
.endproc

.proc clear_current_page_T1 ;LINTEXCLUDE
	lda current_page
	sta zp_temp_0
	jsr clear_page_T2
	rts
.endproc

.proc clear_page_T2 ;LINTEXCLUDE
	lda zp_temp_0
	pha
	clc
	adc #$60
	sta zp_temp_1
	lda #0
	sta zp_temp_0
	ldy #0
 :
	sta (zp_temp_0),y
	iny
	bne :-

	jsr redraw_current_page_T5
	pla
	sta zp_temp_0
	rts
.endproc

.proc clear_wram_T3 ;LINTEXCLUDE
	lda #0
	sta zp_temp_0
	:
		jsr clear_page_T2
		inc zp_temp_0
		lda zp_temp_0
		cmp #32
		bne :-
	rts
.endproc

.macro push_pointers
	lda current_text_index
	pha 
	lda current_wram_text_ptr_lo
	pha 
	lda current_wram_text_ptr_hi
	pha 
	lda current_nametable_ptr_lo
	pha 
	lda current_nametable_ptr_hi
	pha 
.endmacro

.macro pop_pointers
	pla 
	sta current_nametable_ptr_hi
	pla 
	sta current_nametable_ptr_lo
	pla 
	sta current_wram_text_ptr_hi
	pla 
	sta current_wram_text_ptr_lo
	pla 
	sta current_text_index
.endmacro
