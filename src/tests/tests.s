.include "test_framework.s"

start_tests

__CATEGORY__ ; Testing Keyboard Input
    __CASE__ ; Keyboard test 1
        lda #12
        sta screen_keyboard_index
        jsr keyboard_idx_to_nametable_pos_T2
        TEST_val16_eq_literal zp_temp_1, zp_temp_2, $02C5
        jsr convert_nametable_index_to_XY_T2
        TEST_val_eq_literal zp_temp_0, $28
        TEST_val_eq_literal zp_temp_1, $B0
        ;test for each of the keyboard states
        lda #%00000100
        sta notepad_state
        jsr keyboard_idx_to_pattern_idx_T1
        TEST_a_eq_literal $2E

    __CASE__ ; Keyboard test 2

        lda #20
        sta screen_keyboard_index
        jsr keyboard_idx_to_nametable_pos_T2
        TEST_val16_eq_literal zp_temp_1, zp_temp_2, $02D5
        jsr convert_nametable_index_to_XY_T2
        TEST_val_eq_literal zp_temp_0, $A8
        TEST_val_eq_literal zp_temp_1, $B0
        lda #%00000101
        sta notepad_state
        jsr keyboard_idx_to_pattern_idx_T1
        TEST_a_eq_literal $53

    __CASE__ ; Keyboard test 3

        lda #41
        sta screen_keyboard_index
        jsr keyboard_idx_to_nametable_pos_T2
        TEST_val16_eq_literal zp_temp_1, zp_temp_2, $0353
        jsr convert_nametable_index_to_XY_T2
        TEST_val_eq_literal zp_temp_0, $98
        TEST_val_eq_literal zp_temp_1, $D0

        lda #%00000010
        sta notepad_state
        jsr keyboard_idx_to_pattern_idx_T1
        TEST_a_eq_literal $B8

    __CASE__ ; Keyboard test 4
        lda #44
        sta screen_keyboard_index
        jsr keyboard_idx_to_nametable_pos_T2
        TEST_val16_eq_literal zp_temp_1, zp_temp_2, $038A
        jsr convert_nametable_index_to_XY_T2
        TEST_val_eq_literal zp_temp_0, $50
        TEST_val_eq_literal zp_temp_1, $E0
        lda #%00000110
        sta notepad_state
        jsr keyboard_idx_to_pattern_idx_T1
        TEST_a_eq_literal $E7

__CATEGORY__ ; Conversion Tests
    __CASE__ ; If end of line

        set_carry_if_eol #27
        TEST_carry_set
        set_carry_if_eol #50
        TEST_carry_clear
        set_carry_if_eol #223
        TEST_carry_set
        set_carry_if_eol #0
        TEST_carry_clear

    __CASE__ ; If start of line

        set_carry_if_sol #27
        TEST_carry_clear
        set_carry_if_sol #28
        TEST_carry_set
        set_carry_if_sol #50
        TEST_carry_clear
        set_carry_if_sol #224
        TEST_carry_set
        set_carry_if_sol #0 ; yes, 0 shouldn't count as line start. This prevents wrong nametable offsets at the start of a page.
        TEST_carry_clear

    __CASE__ ; Increment nametable ptr
        lda #28
        sta current_text_index
        lda #$20
        sta current_nametable_ptr_hi
        lda #$82
        sta current_nametable_ptr_lo
        jsr increment_nametable_ptr
        TEST_val16_eq_literal current_nametable_ptr_lo, current_nametable_ptr_hi, $2083

        lda #0
        sta current_text_index
        lda #$20
        sta current_nametable_ptr_hi
        lda #$00
        sta current_nametable_ptr_lo
        jsr increment_nametable_ptr
        TEST_val16_eq_literal current_nametable_ptr_lo, current_nametable_ptr_hi, $2001

        lda #223
        sta current_text_index
        lda #$22
        sta current_nametable_ptr_hi
        lda #$1D
        sta current_nametable_ptr_lo
        jsr increment_nametable_ptr
        TEST_val16_eq_literal current_nametable_ptr_lo, current_nametable_ptr_hi, $2242

    __CASE__ ; Decrement nametable ptr
        lda #27
        sta current_text_index
        lda #$20
        sta current_nametable_ptr_hi
        lda #$5d
        sta current_nametable_ptr_lo

        jsr decrement_nametable_ptr_T0
        TEST_val16_eq_literal current_nametable_ptr_lo, current_nametable_ptr_hi, $205C

        lda #29
        sta current_text_index
        lda #$20
        sta current_nametable_ptr_hi
        lda #$83
        sta current_nametable_ptr_lo

        jsr decrement_nametable_ptr_T0
        TEST_val16_eq_literal current_nametable_ptr_lo, current_nametable_ptr_hi, $2082

        lda #28
        sta current_text_index
        lda #$20
        sta current_nametable_ptr_hi
        lda #$82
        sta current_nametable_ptr_lo

        jsr decrement_nametable_ptr_T0
        TEST_val16_eq_literal current_nametable_ptr_lo, current_nametable_ptr_hi, $205D

