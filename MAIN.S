; Name:		Mohammed Arab
; Email:	marab065@mtroyal.ca
; File:		main.s
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
;status:	the program is working
;-------------test cases--------------
; tests
;1) test when a player hits strikes every frame his score should be 300
;2)if a player doesn't hit any pin for the 10 frames then the score stays 0
;3)hitting spare after a strike.
;4)hitting strike after a spare
;
; Register table:
;	d0:	
;		-input/output stores the ASCII value of a digit
;		-used to store down2 for the first 9 frames
;		-stores extra ball for the last frame
;		-num_players to initialize players
;	d1:	
;		-stores down1+down2 for the last frame
;		-stores weight_ball1 & weight_ball3
;		-stores the first digit of the score
;	d2:
;		-used as an offset 
;	d3:	
;		-counter for the first 9 frames
;		-holds weight_ball1&2 for the last frame
;		-used to test conditional branching for the last frame
;		-stores the second digit of the score
;	d4:	
;		-holds num_players
;	d5:
;		-address increment when printing printing
;		-holds num_players for dbra 
;	d6:
;		-stores down1
;		-stores score
;		-stores the third digit of the score 
;	d7:
;		-address increment when loading name
;		-stores weight_ball2
;		-stores down2 for the last frame
;-----------------------------------------------------------------
	xref	FileOpen
	xref	FileReset
	xref	FileClose
	xref	FileCharRead
	xref	Exit
	xref	KbdCharRead
	xref	ScrnCharWrite
;-------const----------------
MAX_NAME	equ	11
MAX_PLAYERS	equ	9
ALL_PINS	equ	10
CR		equ	13
LF		equ	10
SPACE		equ	32
;-------typedef struct-------
NAME		equ	0
SCORE		equ	12
WEIGHT_BALL1	equ	14
WEIGHT_BALL2	equ	15
PLAYERS		equ	16
;-------opening file and loading data-----
Start:
	jsr	FileOpen
	tst.l	d0
	bne	terminate
	jsr	FileCharRead
	clr.l	d1
	clr.l	d2
	clr.l	d4
	clr.l	d5
	clr.l	d6
	sub.b	#'0',d0
	move.b	d0,d4			
	move.b	d4,d5
;---loading and initilazing players----
	lea	player,a0
	subq.b	#1,d5
	move.b	#8,d3			
	jsr	FileCharRead
	
reading_name:
	jsr	FileCharRead
	clr.l	d7

name:
	jsr	FileCharRead
	cmp.b	#CR,d0
	beq	initialize
	move.b	d0,NAME(a0,d2.w)
	adda.l	#1,a0
	addq.b	#1,d7
	bra	name

initialize:
	suba.l	d7,a0
	move.w	#0,SCORE(a0,d2.w)		;score = 0
	move.b	#1,WEIGHT_BALL1(a0,d2.w)	;weight_ball=1
	move.b	#1,WEIGHT_BALL2(a0,d2.w)	;weight_ball2=1
	add.w	#PLAYERS,d2			;moves to the next player
	dbra	d5,reading_name
	
;---------updating scores of all players for the first 9-----------
frames:	
	clr.l	d2				;clears offset to go for the next frame
	clr.l	d5				
	move.b	d4,d5			
	subq.b	#1,d5				;accessing first player

updating:
	clr.l	d1
	clr.l	d6
	clr.l	d7
	cmp	#CR,d0
	beq	read_next
	jsr	FileCharRead			;reads next byte 

read_next:

	jsr	FileCharRead			;reads first score
	jsr	FileCharRead
	sub.b	#'0',d0				
	cmpi.b	#17,d0				;checks if down1=10
	bne	down1_not_10
	clr.l	d0
	move.b	#10,d0

down1_not_10:
	move.b	d0,d6				
	jsr	FileCharRead			;reads next byte
	jsr	FileCharRead			;next score
	sub.b	#'0',d0				
	cmpi.b	#17,d0				;checks if down2=10
	bne	down2_not_10
	clr.l	d0
	move.b	#10,d0

down2_not_10:
	clr.l	d1
	move.b	WEIGHT_BALL1(a0,d2.w),d1
	move.b	WEIGHT_BALL2(a0,d2.w),d7	
	cmpi.b	#10,d3				;branches to last frame
	beq	frame_10			;branches to last frame
	cmpi.b	#ALL_PINS,d6			;checks if (down1)=10
	bne	down1_not_equal_all_pins

down1_equals_all_pins:
	mulu	d6,d1				;weight_ball1*=down1
	clr.l	d0
	move.w	SCORE(a0,d2.w),d0		
	add.w	d1,d0				
	move.w	d0,SCORE(a0,d2.w)		;score +=down1 * weight_ball1
	addq.b	#1,d7
	move.b	d7,WEIGHT_BALL1(a0,d2.w)	;weight_ball1 = weight_ball2 + 1
	move.b	#2,WEIGHT_BALL2(a0,d2.w)	;weight_ball2 = 2 
	bra	next_player_and_frame		;branch next player

down1_not_equal_all_pins:
	mulu	d6,d1				;weightball1 *=down1
	mulu	d0,d7				;weight_ball2 *= down2
	add.b	d6,d0				;down2+=down1
	clr.l	d6
	move.w	SCORE(a0,d2.w),d6		
	add.b	d7,d1				
	add.w	d1,d6				
	clr.w	SCORE(a0,d2.w)			;clearing player.score
	move.w	d6,SCORE(a0,d2.w)		;score+=down1*weight_ball1+down2*weight_ball2
	cmpi.b	#ALL_PINS,d0
	bne	down1_plus_down2_not_equal_all_pins		

down1_plus_down2_equals_all_pins:
	move.b	#2,WEIGHT_BALL1(a0,d2.w)
	move.b	#1,WEIGHT_BALL2(a0,d2.w)
	bra	next_player_and_frame

down1_plus_down2_not_equal_all_pins:
	move.b	#1,WEIGHT_BALL1(a0,d2.w)	
	move.b	#1,WEIGHT_BALL2(a0,d2.w)
	bra	next_player_and_frame

next_player_and_frame:
	add.w	#PLAYERS,d2			;moves offset to next player
	dbra	d5,updating			;branches to update score for next player
	dbra	d3,frames
	
;------------last frame--------------
last_frame:
	clr.l	d3
	move.b #10,d3
	bra	frames

frame_10:
	clr.l	d7
	move.b	d6,d1
	add.b	d0,d1	
	move.b	d0,d7		
	jsr	FileCharRead
	jsr	FileCharRead
	sub.b	#'0',d0				
	cmpi.b	#17,d0		
	bne	extra_not_10	;if(extra==10)
	clr.l	d0
	move.b	#10,d0		;extra=10

extra_not_10:
	cmpi.b	#ALL_PINS,d6	
	beq	extra_ball	;if(down1==all_pins)
	cmpi.b	#ALL_PINS,d1	
	bne	no_extra	;if(down1!=all_pins && down1+down2!=all_pins)
	
extra_ball:
	clr.l	d1
	move.b	#1,d1
	bra	last_score

no_extra:
	clr.l	d1

last_score:			
	clr.l	d3
	move.b	WEIGHT_BALL1(a0,d2.w),d3	
	mulu	d3,d6				;down1*=weightball1
	clr.l	d3 
	move.b	WEIGHT_BALL2(a0,d2.w),d3	
	mulu	d3,d7				;down2*=weight_ball2
	clr.l	d3
	move.b	#10,d3				;counter for loop
	mulu	d1,d0				;extra*=weight_ball3
	add.b	d6,d0				;extra+=down1*weightball1
	add.b	d7,d0				;extra+=down2*weightball2
	clr.l	d6
	move.w	SCORE(a0,d2.w),d6		
	add.w	d0,d6				
	clr.w	SCORE(a0,d2.w)			;clearing player.score
	move.w	d6,SCORE(a0,d2.w)		;score+=down1*weight_ball1+down2*weight_ball2+extra*weight_ball3

end:
	add.w	#PLAYERS,d2	
	dbra	d5,updating
	clr.l	d2				;clears offset
	clr.l	d5				;clears num players for next dbra		
	move.b	d4,d5
	subq.b	#1,d4

output:
	clr.l	d0
	clr.l	d1
	clr.l	d3
	clr.l	d5
	clr.l	d6

print_name:
	move.b	NAME(a0,d2.w),d0
	jsr	ScrnCharWrite
	adda.l	#1,a0
	addq.b	#1,d5
	cmp.b	#0,NAME(a0,d2.w)
	bne	print_name
	suba.l	d5,a0
	move.b	#SPACE,d0
	jsr	ScrnCharWrite		
	move.w	SCORE(a0,d2.w),d1
	divu	#100,d1
	move.l	d1,d3
	tst.b	d1
	beq	first_digit_0
	add.b	#'0',d1
	move.b	d1,d0
	jsr	ScrnCharWrite
	clr.w	d3
	swap	d3
	divu	#10,d3
	move.l	d3,d6
	add.b	#'0',d3
	move.b	d3,d0
	jsr	ScrnCharWrite
	bra	last_digit

first_digit_0:
	clr.w	d3
	swap	d3
	divu	#10,d3
	move.l	d3,d6
	tst.b	d3
	beq	last_digit
	add.b	#'0',d3
	move.b	d3,d0
	jsr	ScrnCharWrite

last_digit:
	clr.w	d6
	swap	d6
	tst.b	d6
	add.b	#'0',d6
	move.b	d6,d0
	jsr	ScrnCharWrite

next_print:
	add.w	#PLAYERS,d2
	move.b	#LF,d0
	jsr	ScrnCharWrite
	move.b	#CR,d0	
	jsr	ScrnCharWrite
	dbra	d4,output


terminate:
	jsr	FileClose
	jsr	Exit


player:	ds.b	MAX_PLAYERS*PLAYERS
