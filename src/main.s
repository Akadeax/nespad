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

a_time_held: .res 1
b_time_held: .res 1
start_time_held: .res 1
down_time_held: .res 1
up_time_held: .res 1
left_time_held: .res 1
right_time_held: .res 1

frame_counter: .res 1 ;doesnt really count frames but can be used for stuff that needs to happen every 10 frames ect ect

notepad_state: .res 1

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
.include "utils/utils.s"
.include "utils/nametable_utils.s"
.include "utils/keyboard_utils.s"
.include "utils/drawing_utils.s"
.include "utils/input_utils.s"
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
.proc main ;LINTEXCLUDE
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

.ifdef TESTS
	.include "tests/tests.s"
.endif

	jsr redraw_current_page_T5
	jsr draw_indicator_T1
	.include "mainloop.s"
.endproc

;***************************************
; Our default palette table; 16 entries for tiles and 16 entries for sprites
.segment "RODATA"
default_palette:
;bg tiles/ text
.byte $0f,$23,$10,$30
.byte $0f,$3c,$1c,$2c
.byte $0f,$37,$17,$27
.byte $0f,$3a,$2a,$1a

;sprites
.byte $0f,$23,$10,$30
.byte $0f,$3c,$1c,$2c
.byte $0f,$37,$17,$27
.byte $0f,$3a,$2a,$1a

preloadScreen1:
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$f0,$fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc,$fc,$f1,$00
	.byte $00,$fb,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$fb,$00
	.byte $00,$fb,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$fb,$00
	.byte $00,$fb,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$fb,$00
	.byte $00,$fb,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$fb,$00
	.byte $00,$fb,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$fb,$00
	.byte $00,$fb,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$fb,$00

preloadScreen2:
	.byte $00,$fb,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$fb,$00
	.byte $00,$fb,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$fb,$00
	.byte $00,$fb,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$fb,$00
	.byte $00,$fb,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$fb,$00
	.byte $00,$fb,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$fb,$00
	.byte $00,$fb,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$fb,$00
	.byte $00,$fb,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$fb,$00
	.byte $00,$fb,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$fb,$00


normalKeyboard1: ;normal keyboard
	.byte $00,$fb,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$fb,$00
	.byte $00,$fb,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$fb,$00
	.byte $00,$fb,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$fb,$00
	.byte $00,$f9,$d8,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$da,$db,$fa,$00
	.byte $00,$00,$ea,$01,$e3,$02,$e3,$03,$e3,$04,$e3,$05,$e3,$06,$e3,$07,$e3,$08,$e3,$09,$e3,$0a,$e3,$0b,$f2,$eb,$e2,$eb,$eb,$e4,$00,$00
	.byte $00,$00,$e1,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e9,$e7,$e3,$d3,$d4,$ed,$00,$00
	.byte $00,$00,$ea,$13,$e3,$14,$e3,$15,$e3,$16,$e3,$17,$e3,$18,$e3,$19,$e3,$1a,$e3,$0c,$e3,$0d,$e3,$0e,$f2,$eb,$e9,$dc,$dd,$ed,$00,$00
	.byte $00,$00,$e1,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e9,$de,$f2,$eb,$eb,$e4,$00,$00
normalKeyboard2:
	.byte $00,$00,$ea,$1b,$e3,$1c,$e3,$1d,$e3,$1e,$e3,$1f,$e3,$20,$e3,$21,$e3,$22,$e3,$23,$e3,$0f,$e3,$10,$f2,$eb,$e9,$e5,$e6,$ed,$00,$00
	.byte $00,$00,$e1,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e9,$d5,$e3,$ee,$ef,$ed,$00,$00
	.byte $00,$00,$ea,$24,$e3,$25,$e3,$26,$e3,$27,$e3,$28,$e3,$29,$e3,$2a,$e3,$2b,$e3,$2c,$e3,$11,$e3,$12,$f2,$eb,$e2,$eb,$eb,$e4,$00,$00
	.byte $00,$00,$e1,$eb,$d7,$eb,$d7,$eb,$d7,$e0,$d7,$e0,$d7,$eb,$d7,$eb,$d7,$e0,$d7,$e0,$d7,$e0,$d7,$eb,$d7,$eb,$d7,$e0,$eb,$e4,$00,$00
	.byte $00,$00,$ea,$3a,$31,$3f,$3c,$2d,$30,$e3,$00,$e3,$fd,$fe,$fe,$fe,$ff,$e3,$00,$e3,$f8,$e3,$01,$01,$ec,$04,$03,$e3,$f7,$ed,$00,$00
	.byte $00,$00,$f3,$f5,$f5,$f5,$f5,$f5,$f5,$f4,$f5,$f4,$f5,$f5,$f5,$f5,$f5,$f4,$f5,$f4,$f5,$f4,$f5,$f5,$f5,$f5,$f5,$f4,$f5,$f6,$00,$00





