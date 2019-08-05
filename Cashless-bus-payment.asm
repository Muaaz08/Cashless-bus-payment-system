/*
BUS PAYMENT SYSTEM USING RFID,LCD & HEX KEYPAD
Date: 19/4/2019
By: MUAAZ MUSTHAFA
*/

RS EQU P2.0                 //equates P2.0 to RS
E EQU P2.1                  //equates P2.1 to E

ORG 00H 
MOV 35H,#0FFH  //decimal FFH = 255d FOR 1ST CARD
MOV 40H,#0FFH  //decimal FFH = 255d FOR 2ND CARD

MOV A,#255  
MOV P1,A
CLR A                   

MAIN:
	MOV TMOD,#00100001B          //Timer1=Mode2 timer & Timer0=Mode1 timer
	MOV TH1,#253D                //loads TH1 with 253D(9600 baud)
	MOV SCON,#50H                //sets serial port to Mode1 and receiver enabled
	SETB TR1                     //starts Timer1
	LCALL INIT              //calls DINT subroutine
	MOV A,#83H
	LCALL CMD
	MOV DPTR,#TEXT1
	LCALL DISPLAY       
    LCALL LINE2             //calls LINE2 subroutine
	MOV DPTR,#TEXT2
	LCALL DISPLAY 
	LCALL READ              //calls READ subroutine
    ;CLR REN                 //disables serial data receive
    ;LCALL LINE2             //calls LINE2 subroutine
    ;LCALL WRITE             //calls WRITE subroutine
    ;LCALL DELAY2            //calls DELAY1 subroutine
	;SETB REN
	LCALL CHECK_CARD1 
	;LCALL DELAY1
SJMP MAIN 

FAIL:
	LCALL clear 
	MOV DPTR,#FAIL1
	LCALL DISPLAY
	GOBACK: LCALL DELAY2
	LJMP MAIN
RET

CHECK_CARD1:
	MOV R0,#12D
	MOV R1,#200D
	MOV DPTR,#NUM1 
	RPT:CLR A
	MOVC A,@A+DPTR
	XRL A,@R1
	JNZ CHECK_CARD2 
	INC R1
	INC DPTR
	DJNZ R0,RPT
	SJMP HERE

CHECK_CARD2:
	MOV R0,#12D
	MOV R1,#200D
	MOV DPTR,#NUM2 
	RPT1:CLR A
	MOVC A,@A+DPTR
	XRL A,@R1
	JNZ FAIL
	INC R1
	INC DPTR
	DJNZ R0,RPT1
	LJMP BAD1


HERE:
	LCALL CLEAR
	MOV DPTR,#DEST
	LCALL DISPLAY
	LCALL LINE2
	MOV DPTR,#UBAL
	LCALL DISPLAY
	MOV A,35H
	  LCALL HEXTOBCD
	  MOV A,R4
	  ADD A,#30H
	  LCALL DISPLAY1
	  MOV A,R5
	  ADD A,#30H
	  LCALL DISPLAY1
	  MOV A,R6
	  ADD A,#30H
	  LCALL DISPLAY1
	  MOV A,#" "
	  LCALL DISPLAY1
	MOV DPTR,#PASS1
	LCALL DISPLAY
	sd:lcall delay1 //KEYPAD
	lcall key1
	lcall delay
	lcall key2
	lcall delay
	;lcall key3
	;lcall delay
	;lcall key4
	;lcall delay
SJMP SD

// DISPLAY THE RESULT BALANCE

SEL: 
	LCALL CLEAR
	CLR A
	MOV A,35H
	SUBB A,R7
	JC NOBAL
	MOV R7,#00H
	MOV 35H,A
	LCALL HEXTOBCD
	MOV DPTR,#BAL
	LCALL DISPLAY
	MOV A,R4
	ADD A,#30H
	LCALL DISPLAY1
	MOV A,R5
	ADD A,#30H
	LCALL DISPLAY1
	MOV A,R6
	ADD A,#30H
	LCALL DISPLAY1
	LCALL DELAY2
	LCALL INIT_GSM
	LCALL DELAY2
	LCALL GSM_PASS1
	LJMP MAIN
RET
NOBAL: 
	LCALL CLEAR 
	MOV DPTR,#LOWBAL
	LCALL DISPLAY
	;lcall bal1
	LCALL DELAY2
	LJMP MAIN
RET

