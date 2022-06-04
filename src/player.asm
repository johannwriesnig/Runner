INCLUDE "constants.inc"
SECTION "PlayerCode", ROM0

DEF MID_SCREEN EQU 70
DEF STARTING_Y EQU 128
DEF STARTING_X EQU 50
DEF GRAVITY EQU 1
DEF PLAYER_HEIGHT EQU 16
DEF MAX_Y EQU 128
DEF INPUT_RIGHT EQU %00000001
DEF INPUT_LEFT EQU %00000010
DEF INPUT_UP EQU %00000100
DEF INPUT_SHOOT EQU %00001000
DEF INPUT_IDLE EQU %00000000
DEF OAM_ATTRIBUTES_MOVING_LEFT EQU %00100000
DEF COLLISION_BOTTOM EQU %00000001
DEF COLLISION_RIGHT EQU %00000010
DEF COLLISION_LEFT EQU %00000100
DEF FACED_LEFT EQU %00000001
DEF FACED_RIGHT EQU %00000000
DEF PIXEL_PER_UPDATE EQU 1


initPlayer::
	call loadPlayerTiles

	ret

loadPlayerTiles:
	ld a, 0
	ld [is_Dead], a
	ld [Animation_Count], a
	ld [Frame_Time], a
	ld [SPEED_Y], a
	ld [COLLISIONS], a
	ld [ON_GROUND], a 
	ld [JUMP_PRESSED], a
	ld [GOING_UP], a
	ld [GRAVITY_DELAY], a
    ld de, playerTiles
    ld hl, _VRAM_TILES_SPRITES
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

resetPlayer::
	ld a, STARTING_X
	ld [POSITION_X], a
	ld a, STARTING_Y
	ld [POSITION_Y], a
	ld a, 0 
	ld [Frame_Time], a
	ld [Animation_Count], a 
	ret

updatePlayer::
	call checkInput
	call checkCollision
	call updatePositions
	ld a, [ON_GROUND]
	cp a, 1 
	jp nz, .jumpAnim
		call drawMovingRight
		jp .end
	.jumpAnim:
	call drawInAir

	.end:

	ld a, [JOYPAD_INPUT]
	and a,  INPUT_SHOOT
	jp z, .noShot
		;call shoot_Projectile
	
	.noShot

	ret

checkCollision:
	;checkBottomCollision
	ld a, [rSCX]
	ld b, a
	;add a, MID_SCREEN
	ld a, [POSITION_X]
	add a, b
	srl a
	srl a
	srl a
	ld b, a

	ld a, [POSITION_Y]
	srl a
	srl a
	srl a
	;determine bottomtile
	push af
	ld c, a
	ld a, b
	push af
	ld a, c
	call getTileId
	call isSolid
	ld d, a
	pop af
	ld b, a
	dec b
	pop af
	ld c, a
	ld a, d
	push af
	ld a, c
	
	call getTileId
	call isSolid
	ld b, a
	pop af
	or a, b
	jp z, .noBottomCollision
		ld a, COLLISION_BOTTOM 
		ld [COLLISIONS], a
		ld [ON_GROUND], a  
		jp .end
	.noBottomCollision:
	ld a,0
	ld [COLLISIONS], a
	.end:

	;check left-collision
	ld a, [POSITION_X]
	cp a, 9
	jp nc, .notReachedLeftEnd
	ld b, COLLISION_LEFT
	ld a, [COLLISIONS]
	or a, b
	ld [COLLISIONS], a
	.notReachedLeftEnd

	;check rightCollision
	
	ld a, [rSCX]
	ld b, a
	ld a, [POSITION_X]
	add a, b
	srl a
	srl a
	srl a
	add a, 1
	cp a, $20
	jp nz, .skipSetting0
	ld a, 0
	.skipSetting0:
	ld b, a

	ld a, [POSITION_Y]
	srl a
	srl a
	srl a
	sub a, 1
	call getTileId
	call isSolid

	cp a, 1
	jp nz, .noRightCollision
		ld a, [COLLISIONS]
		or a, COLLISION_RIGHT
		ld [COLLISIONS], a
	.noRightCollision:

	ld a, [POSITION_Y]
	cp a, 144
	jp c, .notDeadY
		ld a, 1
		ld [is_Dead], a
	.notDeadY:

	ld a, [POSITION_X]
	cp a, 230
	jp c, .notDeadX
		ld a, 1
		ld [is_Dead], a
	.notDeadX:

	ld a, [enemyX]
	ld b, a
	ld a, [POSITION_X]
	add a, 16
	cp a, b
	jp c, .noProjCol
	ld a, [POSITION_X]
	ld b, a
	ld a, [enemyX]
	add a, 8
	cp a, b
	jp c, .noProjCol
	ld a, [POSITION_Y]
	ld b, a
	ld a, [enemyY]
	add a, 8
	cp a, b
	jp c, .noProjCol
	ld a, [enemyY]
	ld b, a
	ld a, [POSITION_Y]
	add a, 16
	cp a, b
	jp c, .noProjCol
	ld a, 1 
	ld [is_Dead], a 


	.noProjCol:
	ret

