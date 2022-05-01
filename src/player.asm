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

	ret

checkCollision:
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

	ret

updatePositions:
	ld a, [JOYPAD_INPUT]
	and a, INPUT_RIGHT
	jp z, .notGoingRight
		ld a, [COLLISIONS]
		and a, COLLISION_RIGHT
		jp nz, .notGoingRight
			ld a, [POSITION_X]
			add a, PIXEL_PER_UPDATE 
			ld [POSITION_X], a
			jp .notGoingRight
		.moveBackGround:
	.notGoingRight:

	ld a, [JOYPAD_INPUT]
	and a, INPUT_LEFT
	jp z, .notGoingLeft
		ld a, [COLLISIONS]
		and a, COLLISION_LEFT
		jp nz, .notGoingLeft
		ld a, [POSITION_X]
		cp 4
		jp z, .notGoingLeft
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
	ld a, 0
	ld [SPEED_Y], a
	.skipSpeedReset:
	.skipGravity:
	ret



checkInput:
	ld a, [$FF00]
	ld b, a
	ld a, %11111000
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
DB $00,$00,$03,$03,$0C,$0F,$08,$0F
DB $10,$1F,$1F,$1F,$10,$1F,$11,$1A
DB $0D,$08,$07,$04,$07,$07,$0A,$0F
DB $0F,$09,$05,$06,$0F,$0F,$0F,$09
DB $00,$00,$C0,$C0,$30,$F0,$10,$F0
DB $18,$F8,$E8,$F8,$D0,$30,$F0,$50
DB $F0,$50,$F0,$10,$E0,$E0,$A0,$E0
DB $E0,$E0,$A0,$E0,$A0,$E0,$F0,$90
DB $03,$03,$0C,$0F,$08,$0F,$10,$1F
DB $1F,$1F,$10,$1F,$11,$1A,$0D,$08
DB $07,$04,$07,$07,$05,$07,$0F,$0B
DB $0E,$09,$07,$07,$02,$03,$03,$02
DB $C0,$C0,$30,$F0,$10,$F0,$18,$F8
DB $E8,$F8,$D0,$30,$F0,$50,$F0,$50
DB $F0,$10,$E0,$E0,$40,$C0,$C0,$C0
DB $C0,$40,$C0,$C0,$40,$C0,$E0,$20
DB $00,$00,$03,$03,$0C,$0F,$08,$0F
DB $10,$1F,$1F,$1F,$10,$1F,$11,$1A
DB $0D,$08,$07,$04,$07,$07,$0E,$0B
DB $14,$1F,$1D,$17,$0D,$0F,$0F,$09
DB $00,$00,$C0,$C0,$30,$F0,$10,$F0
DB $18,$F8,$E8,$F8,$D0,$30,$F0,$50
DB $F0,$50,$F0,$10,$E0,$E0,$B0,$F0
DB $F8,$E8,$B0,$F0,$20,$E0,$F0,$90
DB $07,$07,$18,$1F,$10,$1F,$20,$3F
DB $3F,$3F,$21,$3E,$23,$34,$1B,$10
DB $0F,$08,$3B,$3F,$4C,$7F,$DB,$BF
DB $70,$7F,$43,$3F,$7C,$3C,$40,$40
DB $80,$80,$60,$E0,$20,$E0,$30,$F0
DB $D0,$F0,$A0,$60,$E0,$A0,$E8,$A8
DB $FC,$34,$C8,$F8,$F0,$F0,$88,$88
DB $F8,$F0,$08,$F0,$F8,$F8,$00,$00
playerTilesEnd::