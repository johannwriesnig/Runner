SECTION "Game_Code", ROM0

gameHandler::
	call initGame
	call startGame
    ret

initGame:: ;loading all stuff
    ld a, 0
    ld [sprite_count], a
    ld [scroll_count], a
    ld a, $80
    ld [_FREE_TILE_MEMORY], a
    ld a, $00
    ld [_FREE_TILE_MEMORY+1], a
    ld a, $C1
    ld [_FREE_SPRITE_SPACE], a
    ld a, $00
    ld [_FREE_SPRITE_SPACE+1], a


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
    call delayAll ;need to find other solution
    call WaitVBlank
    call checkInput
    call updatePlayer
    call updateMap
    ld a, [_FREE_SPRITE_SPACE]
    call startDMA
    jp gameLoop

checkInput:
;missing collision check
    ld a, [$FF00]
    cpl
    and a, %00000111
    ld [playerMovement], a
    ret

setupMap:
    call loadBackgroundTiles
    call loadTileMap
    ret

setupPlayer:
    ld a, 50
    ld [playerX], a
    ld a, 128
    ld [playerY], a

    ld a, [_FREE_TILE_MEMORY]
    ld [playerTileAddress], a
    ld d, a
    ld h, a
    ld a, [_FREE_TILE_MEMORY+1]
    ld [playerTileAddress+1], a
    ld e, a
    ld l, a

    ld bc, playerTilesEnd - playerTiles

    add hl, bc

    ld a, h
    ld [_FREE_TILE_MEMORY], a
    ld a, l
    ld [_FREE_TILE_MEMORY+1], a

    ld a, [_FREE_SPRITE_SPACE]
    ld [playerSpriteAddress], a
    ld a, [_FREE_SPRITE_SPACE+1]
    ld [playerSpriteAddress+1], a

    ld a, [sprite_count]
    ld [playerSpriteStartId], a
    add a, 4
    ld [sprite_count], a

    call loadPlayerTiles

    ret

clearRemainingSpriteSpace:
    ld a, [sprite_count]
    ld b, 40 
    ;4 -> 16(if 4 sprites we got 16 Bytes)
    sla a
    sla a 
    ;40 -> 160 (40 Sprites x 4 Bytes)
    sla b
    sla b
    ld c, a
    ld a, [_FREE_SPRITE_SPACE]
    ld h, a
    ld a, [_FREE_SPRITE_SPACE+1]
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
    _FREE_TILE_MEMORY: DS 2
    _FREE_SPRITE_SPACE: DS 2
    sprite_count:: DS 1 ;40 max
    
    




	

