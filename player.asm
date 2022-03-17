SECTION "PlayerCode", ROM0

copyPlayerTiles:: ;TileAddress must be set
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

SECTION "PlayerVariables", WRAM0
playerSpriteStartId:: DS 1
playerX:: DS 1
playerY:: DS 1
playerStatus:: DS 1;goingRight, goingLeft, idle, jumping
playerTilesAddress:: DS 2
playerSpriteAddress:: DS 2

SECTION "PlayerData", ROM0
playerSpriteCount:: DB $04

playerTiles::
db $09,$09,$17,$17,$1F,$1F,$3F,$3F
db $7F,$7F,$FF,$FF,$77,$7F,$72,$7F
db $78,$7F,$1C,$1F,$0F,$0F,$0E,$0B
db $0F,$09,$0F,$0F,$0F,$08,$07,$07
db $F8,$F8,$F0,$F0,$FC,$FC,$FE,$FE
db $FF,$FF,$F8,$F8,$A8,$E8,$A0,$E0
db $A0,$E0,$40,$C0,$80,$80,$C0,$C0
db $C0,$C0,$C0,$40,$80,$80,$00,$00
playerTilesEnd::
