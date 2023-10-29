# Bowling-game
; purpose:	bowling game for up to nine players
; Details:
;	game data is read from the file.
;	after reading the names of the players next lines will have 2 digits from 0-A
;	down1 and then down2 separated by a single space.
;	down1 and down2 will be the hits of the 10-pin and will keep changing
;	score until frame 9 after frame 9 players will be eligible for 
;	an extra shot if they get a spare or strike in the 10th frame.
;	if a player hits all 10 pins then his score in the next frame 
;	will gain him a bonus of the score depending if he ends up not 
;	hitting any pin then the bonus is gone else if at least one 
;	the pin is being hit then the bonus will add up to the score. 
;	input:	number of players, name of players, and knocked down pins.
;	output:	names of players, and scores after 10 frames.
;	limitations:	no error handling, expecting correct data from the file
