INCLUDE "constants.inc"
SECTION "ProjectilesCode", ROM0

DEF MAX_PROJECTILES EQU 3
DEF SpritesAdd EQU _Sprites_Address + 16
DEF Distance_Update_X EQU 3
DEF Distance_Update_Y EQU 2

setupProjectiles::
    ld a, 0
    ld[Shot_Projectiles], a
    ld [Is_Active], a
    ld de, projectilesTiles
    ld hl, _VRAM_TILES_SPRITES + playerTilesEnd - playerTiles
	ld bc, projectilesTilesEnd- projectilesTiles
    .copy:
	    ld a, [de]
	    ld [hli], a
	    inc de
	    dec bc
	    ld a, b
	    or a, c
	    jp nz, .copy
    ret

    
checkProjectileCollision:
    ld a, [rSCX]
	ld b, a
	;add a, MID_SCREEN
	ld a, [ProjectileX]
	add a, b
	srl a
	srl a
	srl a
	ld b, a

	ld a, [ProjectileY]
	srl a
	srl a
	srl a
    dec a
	;determine bottomtile
	call getTileId
	call isSolid

    cp a, 1
    jp nz, .noBottomCollision
        ld a, 1
        ld [Is_Going_Up], a
    .noBottomCollision:

    ret

updateProjectiles::
    call checkProjectileCollision

    ld a, [Is_Active]
    cp a, 0
    jp z, .end
    ld hl, SpritesAdd
    ld a, 16
    ld b, a

    ld a, [Is_Going_Up]
    cp a, 1
    ld a, [ProjectileY]
    jp z, .isGoingUp
        add a, Distance_Update_Y
        jp .continue
    .isGoingUp:
        sub a, Distance_Update_Y
    .continue
	ld [hli], a
    ld[ProjectileY], a
	ld a, [ProjectileX]
    add a, 3
    ld [ProjectileX], a
	ld [hli], a
    cp a, 180
    jp c, .stillActive
        ld a, 0 
        ld [Is_Active], a
    .stillActive:
	ld a, b
	ld [hli], a
	ld a, 0 
	ld [hli], a	
    .end:

    ret

shoot_Projectile::
    ld a, [Is_Active]

    cp a, 1 
    jp z, .end

    ld a, 1
    ld [Is_Active], a

    ld a, 0 
    ld [Is_Going_Up], a

    ld hl, SpritesAdd
    ld a, 16
    ld b, a

    ld a, [POSITION_Y]
    add a, 4
    ld [ProjectileY], a
	ld [hli], a
	ld a, [POSITION_X]
    add a, 8
    ld [ProjectileX], a
	ld [hli], a
	ld a, b
	ld [hli], a
	ld a, 0 
	ld [hli], a	

    .end:

    ret


SECTION "ProjectilesVariables", WRAM0
Shot_Projectiles:: DS 1
Is_Active:: DS 1
ProjectileX: DS 1
ProjectileY: DS 1
Is_Going_Up:: DS 1

SECTION "ProjectileData", ROM0

projectilesTiles::
DB $00,$00,$00,$00,$1E,$1E,$21,$21
DB $2F,$2F,$3F,$3F,$1E,$1E,$00,$00
projectilesTilesEnd::