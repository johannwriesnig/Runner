INCLUDE "hardware.inc"
 
SECTION "Header", ROM0[$100]

	jp loadData ;
	ds $150 - @, 0 ;Space for Header


TilesAddress: db $80, $00
SpriteAddress: db $C1, $00

loadData: ;load DMARoutine, Tiles, etc.
	call CopyDMARoutine 
	call WaitVBlank
	ld a, 0
	ld [rLCDC], a
	ld a, [TilesAddress]
	ld hl, playerTilesAddress
	ld [hl], a 
	ld a, [TilesAddress+1]
	ld hl, playerTilesAddress+1
	ld [hl],  a
	call initPlayer
	;This is for the OAM test
	ld hl, $C100
	ld [hl], 50
	inc l
	ld [hl], 50
	inc l
	ld [hl], 1
	inc l
	ld [hl], %00000000
	;Delete rest
	ld d, 156
	ld bc, $C104
	ld a, 0

	deleteRest:
	

	ld [bc], a
	inc c
	dec d
	jp nz, deleteRest
	ld a, %11100100
	ld [rBGP], a
	ld [rOBP0], a
	

	; Turn the LCD on
	ld a, LCDCF_ON | LCDCF_OBJON;| LCDCF_BGON 
	ld [rLCDC], a
	jp gameLoop

CopyTiles:
	;Turn off LCD
	ld a, 0
	ld [rLCDC], a
	ld de, Tiles
	ld hl, $8000
	ld bc, TilesEnd - Tiles
.copy:
	ld a, [de]
	ld [hli], a
	inc de
	dec bc
	ld a, b
	or a, c
	jp nz, .copy
	;init palettes
	ld a, %11100100
	ld [rBGP], a
	ld [rOBP0], a
	

	; Turn the LCD on
	ld a, LCDCF_ON | LCDCF_OBJON;| LCDCF_BGON 
	ld [rLCDC], a
	ret



CopyDMARoutine:
  ld  hl, DMARoutine
  ld de, hOAMDMA
  ld  b, DMARoutineEnd - DMARoutine ; 
  ld  c, LOW(hOAMDMA) ; 
.copyRoutine ;copy routine into HRAM
  ld  a, [hli]
  ldh [c], a
  inc c
  dec b
  jr  nz, .copyRoutine
  ret

DMARoutine: ;Start DMA and wait 160 Cycles
  ldh [rDMA], a
  ld  a, 40
.wait
  dec a
  jr  nz, .wait
  ret
DMARoutineEnd:

WaitVBlank: 
	ld a, [rLY]
	cp 144
	jp c, WaitVBlank
	ret

gameLoop:
	call WaitVBlank

;naively making movement slower
	ld a,160
	loop:
	dec a
	jp nz, loop

	ld hl, $FF00
	bit 0, [hl]

	jp nz, noRightInput
	ld hl, $C101
	inc [hl]
	noRightInput:

	ld hl, $FF00
	bit 1, [hl]

	jp nz, noLeftInput
	ld hl, $C101
	dec [hl]
	noLeftInput:

	ld hl, $FF00
	bit 2, [hl]

	jp nz, noUpInput
	ld hl, $C100
	dec [hl]
	noUpInput:

	ld hl, $FF00
	bit 3, [hl]

	jp nz, noDownInput
	ld hl, $C100
	inc [hl]
	noDownInput:


	
	ld a, $C1
	call hOAMDMA
	jp gameLoop


SECTION "OAM DMA", HRAM
hOAMDMA:
  ds DMARoutineEnd - DMARoutine ; Space for DMA-Routine

SECTION "Tile data", ROM0
Tiles:
	db $09,$09,$17,$17,$1F,$1F,$3F,$3F
	db $7F,$7F,$FF,$FF,$77,$7F,$72,$7F
	db $78,$7F,$1C,$1F,$0F,$0F,$0E,$0B
	db $0F,$09,$0F,$0F,$0F,$08,$07,$07
	db $F8,$F8,$F0,$F0,$FC,$FC,$FE,$FE
	db $FF,$FF,$F8,$F8,$A8,$E8,$A0,$E0
	db $A0,$E0,$40,$C0,$80,$80,$C0,$C0
	db $C0,$C0,$C0,$40,$80,$80,$00,$00
TilesEnd: