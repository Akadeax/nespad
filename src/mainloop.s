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
	beq NOT_PAD_UP_PRESSED
		; UP pressed
		jsr handle_up_button_press_T2
		jsr draw_indicator_T1
		lda #1
		sta up_time_held

	NOT_PAD_UP_PRESSED:

	lda input_released_this_frame
	and #PAD_UP
	beq NOT_PAD_UP_RELEASED
		; UP released
		lda #0
		sta up_time_held

	NOT_PAD_UP_RELEASED:

	lda current_input
	and #PAD_UP
	beq NOT_PAD_UP_HELD
		; UP held
		lda up_time_held
		cmp #15
		bpl time_up_held_above_threshold ; if a_time_held > threshold, call type; otherwise just increment it

	time_up_held_below_threshold:
		inc up_time_held
		jmp NOT_PAD_UP_HELD

	time_up_held_above_threshold:
		; UP hold acivated
		lda frame_counter
		and #%00000011
		bne NOT_PAD_UP_HELD
		jsr handle_up_button_press_T2
		jsr draw_indicator_T1
	NOT_PAD_UP_HELD:

	lda input_pressed_this_frame
	and #PAD_DOWN
	beq NOT_PAD_DOWN_PRESSED
		; DOWN pressed
		jsr handle_down_button_press_T2
		jsr draw_indicator_T1
		lda #1
		sta down_time_held

	NOT_PAD_DOWN_PRESSED:

	lda input_released_this_frame
	and #PAD_DOWN
	beq NOT_PAD_DOWN_RELEASED
		; DOWN released
		lda #0
		sta down_time_held

	NOT_PAD_DOWN_RELEASED:

	lda current_input
	and #PAD_DOWN
	beq NOT_PAD_DOWN_HELD
		; DOWN held
		lda down_time_held
		cmp #15
		bpl time_down_held_above_threshold ; if a_time_held > threshold, call type; otherwise just increment it

	time_down_held_below_threshold:
		inc down_time_held
		jmp NOT_PAD_DOWN_HELD

	time_down_held_above_threshold:
		; DOWN hold acivated
		lda frame_counter
		and #%00000011
		bne NOT_PAD_DOWN_HELD
		jsr handle_down_button_press_T2
		jsr draw_indicator_T1
	NOT_PAD_DOWN_HELD:


	lda input_pressed_this_frame
	and #PAD_LEFT
	beq NOT_PAD_LEFT_PRESSED
		; LEFT pressed

		;;; TODO Remove
		lda screen_keyboard_index
		cmp #KEYBOARD_IDX_SPACEBAR
		bne :+
			; on spacebar; left pressed
			jsr move_cursor_left
			jmp NOT_PAD_LEFT_PRESSED
