SECTION "Game_Code", ROM0
tileAddress: db $80, $00
spriteAddress: db $C1, $00

initGame:: ;loading all stuff
    ld a, 0
    ld [spriteNumber], a
    call WaitVBlank
    call turnLCDOFF
    call setupPlayer
    call setPalettes
    call clearRemainingSpriteSpace
    call turnLCDON
    ret

startGame::
    jp gameLoop
    ret

gameLoop:
    call WaitVBlank
    call delayAll ;need to find other solution
    call checkInput
    call updatePlayer
    ld a, [spriteAddress]
    call startDMA
    jp gameLoop

checkInput:
;missing collision check
   
    ret

setupPlayer:
    ld a, 50
    call setPlayerX
    call setPlayerY
    ld a, [tileAddress]
    ld d, a
    ld a, [tileAddress+1]
    ld e, a
    call setPlayersTileAddress   ;address must be supplied by de
    ld a, [spriteAddress]
    ld d, a
    ld a, [spriteAddress+1]
    ld e, a
    call setPlayersSpriteAddress ;address must be supplied by de
    ld a, [spriteNumber]
    ld hl, playerNeededTileCount
    add a, [hl]
    ld [spriteNumber], a
    ld a, 0
    ld [playerSpriteStartId], a
    call copyPlayerTiles
    ret

clearRemainingSpriteSpace:
    ld a, [spriteNumber]
    ld b, 40 
    ;4 -> 16(if 4 sprites we got 16 Bytes)
    sla a
    sla a 
    ;40 -> 160 (40 Sprites x 4 Bytes)
    sla b
    sla b
    ld c, a
    ld a, [spriteAddress]
    ld h, a
    ld a, [spriteAddress+1]
    ld l, a
    ld a, c
    add a, l
    ld l,a
    ld a, c
    .clear:
    ld [hl], 0
    inc l
    dec b
    cp a, b
    jp nz, .clear
    ret
    
SECTION "GAME_VARIABLES", WRAM0
    spriteNumber:: DS 1 ;40 max
    




	

