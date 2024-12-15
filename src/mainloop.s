 mainloop:
 	; skip reading controls if and change has not been drawn
 	lda nmi_ready
 	cmp #0
 	bne mainloop

 	; ensure our changes are rendered
 	lda #1
 	sta nmi_ready

	inc frame_counter

	
 	; read the gamepad
 	poll_gamepad current_input

	lda last_frame_input
	eor #%11111111
	and current_input
	sta input_pressed_this_frame

	lda current_input
	eor #%11111111
	and last_frame_input
	sta input_released_this_frame

    ; do input handling stuff here
	lda input_pressed_this_frame
	and #PAD_UP
	beq not_pad_up_pressed
		; UP pressed
		jsr handle_up_button_press_T2
		jsr draw_indicator_T1
		lda #1
		sta up_time_held

	not_pad_up_pressed:

	lda input_released_this_frame
	and #PAD_UP
	beq not_pad_up_released
		; UP released
		lda #0
		sta up_time_held

	not_pad_up_released:

	lda current_input
	and #PAD_UP
	beq not_pad_up_held
		; UP held
		lda up_time_held
		cmp #15
		bpl time_up_held_above_threshold ; if a_time_held > threshold, call type; otherwise just increment it

	time_up_held_below_threshold:
		inc up_time_held
		jmp not_pad_up_held

	time_up_held_above_threshold:
		; UP hold acivated
		lda frame_counter
		and #%00000011
		bne not_pad_up_held
		jsr handle_up_button_press_T2
		jsr draw_indicator_T1
	not_pad_up_held:

	lda input_pressed_this_frame
	and #PAD_DOWN
	beq not_pad_down_pressed
		; DOWN pressed
		jsr handle_down_button_press_T2
		jsr draw_indicator_T1
		lda #1
		sta down_time_held

	not_pad_down_pressed:

	lda input_released_this_frame
	and #PAD_DOWN
	beq not_pad_down_released
		; DOWN released
		lda #0
		sta down_time_held

	not_pad_down_released:

	lda current_input
	and #PAD_DOWN
	beq not_pad_down_held
		; DOWN held
		lda down_time_held
		cmp #15
		bpl time_down_held_above_threshold ; if a_time_held > threshold, call type; otherwise just increment it

	time_down_held_below_threshold:
		inc down_time_held
		jmp not_pad_down_held

	time_down_held_above_threshold:
		; DOWN hold acivated
		lda frame_counter
		and #%00000011
		bne not_pad_down_held
		jsr handle_down_button_press_T2
		jsr draw_indicator_T1
	not_pad_down_held:


	lda input_pressed_this_frame
	and #PAD_LEFT
	beq not_pad_left_pressed
		; LEFT pressed

		lda screen_keyboard_index
		cmp #KEYBOARD_IDX_SPACEBAR
		bne :+
			; on spacebar; left pressed
			jsr move_cursor_left
			jmp not_pad_left_pressed
:

		jsr handle_left_button_press_T2
		jsr draw_indicator_T1
		
		lda #1
		sta left_time_held

	not_pad_left_pressed:

	lda input_released_this_frame
	and #PAD_LEFT
	beq not_pad_left_released
		; LEFT released
		lda #0
		sta left_time_held

	not_pad_left_released:

	lda current_input
	and #PAD_LEFT
	beq not_pad_left_held
		; LEFT held
		lda left_time_held
		cmp #15
		bpl time_left_held_above_threshold ; if a_time_held > threshold, call type; otherwise just increment it

	time_left_held_below_threshold:
		inc left_time_held
		jmp not_pad_left_held

	time_left_held_above_threshold:


		; LEFT hold acivated
		lda frame_counter
		and #%00000011
		bne not_pad_left_held

		lda screen_keyboard_index
		cmp #KEYBOARD_IDX_SPACEBAR
		bne :+
			; on spacebar; left pressed
			jsr move_cursor_left
			jmp not_pad_left_held