__CATEGORY__ ; Input Testing
    __CASE__ ; Button down test
        lda #25
        sta screen_keyboard_index
        jsr handle_down_button_press_T2
        TEST_val_eq_literal screen_keyboard_index, 36

        lda #36
        sta screen_keyboard_index
        jsr handle_down_button_press_T2
        TEST_val_eq_literal screen_keyboard_index, 44

        lda #44
        sta screen_keyboard_index
        jsr handle_down_button_press_T2
        TEST_val_eq_literal screen_keyboard_index, 44

        lda #47
        sta screen_keyboard_index
        jsr handle_down_button_press_T2
        TEST_val_eq_literal screen_keyboard_index, 49

    __CASE__ ; Button up test
        lda #25
        sta screen_keyboard_index
        jsr handle_up_button_press_T2
        TEST_val_eq_literal screen_keyboard_index, 14

        lda #44
        sta screen_keyboard_index
        jsr handle_up_button_press_T2
        TEST_val_eq_literal screen_keyboard_index, 38

        lda #9
        sta screen_keyboard_index
        jsr handle_up_button_press_T2
        TEST_val_eq_literal screen_keyboard_index, 9

        lda #48
        sta screen_keyboard_index
        jsr handle_up_button_press_T2
        TEST_val_eq_literal screen_keyboard_index, 46

    __CASE__ ; Button left test
        lda #25
        sta screen_keyboard_index
        jsr handle_left_button_press_T2
        TEST_val_eq_literal screen_keyboard_index, 24

        lda #36
        sta screen_keyboard_index
        jsr handle_left_button_press_T2
        TEST_val_eq_literal screen_keyboard_index, 35

        lda #44
        sta screen_keyboard_index
        jsr handle_left_button_press_T2
        TEST_val_eq_literal screen_keyboard_index, 44

        lda #47
        sta screen_keyboard_index
        jsr handle_left_button_press_T2
        TEST_val_eq_literal screen_keyboard_index, 32

    __CASE__ ; Button right test
        lda #25
        sta screen_keyboard_index
        jsr handle_right_button_press_T2
        TEST_val_eq_literal screen_keyboard_index, 26

        lda #44
        sta screen_keyboard_index
        jsr handle_right_button_press_T2
        TEST_val_eq_literal screen_keyboard_index, 44

        lda #9
        sta screen_keyboard_index
        jsr handle_right_button_press_T2
        TEST_val_eq_literal screen_keyboard_index, 10

        lda #48
        sta screen_keyboard_index
        jsr handle_right_button_press_T2
        TEST_val_eq_literal screen_keyboard_index, 48


__CATEGORY__ ; Redraw Functions
    __CASE__ ; Set pointers to last character of page

        reset_current_nametable_ptr
        jsr clear_wram_p1

        lda #0
        sta current_page
        lda #2 ; 1
        sta $6000
        lda #3 ; 2
        sta $6001
        lda #255 ; space
        sta $6002
        lda #4 ; 3
        sta $6003

        jsr set_pointers_to_last_character_of_current_page

        TEST_val_eq_literal current_text_index, 4
        TEST_val16_eq_literal current_wram_text_ptr_lo, current_wram_text_ptr_hi, $6004
        TEST_val16_eq_literal current_nametable_ptr_lo, current_nametable_ptr_hi, $2046


        reset_current_nametable_ptr
        jsr clear_wram_p1

        lda #0
        sta current_wram_text_ptr_lo
        lda #$60
        sta current_wram_text_ptr_hi

        lda #255 ; space
        ldy #0
        :
        sta (current_wram_text_ptr_lo),y
        iny
        cpy #$20
        bne :-

        lda #2
        sta $6020

        jsr set_pointers_to_last_character_of_current_page
        TEST_val_eq_literal current_text_index, $21
        TEST_val16_eq_literal current_wram_text_ptr_lo, current_wram_text_ptr_hi, $6021
        TEST_val16_eq_literal current_nametable_ptr_lo, current_nametable_ptr_hi, $2087


        reset_current_nametable_ptr
        jsr clear_wram_p1

        lda #0
        sta current_wram_text_ptr_lo
        lda #$60
        sta current_wram_text_ptr_hi

        ; write exactly 28 spaces; nametable ptr should be on next line
        lda #255 ; space
        ldy #0
        :
        sta (current_wram_text_ptr_lo),y
        iny
        cpy #28
        bne :-

        jsr set_pointers_to_last_character_of_current_page

        TEST_val_eq_literal current_text_index, 28
        TEST_val16_eq_literal current_wram_text_ptr_lo, current_wram_text_ptr_hi, $601C
        TEST_val16_eq_literal current_nametable_ptr_lo, current_nametable_ptr_hi, $2082


