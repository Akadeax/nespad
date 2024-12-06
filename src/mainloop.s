 mainloop:
 	; skip reading controls if and change has not been drawn
 	lda nmi_ready
 	cmp #0
 	bne mainloop

 	; ensure our changes are rendered
 	lda #1
 	sta nmi_ready

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
	beq NOT_PAD_UP
		; up pressed
		jsr handle_up_button_press_T2
		jsr draw_indicator_T1

	NOT_PAD_UP:

	lda input_pressed_this_frame
	and #PAD_DOWN
	beq NOT_PAD_DOWN
		; down pressed
		jsr handle_down_button_press_T2
		jsr draw_indicator_T1

	NOT_PAD_DOWN:

	lda input_pressed_this_frame
	and #PAD_LEFT
	beq NOT_PAD_LEFT
		; left pressed
		jsr handle_left_button_press_T2
		jsr draw_indicator_T1

	NOT_PAD_LEFT:

	lda input_pressed_this_frame
	and #PAD_RIGHT
	beq NOT_PAD_RIGHT
		; right pressed
		jsr handle_right_button_press_T2
		jsr draw_indicator_T1

	NOT_PAD_RIGHT:

	lda input_pressed_this_frame
	and #PAD_A
	beq NOT_PAD_A_PRESSED
		; A pressed
		jsr activate_selected_key
		lda #1
		sta a_held

	NOT_PAD_A_PRESSED:

	lda input_released_this_frame
	and #PAD_A
	beq NOT_PAD_A_RELEASED
		; A released
		lda #0
		sta a_held
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
		jsr activate_selected_key

	NOT_PAD_A_HELD:

		lda input_pressed_this_frame
	and #PAD_B
	beq NOT_PAD_B_PRESSED
		; A pressed
		jsr remove_last_character_on_page_without_reload_T1
		lda #1
		sta b_held

	NOT_PAD_B_PRESSED:

	lda input_released_this_frame
	and #PAD_B
	beq NOT_PAD_B_RELEASED
		; A released
		jsr redraw_current_page_T2
		lda #0
		sta b_held
		sta b_time_held

	NOT_PAD_B_RELEASED:

	lda current_input
	and #PAD_B
	beq NOT_PAD_B_HELD
		; A held
		lda b_time_held
		cmp #50
		bpl time_b_held_above_threshold ; if a_time_held > threshold, call type; otherwise just increment it

	time_b_held_below_threshold:
		inc b_time_held
		jmp NOT_PAD_B_HELD

	time_b_held_above_threshold:
		inc b_time_held
		lda b_time_held
		and #%00000111
		cmp #0
		beq :+
			jsr remove_last_character_on_page_without_reload_T1
			jmp NOT_PAD_B_HELD
		:
			jsr remove_last_character_on_page_T1
	NOT_PAD_B_HELD:

	lda input_pressed_this_frame
	and #PAD_SELECT
	beq NOT_PAD_SELECT
		; SELECT pressed
		jsr select_pressed
	NOT_PAD_SELECT:

	lda input_pressed_this_frame
	and #PAD_START
	beq NOT_PAD_START
		; START pressed
	NOT_PAD_START:


 	lda current_input
    sta last_frame_input

 	jmp mainloop