:
		jsr handle_left_button_press_T2
		jsr draw_indicator_T1

	not_pad_left_held:

	lda input_pressed_this_frame
	and #PAD_RIGHT
	beq not_pad_right_pressed
		; RIGHT pressed
		lda screen_keyboard_index
		cmp #KEYBOARD_IDX_SPACEBAR
		bne :+
			; on spacebar; right pressed
			jsr move_cursor_right
			jmp not_pad_right_pressed
	:

		jsr handle_right_button_press_T2
		jsr draw_indicator_T1
		lda #1
		sta right_time_held

	not_pad_right_pressed:

	lda input_released_this_frame
	and #PAD_RIGHT
	beq not_pad_right_released
		; RIGHT released
		lda #0
		sta right_time_held

	not_pad_right_released:

	lda current_input
	and #PAD_RIGHT
	beq not_pad_right_held
		; RIGHT held
		lda right_time_held
		cmp #15
		bpl time_right_held_above_threshold ; if a_time_held > threshold, call type; otherwise just increment it

	time_right_held_below_threshold:
		inc right_time_held
		jmp not_pad_right_held

	time_right_held_above_threshold:


		lda frame_counter
		and #%00000011
		bne not_pad_right_held
		
		lda screen_keyboard_index
		cmp #KEYBOARD_IDX_SPACEBAR
		bne :+
			; on spacebar; right pressed
			jsr move_cursor_right
			jmp not_pad_right_held
	:

		jsr handle_right_button_press_T2
		jsr draw_indicator_T1
	not_pad_right_held:

	lda input_pressed_this_frame
	and #PAD_A
	beq not_pad_A_pressed
		; A pressed
		jsr activate_selected_key
		lda #5
		sta a_sound_frame_countdown
		lda #1
		sta a_time_held

	not_pad_A_pressed:

	lda input_released_this_frame
	and #PAD_A
	beq not_pad_A_released
		; A released
		lda #0
		sta a_time_held

	not_pad_A_released:

	lda current_input
	and #PAD_A
	beq not_pad_A_held
		; A held
		lda a_time_held
		cmp #50
		bpl time_a_held_above_threshold ; if a_time_held > threshold, call type; otherwise just increment it

	time_a_held_below_threshold:
		inc a_time_held
		jmp not_pad_A_held

	time_a_held_above_threshold:
		lda frame_counter
		and #%00000010
		bne not_pad_A_held
		lda #5
		sta a_sound_frame_countdown
		jsr activate_selected_key

	not_pad_A_held:

	lda input_pressed_this_frame
	and #PAD_B
	beq not_pad_B_pressed
		; B pressed
		jsr remove_last_character_on_page_without_reload
		lda #4
		sta b_sound_frame_countdown
		lda #1
		sta b_time_held
	not_pad_B_pressed:

	lda input_released_this_frame
	and #PAD_B
	beq not_pad_B_released
		; B released
		
		lda #0
		sta b_time_held

	not_pad_B_released:

	lda current_input
	and #PAD_B
	beq not_pad_B_held
		; B held
		lda b_time_held
		cmp #50
		bcs time_b_held_above_threshold ; if a_time_held > threshold, call type; otherwise just increment it

	time_b_held_below_threshold:
		inc b_time_held
		jmp not_pad_B_held

	time_b_held_above_threshold:
		lda #4
		sta b_sound_frame_countdown
		lda frame_counter
		and #%00000010
		bne not_pad_B_held

		jsr remove_last_character_on_page_without_reload
	not_pad_B_held:

	lda input_pressed_this_frame
	and #PAD_SELECT
	beq not_pad_SELECT
		; SELECT pressed
		jsr select_pressed
	not_pad_SELECT:


	lda input_pressed_this_frame
	and #PAD_START
	beq not_pad_start_pressed
		; B pressed

		lda #1
		sta start_time_held

	not_pad_start_pressed:


	lda input_released_this_frame
	and #PAD_START
	beq not_pad_start_released
		; SELECT released
		lda #0
		sta start_time_held

	not_pad_start_released:

	lda current_input
	and #PAD_START
	beq not_pad_start_held
		; B held
		lda start_time_held
		cmp #255
		beq time_start_held_above_threshold ; if a_time_held > threshold, call type; otherwise just increment it

	time_start_held_below_threshold:
		inc start_time_held
		jmp not_pad_start_held

	time_start_held_above_threshold:
		jsr clear_wram_T3
		lda #0
		sta start_time_held
	not_pad_start_held:

 	lda current_input
    sta last_frame_input
	jsr handle_sound

 	jmp mainloop