__CATEGORY__ ;selected line tests
    __CASE__ ;get line indicator
        lda #%01110000
        sta notepad_state
        jsr get_selected_line_T0
        TEST_val_eq_literal zp_temp_0, %0111

        lda #%01000000
        sta notepad_state
        jsr get_selected_line_T0
        TEST_val_eq_literal zp_temp_0, %0100

        lda #%00110000
        sta notepad_state
        jsr get_selected_line_T0
        TEST_val_eq_literal zp_temp_0, %0011

        lda #%10000000
        sta notepad_state
        jsr get_selected_line_T0
        TEST_val_eq_literal zp_temp_0, %1000

    __CASE__ ;increment line indicator

        lda #0
        sta notepad_state
        jsr increment_selected_line_T0
        TEST_val_eq_literal notepad_state, %00010000

        lda #5
        asl
        asl
        asl
        asl
        sta notepad_state
        jsr increment_selected_line_T0
        TEST_val_eq_literal notepad_state, %01100000

        lda #7
        asl
        asl
        asl
        asl
        sta notepad_state
        jsr increment_selected_line_T0
        TEST_val_eq_literal notepad_state, %10000000

        lda #8
        asl
        asl
        asl
        asl
        sta notepad_state
        jsr increment_selected_line_T0
        TEST_val_eq_literal notepad_state, %10000000

    __CASE__ ;decrement line indicator

        lda #0
        sta notepad_state
        jsr decrement_selected_line_T0
        TEST_val_eq_literal notepad_state, %00000000

        lda #5
        asl
        asl
        asl
        asl
        sta notepad_state
        jsr decrement_selected_line_T0
        TEST_val_eq_literal notepad_state, %01000000

        lda #7
        asl
        asl
        asl
        asl
        sta notepad_state
        jsr decrement_selected_line_T0
        TEST_val_eq_literal notepad_state, %01100000

        lda #8
        asl
        asl
        asl
        asl
        sta notepad_state
        jsr decrement_selected_line_T0
        TEST_val_eq_literal notepad_state, %01110000

