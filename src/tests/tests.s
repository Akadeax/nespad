.include "test_framework.s"

start_tests


lda #12
sta screen_keyboard_index
jsr keyboard_idx_to_nametable_pos_T2
val16_eq_literal zp_temp_1, zp_temp_2, $02C5
jsr convert_nametable_index_to_XY_T2
val_eq_literal zp_temp_0, $28
val_eq_literal zp_temp_1, $B0

__CATEGORY__

lda #20
sta screen_keyboard_index
jsr keyboard_idx_to_nametable_pos_T2
val16_eq_literal zp_temp_1, zp_temp_2, $02D5
jsr convert_nametable_index_to_XY_T2
val_eq_literal zp_temp_0, $A8
val_eq_literal zp_temp_1, $B0

__CATEGORY__

lda #41
sta screen_keyboard_index
jsr keyboard_idx_to_nametable_pos_T2
val16_eq_literal zp_temp_1, zp_temp_2, $0353
jsr convert_nametable_index_to_XY_T2
val_eq_literal zp_temp_0, $98
val_eq_literal zp_temp_1, $D0

__CATEGORY__

lda #44
sta screen_keyboard_index
jsr keyboard_idx_to_nametable_pos_T2
val16_eq_literal zp_temp_1, zp_temp_2, $038A
jsr convert_nametable_index_to_XY_T2
val_eq_literal zp_temp_0, $50
val_eq_literal zp_temp_1, $E0


end_tests
