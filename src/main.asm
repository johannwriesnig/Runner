SECTION "Header", ROM0[$100]
	jp main
	ds 150

main::
	call copyDMARoutine
	call turnSoundON
	call logoHandler
	call gameHandler







