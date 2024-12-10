
.proc stop_sound
    lda #$00 
    sta $4015 ; Disable all APU channels
    rts
.endproc

.proc play_keypress_sound
   
    ;first channel
    lda #$40
    sta $4000 ; square channel - Volume and envelope 
    lda #$FF
    sta $4002 ; square channel - Frequency register (low) 
    lda #$70 ; Adjust this value for different noise pitches 
    sta $4003 ; square channel - Frequency register (high) and length counter 

    ;second channel
    lda #$40 
    sta $4004 ; square channel 2 - Volume and envelope 
    lda #$FF
    sta $4006 ; square channel 2 - Frequency register (low) 
    lda #$20 ; Adjust this value for different noise pitches 
    sta $4007 ; square channel 2 - Frequency register (high) and length counter 

    lda #%00000011 
    sta $4015 ; Enable square channel 
    endProc:
    rts
.endproc

.proc play_delete_sound
   
    ;first channel
    lda #$40
    sta $4000 ; square channel - Volume and envelope 
    lda #$35
    sta $4002 ; square channel - Frequency register (low) 
    lda #$25 ; Adjust this value for different noise pitches 
    sta $4003 ; square channel - Frequency register (high) and length counter 

    ;second channel
    lda #$40 
    sta $4004 ; square channel 2 - Volume and envelope 
    lda #$35
    sta $4006 ; square channel 2 - Frequency register (low) 
    lda #$10 ; Adjust this value for different noise pitches 
    sta $4007 ; square channel 2 - Frequency register (high) and length counter 

    lda #%00000011 
    sta $4015 ; Enable square channel 
    endProc:
    rts
.endproc

.proc handle_sound
    lda a_sound_frame_countdown
    beq not_a_sound_played
        jsr play_keypress_sound
        lda #0
        sta b_sound_frame_countdown
        dec a_sound_frame_countdown
        rts
    not_a_sound_played:
    lda b_sound_frame_countdown
    beq not_b_sound_played
        jsr play_delete_sound
        lda #0
        sta a_sound_frame_countdown
        dec b_sound_frame_countdown
        rts
    not_b_sound_played:
    sound_stopped:
        jsr stop_sound
        rts
.endproc