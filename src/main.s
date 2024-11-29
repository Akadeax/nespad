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

zp_text_info: .res 1

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
.include "draw.s"

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

 	jsr ppu_update

	jsr redraw_current_page_T2
	jsr draw_indicator_T1
	.include "mainloop.s"
.endproc

;***************************************
; Our default palette table; 16 entries for tiles and 16 entries for sprites
.segment "RODATA"
default_palette:
;bg tiles/ text
.byte $0f,$23,$10,$30
.byte $0f,$23,$31,$21
.byte $0f,$23,$24,$14
.byte $0f,$23,$39,$29
;sprites
.byte $0f,$23,$10,$30
.byte $0f,$23,$31,$21
.byte $0f,$23,$24,$14
.byte $0f,$23,$39,$29

preloadScreen1:
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$ea,$f9,$f9,$f9,$f9,$f9,$f9,$f9,$f9,$f9,$f9,$f9,$f9,$f9,$f9,$f9,$f9,$f9,$f9,$f9,$f9,$f9,$f9,$f9,$f9,$f9,$f9,$f9,$f9,$eb,$00
	.byte $00,$f8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$f8,$00
	.byte $00,$f8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$f8,$00
	.byte $00,$f8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$f8,$00
	.byte $00,$f8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$f8,$00
	.byte $00,$f8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$f8,$00
	.byte $00,$f8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$f8,$00
preloadScreen2:
	.byte $00,$f8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$f8,$00
	.byte $00,$f8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$f8,$00
	.byte $00,$f8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$f8,$00
	.byte $00,$f8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$f8,$00
	.byte $00,$f8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$f8,$00
	.byte $00,$f8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$f8,$00
	.byte $00,$f8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$f8,$00
	.byte $00,$f8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$f8,$00

normalKeyboard1: ;normal keyboard
	.byte $00,$f8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$f8,$00
	.byte $00,$f8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$f8,$00
	.byte $00,$f8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$f8,$00
	.byte $00,$fa,$d3,$d4,$d6,$d4,$d6,$d4,$d6,$d4,$d6,$d4,$d6,$d4,$d6,$d4,$d6,$d4,$d6,$d4,$d6,$d4,$d6,$d4,$d6,$d4,$d6,$d4,$d4,$d5,$fb,$00
	.byte $00,$00,$de,$01,$d8,$02,$d8,$03,$d8,$04,$d8,$05,$d8,$06,$d8,$07,$d8,$08,$d8,$09,$d8,$0a,$d8,$0b,$dd,$d9,$d7,$d9,$d9,$e0,$00,$00
	.byte $00,$00,$df,$d9,$d7,$d9,$d7,$d9,$d7,$d9,$d7,$d9,$d7,$d9,$d7,$d9,$d7,$d9,$d7,$d9,$d7,$d9,$d7,$d9,$dc,$f1,$d8,$ec,$ed,$e1,$00,$00
	.byte $00,$00,$de,$13,$d8,$14,$d8,$15,$d8,$16,$d8,$17,$d8,$18,$d8,$19,$d8,$1a,$d8,$0c,$d8,$0d,$d8,$0e,$dd,$d9,$dc,$fc,$fd,$e1,$00,$00
	.byte $00,$00,$df,$d9,$d7,$d9,$d7,$d9,$d7,$d9,$d7,$d9,$d7,$d9,$d7,$d9,$d7,$d9,$d7,$d9,$d7,$d9,$d7,$d9,$dc,$f3,$dd,$d9,$d9,$e0,$00,$00
