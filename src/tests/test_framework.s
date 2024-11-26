.segment "CODE"
.macro val_eq_literal address, literal
    inc $0 ; increment test index

    lda address
    cmp #literal
:
    bne :-
.endmacro

.macro val_neq_literal address, literal
    inc $0 ; increment test index

    lda address
    cmp #literal
:
    beq :-
.endmacro

.macro val16_eq_literal lo, hi, literal
    inc $0 ; increment test index

    lda lo
    cmp #<literal
:
    bne :-

    lda hi
    cmp #>literal
:
    bne :-
.endmacro