//FOR 2ND CARD
BAD1:
	LCALL CLEAR
	MOV DPTR,#DEST
	LCALL DISPLAY
	LCALL LINE2
	MOV DPTR,#UBAL
	LCALL DISPLAY
	MOV A,40H
	  LCALL HEXTOBCD
	  MOV A,R4
	  ADD A,#30H
	  LCALL DISPLAY1
	  MOV A,R5
	  ADD A,#30H
	  LCALL DISPLAY1
	  MOV A,R6
	  ADD A,#30H
	  LCALL DISPLAY1
	  MOV A,#" "
	  LCALL DISPLAY1
	MOV DPTR,#PASS2
	LCALL DISPLAY
	sd1:lcall delay1 //KEYPAD
	lcall key5
	lcall delay
	lcall key6
	lcall delay
	;lcall key3
	;lcall delay
	;lcall key4
	;lcall delay
SJMP SD1

// DISPLAY THE RESULT BALANCE

SEL1: LCALL CLEAR
	  CLR A
	  MOV A,40H
	  SUBB A,R7
	  JC NOBAL
	  MOV R7,#00H
	  MOV 40H,A
	  LCALL HEXTOBCD
	  MOV DPTR,#BAL
	  LCALL DISPLAY
	  ;LCALL BAL
	  MOV A,R4
	  ADD A,#30H
	  LCALL DISPLAY1
	  MOV A,R5
	  ADD A,#30H
	  LCALL DISPLAY1
	  MOV A,R6
	  ADD A,#30H
	  LCALL DISPLAY1
	  LCALL DELAY2
	  LCALL INIT_GSM
	  LCALL DELAY2
	  LCALL GSM_PASS2
	  LJMP MAIN
RET
/////////////////////


HEXTOBCD:
	MOV B,#10
	DIV AB
	MOV R6,B
	MOV B,#10
	DIV AB
	MOV R5,B
	MOV R4,A
RET


LINE1: 
	MOV A,#80H    
	LCALL CMD
RET

// GENERATING A SMALL DELAY
DELAY: 
	MOV R0,#255
	DJNZ R0,$
RET

; Generating a Bigger Delay
delay1:mov r1,#255
loop1: mov r3,#120
	   djnz r3,$ 
       djnz r1,loop1
RET

DELAY2:MOV R3,#10D           //loads R3 with 46D
BACK:  MOV TH0,#00000000B    //loads TH0 with all 0's 
       MOV TL0,#00000000B    //loads TL0 with all 0's
       SETB TR0              //starts Timer 0            
HERE1: JNB TF0,HERE1         //loops here until TFO flag is 1     
       CLR TR0               //stops TR1      
       CLR TF0               //clears TF0 flag
       DJNZ R3,BACK          //iterates the loop 46 times for 3s delay
RET                   //returns from subroutine

READ:MOV R0,#12D             //loads R0 with 12D
     MOV R1,#200D            //loads R1 with 160D
WAIT:JNB RI,WAIT             //loops here until RI flag is set
     MOV A,SBUF              //moves SBUF to A         
     MOV @R1,A               //moves A to location pointed by R1
     CLR RI
	 INC R1                  //clears RI flag
     DJNZ R0,WAIT            //iterates the loop 12 times
RET                     //return from subroutine

WRITE:MOV R2,#12D            //loads R2 with 12D
      MOV R1,#200D           //loads R1 with 160D
BACK1:MOV A,@R1              //loads A with data pointed by R1
      LCALL DISPLAY          //calls DISPLAY subroutine
      INC R1                 //incremets R1
      DJNZ R2,BACK1          //iterates the loop 12 times
RET                    //return from subroutine



INIT:MOV A,#0FH              //display ON cursor blinking ON           
    LCALL CMD                //calls CMD subroutine
    MOV A,#01H               //clear display screen
    LCALL CMD                //calls CMD subroutine
    MOV A,#06H               //increment cursor
    LCALL CMD                //calls CMD subroutine
    MOV A,#83H               //cursor line 1 position 3
    LCALL CMD                //calls CMD subroutine
    MOV A,#3CH               //activate 2nd line
    LCALL CMD                //calls CMD subroutine 
RET                      //return from subroutine

LINE2:MOV A,#0C0H            //force cursor to line 2 position 1
    LCALL CMD                //calls CMD subroutine
RET                      //return from subroutine

CMD:                 //moves content of A to Port 0
    CLR RS                   //clears register select pin 
	MOV P0,A                  //clears read/write pin
    SETB E                   //sets enable pin
    CLR E                    //clears enable pin
    LCALL DELAY              //calls DELAY subroutine
RET                      //return from subroutine

DISPLAY1:             //moves content of A to Port 0
    SETB RS                  //sets register select pin
    MOV P0,A                  //clears read/write pin
    SETB E                   //sets enable pin
    CLR E                    //clears enable pin
    LCALL DELAY              //calls DELAY subroutine         
RET                      //return from subroutine

DISPLAY:
NEXT: CLR A
MOVC A,@A+DPTR
JZ EXT
LCALL DISPLAY1
INC DPTR
JMP NEXT
EXT: RET

clear:
	mov A,#01H
	lcall CMD
	lcall delay
	mov A,#02H ; Set The DDRAM Address to Home Position
	lcall CMD
	lcall delay
