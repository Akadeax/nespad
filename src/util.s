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

.macro poll_gamepad OutAddr
	; strobe the gamepad to latch current button state
	lda #1
	sta JOYPAD1
	lda #0
	sta JOYPAD1
	; read 8 bytes from the interface at $4016
	ldx #8
poll_loop:
	pha
	lda JOYPAD1
	; combine low two bits and store in carry bit
	and #%00000011
	cmp #%00000001
	pla
	; rotate carry into gamepad variable
	ror
	dex
	bne poll_loop

	sta OutAddr
.endmacro


.proc clear_nametable
 	lda PPU_STATUS ; reset address latch
 	lda #$20 ; set PPU address to $2000
 	sta PPU_ADDR
 	lda #$00
 	sta PPU_ADDR

 	; empty nametable A
 	lda #0
 	ldy #30 ; clear 30 rows
 	rowloop:
 		ldx #32 ; 32 columns
 		columnloop:
 			sta PPU_DATA
 			dex
 			bne columnloop
 		dey
 		bne rowloop

 	; empty attribute table
 	ldx #64 ; attribute table is 64 bytes
 	loop:
 		sta PPU_DATA
 		dex
 		bne loop

 	rts
 .endproc


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
	cmp #DISPLAY_LINE9_END
	beq :+
:
.endmacro


.macro increment_nametable_ptr
	set_carry_if_eol current_text_index

	bcc single_increase

    increment_zp_16 #(DISPLAY_SCREEN_WIDTH + DISPLAY_SIDE_MARGIN * 2 + 1), current_nametable_ptr_lo, current_nametable_ptr_hi
	lda #$FF
	sta 32
	jmp inc_end
single_increase:
    increment_zp_16 #1, current_nametable_ptr_lo, current_nametable_ptr_hi
	lda #$01
	sta 32
	
inc_end:
.endmacro


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