__CATEGORY__ ;color changing tests
    TEST_COLOR_INFO_PTR = $60FC
    __CASE__ ;get color from line pointer 1
        lda #%00110110
        ldy #0
        sta TEST_COLOR_INFO_PTR,y
        lda #0
        sta zp_temp_0
        jsr get_color_from_line_T2
        TEST_val_eq_literal zp_temp_0, %00000010

        lda #%00110110
        ldy #0
        sta TEST_COLOR_INFO_PTR,y
        lda #1
        sta zp_temp_0
        jsr get_color_from_line_T2
        TEST_val_eq_literal zp_temp_0, %00000001

        lda #%00110110
        ldy #0
        sta TEST_COLOR_INFO_PTR,y
        lda #2
        sta zp_temp_0
        jsr get_color_from_line_T2
        TEST_val_eq_literal zp_temp_0, %00000011

        lda #%00110110
        ldy #0
        sta TEST_COLOR_INFO_PTR,y
        lda #3
        sta zp_temp_0
        jsr get_color_from_line_T2
        TEST_val_eq_literal zp_temp_0, %00000000
    __CASE__ ;get color from line pointer 2
        lda #%00110110
        ldy #1
        sta TEST_COLOR_INFO_PTR,y
        lda #4
        sta zp_temp_0
        jsr get_color_from_line_T2
        TEST_val_eq_literal zp_temp_0, %00000010

        lda #%00110110
        ldy #1
        sta TEST_COLOR_INFO_PTR,y
        lda #5
        sta zp_temp_0
        jsr get_color_from_line_T2
        TEST_val_eq_literal zp_temp_0, %00000001

        lda #%00110110
        ldy #1
        sta TEST_COLOR_INFO_PTR,y
        lda #6
        sta zp_temp_0
        jsr get_color_from_line_T2
        TEST_val_eq_literal zp_temp_0, %00000011

        lda #%00110110
        ldy #1
        sta TEST_COLOR_INFO_PTR,y
        lda #7
        sta zp_temp_0
        jsr get_color_from_line_T2
        TEST_val_eq_literal zp_temp_0, %00000000
    __CASE__ ;get color from line pointer 3
        lda #%00000011
        ldy #2
        sta TEST_COLOR_INFO_PTR,y
        lda #8
        sta zp_temp_0
        jsr get_color_from_line_T2
        TEST_val_eq_literal zp_temp_0, %00000011

    __CASE__ ;set color from line pointer 1
        lda #%00110110
        ldy #0
        sta TEST_COLOR_INFO_PTR,y
        lda #%01
        sta zp_temp_1
        lda #0
        sta zp_temp_0
        jsr set_color_from_line_T4
        ldy #0
        lda TEST_COLOR_INFO_PTR,y
        TEST_a_eq_literal %00110101

        lda #%00110110
        ldy #0
        sta TEST_COLOR_INFO_PTR,y
        lda #%00
        sta zp_temp_1
        lda #1
        sta zp_temp_0
        jsr set_color_from_line_T4
        ldy #0
        lda TEST_COLOR_INFO_PTR,y
        TEST_a_eq_literal %00110010
        
        lda #%00110110
        ldy #0
        sta TEST_COLOR_INFO_PTR,y
        lda #%10
        sta zp_temp_1
        lda #2
        sta zp_temp_0
        jsr set_color_from_line_T4
        ldy #0
        lda TEST_COLOR_INFO_PTR,y
        TEST_a_eq_literal %00100110
        
        lda #%00110110
        ldy #0
        sta TEST_COLOR_INFO_PTR,y
        lda #%11
        sta zp_temp_1
        lda #3
        sta zp_temp_0
        jsr set_color_from_line_T4
        ldy #0
        lda TEST_COLOR_INFO_PTR,y
        TEST_a_eq_literal %11110110
    __CASE__ ;set color from line pointer 2
        lda #%00110110
        ldy #1
        sta TEST_COLOR_INFO_PTR,y
        lda #%01
        sta zp_temp_1
        lda #4
        sta zp_temp_0
        jsr set_color_from_line_T4
        ldy #1
        lda TEST_COLOR_INFO_PTR,y
        TEST_a_eq_literal %00110101

        lda #%00110110
        ldy #1
        sta TEST_COLOR_INFO_PTR,y
        lda #%00
        sta zp_temp_1
        lda #5
        sta zp_temp_0
        jsr set_color_from_line_T4
        ldy #1
        lda TEST_COLOR_INFO_PTR,y
        TEST_a_eq_literal %00110010
        
        lda #%00110110
        ldy #1
        sta TEST_COLOR_INFO_PTR,y
        lda #%10
        sta zp_temp_1
        lda #6
        sta zp_temp_0
        jsr set_color_from_line_T4
        ldy #1
        lda TEST_COLOR_INFO_PTR,y
        TEST_a_eq_literal %00100110
        
        lda #%00110110
        ldy #1
        sta TEST_COLOR_INFO_PTR,y
        lda #%11
        sta zp_temp_1
        lda #7
        sta zp_temp_0
        jsr set_color_from_line_T4
        ldy #1
        lda TEST_COLOR_INFO_PTR,y
        TEST_a_eq_literal %11110110

    __CASE__ ;set color from line pointer 3
        lda #%00110110
        ldy #2
        sta TEST_COLOR_INFO_PTR,y
        lda #%01
        sta zp_temp_1
        lda #8
        sta zp_temp_0
        jsr set_color_from_line_T4
        ldy #2
        lda TEST_COLOR_INFO_PTR,y
        TEST_a_eq_literal %00110101
    __CASE__ ;test color increment
        lda #0
        sta notepad_state
        ldy #0
        sta TEST_COLOR_INFO_PTR,y
        jsr increment_color_T0
        ldy #0
        lda TEST_COLOR_INFO_PTR,y
        TEST_a_eq_literal 1

        jsr increment_color_T0
        ldy #0
        lda TEST_COLOR_INFO_PTR,y
        TEST_a_eq_literal 2
        
        jsr increment_color_T0
        ldy #0
        lda TEST_COLOR_INFO_PTR,y
        TEST_a_eq_literal 3
        
        jsr increment_color_T0
        ldy #0
        lda TEST_COLOR_INFO_PTR,y
        TEST_a_eq_literal 0
    __CASE__ ;test color decrement
        lda #0
        sta notepad_state
        ldy #0
        sta TEST_COLOR_INFO_PTR,y
        jsr decrement_color_T0
        ldy #0
        lda TEST_COLOR_INFO_PTR,y
        TEST_a_eq_literal 3

        jsr decrement_color_T0
        ldy #0
        lda TEST_COLOR_INFO_PTR,y
        TEST_a_eq_literal 2
        
        jsr decrement_color_T0
        ldy #0
        lda TEST_COLOR_INFO_PTR,y
        TEST_a_eq_literal 1
        
        jsr decrement_color_T0
        ldy #0
        lda TEST_COLOR_INFO_PTR,y
        TEST_a_eq_literal 0       
end_tests
