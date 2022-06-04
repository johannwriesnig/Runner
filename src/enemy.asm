INCLUDE "constants.inc"
SECTION "EnemyCode", ROM0

DEF SpritesEnemy EQU _Sprites_Address + 20
DEF SpritesCount EQU 2

initEnemy::
    call loadEnemyData
    ret

loadEnemyData::
    ld a, 250
    ld [enemyX], a
    ld a, 0
    ld [isActive], a
    ld [frame_time], a
    ld a, 1
    ld [sendable], a
    ld de, enemyTiles
    ld hl, _VRAM_TILES_SPRITES + playerTilesEnd - playerTiles + projectilesTilesEnd - projectilesTiles 
	ld bc, enemyTilesEnd - enemyTiles
.copy:
	ld a, [de]
	ld [hli], a
	inc de
	dec bc
	ld a, b
	or a, c
	jp nz, .copy
 ret

 resetEnemy::
    ld a, 0
    ld [frame_time], a
    ld [isActive], a
    ld a, 1
    ld [sendable], a
    ret

sendEnemy::
    ld a, [sendable]
    cp a, 1 
    jp z, .continue
        ret
    .continue:
    ld a, 0
    ld [sendable], a

    ld a, 172
    ld [enemyX], a
    ld a, [POSITION_Y]
    sub a, 1
    ld [enemyY], a

    ld a, 1
    ld[isActive], a

    ret

updateEnemy::
    ld a, [isActive]
    cp a, 1
    jp z, .next
        ret
    .next:

    ld hl, SpritesEnemy
    ld a, [enemyY]
    ld [hli], a

	ld a, [enemyX]
    sub a, 4
    ld [enemyX], a
    cp a, 252
    jp nz, .continue
        ld hl, SpritesEnemy
        ld a, 0
        ld [hl], a
        ld [isActive], a
        ld a, 1
        ld [sendable], a
        ret
    .continue:

    ld a, [frame_time]
    inc a
    cp a, 4
    jp nz, .keep
        ld a, 0
        ld [frame_time], a
        ld a, [animation]
        inc a
        cp a, SpritesCount
        jp z, .skipReset
            ld a, 1
            ld [animation], a
            jp .keepAnim
        .skipReset:
        ld [animation], a
        jp .keepAnim
    .keep:
    ld [frame_time], a
    .keepAnim:
    ld a, [enemyX]
	ld [hli], a
    ld b, 16
    ld a, [animation]
    add a,b
    ld [hli], a
    ret

SECTION "EnemyVariables", WRAM0
sendable:: DS $1
isActive:: DS $1
enemyX:: DS 1
enemyY:: DS 1
animation:: DS 1
frame_time: DS 1



SECTION "EnemyData", ROM0

enemyTiles::
DB $02,$02,$84,$84,$48,$48,$38,$38
DB $1C,$1C,$12,$12,$21,$21,$40,$40
DB $04,$04,$08,$08,$90,$90,$5C,$5C
DB $3A,$3A,$09,$09,$10,$10,$20,$20
enemyTilesEnd::

