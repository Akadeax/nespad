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

.proc redraw_screen
	jsr clear_nametable

	ldx #0 ; low byte idx
	ldy #>NAME_TABLE_1
	sty PPU_ADDR
	stx PPU_ADDR
	ldx #0
	preLoadLoop1:
		lda preloadScreen1,x
		sta PPU_DATA
		inx
		cpx #$FF
		BCC preLoadLoop1
		lda preloadScreen1,x
		sta PPU_DATA
	ldx #0
	preLoadLoop2:
		lda preloadScreen2,x
		sta PPU_DATA
		inx
		cpx #$FF
		BCC preLoadLoop2
		lda preloadScreen2,x
		sta PPU_DATA
	ldx #0
	preLoadLoop3:
		lda preloadScreen3,x
		sta PPU_DATA
		inx
		cpx #$FF
		BCC preLoadLoop3
		lda preloadScreen3,x
		sta PPU_DATA
	ldx #0
	preLoadLoop4:
		lda preloadScreen4,x
		sta PPU_DATA
		inx
		cpx #$C0
		BCC preLoadLoop4
		lda preloadScreen4,x
		sta PPU_DATA
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
	cmp #DISPLAY_LINE9_END ; this is here for no reason but if it's gone it breaks
	beq :+
:
.endmacro


.proc increment_nametable_ptr
; 	lda current_text_index
; 	cmp #DISPLAY_LINE9_END
; 	bne not_last_char
; 		increment_zp_16 #3, current_nametable_ptr_lo, current_nametable_ptr_hi
; 		jmp inc_end
; not_last_char:

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


.proc keyboard_idx_to_pattern_idx_T1 ;takes the A register as the keyboard index and outputs to the A register as well
	sta zp_temp_0
;check if keyboardIdx is 11-18, 22-30, 33-41
	ldx #10
	cpx zp_temp_0
	bpl betweenJmp ;check if temp_1 is smaller than 11
	ldx #18
	cpx zp_temp_0
	bmi :++ ;check if temp_1 is 18 or smaller
		clc
		adc #7 ; add the amount of special characters left to come
		sta zp_temp_1 ; store a in temp to do binary logic
		lda zp_text_info
		and #%00000100 ; check if the capitilisation bit is set
		beq :+
			lda zp_temp_1
			clc
			adc #26
			sta zp_temp_1
		:
		lda zp_temp_1
		jmp endProc
:
	;check if keyboardIdx = 19-21
	ldx #21
	cpx zp_temp_0
	bmi :+ ;check if temp_1 is 21 or smaller
		clc
		sbc #8 ;remove the letters that have already been on the keyboard
		jmp endProc
:
	jmp skipJmp
betweenJmp: ;error range error mimimimimimimi
	jmp endProc
skipJmp:
	;check if a = 22-30
	ldx #30
	cpx zp_temp_0
	bmi :++ ;check if temp_1 is 30 or smaller
		clc
		adc #4 ; add the amount of special characters left to come
		sta zp_temp_1 ; store a in temp to do binary logic
		lda zp_text_info
		and #%00000100 ; check if the capitilisation bit is set
		beq :+
			lda zp_temp_1
			clc
			adc #26
			sta zp_temp_1
		:
		lda zp_temp_1
		jmp endProc
:
	;check if keyboardIdx = 31-32
	ldx #32
	cpx zp_temp_0
	bmi :+ ;check if temp_1 is 21 or smaller
		clc
		sbc #17 ;remove the letters that have already been on the keyboard
		jmp endProc
:
	;check if a = 33-41
	ldx #41
	cpx zp_temp_0
	bmi :++ ;check if temp_1 is 30 or smaller
		clc
		adc #2 ; add the amount of special characters left to come
		sta zp_temp_1 ; store a in temp to do binary logic
		lda zp_text_info
		and #%00000100 ; check if the capitilisation bit is set
		beq :+
			lda zp_temp_1
			clc
			adc #26
			sta zp_temp_1
		:
		lda zp_temp_1
		jmp endProc
:
	;check if keyboardIdx = 42-43
	ldx #43
	cpx zp_temp_0
	bmi :+ ;check if temp_1 is 21 or smaller
		clc
		sbc #26 ;remove the letters that have already been on the keyboard
		jmp endProc
:
	ldx #44
	cpx zp_temp_0
	bne :+ ;if keyboardIdx = 44(spaceBar)
		lda #0
		rts
:
	;space for code for the special characters i guess, didnt know how to incorporate it with the current layout