RET

//GSM 
INIT_GSM:
MOV TMOD,#00100001B        
MOV TH1,#253D           
MOV SCON,#50H          
SETB TR1

MOV A,#"A"
ACALL SEND
MOV A,#"T"
ACALL SEND
MOV A,#0DH
ACALL SEND
ACALL DELAY1


MOV A,#"A"
ACALL SEND
MOV A,#"T"
ACALL SEND
MOV A,#"+"
ACALL SEND
MOV A,#"C"
ACALL SEND
MOV A,#"M"
ACALL SEND
MOV A,#"G"
ACALL SEND
MOV A,#"F"
ACALL SEND
MOV A,#"="
ACALL SEND
MOV A,#"1"
ACALL SEND
MOV A,#0DH
ACALL SEND
ACALL DELAY1
RET

GSM_PASS1:
MOV A,#"A"
ACALL SEND
MOV A,#"T"
ACALL SEND
MOV A,#"+"
ACALL SEND
MOV A,#"C"
ACALL SEND
MOV A,#"M"
ACALL SEND
MOV A,#"G"
ACALL SEND
MOV A,#"S"
ACALL SEND
MOV A,#"="
ACALL SEND
MOV A,#34D
ACALL SEND
MOV A,#"+"
ACALL SEND
MOV A,#"9"
ACALL SEND
MOV A,#"1"
ACALL SEND
MOV A,#"7"
ACALL SEND
MOV A,#"9"
ACALL SEND
MOV A,#"9"
ACALL SEND
MOV A,#"6"
ACALL SEND
MOV A,#"0"
ACALL SEND
MOV A,#"2"
ACALL SEND
MOV A,#"6"
ACALL SEND
MOV A,#"3"
ACALL SEND
MOV A,#"4"
ACALL SEND
MOV A,#"2"
ACALL SEND
MOV A,#34D
ACALL SEND
MOV A,#0DH
ACALL SEND
ACALL DELAY1


MOV A,#"B"
ACALL SEND
MOV A,#"A"
ACALL SEND
MOV A,#"L"
ACALL SEND
MOV A,#"A"
ACALL SEND
MOV A,#"N"
ACALL SEND
MOV A,#"C"
ACALL SEND
MOV A,#"E"
ACALL SEND
MOV A,#":"
ACALL SEND
MOV A,#" "
ACALL SEND
MOV A,R4
ADD A,#30H
ACALL SEND
MOV A,R5
ADD A,#30H
ACALL SEND
MOV A,R6
ADD A,#30H
ACALL SEND
ACALL DELAY1
MOV A,#1AH
ACALL SEND
ACALL DELAY1
RET

GSM_PASS2:
MOV A,#"A"
ACALL SEND
MOV A,#"T"
ACALL SEND
MOV A,#"+"
ACALL SEND
MOV A,#"C"
ACALL SEND
MOV A,#"M"
ACALL SEND
MOV A,#"G"
ACALL SEND
MOV A,#"S"
ACALL SEND
MOV A,#"="
ACALL SEND
MOV A,#34D
ACALL SEND
MOV A,#"+"
ACALL SEND
MOV A,#"9"
ACALL SEND
MOV A,#"1"
ACALL SEND
MOV A,#"8"
ACALL SEND
MOV A,#"7"
ACALL SEND
MOV A,#"4"
ACALL SEND
MOV A,#"8"
ACALL SEND
MOV A,#"9"
ACALL SEND
MOV A,#"0"
ACALL SEND
MOV A,#"7"
ACALL SEND
MOV A,#"4"
ACALL SEND
MOV A,#"2"
ACALL SEND
MOV A,#"2"
ACALL SEND
MOV A,#34D
ACALL SEND
MOV A,#0DH
ACALL SEND
ACALL DELAY1


MOV A,#"B"
ACALL SEND
MOV A,#"A"
ACALL SEND
MOV A,#"L"
ACALL SEND
MOV A,#"A"
ACALL SEND
MOV A,#"N"
ACALL SEND
MOV A,#"C"
ACALL SEND
MOV A,#"E"
ACALL SEND
MOV A,#":"
ACALL SEND
MOV A,#" "
ACALL SEND
MOV A,R4
ADD A,#30H
ACALL SEND
MOV A,R5
ADD A,#30H
ACALL SEND
MOV A,R6
ADD A,#30H
ACALL SEND
ACALL DELAY1
MOV A,#1AH
ACALL SEND
ACALL DELAY1
RET

SEND:CLR TI
     MOV SBUF,A
WAIT1:JNB TI,WAIT1
     RET

