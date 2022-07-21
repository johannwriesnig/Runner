INCLUDE "constants.inc"
SECTION "SounCode", ROM0

turnSoundON::
    ld a, $FF
    ld [$FF25], a

    ;channel 1
    ld a, %10000000
    ld [$FF10], a

    ld a, %10111111
    ld [$FF11], a

    ld a, %11010010
    ld [$FF12], a

    ld a, %11111111
    ld [$FF13], a 

    ld a, %1111111
    ld [$FF14], a
    ret

initSoundData::
    ld a, 0
    ld [$FF1A], a
    ld hl, $FF30
    ld de, 16
    ld bc, soundData
    call memcpy
    ret

playJump::
    ld a, %00110010
    ld [$FF12], a
ret
playSound::
  

ret

soundData: 
DB $50, $50, $50, $50, $50, $50, $50, $50
DB $10, $20, $30, $40, $50, $60, $70, $80
DB $A0, $F0, $B0, $C0, $E0, $60, $90, $20