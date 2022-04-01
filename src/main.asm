SECTION "Header", ROM0[$100]
	jp main
	ds 150

main::
	call copyDMARoutine
	call logoHandler
	call gameHandler







