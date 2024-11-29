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
		jsr handle_up_button_press
		jsr draw_indicator_T1

	NOT_PAD_UP:

	lda input_pressed_this_frame
	and #PAD_DOWN
	beq NOT_PAD_DOWN
		; down pressed
		jsr handle_down_button_press
		jsr draw_indicator_T1

	NOT_PAD_DOWN:

	lda input_pressed_this_frame
	and #PAD_LEFT
	beq NOT_PAD_LEFT
		; left pressed
		jsr handle_left_button_press
		jsr draw_indicator_T1

	NOT_PAD_LEFT:

	lda input_pressed_this_frame
	and #PAD_RIGHT
	beq NOT_PAD_RIGHT
		; right pressed
		jsr handle_right_button_press
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
		bpl time_held_above_threshold ; if a_time_held > threshold, call type; otherwise just increment it

	time_held_below_threshold:
		inc a_time_held
		jmp NOT_PAD_A_HELD

	time_held_above_threshold:
		jsr activate_selected_key

	NOT_PAD_A_HELD:

	lda current_input

	lda input_pressed_this_frame
	and #PAD_SELECT
	beq NOT_PAD_SELECT
		; SELECT pressed
		lda current_page
		beq NOT_PAD_START ; if we're at first page, don't dec

		dec current_page
		jsr redraw_current_page_T2



	NOT_PAD_SELECT:

	lda input_pressed_this_frame
	and #PAD_START
	beq NOT_PAD_START
		; START pressed
		lda current_page
		cmp #(MAX_PAGE_AMOUNT - 1)
		beq NOT_PAD_START ; if we're at the last page, don't inc

		inc current_page
		jsr redraw_current_page_T2

	NOT_PAD_START:

	lda input_pressed_this_frame
	and #PAD_B
	beq NOT_PAD_B
		; B pressed
		jsr remove_last_character_on_page_T1

	NOT_PAD_B:

 	lda current_input
    sta last_frame_input

 	jmp mainloop
