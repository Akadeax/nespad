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
	lda notepad_state
	and #%00001000
	beq not_special_keyboard
		jsr redraw_symbol_keyboard_T0
		rts
	not_special_keyboard:
	


	lda notepad_state
	and #%00000011
	cmp #KEYBOARD_INFO_NORMAL
	bne not_normal_text
		lda notepad_state
		and #%00000100
		bne is_normal_capital
			draw_segment normalKeyboard1, $FF
			draw_segment normalKeyboard2, $C0
			jmp endProc
		is_normal_capital:
		draw_segment normalCapitalKeyboard1, $FF
		draw_segment normalCapitalKeyboard2, $C0
		jmp endProc
	not_normal_text:
	cmp #KEYBOARD_INFO_BOLD
	bne not_bold_text
		lda notepad_state
		and #%00000100
		bne is_bold_capital
			draw_segment boldKeyboard1, $FF
			draw_segment boldKeyboard2, $C0
			jmp endProc
		is_bold_capital:
		draw_segment boldCapitalKeyboard1, $FF
		draw_segment boldCapitalKeyboard2, $C0
		jmp endProc
	not_bold_text:
	cmp #KEYBOARD_INFO_ITALIC
	bne not_italic_text
		lda notepad_state
		and #%00000100
		bne is_italic_capital
			draw_segment italicKeyboard1, $FF
			draw_segment italicKeyboard2, $C0
			jmp endProc
		is_italic_capital:
		draw_segment italicCapitalKeyboard1, $FF
		draw_segment italicCapitalKeyboard2, $C0
		jmp endProc
	not_italic_text:
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
		bpl :+ ; if its lower than 20, render 1 as the first number
			lda #$02 ;index of character 1
			sta PPU_DATA
			lda current_page
			sec
			sbc #8
			sta PPU_DATA
			rts
		:
		cpx #30
		bpl :+ ; if its lower than 30, render 2 as the first number
			lda #$03 ;index of character 2
			sta PPU_DATA
			lda current_page
			sec
			sbc #18
			sta PPU_DATA
			rts
		:
		cpx #40
		bpl :+ ; if its lower than 40, render 3 as the first number
			lda #$04 ;index of character 3
			sta PPU_DATA
			lda current_page
			sec
			sbc #28
			sta PPU_DATA
			rts
		:
		
.endproc

.proc redraw_symbol_keyboard_T0 ;LINTEXCLUDE
	draw_segment characterKeyboard1, $FF
	draw_segment characterKeyboard2, $C0
	;render the line number
	jsr redraw_line_counter_T0
	rts
.endproc

.proc redraw_line_counter_T0
	lda PPU_STATUS
	ldx #$04 ; low byte idx
	ldy #$23
	sty PPU_ADDR
	stx PPU_ADDR
	jsr get_selected_line_T0
	lda zp_temp_0
	adc #1
	sta PPU_DATA
	rts
.endproc

.macro draw_sprite_at_location_T2 x_pos, x_offset, x_is_subtracting, y_pos, y_offset, y_is_subtracting, sprite, spriteIdx, attribute ; for some fucken reason if you subtract it subtracts by offset +1, i clear the carry flag so got no fucken clue
	
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

	lda zp_temp_2
	clc
	adc #02
	tay 
	lda attribute 
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