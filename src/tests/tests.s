.include "test_framework.s"

start_tests

__CATEGORY__ ; Testing keyboard input
__CASE__ ; keyboard_test_1

lda #12
sta screen_keyboard_index
jsr keyboard_idx_to_nametable_pos_T2
TEST_val16_eq_literal zp_temp_1, zp_temp_2, $02C5
jsr convert_nametable_index_to_XY_T2
TEST_val_eq_literal zp_temp_0, $28
TEST_val_eq_literal zp_temp_1, $B0
;test for each of the keyboard states
lda #%00000100
sta zp_text_info
jsr keyboard_idx_to_pattern_idx_T1
TEST_a_eq_literal $2E

__CASE__ ; keyboard_test_2

lda #20
sta screen_keyboard_index
jsr keyboard_idx_to_nametable_pos_T2
TEST_val16_eq_literal zp_temp_1, zp_temp_2, $02D5
jsr convert_nametable_index_to_XY_T2
TEST_val_eq_literal zp_temp_0, $A8
TEST_val_eq_literal zp_temp_1, $B0
lda #%00000101
sta zp_text_info
jsr keyboard_idx_to_pattern_idx_T1
TEST_a_eq_literal $53

__CASE__ ; keyboard_test_3

lda #41
sta screen_keyboard_index
jsr keyboard_idx_to_nametable_pos_T2
TEST_val16_eq_literal zp_temp_1, zp_temp_2, $0353
jsr convert_nametable_index_to_XY_T2
TEST_val_eq_literal zp_temp_0, $98
TEST_val_eq_literal zp_temp_1, $D0

lda #%00000010
sta zp_text_info
jsr keyboard_idx_to_pattern_idx_T1
TEST_a_eq_literal $B8

__CASE__ ; keyboard_test_4

lda #44
sta screen_keyboard_index
jsr keyboard_idx_to_nametable_pos_T2
TEST_val16_eq_literal zp_temp_1, zp_temp_2, $038A
jsr convert_nametable_index_to_XY_T2
TEST_val_eq_literal zp_temp_0, $50
TEST_val_eq_literal zp_temp_1, $E0
lda #%00000110
sta zp_text_info
jsr keyboard_idx_to_pattern_idx_T1
TEST_a_eq_literal $FF

__CATEGORY__ ; conversion tests
__CASE__ ; if end of line

set_carry_if_eol #28
TEST_carry_set
set_carry_if_eol #50
TEST_carry_clear
set_carry_if_eol #224
TEST_carry_set
set_carry_if_eol #0
TEST_carry_clear

__CASE__ ;increment nametable pointer test
lda #28
sta current_text_index
lda #$20
sta current_nametable_ptr_hi
lda #$5d
sta current_nametable_ptr_lo
jsr increment_nametable_ptr
TEST_val16_eq_literal current_nametable_ptr_lo, current_nametable_ptr_hi, $2082

lda #178
sta current_text_index
lda #$21
sta current_nametable_ptr_hi
lda #$CA
sta current_nametable_ptr_lo
jsr increment_nametable_ptr
TEST_val16_eq_literal current_nametable_ptr_lo, current_nametable_ptr_hi, $21CB

lda #1
sta current_text_index
lda #$20
sta current_nametable_ptr_hi
lda #$00
sta current_nametable_ptr_lo
jsr increment_nametable_ptr
TEST_val16_eq_literal current_nametable_ptr_lo, current_nametable_ptr_hi, $2001

lda #224
sta current_text_index
lda #$22
sta current_nametable_ptr_hi
lda #$1D
sta current_nametable_ptr_lo
jsr increment_nametable_ptr
TEST_val16_eq_literal current_nametable_ptr_lo, current_nametable_ptr_hi, $2242

__CATEGORY__ ;input testing
__CASE__ ;button down test
lda #25
sta screen_keyboard_index
jsr handle_down_button_press
TEST_val_eq_literal screen_keyboard_index, 36

lda #36
sta screen_keyboard_index
jsr handle_down_button_press
TEST_val_eq_literal screen_keyboard_index, 44

lda #44
sta screen_keyboard_index
jsr handle_down_button_press
TEST_val_eq_literal screen_keyboard_index, 44

lda #47
sta screen_keyboard_index
jsr handle_down_button_press
TEST_val_eq_literal screen_keyboard_index, 49

__CASE__ ;button up test
lda #25
sta screen_keyboard_index
jsr handle_up_button_press
TEST_val_eq_literal screen_keyboard_index, 14

lda #44
sta screen_keyboard_index
jsr handle_up_button_press
TEST_val_eq_literal screen_keyboard_index, 38

lda #9
sta screen_keyboard_index
jsr handle_up_button_press
TEST_val_eq_literal screen_keyboard_index, 9

lda #48
sta screen_keyboard_index
jsr handle_up_button_press
TEST_val_eq_literal screen_keyboard_index, 46

__CASE__ ;button left test
lda #25
sta screen_keyboard_index
jsr handle_left_button_press
TEST_val_eq_literal screen_keyboard_index, 24

lda #36
sta screen_keyboard_index
jsr handle_left_button_press
TEST_val_eq_literal screen_keyboard_index, 35

lda #44
sta screen_keyboard_index
jsr handle_left_button_press
TEST_val_eq_literal screen_keyboard_index, 44

lda #47
sta screen_keyboard_index
jsr handle_left_button_press
TEST_val_eq_literal screen_keyboard_index, 32

__CASE__ ;button right test
lda #25
sta screen_keyboard_index
jsr handle_right_button_press
TEST_val_eq_literal screen_keyboard_index, 26

lda #44
sta screen_keyboard_index
jsr handle_right_button_press
TEST_val_eq_literal screen_keyboard_index, 44

lda #9
sta screen_keyboard_index
jsr handle_right_button_press
TEST_val_eq_literal screen_keyboard_index, 10

lda #48
sta screen_keyboard_index
jsr handle_right_button_press
TEST_val_eq_literal screen_keyboard_index, 48

end_tests
