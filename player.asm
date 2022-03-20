SECTION "PlayerCode", ROM0

copyPlayerTiles:: ;TileAddress must be set
	ld a,0
	ld [playerAnimationCount], a
    ld de, playerTiles
    ld a, [playerTilesAddress]
    ld h, a
    ld a, [playerTilesAddress+1]
    ld l, a
	ld bc, playerTilesEnd - playerTiles
.copy:
	ld a, [de]
	ld [hli], a
	inc de
	dec bc
	ld a, b
	or a, c
	jp nz, .copy
    ret

setPlayersTileAddress:: ;address must be stored in de
	ld a, d
	ld [playerTilesAddress], a
	ld a, e
	ld [playerTilesAddress+1], a
	ret

setPlayersSpriteAddress:: ;address must be stored in de
	ld a, d
	ld [playerSpriteAddress], a
	ld a, e
	ld [playerSpriteAddress+1], a
	ret

setPlayerX:: ;address must be stored in a
	ld [playerX], a
	ret

setPlayerY:: ;address must be stored in a
	ld [playerY], a
	ret



updatePlayer::
;decide later where to put
	ld a, [$FF00]
    cpl
	ld [playerMovement], a

	ld a, [playerMovement]
	and a, %00000111
	ld b,a

	bit 0, a
	jp z, .notGoingRight
	ld a, [playerX]
	inc a
	ld [playerX], a
	.notGoingRight:

	ld a, [playerMovement]
	and a, %00000111
	bit 1, a
	jp z, .notGoingLeft
	ld a, [playerX]
	dec a
	ld [playerX], a
	.notGoingLeft:

	ld a, [playerMovement]
	and a, %00000111

	jp nz, .isMoving
		call handleNoMovement
		jp .done
	.isMoving:

	ld a, [playerMovement]
	and a, %00000100

	jp z, .notJumping
		call handleJump
		jp .done
	.notJumping:

	ld a, [playerMovement]
	and a, %00000010

	jp z, .movingRight
		call handleLeftMovement
		jp .done
	.movingRight:

		call handleRightMovement

	.done:
	ret

handleRightMovement:
	ld a, [playerAnimationCount]
	inc a
	and a, %00000001
	ld [playerAnimationCount],a

	cp a, 0
	jp nz, .secondAnim
	ld a, [playerSpriteAddress]
	ld h, a
	ld a, [playerSpriteAddress+1]
	ld l, a

	ld a, [playerSpriteStartId]
	ld b, a
	jp .writeSprites

	.secondAnim:
	ld a, [playerSpriteAddress]
	ld h, a
	ld a, [playerSpriteAddress+1]
	ld l, a

	ld a, [playerSpriteStartId]
	add a, 4
	ld b, a
	
	.writeSprites:

	;upper left sprite
	ld a, [playerY]
	ld [hli], a
	ld a, [playerX]
	ld [hli], a
	ld a,b
	ld [hli], a
	inc b
	ld a, 0 
	ld [hli], a	

	;lower left sprite
	ld a, [playerY]
	add a, 8
	ld [hli], a
	ld a, [playerX]
	ld [hli], a
	ld a,b
	ld [hli], a
	ld a, 0 
	ld [hli], a
	inc b

	;upper right sprite
	ld a, [playerY]
	ld [hli], a
	ld a, [playerX]
	add a,8
	ld [hli], a
	ld a,b
	ld [hli], a
	inc b
	ld a, 0 
	ld [hli], a

	;lower right sprite
	ld a, [playerY]
	add a,8
	ld [hli], a
	ld a, [playerX]
	add a, 8
	ld [hli], a
	ld a,b
	ld [hli], a
	ld a, 0 
	ld [hli], a
ret