// 4x4 HEX KEYPAD 
; Checking for Key Press on The First Column of 4x4 Matrix
KEY1:
	clr p1.4
	MOV A,p1
	ANL A,#0FH
	MOV r2,A
	cjne r2,#14,n1
	MOV r7,#50H	   //KEY 1 50h = 80d
	LCALL SEL
	lcall delay1
	n1: cjne r2,#13,n2
	mov r7,#4H			 //KEY 4
	lcall SEL
	lcall delay1
	n2: cjne r2,#11,n3
	mov r7,#7H					//KEY 7
	lcall SEL
	lcall delay1
	n3: cjne r2,#7,n4
	mov r7,#'D'				//KEY *
	lcall SEL
	lcall delay1
	n4: lcall delay1
	SETB P1.4
RET



; Checking for Key Press on the Second Column of 4x4 Matrix
KEY2:
	clr p1.5
	MOV A,p1
	ANL A,#0FH
	MOV r2,A
	cjne r2,#14,q1
	mov r7,#2H      //KEY 2
	lcall SEL
	lcall delay1
	q1: cjne r2,#13,q2
	mov r7,#'6'	 //KEY 5
	lcall SEL
	lcall delay1
	q2: cjne r2,#11,q3
	mov r7,#65; A=65   // KEY 8
	lcall SEL
	lcall delay1
	q3: cjne r2,#7,q4
	mov r7,#'E'		 //KEY 0
	lcall SEL
	lcall delay1
	q4: lcall delay
	SETB p1.5
RET

; Checking for Key Press On The Third Column of 4x4 Matrix
KEY3:
	clr p1.6
	MOV A,p1
	ANL A,#0FH
	MOV r2,A
	cjne r2,#14,w1
	mov r7,#'3'	   //KEY 3
	lcall SEL
	lcall delay1
	w1: cjne r2,#13,w2
	mov r7,#'7'	   //KEY 6
	lcall SEL
	lcall delay1
	w2: cjne r2,#11,w3
	mov r7,#'B'		//KEY 9
	lcall SEL
	lcall delay1
	w3: cjne r2,#7,w4
	mov r7,#'F'			  //KEY #
	lcall SEL
	lcall delay1
	w4: lcall delay1
	SETB p1.6
RET

 

; Checking for Key Press on the Fourth Column of 4x4 Matrix
KEY4:
	clr p1.7
	MOV A,p1
	ANL A,#0FH
	MOV r2,A
	cjne r2,#14,e1
	mov r7,#'4'			 //KEY A
	lcall SEL
	lcall delay1
	e1: cjne r2,#13,e2
	mov r7,#'8'			 //KEY B
	lcall SEL
	lcall delay1
	e2: cjne r2,#11,e3
	mov r7,#'C'			  //KEY C
	lcall SEL
	lcall delay1
	e3: cjne r2,#7,e4
	mov r7,#'G'			//KEY D
	lcall SEL
	lcall delay1
	e4: lcall delay1
	SETB p1.7
RET

KEY5:
	clr p1.4
	MOV A,p1
	ANL A,#0FH
	MOV r2,A
	cjne r2,#14,M1
	MOV r7,#50H	   //KEY 1 50h = 80d
	LCALL SEL1
	lcall delay1
	M1: cjne r2,#13,M2
	mov r7,#4H			 //KEY 4
	lcall SEL1
	lcall delay1
	M2: cjne r2,#11,M3
	mov r7,#7H					//KEY 7
	lcall SEL1
	lcall delay1
	M3: cjne r2,#7,M4
	mov r7,#20H				//KEY *
	lcall SEL1
	lcall delay1
	M4: lcall delay1
	SETB P1.4
RET

KEY6:
	clr p1.5
	MOV A,p1
	ANL A,#0FH
	MOV r2,A
	cjne r2,#14,qL1
	mov r7,#2H      //KEY 2
	lcall SEL1
	lcall delay1
	qL1: cjne r2,#13,qL2
	mov r7,#'6'	 //KEY 5
	lcall SEL1
	lcall delay1
	qL2: cjne r2,#11,qL3
	mov r7,#65; A=65   // KEY 8
	lcall SEL1
	lcall delay1
	qL3: cjne r2,#7,qL4
	mov r7,#'E'		 //KEY 0
	lcall SEL1
	lcall delay1
	qL4: lcall delay
	SETB p1.5
	RET

UBAL: DB "BAL: ",0
TEXT1: DB "BUS PAYMENT",0
TEXT2: DB "Place your Card",0
FAIL1:DB "WRONG CARD",0
PASS1: DB "Monisha",0
DEST: DB "Enter location",0
PASS2: DB "Muaaz",0
BAL: DB "BALANCE: ",0
LOWBAL: DB "LOW BALANCE",0
NUM1: DB "1","E","0","0","3","1","A","6","B","2","3","B"
NUM2: DB "8","8","0","0","4","A","5","2","E","B","7","B"

END          
