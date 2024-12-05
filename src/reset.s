.proc reset ;LINTEXCLUDE
	lda PPU_STATUS
	lda #0
	sta PPU_SCROLL
	sta PPU_SCROLL

	sei			; mask interrupts
	lda #0
	sta PPU_CONTROL	; disable NMI
	sta PPU_MASK	; disable rendering
	sta APU_DM_CONTROL	; disable DMC IRQ
	lda #$40
	sta JOYPAD2		; disable APU frame IRQ

	cld			; disable decimal mode
	ldx #$FF
	txs			; initialise stack

	; wait for first vBlank
	bit PPU_STATUS
wait_vblank:
	bit PPU_STATUS
	bpl wait_vblank

	lda PPU_STATUS
	lda #0
	sta PPU_SCROLL
	sta PPU_SCROLL
		lda PPU_STATUS
	lda #0
	sta PPU_SCROLL
	sta PPU_SCROLL
	; clear all RAM to 0
	lda #0
	ldx #0
clear_ram:
	sta $0000,x
	sta $0100,x
	sta $0200,x
	sta $0300,x
	sta $0400,x
	sta $0500,x
	sta $0600,x
	sta $0700,x
	inx
	bne clear_ram

	; handy for debugging if a clean page is needed
	; jsr clear_wram_p1

	; place all sprites offscreen at Y=255
	lda #255
	ldx #0
clear_oam:
	sta oam,x
	inx
	inx
	inx
	inx
	bne clear_oam

; wait for second vBlank
wait_vblank2:
	bit PPU_STATUS
	bpl wait_vblank2

	; NES is initialized and ready to begin
	; - enable the NMI for graphical updates and jump to our main program
	lda #%10000000
	sta PPU_CONTROL
	
	jmp main
.endproc