handleLeftMovement:
	ld a, [playerAnimationCount]
	inc a
	and a, %00000001
	ld [playerAnimationCount],a

	cp a, 0
	jp nz, .secondAnim
	ld a, [playerSpriteAddress]
	ld h, a
	ld a, [playerSpriteAddress+1]
	ld l, a

	ld a, [playerSpriteStartId]
	ld b, a
	jp .writeSprites

	.secondAnim:
	ld a, [playerSpriteAddress]
	ld h, a
	ld a, [playerSpriteAddress+1]
	ld l, a

	ld a, [playerSpriteStartId]
	add a, 4
	ld b, a
	
	.writeSprites:

	;upper left sprite
	ld a, [playerY]
	ld [hli], a
	ld a, [playerX]
	ld [hli], a
	ld a,b
	add a,2
	ld [hli], a
	inc b
	ld a, %00100000
	ld [hli], a	

	;lower left sprite
	ld a, [playerY]
	add a, 8
	ld [hli], a
	ld a, [playerX]
	ld [hli], a
	ld a,b
	add a,2
	ld [hli], a
	ld a, %00100000 
	ld [hli], a
	inc b

	;upper right sprite
	ld a, [playerY]
	ld [hli], a
	ld a, [playerX]
	add a,8
	ld [hli], a
	ld a,b
	sub a, 2
	ld [hli], a
	inc b
	ld a, %00100000
	ld [hli], a

	;lower right sprite
	ld a, [playerY]
	add a,8
	ld [hli], a
	ld a, [playerX]
	add a, 8
	ld [hli], a
	ld a,b
	sub a,2
	ld [hli], a
	ld a, %00100000
	ld [hli], a
ret

handleNoMovement:
	ld a, [playerSpriteAddress]
	ld h, a
	ld a, [playerSpriteAddress+1]
	ld l, a

	ld a, [playerSpriteStartId]
	ld b, a	

	;upper left sprite
	ld a, [playerY]
	ld [hli], a
	ld a, [playerX]
	ld [hli], a
	ld a,b
	ld [hli], a
	inc b
	ld a, 0 
	ld [hli], a	

	;lower left sprite
	ld a, [playerY]
	add a, 8
	ld [hli], a
	ld a, [playerX]
	ld [hli], a
	ld a,b
	ld [hli], a
	ld a, 0 
	ld [hli], a
	inc b

	;upper right sprite
	ld a, [playerY]
	ld [hli], a
	ld a, [playerX]
	add a,8
	ld [hli], a
	ld a,b
	ld [hli], a
	inc b
	ld a, 0 
	ld [hli], a

	;lower right sprite
	ld a, [playerY]
	add a,8
	ld [hli], a
	ld a, [playerX]
	add a, 8
	ld [hli], a
	ld a,b
	ld [hli], a
	ld a, 0 
	ld [hli], a
ret

handleJump:
ret

SECTION "PlayerVariables", WRAM0
playerMovement:: DS 1; -,-,-,-,-,up,left,right
playerAnimationCount:: DS 1
playerSpriteStartId:: DS 1
playerX:: DS 1
playerY:: DS 1
playerTilesAddress:: DS 2
playerSpriteAddress:: DS 2

SECTION "PlayerData", ROM0
playerNeededTileCount:: DB $04
playerTilesCount::DB $08

playerTiles::
playerTilesFirst:
DB $09,$09,$17,$17,$3F,$3F,$3F,$3F
DB $7F,$7F,$FF,$FF,$77,$7F,$72,$7F
DB $7F,$78,$1F,$1C,$1F,$1F,$0B,$0E
DB $09,$0F,$0F,$0F,$08,$0F,$07,$07
DB $F8,$F8,$F0,$F0,$FC,$FC,$FE,$FE
DB $FF,$FF,$F8,$F8,$E8,$A8,$E0,$A0
DB $E0,$A0,$C0,$40,$80,$80,$C0,$C0
DB $C0,$C0,$40,$C0,$C0,$C0,$00,$00
playerTilesSecond:
DB $09,$09,$17,$17,$3F,$3F,$3F,$3F
DB $7F,$7F,$FF,$FF,$77,$7F,$72,$7F
DB $7F,$78,$1F,$1C,$0F,$0F,$1D,$17
DB $18,$1F,$0B,$0F,$04,$07,$03,$03
DB $F8,$F8,$F0,$F0,$FC,$FC,$FE,$FE
DB $FF,$FF,$F8,$F8,$E8,$A8,$E0,$A0
DB $E0,$A0,$C0,$40,$80,$80,$C0,$C0
DB $40,$C0,$C0,$C0,$40,$C0,$80,$80
playerTilesEnd::
