; Define PPU Registers
PPU_CONTROL = $2000 ; PPU Control Register 1 (Write)
PPU_MASK = $2001 ; PPU Control Register 2 (Write)
PPU_STATUS = $2002; PPU Status Register (Read)
PPU_OAMADDR = $2003 ; PPU SPR-RAM Address Register (Write)
PPU_OAMDATA = $2004 ; PPU SPR-RAM I/O Register (Write)
PPU_SCROLL = $2005 ; PPU VRAM Address Register 1 (Write)
PPU_ADDR = $2006 ; PPU VRAM Address Register 2 (Write)
PPU_DATA = $2007 ; VRAM I/O Register (Read/Write)
PPU_OAMDMA = $4014 ; Sprite DMA Register

; Define APU Registers
APU_DM_CONTROL = $4010 ; APU Delta Modulation Control Register (Write)
APU_CLOCK = $4015 ; APU Sound/Vertical Clock Signal Register (Read/Write)

; Joystick/Controller values
JOYPAD1 = $4016 ; Joypad 1 (Read/Write)
JOYPAD2 = $4017 ; Joypad 2 (Read/Write)

; Gamepad bit values
PAD_A      = $01
PAD_B      = $02
PAD_SELECT = $04
PAD_START  = $08
PAD_UP     = $10
PAD_DOWN   = $20
PAD_LEFT   = $40
PAD_RIGHT  = $80

; name tables
NAME_TABLE_1 = $2000
NAME_TABLE_2 = $2400

; text encoding values
LETTER_NORMAL_START = 0
CAPITAL_OFFSET      = 26
NUMBER_OFFSET       = 52
LETTER_BOLD_OFFSET  = 70

; keyboard values
KEYBOARD_CHARACTER_KEY_AMOUNT = 44
KEYBOARD_CONTROL_KEY_AMOUNT   = 3

WRAM_START = $6000
WRAM_END   = $7FFF


; display
DISPLAY_SCREEN_WIDTH  = 32
DISPLAY_SCREEN_HEIGHT = 30

DISPLAY_TOP_MARGIN      = 2
DISPLAY_SIDE_MARGIN     = 2
DISPLAY_CHARACTER_WIDTH = 32 - (DISPLAY_SIDE_MARGIN * 2)

DISPLAY_LINE_AMOUNT     = 7

TOTAL_PAGE_SIZE         = DISPLAY_LINE_AMOUNT * DISPLAY_CHARACTER_WIDTH

DISPLAY_NAMETABLE_BASE_OFFSET =  ($2000 + (DISPLAY_TOP_MARGIN * DISPLAY_SCREEN_WIDTH + DISPLAY_SIDE_MARGIN))
