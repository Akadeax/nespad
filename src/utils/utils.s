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