SECTION "Player", ROM0
playerTilesAdress:: DS 2

initPlayer::

updatePlayer::

SECTION "PlayreVariables", ROM0
playerX:: DS 1
playerY:: DS 1
playerStatus:: DS ;goingRight, goingLeft, idle, jumping

SECTION "PlayerData", ROM0
playerTiles::
db $09,$09,$17,$17,$1F,$1F,$3F,$3F
db $7F,$7F,$FF,$FF,$77,$7F,$72,$7F
db $78,$7F,$1C,$1F,$0F,$0F,$0E,$0B
db $0F,$09,$0F,$0F,$0F,$08,$07,$07
db $F8,$F8,$F0,$F0,$FC,$FC,$FE,$FE
db $FF,$FF,$F8,$F8,$A8,$E8,$A0,$E0
db $A0,$E0,$40,$C0,$80,$80,$C0,$C0
db $C0,$C0,$C0,$40,$80,$80,$00,$00
playerTilesEnd::