normalCapitalKeyboard1:	
	.byte $00,$fb,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$fb,$00
	.byte $00,$fb,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$fb,$00
	.byte $00,$fb,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$fb,$00
	.byte $00,$f9,$d8,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$da,$db,$fa,$00
	.byte $00,$00,$ea,$01,$e3,$02,$e3,$03,$e3,$04,$e3,$05,$e3,$06,$e3,$07,$e3,$08,$e3,$09,$e3,$0a,$e3,$0b,$f2,$eb,$e2,$eb,$eb,$e4,$00,$00
	.byte $00,$00,$e1,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e9,$e7,$e3,$d3,$d4,$ed,$00,$00
	.byte $00,$00,$ea,$2d,$e3,$2e,$e3,$2f,$e3,$30,$e3,$31,$e3,$32,$e3,$33,$e3,$34,$e3,$0c,$e3,$0d,$e3,$0e,$f2,$eb,$e9,$dc,$dd,$ed,$00,$00
	.byte $00,$00,$e1,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e9,$de,$f2,$eb,$eb,$e4,$00,$00
	
normalCapitalKeyboard2:
	.byte $00,$00,$ea,$35,$e3,$36,$e3,$37,$e3,$38,$e3,$39,$e3,$3a,$e3,$3b,$e3,$3c,$e3,$3d,$e3,$0f,$e3,$10,$f2,$eb,$e9,$e5,$e6,$ed,$00,$00
	.byte $00,$00,$e1,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e9,$d6,$e3,$ee,$ef,$ed,$00,$00
	.byte $00,$00,$ea,$3e,$e3,$3f,$e3,$40,$e3,$41,$e3,$42,$e3,$43,$e3,$44,$e3,$45,$e3,$46,$e3,$11,$e3,$12,$f2,$eb,$e2,$eb,$eb,$e4,$00,$00
	.byte $00,$00,$e1,$eb,$d7,$eb,$d7,$eb,$d7,$e0,$d7,$e0,$d7,$eb,$d7,$eb,$d7,$e0,$d7,$e0,$d7,$e0,$d7,$eb,$d7,$eb,$d7,$e0,$eb,$e4,$00,$00
	.byte $00,$00,$ea,$3a,$31,$3f,$3c,$2d,$30,$e3,$00,$e3,$fd,$fe,$fe,$fe,$ff,$e3,$00,$e3,$f8,$e3,$01,$01,$ec,$04,$03,$e3,$f7,$ed,$00,$00
	.byte $00,$00,$f3,$f5,$f5,$f5,$f5,$f5,$f5,$f4,$f5,$f4,$f5,$f5,$f5,$f5,$f5,$f4,$f5,$f4,$f5,$f4,$f5,$f5,$f5,$f5,$f5,$f4,$f5,$f6,$00,$00



boldKeyboard1:	
	.byte $00,$fb,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$fb,$00
	.byte $00,$fb,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$fb,$00
	.byte $00,$fb,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$fb,$00
	.byte $00,$f9,$d8,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$da,$db,$fa,$00
	.byte $00,$00,$ea,$47,$e3,$48,$e3,$49,$e3,$4a,$e3,$4b,$e3,$4c,$e3,$4d,$e3,$4e,$e3,$4f,$e3,$50,$e3,$51,$f2,$eb,$e2,$eb,$eb,$e4,$00,$00
	.byte $00,$00,$e1,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e9,$e7,$e3,$d3,$d4,$ed,$00,$00
	.byte $00,$00,$ea,$59,$e3,$5a,$e3,$5b,$e3,$5c,$e3,$5d,$e3,$5e,$e3,$5f,$e3,$60,$e3,$52,$e3,$53,$e3,$54,$f2,$eb,$e9,$dc,$dd,$ed,$00,$00
	.byte $00,$00,$e1,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e9,$df,$f2,$eb,$eb,$e4,$00,$00
	
