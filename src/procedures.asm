INCLUDE "constants.inc"
SECTION "Procedures", ROM0

memcpy::
  ;DE = block_Size
  ;BC = source_Address
  ;HL = destination_Address

.memcpy_loop:
    ld A, [BC]
    ld [HLI], A
    inc BC
    dec DE
.memcpy_check_limit:
    ld A, E
    cp $00
    jr nz, .memcpy_loop
    ld A, D
    cp $00
    jr nz, .memcpy_loop
    ret

memclear::
    ;DE = block_Size
    ;HL = destination_Address
.memclear_loop:
    ld A, 0
    ld [HLI], A
    dec DE
.memclear_check_limit:
    ld A, E
    cp $00
    jr nz, .memclear_loop
    ld A, D
    cp $00
    jr nz, .memclear_loop
    ret

turnLCDOFF::
	ld a, 0
	ld [rLCDC], a
  ret

turnLCDON::	
	ld a, LCDCF_ON |  LCDCF_BG8000 | LCDCF_BG9800 | LCDCF_OBJ8 | LCDCF_OBJON | LCDCF_BGON 
	ld [rLCDC], a
  ret

delayAll:: ;naively delaying cpu
  ld b, 15
  outerLoop:
 
    dec b
    ld a, b
    cp a, 0
    jp z, outerLoopEnd
  
    ld a,255
	  loop:
	    dec a
	    jp nz, loop
      jp outerLoop
  outerLoopEnd:
  ret

setPalettes::
	ld a, %11100100
	ld [rBGP], a
	ld [rOBP0], a
  ret

WaitVBlank::
	ld a, [rLY]
	cp 144
	jp nz, WaitVBlank
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