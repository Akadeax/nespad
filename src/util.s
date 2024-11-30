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

.macro draw_segment adress, amount
	clc
	ldx #0
	:
		lda adress,x
		sta PPU_DATA
		inx
		cpx #amount
		BCC :-
		lda adress,x
		sta PPU_DATA
.endmacro

.proc redraw_screen
	jsr clear_nametable
	lda PPU_STATUS
	ldx #0 ; low byte idx
	ldy #>NAME_TABLE_1
	sty PPU_ADDR
	stx PPU_ADDR
	draw_segment preloadScreen1, $FF
	draw_segment preloadScreen2, $FF

	lda zp_text_info
	and #%00000011
	cmp #KEYBOARD_INFO_NORMAL
	bne NOT_NORMAL_TEXT
		lda zp_text_info
		and #%00000100
		bne is_normal_capital
			draw_segment normalKeyboard1, $FF
			draw_segment normalKeyboard2, $C0
			jmp endProc
		is_normal_capital:
		draw_segment normalCapitalKeyboard1, $FF
		draw_segment normalCapitalKeyboard2, $C0
		jmp endProc
	NOT_NORMAL_TEXT:
	cmp #KEYBOARD_INFO_BOLD
	bne NOT_BOLD_TEXT
		lda zp_text_info
		and #%00000100
		bne is_bold_capital
			draw_segment boldKeyboard1, $FF
			draw_segment boldKeyboard2, $C0
			jmp endProc
		is_bold_capital:
		draw_segment boldCapitalKeyboard1, $FF
		draw_segment boldCapitalKeyboard2, $C0
		jmp endProc
	NOT_BOLD_TEXT:
	cmp #KEYBOARD_INFO_ITALIC
	bne NOT_ITALIC_TEXT
		lda zp_text_info
		and #%00000100
		bne is_italic_capital
			draw_segment italicKeyboard1, $FF
			draw_segment italicKeyboard2, $C0
			jmp endProc
		is_italic_capital:
		draw_segment italicCapitalKeyboard1, $FF
		draw_segment italicCapitalKeyboard2, $C0
		jmp endProc
	NOT_ITALIC_TEXT:
	endProc:
		;render the page number
		lda PPU_STATUS
		ldx #$96 ; low byte idx
		ldy #$23
		sty PPU_ADDR
		stx PPU_ADDR
		ldx current_page
		inx
		cpx #10
		bpl :+ ; if its lower than 10, render 0 as the first number
			lda #$01 ;index of character 0
			sta PPU_DATA
			lda current_page
			clc
			adc #2
			sta PPU_DATA
			rts
		:
		cpx #20
		bpl :+ ; if its lower than 10, render 0 as the first number
			lda #$02 ;index of character 0
			sta PPU_DATA
			lda current_page
			sec
			sbc #8
			sta PPU_DATA
			rts
		:
		cpx #30
		bpl :+ ; if its lower than 10, render 0 as the first number
			lda #$03 ;index of character 0
			sta PPU_DATA
			lda current_page
			sec
			sbc #18
			sta PPU_DATA
			rts
		:
		cpx #40
		bpl :+ ; if its lower than 10, render 0 as the first number
			lda #$04 ;index of character 0
			sta PPU_DATA
			lda current_page
			sec
			sbc #28
			sta PPU_DATA
			rts
		:
		
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
	lda screen_keyboard_index
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
		sbc #7 ;remove the letters that have already been on the keyboard
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
		sbc #16 ;remove the letters that have already been on the keyboard
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
		sbc #25 ;remove the letters that have already been on the keyboard
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
	clc
	adc #1 ;offset for the empty character
	;add current text type offset(first 2 bits of TextInfo)
	sta zp_temp_1 ;store a in zp_temp_1 for bitwise logic
	lda zp_text_info
	and #%00000011
	cmp #KEYBOARD_INFO_BOLD
	bne :+ ; if its bold
		lda zp_temp_1
		clc
		adc #70
		rts
 :
	cmp #KEYBOARD_INFO_ITALIC
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

.macro draw_sprite_at_location_T2 x_pos, x_offset, x_is_subtracting, y_pos, y_offset, y_is_subtracting, sprite, spriteIdx ; for some fucken reason if you subtract it subtracts by offset +1, i clear the carry flag so got no fucken clue
	
	lda #0
	clc
	adc spriteIdx ;spriteIdx *4 is the offset for the cpu_oam ptr
	adc spriteIdx
	adc spriteIdx
	adc spriteIdx
	sta zp_temp_2

	lda y_pos
	ldx y_is_subtracting
	cpx #0
	beq :+
		clc
		sbc y_offset
		jmp :++ 
	:
		clc
		adc y_offset
	:
	ldy zp_temp_2
	sta CPU_OAM_PTR, y
	
	lda zp_temp_2
	clc
	adc #01
	tay 
	lda sprite 
	sta CPU_OAM_PTR, y

	lda x_pos
	ldx x_is_subtracting
	cpx #0
	beq :+
		clc
		sbc x_offset
		jmp :++ 
	:
		clc
		adc x_offset
	:
	tax
	lda zp_temp_2
	clc
	adc #3
	tay
	txa
	sta CPU_OAM_PTR, y

.endmacro

.proc handle_down_button_press
	lda screen_keyboard_index
	;if the idx is lower than  33, add 11 and skip
	cmp #KEYBOARD_IDX_R
	bpl :+
		clc
		adc #11
		sta screen_keyboard_index
		rts
	:
	;if its lower than 44, go to 44 and skip
	cmp #KEYBOARD_IDX_SPACEBAR
	bpl :+
		lda #KEYBOARD_IDX_SPACEBAR
		sta screen_keyboard_index
		rts
	:
	;if its 44, skip
	cmp #KEYBOARD_IDX_SPACEBAR
	bne :+
		rts
	:
	;if its 48, skip
	cmp #KEYBOARD_IDX_PREV_PAGE
	bne :+
		rts
	:
	;if its 49, skip
	cmp #KEYBOARD_IDX_SHIFT
	bne :+
		rts
	:
	;if its lower than 48, add 2 and skip
	cmp #KEYBOARD_IDX_PREV_PAGE
	bpl :+
		clc
		adc #2
		sta screen_keyboard_index
		rts
	:
	rts
.endproc

.proc handle_up_button_press
	lda screen_keyboard_index
	;if the current idx is lower than 12, skip
	cmp #KEYBOARD_IDX_A
	bpl :+
		rts
	:
	;if the current idx is 45 skip
	cmp #KEYBOARD_IDX_ITALIC
	bne :+
		rts
	:
	;if the current idx is 46 skip
	cmp #KEYBOARD_IDX_NEXT_PAGE
	bne :+
		rts
	:
	;if its lower than 44 subtract by 11, then skip
	cmp #KEYBOARD_IDX_UNDERSCORE+1
	bpl :+
		clc
		sbc #10
		sta screen_keyboard_index
		rts
	:
	;if its 44, make it 40 then skip
	cmp #KEYBOARD_IDX_SPACEBAR
	bne :+
		lda #38
		sta screen_keyboard_index
		rts
	:
	;if its lower than 49, subtract by 2
	cmp #KEYBOARD_IDX_SHIFT + 1
	bpl :+
		sec
		sbc #2
		sta screen_keyboard_index
		rts
	:
	rts
.endproc

.proc handle_right_button_press
	;if current idx is 44, skip
	lda screen_keyboard_index
	cmp #KEYBOARD_IDX_SPACEBAR
	bne :+
		rts
	:
	;if its 48, skip
	cmp #KEYBOARD_IDX_NEXT_PAGE
	bne :+
		rts
	:
	;if its 46, skip
	cmp #KEYBOARD_IDX_PREV_PAGE
	bne :+
		rts
	:
	;special cases for control characters 

	;if its 10, go to 45, then skip
	cmp #KEYBOARD_IDX_EXCLAMATION
	bne :+
		lda #KEYBOARD_IDX_ITALIC
		sta screen_keyboard_index
		rts
	:
	;if its 21, go to 47, then skip
	cmp #KEYBOARD_IDX_PERIOD
	bne :+
		lda #KEYBOARD_IDX_BOLD
		sta screen_keyboard_index
		rts
	:
	;if its 32, go to 49, then skip
	cmp #KEYBOARD_IDX_COLON
	bne :+
		lda #KEYBOARD_IDX_SHIFT
		sta screen_keyboard_index
		rts
	:
	;if its 43, go to 49, then skip
	cmp #KEYBOARD_IDX_UNDERSCORE
	bne :+
		lda #KEYBOARD_IDX_SHIFT
		sta screen_keyboard_index
		rts
	:

	;if its 45, go to 46, then skip
	cmp #KEYBOARD_IDX_ITALIC
	bne :+
		lda #KEYBOARD_IDX_NEXT_PAGE
		sta screen_keyboard_index
		rts
	:
	;if its 47, go to 48, then skip
	cmp #KEYBOARD_IDX_BOLD
	bne :+
		lda #KEYBOARD_IDX_PREV_PAGE
		sta screen_keyboard_index
		rts
	:
	;if its 49, go to 48, then skip
	cmp #KEYBOARD_IDX_SHIFT
	bne :+
		lda #KEYBOARD_IDX_PREV_PAGE
		sta screen_keyboard_index
		rts
	:

	;otherwise, increase it by 1, and skip
	tax
	inx
	txa
	sta screen_keyboard_index
	rts
.endproc

.proc handle_left_button_press
	;if current idx is 44, skip
	lda screen_keyboard_index
	cmp #KEYBOARD_IDX_SPACEBAR
	bne :+
		rts
	:
	;if its 0, skip
	cmp #KEYBOARD_IDX_0
	bne :+
		rts
	:
	;if its 11, skip
	cmp #KEYBOARD_IDX_A
	bne :+
		rts
	:
	;if its 22, skip
	cmp #KEYBOARD_IDX_I
	bne :+
		rts
	:
	;if its 33, skip
	cmp #KEYBOARD_IDX_R
	bne :+
		rts
	:

	;special cases for control characters 

	;if its 45, go to 21, then skip
	cmp #KEYBOARD_IDX_ITALIC
	bne :+
		lda #KEYBOARD_IDX_PERIOD
		sta screen_keyboard_index
		rts
	:
	;if its 47, go to 32, then skip
	cmp #KEYBOARD_IDX_BOLD
	bne :+
		lda #KEYBOARD_IDX_COLON
		sta screen_keyboard_index
		rts
	:
	;if its 49, go to 43, then skip
	cmp #KEYBOARD_IDX_SHIFT
	bne :+
		lda #KEYBOARD_IDX_UNDERSCORE
		sta screen_keyboard_index
		rts
	:

	;if its 46, go to 45, then skip
	cmp #KEYBOARD_IDX_NEXT_PAGE
	bne :+
		lda #KEYBOARD_IDX_ITALIC
		sta screen_keyboard_index
		rts
	:
	;if its 48, go to 49, then skip
	cmp #KEYBOARD_IDX_PREV_PAGE
	bne :+
		lda #KEYBOARD_IDX_SHIFT
		sta screen_keyboard_index
		rts
	:
	;otherwise, decrease it by 1
	tax
	dex
	txa
	sta screen_keyboard_index
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

