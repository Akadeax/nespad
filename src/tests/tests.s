lda #0
sta $0

lda #$FF
sta zp_temp_0
lda #$05
sta zp_temp_1
increment_zp_16 #3, zp_temp_0, zp_temp_1
; val_eq_literal zp_temp_0, $02
; val_eq_literal zp_temp_1, $07 ; $05FF + 3 should be $0602
val16_eq_literal zp_temp_0, zp_temp_1, $0603