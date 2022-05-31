INCLUDE "constants.inc"
SECTION "Game_Code", ROM0


gameHandler::
    call WaitVBlank
    call turnLCDOFF
    call clearSpriteSpace
    call initMap
    call initPlayer
    call initEnemy
    call setupStartVariables
    ;call setupProjectiles
    call setPalettes
    call turnLCDON
    

    jp startNewGame
    ret

startNewGame:
    ld a, 2
    ld [DELAY], a
    ld a, 0
    ld [enemyCounter], a
    jp gameLoop

clearSpriteSpace:
    ld de, 4*40
    ld hl, _Sprites_Address
    call memclear
    ret

setupStartVariables:
    call resetMap
    call resetPlayer
    call resetEnemy
    ret

gameLoop:
    call delayAll
    call updateMap
    call updatePlayer
    ;call updateProjectiles
    call updateEnemy
    ld a, [is_Dead]
    cp a, 1
    jp nz, .continue
    jp gameHandler
    .continue:

    call playSound
    call WaitVBlank
    ld a, [DRAW_ME]
    cp a, 1
    jp nz, .skip
    call loadRowFromBuffer
    .skip:
    ld a, HIGH(_Sprites_Address)
    call startDMA

    ld a, [enemyCounter]
    inc a
    ld[enemyCounter], a

    cp a, 250
    jp nz, .skipSendingEnemy
        call sendEnemy
        call playSound
    .skipSendingEnemy:
    jp gameLoop ;wenn gameEnd dann zum gameendhandler springen

    SECTION "VARIABLES", WRAM0
    DELAY:: DS 1
    enemyCounter: DS  1
    




	

