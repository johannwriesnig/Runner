SECTION "Game_Code", ROM0

initGame:: ;loading all stuff
    ld a, 0
    ld [spriteNumber], a
    ld a, $80
    ld [startOfFreeTileSpace], a
    ld a, $00
    ld [startOfFreeTileSpace+1], a
    ld a, $C1
    ld [startOfFreeSpriteSpace], a
    ld a, $00
    ld [startOfFreeSpriteSpace+1], a

    call WaitVBlank
    call turnLCDOFF
    call setupPlayer
    call setupMap
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
    ld a, [startOfFreeSpriteSpace]
    call startDMA
    jp gameLoop

checkInput:
;missing collision check
   
    ret

setupMap:
    ld a, [startOfFreeTileSpace]
    ld [mapTileStartAddress], a
    ld a, [startOfFreeTileSpace+1]
    ld [mapTileStartAddress+1], a
    ld a , 8
    ld [mapTileStartIndex], a
    call copyMapTiles
    call loadMap
    ret

setupPlayer:
    ld a, 50
    call setPlayerX
    ld a, 130
    call setPlayerY
    ld a, [startOfFreeTileSpace]
    ld d, a
    ld h, a
    ld a, [startOfFreeTileSpace+1]
    ld e, a
    ld l, a

    ld bc, playerTilesEnd - playerTiles

    add hl, bc

    ld a, h
    ld [startOfFreeTileSpace], a
    ld a, l
    ld [startOfFreeTileSpace+1], a
    
    call setPlayersTileAddress   ;address must be supplied by de
    ld a, [startOfFreeSpriteSpace]
    ld d, a
    ld a, [startOfFreeSpriteSpace+1]
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
    ld a, [startOfFreeSpriteSpace]
    ld h, a
    ld a, [startOfFreeSpriteSpace+1]
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
    startOfFreeTileSpace: DS 2
    startOfFreeSpriteSpace: DS 2
    spriteNumber:: DS 1 ;40 max
    




	

