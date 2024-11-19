.include "constants.s"

; NES Cartridge header
.segment "HEADER"
INES_MAPPER = 0 ; 0 = NROM
INES_MIRROR = 0 ; 0 = horizontal mirroring, 1 = vertical mirroring
INES_SRAM   = 1 ; 1 = battery backed SRAM at $6000-7FFF

.byte 'N', 'E', 'S', $1A ; ID
.byte $02 ; 16k PRG bank count
.byte $01 ; 8k CHR bank count
.byte INES_MIRROR | (INES_SRAM << 1) | ((INES_MAPPER & $f) << 4)
.byte (INES_MAPPER & %11110000)
.byte $0, $0, $0, $0, $0, $0, $0, $0 ; padding

; Import both the background and sprite character sets
.segment "TILES"
.incbin "game.chr"

; Define NES interrupt vectors
.segment "VECTORS"
.word nmi
.word reset
.word irq

;********************************************
; Reserves
;********************************************

; 6502 Zero Page Memory (256 bytes)
.segment "ZEROPAGE"

nmi_ready: .res 1 ; set to 1 to push a PPU frame update, 2 to turn rendering off next NMI

current_input:				.res 1 ; stores the current gamepad values
last_frame_input:			.res 1
input_pressed_this_frame:	.res 1
input_released_this_frame:	.res 1

current_page: .res 1 ; current page in WRAM; used to calc the other vars here on page load
current_text_index: .res 1 ; text index betewen 0-251 (252 characters; PAGE_TEXT_SIZE)

current_wram_text_ptr_lo: .res 1 ; pointer keeping up with text_index, but in actual WRAM
current_wram_text_ptr_hi: .res 1
current_nametable_ptr_lo: .res 1 ; pointer keeping up with text_index, but in nametable memory
current_nametable_ptr_hi: .res 1

a_held: .res 1
a_time_held: .res 1

screen_keyboard_index:  .res 1
.segment "ZEROPAGE"
zp_temp_0: .res 1
zp_temp_1: .res 1
zp_temp_2: .res 1
zp_temp_3: .res 1
zp_temp_4: .res 1
zp_temp_5: .res 1
zp_temp_6: .res 1
zp_temp_7: .res 1
zp_temp_8: .res 1
zp_temp_9: .res 1


; Sprite OAM Data area - copied to VRAM in NMI routine
.segment "OAM"
oam: .res 256	; sprite OAM data

; Remainder of normal RAM area
.segment "BSS"
palette: .res 32 ; current palette buffer

;*****************************************************************
; Main application logic section
;*****************************************************************

;***************************************
; Some useful functions
.segment "CODE"
.include "util.s"

;***************************************
; starting point
.segment "CODE"
.include "reset.s"

;***************************************
; nmi
.segment "CODE"
.include "nmi.s"

;***************************************
; irq
.segment "CODE"
irq:
	rti

;***************************************
.segment "CODE"
.proc main
 	; main application - rendering is currently off
 	; clear 1st name table
 	jsr clear_nametable

 	; initialize palette table
 	ldx #0
paletteloop:
	lda default_palette, x
	sta palette, x
	inx
	cpx #32
	bcc paletteloop

 	; get the screen to render
 	jsr ppu_update

	jsr redraw_current_page_T2

	.include "mainloop.s"
.endproc

;***************************************
; Our default palette table; 16 entries for tiles and 16 entries for sprites
.segment "RODATA"
default_palette:
.byte $0f,$00,$10,$30
.byte $0f,$0c,$21,$32
.byte $0f,$05,$16,$27
.byte $0f,$0b,$1a,$29
.byte $0f,$00,$10,$30
.byte $0f,$0c,$21,$32
.byte $0f,$05,$16,$27
.byte $0f,$0b,$1a,$29
