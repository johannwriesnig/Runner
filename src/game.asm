INCLUDE "constants.inc"
SECTION "Game_Code", ROM0


gameHandler::
    call WaitVBlank
    call turnLCDOFF
    call clearSpriteSpace
    call initMap
    call initPlayer
    call setupStartVariables
    call setPalettes
    call turnLCDON

    jp startNewGame
    ret

startNewGame:
    jp gameLoop

clearSpriteSpace:
    ld de, 4*40
    ld hl, _Sprites_Address
    call memclear
    ret

setupStartVariables:
    call resetMap
    call resetPlayer
    ret

gameLoop:
    call delayAll
    call updateMap
    call updatePlayer
    ld a, [is_Dead]
    cp a, 1
    jp nz, .continue
    jp gameHandler
    .continue:

    call WaitVBlank
    ld a, [DRAW_ME]
    cp a, 1
    jp nz, .skip
    call loadRowFromBuffer
    .skip:
    ld a, HIGH(_Sprites_Address)
    call startDMA
    jp gameLoop ;wenn gameEnd dann zum gameendhandler springen
    




	

