INCLUDE "constants.inc"
SECTION "SounCode", ROM0

initSoundData::
    ld a, %01110111
    ld a, [$FF24]

    ld a,%11111111
    ld [$FF25], a

    ld a, 0
    ld [$FF1A], a
    ld hl, $FF30
    ld de, 16
    ld bc, soundData
    call memcpy
    ret

playSound::
    call initSoundData
   ld a, %0010000
   ld [$FF1C], a

   ld a, %10000000
   ld [$FF1A], a

   ld a,0
   ld [$FF1B], a

   ld a,%11111111
   ld [$FF1D], a

   ld a, %11000011
   ld [$FF1E], a

ret

soundData: 
DB $50, $50, $50, $50, $50, $50, $50, $50
DB $10, $20, $30, $40, $50, $60, $70, $80
DB $A0, $F0, $B0, $C0, $E0, $60, $90, $20