boldKeyboard2:
	.byte $00,$00,$ea,$61,$e3,$62,$e3,$63,$e3,$64,$e3,$65,$e3,$66,$e3,$67,$e3,$68,$e3,$69,$e3,$55,$e3,$56,$f2,$eb,$e9,$e5,$e6,$ed,$00,$00
	.byte $00,$00,$e1,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e9,$d5,$e3,$ee,$ef,$ed,$00,$00
	.byte $00,$00,$ea,$6a,$e3,$6b,$e3,$6c,$e3,$6d,$e3,$6e,$e3,$6f,$e3,$70,$e3,$71,$e3,$72,$e3,$57,$e3,$58,$f2,$eb,$e2,$eb,$eb,$e4,$00,$00
	.byte $00,$00,$e1,$eb,$d7,$eb,$d7,$eb,$d7,$e0,$d7,$e0,$d7,$eb,$d7,$eb,$d7,$e0,$d7,$e0,$d7,$e0,$d7,$eb,$d7,$eb,$d7,$e0,$eb,$e4,$00,$00
	.byte $00,$00,$ea,$3a,$31,$3f,$3c,$2d,$30,$e3,$00,$e3,$fd,$fe,$fe,$fe,$ff,$e3,$00,$e3,$f8,$e3,$01,$01,$ec,$04,$03,$e3,$f7,$ed,$00,$00
	.byte $00,$00,$f3,$f5,$f5,$f5,$f5,$f5,$f5,$f4,$f5,$f4,$f5,$f5,$f5,$f5,$f5,$f4,$f5,$f4,$f5,$f4,$f5,$f5,$f5,$f5,$f5,$f4,$f5,$f6,$00,$00


boldCapitalKeyboard1:	
	.byte $00,$fb,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$fb,$00
	.byte $00,$fb,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$fb,$00
	.byte $00,$fb,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$fb,$00
	.byte $00,$f9,$d8,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$da,$db,$fa,$00
	.byte $00,$00,$ea,$47,$e3,$48,$e3,$49,$e3,$4a,$e3,$4b,$e3,$4c,$e3,$4d,$e3,$4e,$e3,$4f,$e3,$50,$e3,$51,$f2,$eb,$e2,$eb,$eb,$e4,$00,$00
	.byte $00,$00,$e1,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e9,$e7,$e3,$d3,$d4,$ed,$00,$00
	.byte $00,$00,$ea,$73,$e3,$74,$e3,$75,$e3,$76,$e3,$77,$e3,$78,$e3,$79,$e3,$7a,$e3,$52,$e3,$53,$e3,$54,$f2,$eb,$e9,$dc,$dd,$ed,$00,$00
	.byte $00,$00,$e1,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e9,$df,$f2,$eb,$eb,$e4,$00,$00
	
boldCapitalKeyboard2:	
	.byte $00,$00,$ea,$7b,$e3,$7c,$e3,$7d,$e3,$7e,$e3,$7f,$e3,$80,$e3,$81,$e3,$82,$e3,$83,$e3,$55,$e3,$56,$f2,$eb,$e9,$e5,$e6,$ed,$00,$00
	.byte $00,$00,$e1,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e9,$d6,$e3,$ee,$ef,$ed,$00,$00
	.byte $00,$00,$ea,$84,$e3,$85,$e3,$86,$e3,$87,$e3,$88,$e3,$89,$e3,$8a,$e3,$8b,$e3,$8c,$e3,$57,$e3,$58,$f2,$eb,$e2,$eb,$eb,$e4,$00,$00
	.byte $00,$00,$e1,$eb,$d7,$eb,$d7,$eb,$d7,$e0,$d7,$e0,$d7,$eb,$d7,$eb,$d7,$e0,$d7,$e0,$d7,$e0,$d7,$eb,$d7,$eb,$d7,$e0,$eb,$e4,$00,$00
	.byte $00,$00,$ea,$3a,$31,$3f,$3c,$2d,$30,$e3,$00,$e3,$fd,$fe,$fe,$fe,$ff,$e3,$00,$e3,$f8,$e3,$01,$01,$ec,$04,$03,$e3,$f7,$ed,$00,$00
	.byte $00,$00,$f3,$f5,$f5,$f5,$f5,$f5,$f5,$f4,$f5,$f4,$f5,$f5,$f5,$f5,$f5,$f4,$f5,$f4,$f5,$f4,$f5,$f5,$f5,$f5,$f5,$f4,$f5,$f6,$00,$00



