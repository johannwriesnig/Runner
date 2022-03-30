INCLUDE "constants.inc"
SECTION "LogoCode", ROM0

logoHandler::
    call loadLogo
    call initAnimation
    call animateTillStart
    ret

loadLogo:
    call WaitVBlank
    call turnLCDOFF
    call loadLogoTiles
    call setPalettes
    call clearSpriteSpace
    call turnLCDON
    ret

loadLogoTiles:
    call loadLogoBGTiles
    call loadLogoTileMap
    call loadLogoAnimationTiles
    ret

loadLogoBGTiles:
    ld de, LogoBGTilesEnd-LogoBGTiles
    ld bc, LogoBGTiles
    ld hl, _VRAM_TILES_BACKGROUND
    call memcpy
    ret

loadLogoTileMap:
    ld de, LogoTileMapEnd-LogoTileMap
    ld bc, LogoTileMap
    ld hl, _VRAM_TILEMAP
    call memcpy
    ret

loadLogoAnimationTiles:
    ld de, LogoPlayerTilesEnd-LogoPlayerTiles
    ld bc, LogoPlayerTiles
    ld hl, _VRAM_TILES_SPRITES
    call memcpy
    ret

clearSpriteSpace::
    ld de, _Sprites_Block_Size
    ld hl, _Sprites_Address
    call memclear
    ld hl, _Sprites_Address
    ld a, h
    call startDMA
    ret

initAnimation:
    ld a, _LOGO_PLAYER_STARTING_X
    ld [Player_X], a
    ld a, _LOGO_PLAYER_STARTING_Y
    ld [Player_Y], a
    ld a, 0
    ld [Player_Animation_Count], a
    ld [Player_Frame_Time], a
    ld [Player_Idle_Time], a
    ret

animateTillStart:
    .loop:
        call drawRunAnim
        call drawTurnAnim
        call drawJumpAnim
    jp .loop
    ret

drawTurnAnim:
    call drawLeftTurn
    call drawRightTurn
    ret

drawLeftTurn:
    ld a, 0
    call stopAnimFor1Sek
    .loop:
    call delayAll
    call WaitVBlank
    ld a, [Player_Animation_Count]
    ld b, 0
    .multLoop:
        cp a, 0
        jp z, .multLoopEnd
        push af
        ld a, 4
        add a, b
        ld b, a
        pop af
        dec a
        jp .multLoop
    .multLoopEnd:

    ld hl, _Sprites_Address
    ;upper right sprite
	ld a, [Player_Y]
	ld [hli], a
	ld a, [Player_X]
	add a,8
	ld [hli], a
	ld a,b
	ld [hli], a
	inc b
	ld a, %00100000
	ld [hli], a

    ;lower right sprite
	ld a, [Player_Y]
	add a,8
	ld [hli], a
	ld a, [Player_X]
	add a, 8
	ld [hli], a
	ld a,b
	ld [hli], a
    inc b
	ld a, %00100000
	ld [hli], a

    ;upper left sprite
    ld a, [Player_Y]
	ld [hli], a
	ld a, [Player_X]
	ld [hli], a
	ld a, b
	ld [hli], a
	inc b
	ld a, %00100000 
	ld [hli], a	

	;lower left sprite
	ld a, [Player_Y]
	add a, 8
	ld [hli], a
	ld a, [Player_X]
	ld [hli], a
	ld a,b
	ld [hli], a
	ld a, %00100000
	ld [hli], a
	inc b


    ld a, HIGH(_Sprites_Address)
    call startDMA

    ld a, [Player_X]
    dec a
    ld [Player_X], a

    ld a, [Player_Frame_Time]
    inc a
    ld [Player_Frame_Time], a
    cp a, 5; frametime per animation
    jp nz, .keepAnimation
    ld a, 0
    ld [Player_Frame_Time], a
    ld a, [Player_Animation_Count]
    inc a 
    cp a, 3
    jp nz, .inRange
        ld a, 0
    .inRange
    ld [Player_Animation_Count], a

    .keepAnimation:

    ld a, [Player_X]
    cp a, _LOGO_PLAYER_TURN_RIGHT_X
    jp nz, .loop
    ret

stopAnimFor1Sek:
    ld b, 0
    .outerLoop:
    inc b
        ld a, 0
        .innerLoop:
        inc a
        cp a, 255
        jp nz, .innerLoop
    ld a,b
    cp a, 250
    jp nz, .outerLoop
    ret

drawRightTurn:
    ret

drawRunAnim:
    .loop:
    call delayAll
    call WaitVBlank
    ld a, [Player_Animation_Count]
    ld b, 0
    .multLoop:
        cp a, 0
        jp z, .multLoopEnd
        push af
        ld a, 4
        add a, b
        ld b, a
        pop af
        dec a
        jp .multLoop
    .multLoopEnd:

    ld hl, _Sprites_Address
    ;upper left sprite
    ld a, [Player_Y]
	ld [hli], a
	ld a, [Player_X]
	ld [hli], a
	ld a, b
	ld [hli], a
	inc b
	ld a, 0 
	ld [hli], a	

	;lower left sprite
	ld a, [Player_Y]
	add a, 8
	ld [hli], a
	ld a, [Player_X]
	ld [hli], a
	ld a,b
	ld [hli], a
	ld a, 0 
	ld [hli], a
	inc b

	;upper right sprite
	ld a, [Player_Y]
	ld [hli], a
	ld a, [Player_X]
	add a,8
	ld [hli], a
	ld a,b
	ld [hli], a
	inc b
	ld a, 0 
	ld [hli], a

	;lower right sprite
	ld a, [Player_Y]
	add a,8
	ld [hli], a
	ld a, [Player_X]
	add a, 8
	ld [hli], a
	ld a,b
	ld [hli], a
	ld a, 0 
	ld [hli], a

    ld a, HIGH(_Sprites_Address)
    call startDMA

    ld a, [Player_X]
    inc a
    ld [Player_X], a

    ld a, [Player_Frame_Time]
    inc a
    ld [Player_Frame_Time], a
    cp a, 5; frametime per animation
    jp nz, .keepAnimation
    ld a, 0
    ld [Player_Frame_Time], a
    ld a, [Player_Animation_Count]
    inc a 
    cp a, 3
    jp nz, .inRange
        ld a, 0
    .inRange:
    ld [Player_Animation_Count], a

    .keepAnimation:

    ld a, [Player_X]
    cp a, _LOGO_PLAYER_TURN_LEFT_X
    jp nz, .loop
    ret


drawJumpAnim:
    .loop:

    jp .loop
    ret


SECTION "LogoVariables", WRAM0
Player_X: DS 1
Player_Y: DS 1
Player_Animation_Count: DS 1
Player_Frame_Time: DS 1
Player_Idle_Time: DS 1


SECTION "LogoData", ROM0

LogoBGTiles::
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $1C,$FF,$22,$FF,$5D,$FF,$51,$FF
DB $5D,$FF,$22,$FF,$1C,$FF,$00,$FF
DB $FF,$00,$FF,$7C,$FF,$66,$FF,$66
DB $FF,$7C,$FF,$60,$FF,$60,$FF,$00
DB $FF,$00,$FF,$7C,$FF,$66,$FF,$66
DB $FF,$7C,$FF,$68,$FF,$66,$FF,$00
DB $FF,$00,$FF,$7E,$FF,$60,$FF,$7C
DB $FF,$60,$FF,$60,$FF,$7E,$FF,$00
DB $FF,$00,$FF,$3C,$FF,$60,$FF,$3C
DB $FF,$0E,$FF,$4E,$FF,$3C,$FF,$00
DB $00,$FF,$63,$FF,$94,$FF,$90,$FF
DB $91,$FF,$67,$FF,$00,$FF,$00,$FF
DB $00,$FF,$38,$FF,$44,$FF,$04,$FF
DB $18,$FF,$7E,$FF,$00,$FF,$00,$FF
DB $00,$FF,$F9,$FF,$0B,$FF,$0B,$FF
DB $4B,$FF,$79,$FF,$00,$FF,$00,$FF
DB $00,$FF,$E4,$FF,$34,$FF,$37,$FF
DB $34,$FF,$E4,$FF,$00,$FF,$00,$FF
DB $00,$FF,$5C,$FF,$48,$FF,$C8,$FF
DB $48,$FF,$5C,$FF,$00,$FF,$00,$FF
DB $00,$FF,$87,$FF,$48,$FF,$40,$FF
DB $83,$FF,$EF,$FF,$00,$FF,$00,$FF
DB $FF,$81,$FF,$3C,$FF,$46,$FF,$46
DB $FF,$7E,$FF,$46,$FF,$46,$FF,$81
DB $FF,$00,$FF,$01,$FF,$01,$FF,$01
DB $FF,$01,$FF,$01,$FF,$01,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$7E
DB $FF,$7E,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$80,$FF,$80,$FF,$80
DB $FF,$80,$FF,$80,$FF,$80,$FF,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $3F,$3F,$7F,$40,$3F,$30,$FF,$FF
DB $00,$00,$00,$00,$00,$00,$FF,$FF
DB $FF,$00,$FF,$00,$FF,$FF,$00,$00
DB $00,$00,$00,$00,$0F,$0F,$FF,$F1
DB $FF,$00,$FF,$00,$FF,$FF,$00,$00
DB $00,$00,$00,$00,$FE,$FE,$FF,$09
DB $FF,$00,$FF,$FF,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$F8,$F8
DB $FF,$1F,$E0,$E0,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $FF,$00,$00,$00,$FF,$00,$00,$00
DB $FF,$00,$00,$00,$00,$00,$00,$00
DB $FF,$FF,$00,$00,$FF,$FF,$FF,$FF
DB $FF,$10,$FF,$40,$FF,$00,$FF,$FF
DB $00,$FF,$FF,$FF,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $00,$02,$00,$0A,$00,$0E,$00,$28
DB $00,$38,$00,$08,$00,$08,$00,$08
DB $00,$00,$00,$00,$00,$00,$00,$10
DB $00,$54,$00,$5C,$00,$70,$00,$10
DB $00,$00,$00,$00,$00,$00,$38,$38
DB $7C,$44,$E6,$9A,$C6,$BA,$CE,$B2
DB $7C,$44,$78,$78,$08,$F8,$00,$70
DB $44,$7C,$48,$78,$00,$30,$00,$30
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$38,$38,$7C,$44
DB $64,$5C,$7C,$44,$38,$38,$08,$78
DB $24,$3C,$28,$38,$00,$10,$00,$10
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $08,$08,$1C,$14,$32,$22,$61,$47
DB $7E,$7E,$81,$81,$9F,$9F,$9F,$9F
DB $9F,$9F,$9F,$9F,$FF,$FF,$7E,$7E
DB $00,$18,$00,$3C,$00,$3C,$00,$24
DB $00,$24,$00,$3C,$00,$3C,$00,$18
DB $00,$00,$00,$00,$00,$00,$FF,$FF
DB $FF,$00,$FF,$0F,$FF,$00,$FF,$FF
DB $00,$00,$00,$00,$1F,$1F,$FF,$E0
DB $FF,$01,$FF,$F0,$FF,$00,$FF,$FF
DB $00,$00,$00,$00,$FE,$FE,$FF,$01
DB $FF,$10,$FF,$00,$FF,$FF,$00,$00
DB $00,$00,$00,$00,$00,$00,$FF,$FF
DB $FF,$03,$FC,$FC,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $F0,$F0,$00,$00,$00,$00,$00,$00
DB $FF,$FF,$00,$FF,$00,$00,$FF,$FF
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $09,$0D,$09,$0D,$09,$0D,$09,$0D
DB $09,$0D,$09,$0D,$09,$0D,$09,$0D
DB $90,$B0,$90,$B0,$90,$B0,$90,$B0
DB $90,$B0,$90,$B0,$90,$B0,$90,$B0
DB $FF,$FF,$00,$00,$00,$FF,$FF,$FF
DB $FF,$FF,$FF,$FF,$00,$00,$00,$00
DB $09,$0D,$08,$0C,$08,$0F,$0F,$0F
DB $07,$07,$03,$03,$00,$00,$00,$00
DB $90,$B0,$10,$30,$10,$F0,$F0,$F0
DB $E0,$E0,$C0,$C0,$00,$00,$00,$00
DB $07,$07,$08,$0F,$08,$0C,$09,$0D
DB $09,$0D,$09,$0D,$09,$0D,$09,$0D
DB $E0,$E0,$10,$F0,$10,$30,$90,$B0
DB $90,$B0,$90,$B0,$90,$B0,$90,$B0
DB $00,$00,$3F,$3F,$3F,$3F,$30,$30
DB $30,$30,$30,$30,$3F,$3F,$3F,$3F
DB $37,$37,$33,$33,$31,$31,$30,$30
DB $30,$30,$30,$30,$30,$30,$00,$00
DB $00,$00,$FC,$FC,$FE,$FE,$06,$06
DB $06,$06,$06,$06,$FE,$FE,$FC,$FC
DB $00,$00,$80,$80,$C0,$C0,$E0,$E0
DB $70,$70,$38,$38,$1C,$1C,$00,$00
DB $00,$00,$60,$60,$60,$60,$60,$60
DB $60,$60,$60,$60,$60,$60,$60,$60
DB $60,$60,$60,$60,$60,$60,$60,$60
DB $60,$60,$60,$60,$3F,$3F,$00,$00
DB $00,$00,$06,$06,$06,$06,$06,$06
DB $06,$06,$06,$06,$06,$06,$06,$06
DB $06,$06,$06,$06,$06,$06,$06,$06
DB $06,$06,$06,$06,$FC,$FC,$00,$00
DB $00,$00,$60,$60,$70,$70,$78,$78
DB $6C,$6C,$66,$66,$63,$63,$61,$61
DB $60,$60,$60,$60,$60,$60,$60,$60
DB $60,$60,$60,$60,$00,$00,$00,$00
DB $00,$00,$06,$06,$06,$06,$06,$06
DB $06,$06,$06,$06,$06,$06,$86,$86
DB $C6,$C6,$66,$66,$36,$36,$1E,$1E
DB $0E,$0E,$06,$06,$00,$00,$00,$00
DB $00,$00,$7F,$7F,$60,$60,$60,$60
DB $60,$60,$60,$60,$60,$60,$60,$60
DB $7F,$7F,$60,$60,$60,$60,$60,$60
DB $60,$60,$60,$60,$7F,$7F,$00,$00
DB $00,$00,$FE,$FE,$00,$00,$00,$00
DB $00,$00,$00,$00,$00,$00,$00,$00
DB $F0,$F0,$00,$00,$00,$00,$00,$00
DB $00,$00,$00,$00,$FC,$FC,$00,$00
DB $00,$FF,$00,$FF,$80,$FF,$80,$FF
DB $00,$FF,$C0,$FF,$00,$FF,$00,$FF
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$FF,$00,$FF,$00,$FF
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $FF,$00,$FF,$00,$FF,$00,$FF,$00
DB $00,$FF,$00,$FF,$00,$FF,$00,$FF
DB $00,$FF,$00,$FF,$00,$FF,$00,$FF
LogoBGTilesEnd:

