.include "test_framework.s"

start_tests

__CATEGORY__;Testing keyboard input
__CATEGORY__;keyboard_test_1
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



__CATEGORY__;keyboard_test_2

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

__CATEGORY__;keyboard_test_3

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



__CATEGORY__;keyboard_test_4

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


__CATEGORY__;conversion tests
__CATEGORY__;if end of line
set_carry_if_eol #28
TEST_carry_set
set_carry_if_eol #50
TEST_carry_clear
set_carry_if_eol #224
TEST_carry_set
set_carry_if_eol #0
TEST_carry_clear
__CATEGORY__;



end_tests