italicKeyboard1:	
	.byte $00,$fb,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$fb,$00
	.byte $00,$fb,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$fb,$00
	.byte $00,$fb,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$fb,$00
	.byte $00,$f9,$d8,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$da,$db,$fa,$00
	.byte $00,$00,$ea,$8d,$e3,$8e,$e3,$8f,$e3,$90,$e3,$91,$e3,$92,$e3,$93,$e3,$94,$e3,$95,$e3,$96,$e3,$97,$f2,$eb,$e2,$eb,$eb,$e4,$00,$00
	.byte $00,$00,$e1,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e9,$e8,$e3,$d3,$d4,$ed,$00,$00
	.byte $00,$00,$ea,$9f,$e3,$a0,$e3,$a1,$e3,$a2,$e3,$a3,$e3,$a4,$e3,$a5,$e3,$a6,$e3,$98,$e3,$99,$e3,$9a,$f2,$eb,$e9,$dc,$dd,$ed,$00,$00
	.byte $00,$00,$e1,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e9,$de,$f2,$eb,$eb,$e4,$00,$00

italicKeyboard2:
	.byte $00,$00,$ea,$a7,$e3,$a8,$e3,$a9,$e3,$aa,$e3,$ab,$e3,$ac,$e3,$ad,$e3,$ae,$e3,$af,$e3,$9b,$e3,$9c,$f2,$eb,$e9,$e5,$e6,$ed,$00,$00
	.byte $00,$00,$e1,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e9,$d5,$e3,$ee,$ef,$ed,$00,$00
	.byte $00,$00,$ea,$b0,$e3,$b1,$e3,$b2,$e3,$b3,$e3,$b4,$e3,$b5,$e3,$b6,$e3,$b7,$e3,$b8,$e3,$9d,$e3,$9e,$f2,$eb,$e2,$eb,$eb,$e4,$00,$00
	.byte $00,$00,$e1,$eb,$d7,$eb,$d7,$eb,$d7,$e0,$d7,$e0,$d7,$eb,$d7,$eb,$d7,$e0,$d7,$e0,$d7,$e0,$d7,$eb,$d7,$eb,$d7,$e0,$eb,$e4,$00,$00
	.byte $00,$00,$ea,$3a,$31,$3f,$3c,$2d,$30,$e3,$00,$e3,$fd,$fe,$fe,$fe,$ff,$e3,$00,$e3,$f8,$e3,$01,$01,$ec,$04,$03,$e3,$f7,$ed,$00,$00
	.byte $00,$00,$f3,$f5,$f5,$f5,$f5,$f5,$f5,$f4,$f5,$f4,$f5,$f5,$f5,$f5,$f5,$f4,$f5,$f4,$f5,$f4,$f5,$f5,$f5,$f5,$f5,$f4,$f5,$f6,$00,$00



italicCapitalKeyboard1:	
	.byte $00,$fb,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$fb,$00
	.byte $00,$fb,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$fb,$00
	.byte $00,$fb,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$fb,$00
	.byte $00,$f9,$d8,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$da,$db,$fa,$00
	.byte $00,$00,$ea,$8d,$e3,$8e,$e3,$8f,$e3,$90,$e3,$91,$e3,$92,$e3,$93,$e3,$94,$e3,$95,$e3,$96,$e3,$97,$f2,$eb,$e2,$eb,$eb,$e4,$00,$00
	.byte $00,$00,$e1,$eb,$eb,$eb,$eb,$eb,$eb,$e0,$eb,$e0,$eb,$eb,$eb,$eb,$eb,$e0,$eb,$e0,$eb,$eb,$eb,$eb,$eb,$eb,$eb,$e0,$eb,$e4,$00,$00
	.byte $00,$00,$ea,$3a,$31,$3f,$3c,$2d,$30,$e3,$00,$e3,$fd,$fe,$fe,$fe,$ff,$e3,$00,$e3,$f8,$e3,$01,$01,$ec,$01,$01,$e3,$f7,$ed,$00,$00
	.byte $00,$00,$f3,$f5,$f5,$f5,$f5,$f5,$f5,$f4,$f5,$f4,$f5,$f5,$f5,$f5,$f5,$f4,$f5,$f4,$f5,$f5,$f5,$f5,$f5,$f5,$f5,$f4,$f5,$f6,$00,$00

italicCapitalKeyboard2:
	.byte $00,$00,$ea,$c1,$e3,$c2,$e3,$c3,$e3,$c4,$e3,$c5,$e3,$c6,$e3,$c7,$e3,$c8,$e3,$c9,$e3,$9b,$e3,$9c,$f2,$eb,$e9,$e5,$e6,$ed,$00,$00
	.byte $00,$00,$e1,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e9,$d6,$e3,$ee,$ef,$ed,$00,$00
	.byte $00,$00,$ea,$ca,$e3,$cb,$e3,$cc,$e3,$cd,$e3,$ce,$e3,$cf,$e3,$d0,$e3,$d1,$e3,$d2,$e3,$9d,$e3,$9e,$f2,$eb,$e2,$eb,$eb,$e4,$00,$00
	.byte $00,$00,$e1,$eb,$d7,$eb,$d7,$eb,$d7,$e0,$d7,$e0,$d7,$eb,$d7,$eb,$d7,$e0,$d7,$e0,$d7,$e0,$d7,$eb,$d7,$eb,$d7,$e0,$eb,$e4,$00,$00
	.byte $00,$00,$ea,$3a,$31,$3f,$3c,$2d,$30,$e3,$00,$e3,$fd,$fe,$fe,$fe,$ff,$e3,$00,$e3,$f8,$e3,$01,$01,$ec,$04,$03,$e3,$f7,$ed,$00,$00
	.byte $00,$00,$f3,$f5,$f5,$f5,$f5,$f5,$f5,$f4,$f5,$f4,$f5,$f5,$f5,$f5,$f5,$f4,$f5,$f4,$f5,$f4,$f5,$f5,$f5,$f5,$f5,$f4,$f5,$f6,$00,$00

characterKeyboard1:
	.byte $00,$fb,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$fb,$00
	.byte $00,$fb,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$fb,$00
	.byte $00,$fb,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$fb,$00
	.byte $00,$f9,$d8,$da,$da,$da,$da,$da,$da,$da,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$d9,$da,$db,$fa,$00
	.byte $00,$00,$e1,$eb,$eb,$eb,$e0,$e0,$eb,$eb,$eb,$e9,$d3,$e3,$d4,$e3,$d5,$e3,$d6,$e3,$d7,$e3,$d8,$e3,$d9,$e3,$da,$e3,$db,$ed,$00,$00
	.byte $00,$00,$ea,$00,$d6,$00,$e3,$e3,$00,$d6,$00,$f2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e4,$00,$00
	.byte $00,$00,$ea,$00,$00,$00,$e3,$e3,$00,$00,$00,$e3,$dc,$e3,$dd,$e3,$de,$e3,$df,$e3,$e0,$e3,$e1,$e3,$e2,$e3,$e3,$e3,$e4,$ed,$00,$00
	.byte $00,$00,$ea,$d8,$da,$db,$e3,$e3,$d8,$da,$db,$f2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e4,$00,$00
	
characterKeyboard2:
	.byte $00,$00,$ea,$ea,$00,$ed,$e3,$e3,$ea,$00,$ed,$e3,$e5,$e3,$e6,$e3,$e7,$e3,$e8,$e3,$e9,$e3,$ea,$e3,$eb,$e3,$ec,$e3,$ed,$ed,$00,$00
	.byte $00,$00,$ea,$f3,$f5,$f6,$e3,$e3,$f3,$f5,$f6,$f2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e4,$00,$00
	.byte $00,$00,$ea,$00,$00,$00,$e3,$e3,$00,$00,$00,$e3,$ee,$e3,$ef,$e3,$f0,$e3,$f1,$e3,$f2,$e3,$f3,$e3,$f4,$e3,$f5,$e3,$f6,$ed,$00,$00
	.byte $00,$00,$ea,$00,$d5,$00,$e3,$e3,$00,$d5,$00,$f2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e2,$eb,$e4,$00,$00
	.byte $00,$00,$e1,$eb,$eb,$eb,$d7,$d7,$eb,$eb,$eb,$e9,$f7,$e3,$f8,$e3,$f9,$e3,$fa,$e3,$fb,$e3,$fc,$e3,$fd,$e3,$fe,$e3,$ff,$ed,$00,$00
	.byte $00,$00,$f3,$f5,$f5,$f5,$f5,$f5,$f5,$f5,$f5,$f4,$f5,$f4,$f5,$f4,$f5,$f4,$f5,$f4,$f5,$f4,$f5,$f4,$f5,$f4,$f5,$f4,$f5,$f6,$00,$00