normalKeyboard2:
	.byte $00,$00,$de,$1b,$d8,$1c,$d8,$1d,$d8,$1e,$d8,$1f,$d8,$20,$d8,$21,$d8,$22,$d8,$23,$d8,$0f,$d8,$10,$dd,$d9,$dc,$ee,$ef,$e1,$00,$00
	.byte $00,$00,$df,$d9,$d7,$d9,$d7,$d9,$d7,$d9,$d7,$d9,$d7,$d9,$d7,$d9,$d7,$d9,$d7,$d9,$d7,$d9,$d7,$d9,$dc,$f5,$d8,$fe,$ff,$e1,$00,$00
	.byte $00,$00,$de,$24,$d8,$25,$d8,$26,$d8,$27,$d8,$28,$d8,$29,$d8,$2a,$d8,$2b,$d8,$2c,$d8,$11,$d8,$12,$dd,$d9,$d7,$d9,$d9,$e0,$00,$00
	.byte $00,$00,$df,$d9,$da,$d9,$da,$d9,$da,$db,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$db,$da,$db,$da,$d9,$da,$d9,$da,$db,$d9,$e0,$00,$00
	.byte $00,$00,$de,$3a,$31,$3f,$3c,$2d,$30,$d8,$e7,$e8,$e8,$e8,$e8,$e8,$e8,$e8,$e9,$d8,$f6,$d8,$01,$02,$e6,$04,$03,$d8,$f7,$e1,$00,$00
	.byte $00,$00,$e2,$e4,$e4,$e4,$e4,$e4,$e4,$e5,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e5,$e4,$e5,$e4,$e4,$e4,$e4,$e4,$e5,$e4,$e3,$00,$00


capitalKeyboard1:	
	.byte $00,$f8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$f8,$00
	.byte $00,$f8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$f8,$00
	.byte $00,$f8,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$f8,$00
	.byte $00,$fa,$d3,$d4,$d6,$d4,$d6,$d4,$d6,$d4,$d6,$d4,$d6,$d4,$d6,$d4,$d6,$d4,$d6,$d4,$d6,$d4,$d6,$d4,$d6,$d4,$d6,$d4,$d4,$d5,$fb,$00
	.byte $00,$00,$de,$01,$d8,$02,$d8,$03,$d8,$04,$d8,$05,$d8,$06,$d8,$07,$d8,$08,$d8,$09,$d8,$0a,$d8,$0b,$dd,$d9,$d7,$d9,$d9,$e0,$00,$00
	.byte $00,$00,$df,$d9,$d7,$d9,$d7,$d9,$d7,$d9,$d7,$d9,$d7,$d9,$d7,$d9,$d7,$d9,$d7,$d9,$d7,$d9,$d7,$d9,$dc,$f1,$d8,$ec,$ed,$e1,$00,$00
	.byte $00,$00,$de,$2d,$d8,$2e,$d8,$2f,$d8,$30,$d8,$31,$d8,$32,$d8,$33,$d8,$34,$d8,$0c,$d8,$0d,$d8,$0e,$dd,$d9,$dc,$fc,$fd,$e1,$00,$00
	.byte $00,$00,$df,$d9,$d7,$d9,$d7,$d9,$d7,$d9,$d7,$d9,$d7,$d9,$d7,$d9,$d7,$d9,$d7,$d9,$d7,$d9,$d7,$d9,$dc,$f3,$dd,$d9,$d9,$e0,$00,$00
capitalKeyboard2:
	.byte $00,$00,$de,$35,$d8,$36,$d8,$37,$d8,$38,$d8,$39,$d8,$3a,$d8,$3b,$d8,$3c,$d8,$3d,$d8,$0f,$d8,$10,$dd,$d9,$dc,$ee,$ef,$e1,$00,$00
	.byte $00,$00,$df,$d9,$d7,$d9,$d7,$d9,$d7,$d9,$d7,$d9,$d7,$d9,$d7,$d9,$d7,$d9,$d7,$d9,$d7,$d9,$d7,$d9,$dc,$f4,$d8,$fe,$ff,$e1,$00,$00
	.byte $00,$00,$de,$3e,$d8,$3f,$d8,$40,$d8,$41,$d8,$42,$d8,$43,$d8,$44,$d8,$45,$d8,$46,$d8,$11,$d8,$12,$dd,$d9,$d7,$d9,$d9,$e0,$00,$00
	.byte $00,$00,$df,$d9,$da,$d9,$da,$d9,$da,$db,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$db,$da,$db,$da,$d9,$da,$d9,$da,$db,$d9,$e0,$00,$00
	.byte $00,$00,$de,$3a,$31,$3f,$3c,$2d,$30,$d8,$e7,$e8,$e8,$e8,$e8,$e8,$e8,$e8,$e9,$d8,$f6,$d8,$01,$02,$e6,$04,$03,$d8,$f7,$e1,$00,$00
	.byte $00,$00,$e2,$e4,$e4,$e4,$e4,$e4,$e4,$e5,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e4,$e5,$e4,$e5,$e4,$e4,$e4,$e4,$e4,$e5,$e4,$e3,$00,$00

