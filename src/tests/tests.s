lda #0
sta $0

lda #12
jsr keyboard_idx_to_nametable_pos_T2
val16_eq_literal zp_temp_1, zp_temp_2, $02C5

lda #20
jsr keyboard_idx_to_nametable_pos_T2
val16_eq_literal zp_temp_1, zp_temp_2, $02D5

lda #44
jsr keyboard_idx_to_nametable_pos_T2
val16_eq_literal zp_temp_1, zp_temp_2, $038A

lda #41
jsr keyboard_idx_to_nametable_pos_T2
val16_eq_literal zp_temp_1, zp_temp_2, $0353
