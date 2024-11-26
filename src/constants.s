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
DISPLAY_CHARACTER_WIDTH = 28

DISPLAY_LINE_AMOUNT     = 9

DISPLAY_LINE1_END = DISPLAY_CHARACTER_WIDTH * 1
DISPLAY_LINE2_END = DISPLAY_CHARACTER_WIDTH * 2
DISPLAY_LINE3_END = DISPLAY_CHARACTER_WIDTH * 3
DISPLAY_LINE4_END = DISPLAY_CHARACTER_WIDTH * 4
DISPLAY_LINE5_END = DISPLAY_CHARACTER_WIDTH * 5
DISPLAY_LINE6_END = DISPLAY_CHARACTER_WIDTH * 6
DISPLAY_LINE7_END = DISPLAY_CHARACTER_WIDTH * 7
DISPLAY_LINE8_END = DISPLAY_CHARACTER_WIDTH * 8
DISPLAY_LINE9_END = DISPLAY_CHARACTER_WIDTH * 9

TOTAL_PAGE_SIZE = 256
PAGE_TEXT_SIZE = DISPLAY_LINE_AMOUNT * DISPLAY_CHARACTER_WIDTH
PAGE_HEADER = TOTAL_PAGE_SIZE - PAGE_TEXT_SIZE

; -1 to get index
DISPLAY_NAMETABLE_BASE_OFFSET = (NAME_TABLE_1 + (DISPLAY_TOP_MARGIN * DISPLAY_SCREEN_WIDTH + DISPLAY_SIDE_MARGIN))

MAX_PAGE_AMOUNT = 32

;consts for indicator rendering 
KEYBOARD_NAMETABLE_BEGIN_OFFSET = $0283
KEYBOARD_NAMETABLE_NEXTLINE_OFFSET = $2a
KEYBOARD_NAMETABLE_SPACEBAR_POS_OFFSET = $038A
KEYBOARD_NAMETABLE_SHIFT_POS_OFFSET = $0339
KEYBOARD_NAMETABLE_BOLD_POS_OFFSET = $02F9
KEYBOARD_NAMETABLE_ITALIC_POS_OFFSET = $02B9
KEYBOARD_NAMETABLE_PREV_PAGE_POS_OFFSET = $033B
KEYBOARD_NAMETABLE_NEXT_PAGE_POS_OFFSET = $02DB

KEYBOARD_IDX_SPACEBAR = 44
KEYBOARD_IDX_ITALIC = 45
KEYBOARD_IDX_NEXT_PAGE = 46
KEYBOARD_IDX_BOLD = 47
KEYBOARD_IDX_PREV_PAGE = 48
KEYBOARD_IDX_SHIFT = 49