:

		jsr handle_left_button_press_T2
		jsr draw_indicator_T1
		
		lda #1
		sta left_time_held

	NOT_PAD_LEFT_PRESSED:

	lda input_released_this_frame
	and #PAD_LEFT
	beq NOT_PAD_LEFT_RELEASED
		; LEFT released
		lda #0
		sta left_time_held

	NOT_PAD_LEFT_RELEASED:

	lda current_input
	and #PAD_LEFT
	beq NOT_PAD_LEFT_HELD
		; LEFT held
		lda left_time_held
		cmp #15
		bpl time_left_held_above_threshold ; if a_time_held > threshold, call type; otherwise just increment it

	time_left_held_below_threshold:
		inc left_time_held
		jmp NOT_PAD_LEFT_HELD

	time_left_held_above_threshold:
		; LEFT hold acivated
		lda frame_counter
		and #%00000011
		bne NOT_PAD_LEFT_HELD

		jsr handle_left_button_press_T2
		jsr draw_indicator_T1

	NOT_PAD_LEFT_HELD:

	lda input_pressed_this_frame
	and #PAD_RIGHT
	beq NOT_PAD_RIGHT_PRESSED
		; RIGHT pressed
		;;; TODO Remove
		lda screen_keyboard_index
		cmp #KEYBOARD_IDX_SPACEBAR
		bne :+
			; on spacebar; right pressed
			jsr move_cursor_right
			jmp NOT_PAD_RIGHT_PRESSED
	:

		jsr handle_right_button_press_T2
		jsr draw_indicator_T1
		lda #1
		sta right_time_held

	NOT_PAD_RIGHT_PRESSED:

	lda input_released_this_frame
	and #PAD_RIGHT
	beq NOT_PAD_RIGHT_RELEASED
		; RIGHT released
		lda #0
		sta right_time_held

	NOT_PAD_RIGHT_RELEASED:

	lda current_input
	and #PAD_RIGHT
	beq NOT_PAD_RIGHT_HELD
		; RIGHT held
		lda right_time_held
		cmp #15
		bpl time_right_held_above_threshold ; if a_time_held > threshold, call type; otherwise just increment it

	time_right_held_below_threshold:
		inc right_time_held
		jmp NOT_PAD_RIGHT_HELD

	time_right_held_above_threshold:

		lda frame_counter
		and #%00000011
		bne NOT_PAD_RIGHT_HELD

		jsr handle_right_button_press_T2
		jsr draw_indicator_T1
	NOT_PAD_RIGHT_HELD:

	lda input_pressed_this_frame
	and #PAD_A
	beq NOT_PAD_A_PRESSED
		; A pressed
		jsr activate_selected_key
		lda #1
		sta a_time_held

	NOT_PAD_A_PRESSED:

	lda input_released_this_frame
	and #PAD_A
	beq NOT_PAD_A_RELEASED
		; A released
		lda #0
		sta a_time_held

	NOT_PAD_A_RELEASED:

	lda current_input
	and #PAD_A
	beq NOT_PAD_A_HELD
		; A held
		lda a_time_held
		cmp #50
		bpl time_a_held_above_threshold ; if a_time_held > threshold, call type; otherwise just increment it

	time_a_held_below_threshold:
		inc a_time_held
		jmp NOT_PAD_A_HELD

	time_a_held_above_threshold:
		lda frame_counter
		and #%00000010
		bne NOT_PAD_A_HELD

		jsr activate_selected_key

	NOT_PAD_A_HELD:

	lda input_pressed_this_frame
	and #PAD_B
	beq NOT_PAD_B_PRESSED
		; B pressed
		jsr remove_last_character_on_page_without_reload
		lda #1
		sta b_time_held
	NOT_PAD_B_PRESSED:

	lda input_released_this_frame
	and #PAD_B
	beq NOT_PAD_B_RELEASED
		; B released
		
		lda #0
		sta b_time_held

	NOT_PAD_B_RELEASED:

	lda current_input
	and #PAD_B
	beq NOT_PAD_B_HELD
		; B held
		lda b_time_held
		cmp #50
		bcs time_b_held_above_threshold ; if a_time_held > threshold, call type; otherwise just increment it

	time_b_held_below_threshold:
		inc b_time_held
		jmp NOT_PAD_B_HELD

	time_b_held_above_threshold:
		lda frame_counter
		and #%00000010
		bne NOT_PAD_B_HELD

		jsr remove_last_character_on_page_without_reload
	NOT_PAD_B_HELD:

	lda input_pressed_this_frame
	and #PAD_SELECT
	beq NOT_PAD_SELECT
		; SELECT pressed
		jsr select_pressed
	NOT_PAD_SELECT:


	lda input_pressed_this_frame
	and #PAD_START
	beq NOT_PAD_START_PRESSED
		; B pressed

		lda #1
		sta start_time_held

	NOT_PAD_START_PRESSED:


	lda input_released_this_frame
	and #PAD_START
	beq NOT_PAD_START_RELEASED
		; SELECT released
		lda #0
		sta start_time_held

	NOT_PAD_START_RELEASED:

	lda current_input
	and #PAD_START
	beq NOT_PAD_START_HELD
		; B held
		lda start_time_held
		cmp #255
		beq time_start_held_above_threshold ; if a_time_held > threshold, call type; otherwise just increment it

	time_start_held_below_threshold:
		inc start_time_held
		jmp NOT_PAD_START_HELD

	time_start_held_above_threshold:
		jsr clear_wram_T3
		lda #0
		sta start_time_held
	NOT_PAD_START_HELD:

 	lda current_input
    sta last_frame_input

 	jmp mainloop
