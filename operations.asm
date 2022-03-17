INCLUDE "hardware.inc"
SECTION "Operations", ROM0

turnLCDOFF::
	ld a, LCDCF_ON | LCDCF_OBJON;| LCDCF_BGON 
	ld [rLCDC], a
    ret

turnLCDON::	
	ld a, LCDCF_ON | LCDCF_OBJON;| LCDCF_BGON 
	ld [rLCDC], a
    ret

delayAll:: ;naively delaying cpu
    ld a,160
	loop:
	dec a
	jp nz, loop

setPalettes::
	ld a, %11100100
	ld [rBGP], a
	ld [rOBP0], a
    ret

WaitVBlank::
	ld a, [rLY]
	cp 144
	jp c, WaitVBlank
	ret

copyDMARoutine::
  ld  hl, DMARoutine
  ld de, startDMA
  ld  b, DMARoutineEnd - DMARoutine ; 
  ld  c, LOW(startDMA) ; 
.copyRoutine 
  ld  a, [hli]
  ldh [c], a
  inc c
  dec b
  jr  nz, .copyRoutine
  ret

DMARoutine: 
  ldh [rDMA], a
  ld  a, 40
.wait
  dec a
  jr  nz, .wait
  ret
DMARoutineEnd:

SECTION "DMA", HRAM
startDMA::
  ds DMARoutineEnd - DMARoutine ; Space for DMA-Routine