updatePositions:

	ld a, [COLLISIONS]
	and a, COLLISION_RIGHT
	jp z, .noRightCollision
		ld a, [POSITION_X]
		sub a, SCROLL_PER_UPDATE 
		ld [POSITION_X], a
		jp .notGoingRight
	.noRightCollision

	ld a, [JOYPAD_INPUT]
	and a, INPUT_RIGHT
	jp z, .notGoingRight
			ld a, [POSITION_X]
			cp a, 153
			jp c, .goRight
			ld a, 152
			ld a, [POSITION_X]
			jp .notGoingRight
			.goRight:
			ld a, [POSITION_X]
			add a, PIXEL_PER_UPDATE 
			ld [POSITION_X], a
			jp .notGoingRight
			
	.notGoingRight:

	ld a, [JOYPAD_INPUT]
	and a, INPUT_LEFT
	jp z, .notGoingLeft
		ld a, [COLLISIONS]
		and a, COLLISION_LEFT
		jp z, .goingLeft
		ld a, 8
		ld [POSITION_X], a
		jp .notGoingLeft
		.goingLeft:
		ld a, [POSITION_X]
		sub a, PIXEL_PER_UPDATE + SCROLL_PER_UPDATE
		ld [POSITION_X], a
	.notGoingLeft:

	;part to set going up 
	ld a, [JOYPAD_INPUT]
	and a, INPUT_UP
	jp z, .jumpNotPressed
	ld a, [ON_GROUND]
	cp a, 1 
	jp nz, .isMidAir
	ld [GOING_UP], a
	call playJump
	ld a, 0
	ld [ON_GROUND], a 
	ld a, 9
	ld [SPEED_Y], a
	.isMidAir:
	.jumpNotPressed:

	;part to sub or add from speed based on going up or not

	ld a, [GOING_UP]
	cp a, 1
	jp nz, .notGoingUp
	ld a, [SPEED_Y]
	sub a, GRAVITY
	ld [SPEED_Y], a
	cp a, 0 
	jp nz, .stillGoingUp
	ld [GOING_UP], a 
	.stillGoingUp:
	jp .skipSpeedInc
	.notGoingUp:
	ld a, [SPEED_Y]
	cp a, 4
	jp z, .skipSpeedInc
	add a, GRAVITY
	ld [SPEED_Y], a
	.skipSpeedInc:
	
	
	;part to change position Y
	ld a, [GOING_UP]
	cp a, 1
	jp nz, .handleFall
	ld a, [SPEED_Y]
	ld b, a
	ld a, [POSITION_Y]
	sub a, b
	ld [POSITION_Y], a
	jp .skipFall
	.handleFall:
	ld a, [COLLISIONS]
	and a, COLLISION_BOTTOM
	cp a, 1
	jp z, .collision
	ld a, [POSITION_Y]
	ld b, a
	ld a, [SPEED_Y]
	add a, b
	ld [POSITION_Y], a
	jp .noCollision
	.collision:
	ld a, [POSITION_Y]
	srl a
	srl a
	srl a
	sla a
	sla a
	sla a
	ld [POSITION_Y], a
	.skipFall:
	.noCollision:
	ld a, [SPEED_Y]
	cp a, 9
	jp nz, .skipSpeedReset
	;ld a, 0
	;ld [SPEED_Y], a
	.skipSpeedReset:
	.skipGravity:
	ret



checkInput:
	ld a, [$FF00]
	ld b, a
	ld a, %11110000
	or a, b
	cpl
	ld [JOYPAD_INPUT], a
	ret

drawInAir:
	ld hl, _Sprites_Address
	ld b, 12

	ld a, [POSITION_Y]
	ld [hli], a
	ld a, [POSITION_X]
	ld [hli], a
	ld a,b
	ld [hli], a
	inc b
	ld a, 0 
	ld [hli], a	

	;lower left sprite
	ld a, [POSITION_Y]
	add a, 8
	ld [hli], a
	ld a, [POSITION_X]
	ld [hli], a
	ld a,b
	ld [hli], a
	ld a, 0 
	ld [hli], a
	inc b

	;upper right sprite
	ld a, [POSITION_Y]
	ld [hli], a
	ld a, [POSITION_X]
	add a,8
	ld [hli], a
	ld a,b
	ld [hli], a
	inc b
	ld a, 0 
	ld [hli], a

	;lower right sprite
	ld a, [POSITION_Y]
	add a,8
	ld [hli], a
	ld a, [POSITION_X]
	add a, 8
	ld [hli], a
	ld a,b
	ld [hli], a
	ld a, 0 
	ld [hli], a

	ret

drawMovingRight:
	ld a, [Frame_Time]
	inc a
	ld [Frame_Time], a
	cp a, 5
	jp nz, .keepTiles
	ld a, 0
	ld [Frame_Time], a
	ld a, [Animation_Count]
	inc a
	cp a, 3
	jp nz, .tilesInRange
	ld a, 0 
	.tilesInRange:
	ld [Animation_Count],a
	.keepTiles:

	ld hl, _Sprites_Address

	ld a, [Animation_Count]
	add a,a
	add a,a
	ld b, a

	ld a, 0

	add a, b
	ld b, a

	;upper left sprite
	ld a, [POSITION_Y]
	ld [hli], a
	ld a, [POSITION_X]
	ld [hli], a
	ld a,b
	ld [hli], a
	inc b
	ld a, 0 
	ld [hli], a	

	;lower left sprite
	ld a, [POSITION_Y]
	add a, 8
	ld [hli], a
	ld a, [POSITION_X]
	ld [hli], a
	ld a,b
	ld [hli], a
	ld a, 0 
	ld [hli], a
	inc b

	;upper right sprite
	ld a, [POSITION_Y]
	ld [hli], a
	ld a, [POSITION_X]
	add a,8
	ld [hli], a
	ld a,b
	ld [hli], a
	inc b
	ld a, 0 
	ld [hli], a

	;lower right sprite
	ld a, [POSITION_Y]
	add a,8
	ld [hli], a
	ld a, [POSITION_X]
	add a, 8
	ld [hli], a
	ld a,b
	ld [hli], a
	ld a, 0 
	ld [hli], a

	ret


SECTION "PlayerVariables", WRAM0
Animation_Count:: DS 1
Frame_Time:: DS 1
POSITION_X:: DS 1
POSITION_Y:: DS 1
SPEED_Y:: DS 1
ON_GROUND:: DS 1
GOING_UP:: DS 1
JUMP_PRESSED:: DS 1
JOYPAD_INPUT::DS 1
COLLISIONS:: DS 1 ; 1-down, 2-right, 3-top
GRAVITY_DELAY:: DS 1
is_Dead:: DS 1


SECTION "PlayerData", ROM0

playerTiles::
idle:
DB $00,$00,$00,$00,$01,$01,$01,$01
DB $02,$03,$03,$03,$02,$03,$02,$03
DB $01,$01,$00,$00,$00,$00,$01,$01
DB $01,$01,$00,$00,$01,$01,$01,$01
DB $00,$00,$78,$78,$86,$FE,$02,$FE
DB $03,$FF,$FD,$FF,$1A,$E6,$3E,$4A
DB $BE,$0A,$FE,$82,$FC,$FC,$54,$FC
DB $FC,$3C,$B4,$DC,$F4,$FC,$FE,$32
DB $00,$00,$01,$01,$01,$01,$02,$03
DB $03,$03,$02,$03,$02,$03,$01,$01
DB $00,$00,$00,$00,$00,$00,$01,$01
DB $01,$01,$00,$00,$00,$00,$00,$00
DB $78,$78,$86,$FE,$02,$FE,$03,$FF
DB $FD,$FF,$1A,$E6,$3E,$4A,$BE,$0A
DB $FE,$82,$FC,$FC,$A8,$F8,$F8,$78
DB $D8,$28,$F8,$F8,$48,$78,$7C,$44
DB $00,$00,$00,$00,$01,$01,$01,$01
DB $02,$03,$03,$03,$02,$03,$02,$03
DB $01,$01,$00,$00,$00,$00,$01,$01
DB $02,$03,$03,$02,$01,$01,$01,$01
DB $00,$00,$78,$78,$86,$FE,$02,$FE
DB $03,$FF,$FD,$FF,$1A,$E6,$3E,$4A
DB $BE,$0A,$FE,$82,$FC,$FC,$D6,$7E
DB $9F,$FD,$B6,$FE,$A4,$FC,$FE,$32
DB $01,$01,$06,$07,$04,$07,$08,$0F
DB $0F,$0F,$08,$0F,$08,$0D,$06,$04
DB $03,$02,$0E,$0F,$13,$1F,$36,$2F
DB $1C,$1F,$10,$0F,$1F,$0F,$10,$10
DB $E0,$E0,$18,$F8,$08,$F8,$0C,$FC
DB $F4,$FC,$68,$98,$F8,$28,$FA,$2A
DB $FF,$0D,$F2,$FE,$3C,$FC,$E2,$E2
DB $3E,$FC,$C2,$FC,$3E,$3E,$00,$00
playerTilesEnd::