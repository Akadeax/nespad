lda #0 ; mask VBlank interrupt
sta $2000 ; this doesn't use a PPUCTRL constant because it might be different per project
sei ; mask interrupt requests

LUA_BINDING_SEND_ADDR_0 = 2047

LUA_VAL_SUCCESS     = 1
LUA_VAL_FAILURE     = 2
LUA_VAL_CATEGORY    = 3
LUA_VAL_CASE        = 4
LUA_VAL_CLOSE       = 255

; =========================
; SETUP MACROS
; =========================
.macro start_tests ; prepares CPU for tests
    lda #0
    sta $0
.endmacro

.macro __CATEGORY__ ; used as separator between test categories
    __send_to_binding LUA_VAL_CATEGORY
.endmacro

.macro __CASE__
    __send_to_binding LUA_VAL_CASE
.endmacro

.macro end_tests ; tell lua binding to shut off TCP connection
    __send_to_binding LUA_VAL_CLOSE
.endmacro

.macro __send_to_binding value ; sends `value` to the lua binding
    lda #value
    sta $0

    lda #$0
    sta LUA_BINDING_SEND_ADDR_0
.endmacro

; ============================
; TEST MACROS
; ============================
.macro TEST_val_eq_literal address, literal
    lda address
    cmp #literal
    bne :+

    __send_to_binding LUA_VAL_SUCCESS
    jmp :++
:
    __send_to_binding LUA_VAL_FAILURE
:
.endmacro

.macro TEST_val_neq_literal address, literal
    lda address
    cmp #literal
    beq :+

    __send_to_binding LUA_VAL_SUCCESS
    jmp :++
:
    __send_to_binding LUA_VAL_FAILURE
:
.endmacro

.macro TEST_val16_eq_literal lo, hi, literal
    lda lo
    cmp #<literal
    bne :+

    lda hi
    cmp #>literal
    bne :+

    __send_to_binding LUA_VAL_SUCCESS
    jmp :++
:
    __send_to_binding LUA_VAL_FAILURE
:
.endmacro

.macro TEST_a_eq_literal literal
    cmp #literal
    bne :+

    __send_to_binding LUA_VAL_SUCCESS
    jmp :++
:
    __send_to_binding LUA_VAL_FAILURE
:
.endmacro

.macro TEST_x_eq_literal literal
    cpx #literal
    bne :+

    __send_to_binding LUA_VAL_SUCCESS
    jmp :++
:
    __send_to_binding LUA_VAL_FAILURE
:
.endmacro

.macro TEST_y_eq_literal literal
    cpy #literal
    bne :+

    __send_to_binding LUA_VAL_SUCCESS
    jmp :++
:
    __send_to_binding LUA_VAL_FAILURE
:
.endmacro

.macro TEST_carry_set
    bcc :+
    __send_to_binding LUA_VAL_SUCCESS
    jmp :++
:
    __send_to_binding LUA_VAL_FAILURE
:
.endmacro

.macro TEST_carry_clear
    bcs :+
    __send_to_binding LUA_VAL_SUCCESS
    jmp :++
:
    __send_to_binding LUA_VAL_FAILURE
:
.endmacro

.macro TEST_negative_set
    bpl :+
    __send_to_binding LUA_VAL_SUCCESS
    jmp :++
:
    __send_to_binding LUA_VAL_FAILURE
:
.endmacro

.macro TEST_negative_clear
    bmi :+
    __send_to_binding LUA_VAL_SUCCESS
    jmp :++
:
    __send_to_binding LUA_VAL_FAILURE
:
.endmacro

.macro TEST_overflow_set
    bvc :+
    __send_to_binding LUA_VAL_SUCCESS
    jmp :++
:
    __send_to_binding LUA_VAL_FAILURE
:
.endmacro

.macro TEST_overflow_clear
    bvs :+
    __send_to_binding LUA_VAL_SUCCESS
    jmp :++
:
    __send_to_binding LUA_VAL_FAILURE
:
.endmacro

.macro TEST_zero_set
    bne :+
    __send_to_binding LUA_VAL_SUCCESS
    jmp :++
:
    __send_to_binding LUA_VAL_FAILURE
:
.endmacro

.macro TEST_zero_clear
    beq :+
    __send_to_binding LUA_VAL_SUCCESS
    jmp :++
:
    __send_to_binding LUA_VAL_FAILURE
:
.endmacro
