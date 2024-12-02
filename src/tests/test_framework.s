lda #0 ; mask VBlank interrupt
sta $2000 ; this doesn't use a PPUCTRL constant because it might be different per project
sei ; mask interrupt requests

LUA_BINDING_SEND_ADDR_0 = 2047

LUA_VAL_SUCCESS     = 1
LUA_VAL_FAILURE     = 2
LUA_VAL_CATEGORY    = 3
LUA_VAL_CLOSE       = 4

; =========================
; SETUP MACROS
; =========================
.macro start_tests ; prepares CPU for tests
    lda #0
    sta $0

    clear_zp
.endmacro

.macro clear_zp
    lda #0
    ldx #0
:
    sta $0000,x
    inx
    bne :-
.endmacro

.macro __CATEGORY__ ; used as separator between test categories
    send_to_binding LUA_VAL_CATEGORY
.endmacro

.macro end_tests ; tell lua binding to shut off TCP connection
    send_to_binding LUA_VAL_CLOSE
.endmacro

.macro send_to_binding value ; sends `value` to the lua binding
    lda #value
    sta $0

    lda #$0
    sta LUA_BINDING_SEND_ADDR_0
.endmacro


; ============================
; TEST MACROS
; ============================
.macro val_eq_literal address, literal
    lda address
    cmp #literal
    bne :+

    send_to_binding LUA_VAL_SUCCESS
    jmp :++
:
    send_to_binding LUA_VAL_FAILURE
:
.endmacro

.macro val_neq_literal address, literal
    lda address
    cmp #literal
    beq :+

    send_to_binding LUA_VAL_SUCCESS
    jmp :++
:
    send_to_binding LUA_VAL_FAILURE
:
.endmacro

.macro val16_eq_literal lo, hi, literal
    lda lo
    cmp #<literal
    bne :+

    lda hi
    cmp #>literal
    bne :+

    send_to_binding LUA_VAL_SUCCESS
    jmp :++
:
    send_to_binding LUA_VAL_FAILURE
:
.endmacro

.macro a_eq_literal literal
    cmp #literal
    bne :+

    send_to_binding LUA_VAL_SUCCESS
    jmp :++
:
    send_to_binding LUA_VAL_FAILURE
:
.endmacro

.macro x_eq_literal literal
    cpx #literal
    bne :+

    send_to_binding LUA_VAL_SUCCESS
    jmp :++
:
    send_to_binding LUA_VAL_FAILURE
:
.endmacro

.macro y_eq_literal literal
    cpy #literal
    bne :+

    send_to_binding LUA_VAL_SUCCESS
    jmp :++
:
    send_to_binding LUA_VAL_FAILURE
:
.endmacro