endProc:
	adc #1 ;offset for the empty character
	;add current text type offset(first 2 bits of TextInfo)
	sta zp_temp_1 ;store a in zp_temp_1 for bitwise logic
	lda zp_text_info
	and #%00000011
	cmp #1
	bne :+ ; if its bold
		lda zp_temp_1
		clc
		adc #70
		rts
:
	cmp #2
	bne :+ ;if its italic
		lda zp_temp_1
		clc
		adc #140
		rts
:
	lda zp_temp_1
	rts
.endproc

.proc keyboard_idx_to_nametable_pos_T2 ;assumes A is keyboard index returns via lo byte zp_temp_1 and hi byte zp_temp_2
	lda screen_keyboard_index
	sta zp_temp_0
	lda #<KEYBOARD_NAMETABLE_BEGIN_OFFSET
	sta zp_temp_1
	lda #>KEYBOARD_NAMETABLE_BEGIN_OFFSET
	sta zp_temp_2
	; every standard key is offset by 2, so add the keyboard index multiplied by 2
	increment_zp_16 zp_temp_0, zp_temp_1, zp_temp_2
	increment_zp_16 zp_temp_0, zp_temp_1, zp_temp_2
	;if zp_temp_0 is greater than 10, add offset
	lda #10
	cmp zp_temp_0
	bpl endProc
		increment_zp_16 #KEYBOARD_NAMETABLE_NEXTLINE_OFFSET, zp_temp_1, zp_temp_2
		;if zp_temp_0 is greater than 21, add offset
		lda #21
		cmp zp_temp_0
		bpl endProc
			increment_zp_16 #KEYBOARD_NAMETABLE_NEXTLINE_OFFSET, zp_temp_1, zp_temp_2
			;if zp_temp_0 is greater than 32, add offset
			lda #32
			cmp zp_temp_0
			bpl endProc
				increment_zp_16 #KEYBOARD_NAMETABLE_NEXTLINE_OFFSET, zp_temp_1, zp_temp_2
				jmp endProc
endProc:
	lda #KEYBOARD_IDX_SPACEBAR
	cmp zp_temp_0
	bne :+
		lda #<KEYBOARD_NAMETABLE_SPACEBAR_POS_OFFSET
		sta zp_temp_1
		lda #>KEYBOARD_NAMETABLE_SPACEBAR_POS_OFFSET
		sta zp_temp_2
		rts
:
	lda #KEYBOARD_IDX_SHIFT
	cmp zp_temp_0
	bne :+
		lda #<KEYBOARD_NAMETABLE_SHIFT_POS_OFFSET
		sta zp_temp_1
		lda #>KEYBOARD_NAMETABLE_SHIFT_POS_OFFSET
		sta zp_temp_2
		rts
:
	lda #KEYBOARD_IDX_BOLD
	cmp zp_temp_0
	bne :+
		lda #<KEYBOARD_NAMETABLE_BOLD_POS_OFFSET
		sta zp_temp_1
		lda #>KEYBOARD_NAMETABLE_BOLD_POS_OFFSET
		sta zp_temp_2
		rts
:
	lda #KEYBOARD_IDX_ITALIC
	cmp zp_temp_0
	bne :+
		lda #<KEYBOARD_NAMETABLE_ITALIC_POS_OFFSET
		sta zp_temp_1
		lda #>KEYBOARD_NAMETABLE_ITALIC_POS_OFFSET
		sta zp_temp_2
		rts
:
	lda #KEYBOARD_IDX_NEXT_PAGE
	cmp zp_temp_0
	bne :+
		lda #<KEYBOARD_NAMETABLE_NEXT_PAGE_POS_OFFSET
		sta zp_temp_1
		lda #>KEYBOARD_NAMETABLE_NEXT_PAGE_POS_OFFSET
		sta zp_temp_2
		rts
:
	lda #KEYBOARD_IDX_PREV_PAGE
	cmp zp_temp_0
	bne :+
		lda #<KEYBOARD_NAMETABLE_PREV_PAGE_POS_OFFSET
		sta zp_temp_1
		lda #>KEYBOARD_NAMETABLE_PREV_PAGE_POS_OFFSET
		sta zp_temp_2
		rts
:
	rts
.endproc

; Function to convert nametable index to x,y position
.proc convert_nametable_index_to_XY_T2
    
    lda zp_temp_1
    ; Calculate X position (lowest 5 bits of index)
    and #$1F 
	asl ;multiply by 8 to get the y pos
	asl 
	asl        
    sta zp_temp_0    ;store y in temp 0

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
	asl ;multiply by 8 to get the x pos
	asl
	asl
    sta zp_temp_1   ;store x in temp 1

    rts              
.endproc