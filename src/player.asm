INCLUDE "constants.inc"
SECTION "PlayerCode", ROM0

loadPlayerTiles::
    ld de, playerTiles
    ld a, [playerTileAddress]
    ld h, a
    ld a, [playerTileAddress+1]
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

updatePlayer::
	ld a, [playerAnimationCount]
	inc a
	and a, %00000001
	ld [playerAnimationCount],a

	ld a, [playerMovement]
	bit 0, a

	jp z, .notGoingRight
		call handleRightMovement
			ld a, [rSCX]
			inc a
			ld [rSCX], a
			ld a, [scroll_count]
			inc a
			ld [scroll_count], a
		jp .done
	.notGoingRight:

	ld a, [playerMovement]
	bit 1, a

	jp z, .notGoingLeft
		call handleLeftMovement
			ld a, [rSCX]
			dec a
			ld [rSCX], a

		jp .done
	.notGoingLeft:

	call handleNoMovement

	.done:
	ret

handleNoMovement::
	ld a, 0
	ld [playerAnimationCount], a
	ld a, [playerLatestDir]
	cp a, 1 
	jp nz, .facingLeft
		call handleRightMovement
		jp .done
	.facingLeft:
		call handleLeftMovement

	.done:
	ret

handleRightMovement:
	ld a, 1
	ld [playerLatestDir], a

	ld a, [playerSpriteAddress]
	ld h, a
	ld a, [playerSpriteAddress+1]
	ld l, a

	ld a, [playerAnimationCount]
	add a,a
	add a,a
	ld b, a

	ld a, [playerSpriteStartId]

	
	add a, b
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

handleLeftMovement:
	ld a, 1
	ld [playerLatestDir], a

	ld a, [playerSpriteAddress]
	ld h, a
	ld a, [playerSpriteAddress+1]
	ld l, a

	ld a, [playerAnimationCount]
	add a,a
	add a,a
	ld b, a

	ld a, [playerSpriteStartId]

	
	add a, b
	ld b, a

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





SECTION "PlayerVariables", WRAM0
playerMovement:: DS 1; -,-,-,-,-,up,left,right
playerAnimationCount:: DS 1
playerLatestDir: DS 1 ; 1-right 0-left
playerSpriteStartId:: DS 1
playerX:: DS 1
playerY:: DS 1
playerTileAddress:: DS 2
playerSpriteAddress:: DS 2

SECTION "PlayerData", ROM0

playerTiles::
idle:
DB $09,$09,$17,$17,$3F,$3F,$3F,$3F
DB $7F,$7F,$FF,$FF,$77,$7F,$72,$7F
DB $7F,$78,$1F,$1C,$1F,$1F,$0B,$0E
DB $09,$0F,$0F,$0F,$08,$0F,$07,$07
DB $F8,$F8,$F0,$F0,$FC,$FC,$FE,$FE
DB $FF,$FF,$F8,$F8,$E8,$A8,$E0,$A0
DB $E0,$A0,$C0,$40,$80,$80,$C0,$C0
DB $C0,$C0,$40,$C0,$C0,$C0,$00,$00
run:
DB $09,$09,$17,$17,$3F,$3F,$3F,$3F
DB $7F,$7F,$FF,$FF,$77,$7F,$72,$7F
DB $7F,$78,$1F,$1C,$0F,$0F,$1D,$17
DB $18,$1F,$0B,$0F,$04,$07,$03,$03
DB $F8,$F8,$F0,$F0,$FC,$FC,$FE,$FE
DB $FF,$FF,$F8,$F8,$E8,$A8,$E0,$A0
DB $E0,$A0,$C0,$40,$80,$80,$C0,$C0
DB $40,$C0,$C0,$C0,$40,$C0,$80,$80
playerTilesEnd::