LogoPlayerTiles:
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
LogoPlayerTilesEnd:

LogoTileMap:
DB $97,$97,$97,$97,$97,$97,$97,$97,$97,$97
DB $97,$97,$97,$97,$97,$97,$97,$97,$97,$97
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$A1,$80,$80
DB $91,$A3,$A4,$A5,$A6,$A7,$A1,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$93,$94,$95,$80,$80,$A2
DB $80,$80,$80,$80,$80,$80,$80,$80,$A2,$80
DB $80,$91,$A3,$A4,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$AE,$A8
DB $A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8,$A8
DB $A8,$A8,$A8,$AF,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $A9,$80,$B0,$B2,$B4,$B6,$B8,$BA,$B8,$BA
DB $BC,$BE,$B0,$B2,$80,$AA,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$A9,$80,$B1,$B3,$B5,$B7,$B9,$BB
DB $B9,$BB,$BD,$BF,$B1,$B3,$80,$AA,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$AC,$AB,$AB,$AB,$AB,$AB
DB $AB,$AB,$AB,$AB,$AB,$AB,$AB,$AB,$AB,$AD
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$9E,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$9A
DB $9B,$80,$80,$C5,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$9B,$9F,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $98,$98,$98,$98,$98,$98,$98,$98,$98,$98
DB $98,$A0,$A0,$A0,$98,$98,$98,$98,$98,$98
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$99,$99,$99,$99,$99,$99,$99,$99
DB $99,$99,$99,$99,$99,$99,$99,$99,$99,$99
DB $99,$99,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$C2,$C2,$C2,$C2,$C2,$C2
DB $C2,$C2,$C2,$C2,$C2,$C2,$8E,$C2,$C2,$C2
DB $C2,$C2,$C2,$C2,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$C2,$C2,$C2,$C2
DB $C2,$C2,$82,$83,$84,$85,$85,$8D,$8C,$90
DB $C2,$C2,$C2,$C2,$C2,$C2,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$C2,$C2
DB $C2,$C2,$C2,$C2,$C2,$C2,$C2,$C2,$C2,$C2
DB $8F,$C2,$C2,$C2,$C2,$C2,$C2,$C2,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $C2,$C2,$C2,$C2,$C2,$C2,$C2,$C2,$C2,$C2
DB $C2,$C2,$C2,$C2,$C2,$C2,$C2,$C2,$C2,$C2
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$C1,$C1,$C1,$C1,$C1,$C1,$C1,$C1
DB $C1,$C1,$C1,$C1,$C1,$C1,$C1,$C1,$C1,$C1
DB $C1,$C1,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$C3,$C3,$C3,$C3,$C3,$C3
DB $C3,$C3,$C3,$C3,$C3,$C3,$81,$87,$86,$8B
DB $C0,$88,$89,$8A,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80,$80,$80,$80,$80,$80,$80
DB $80,$80,$80,$80
LogoTileMapEnd: