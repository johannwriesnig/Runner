INCLUDE "hardware.inc"

SECTION "Header", ROM0[$100]

	jp EntryPoint
	ds $150 - @, 0 ; Make room for the header

EntryPoint:
	call CopyDMARoutine

WaitVBlank:
	ld a, [rLY]
	cp 144
	jp c, WaitVBlank

	; Turn the LCD off
	ld a, 0
	ld [rLCDC], a


	; Copy the tile data
	ld de, Tiles
	ld hl, $8000
	ld bc, TilesEnd - Tiles
CopyTiles:
	ld a, [de]
	ld [hli], a
	inc de
	dec bc
	ld a, b
	or a, c
	jp nz, CopyTiles

	; Copy the tilemap
	;ld de, Tilemap
	;ld hl, $9800
	;ld bc, TilemapEnd - Tilemap
;CopyTilemap:
	;ld a, [de]
	;ld [hli], a
	;inc de
	;dec bc
	;ld a, b
	;or a, c
	;jp nz, CopyTilemap

	;This is for the OAM test
	ld hl, $C100
	ld [hl], 50
	inc l
	ld [hl], 50
	inc l
	ld [hl], 1
	inc l
	ld [hl], %00000000

	ld d, 156
	ld bc, $C104
	ld a, 0

	deleteRest:
	

	ld [bc], a
	inc c
	dec d
	jp nz, deleteRest


	ld a, $C1
	call hOAMDMA
	


	; During the first (blank) frame, initialize display registers
	ld a, %11100100
	ld [rBGP], a
	ld [rOBP0], a
	

	; Turn the LCD on
	ld a, LCDCF_ON | LCDCF_OBJON;| LCDCF_BGON 
	ld [rLCDC], a


Done:

	ld a, [$C101]
	inc a
	ld [$C101], a

	here:
	this:
	ld a, [rLY]
	cp 144
	jp c, this

	

	ld a, $C1
	call hOAMDMA


jp Done

CopyDMARoutine:
  ld  hl, DMARoutine
  ld de, hOAMDMA
  ld  b, DMARoutineEnd - DMARoutine ; Number of bytes to copy
  ld  c, LOW(hOAMDMA) ; Low byte of the destination address
.copy
  ld  a, [hli]
  ldh [c], a
  inc c
  dec b
  jr  nz, .copy
  ret

DMARoutine:
  ldh [rDMA], a
  
  ld  a, 40
.wait
  dec a
  jr  nz, .wait
  ret
DMARoutineEnd:

SECTION "OAM DMA", HRAM
hOAMDMA:
  ds DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to

SECTION "Tile data", ROM0
Tiles:
	;db $09,$09,$17,$17,$1F,$1F,$3F,$3F
	;db $7F,$7F,$FF,$FF,$77,$7F,$72,$7F
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $78,$7F,$1C,$1F,$0F,$0F,$0E,$0B
	db $0F,$09,$0F,$0F,$0F,$08,$07,$07
	db $F8,$F8,$F0,$F0,$FC,$FC,$FE,$FE
	db $FF,$FF,$F8,$F8,$A8,$E8,$A0,$E0
	db $A0,$E0,$40,$C0,$80,$80,$C0,$C0
	db $C0,$C0,$C0,$40,$80,$80,$00,$00
TilesEnd:

SECTION "Tilemap", ROM0

Tilemap:
TilemapEnd: