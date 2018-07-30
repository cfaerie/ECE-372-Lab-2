;*****************************************************************
;* TermIOASM.asm
;* DEMO PROGRAM
;* FOR DRAGON12 WITH SERIAL MONITOR
;* DO NOT DELETE ANY LINES IN THIS TEMPLATE
;* --ONLY FILL IN SECTIONS
;*****************************************************************

; export symbols
            XDEF Entry, _Startup            ; export 'Entry' symbol
            ABSENTRY Entry        ; for absolute assembly: mark this as application entry point

; Include derivative-specific definitions 
		INCLUDE 'derivative.inc' 
		
;-------------------------------------------------- 
; Equates Section  
;----------------------------------------------------  
ROMStart    EQU  $2000  ; absolute address to place my code
;-- your equates go here
CR      EQU  $0D    ; carriage return
LF      EQU  $0A    ; line feed
EOS     EQU  0      ; end of string marker
;---------------------------------------------------- 
; Variable/Data Section
;----------------------------------------------------  
            ORG RAMStart   ; loc $1000  (RAMEnd = $3FFF)
; Insert here your data definitions here
MSG1        dc.b  "Microcontrollers are fun",CR,LF,EOS
Prompt      dc.b  "Enter course # (3 digits)",CR,LF,EOS
BUF         ds    3        ;3-byte memory area reserved
NewLine     dc.b  CR,LF,EOS  ;new line and EOS marker
MSG2        dc.b  "Welcome to ECE ",EOS 
MSG3        dc.b  "[$1000] as hex digits: ",EOS 
;DATA        ds    1    ; reserve 1 byte


DATA         DC.B        12,31,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20




COUNT   	DS              1        ; reserve memory for counter

COUNT1    DS              1        ; reserve memory for counter

       INCLUDE 'utilities.inc'
       INCLUDE 'LCD.inc'

;---------------------------------------------------- 
; Code Section
;---------------------------------------------------- 
            ORG   ROMStart  ; loc $2000
Entry:
_Startup:
            ; remap the RAM &amp; EEPROM here. See EB386.pdf
 ifdef _HCS12_SERIALMON
            ; set registers at $0000
            CLR   $11                  ; INITRG= $0
            ; set ram to end at $3FFF
            LDAB  #$39
            STAB  $10                  ; INITRM= $39

            ; set eeprom to end at $0FFF
            LDAA  #$9
            STAA  $12                  ; INITEE= $9
            JSR   PLL_init      ; initialize PLL  
  endif

;---------------------------------------------------- 
; Insert your code here
;---------------------------------------------------- 
;* The following fuctions are available for the terminal  
  
; TermInit  -initialize the terminal
; putchar   -character in B printed to terminal
; getchar   -character from keyboard (terminal) to B register
; out2hex   -print two ascii characters representing the hex digits in B
; printf    -print (zero terminated) string of characters pointed to by D register
       
          LDS   #ROMStart    ; initialize the stack pointer
;*SET UP THE SERVICE ROUTINE (ISR)
;  --see vector setup at end of file
;Note: This code uses the terminal I/O functions in this project (utilities.inc) 
;written by Dr. Kaufman instead of the D-Bug12 I/O functions
    jsr           TermInit    ; initialize terminal (needed for Simulator)    
                 
           
    JSR             TermInit   ; initialize terminal
		CLR            COUNT     ; clear counter
   	CLR            COUNT1     ; clear counter1
		LDX            #DATA  ; initialize X as pointer
		
		
		
LOOP	

		LDAB         COUNT      ; check counter to continue
		CMPB         #20        ; have 20 bytes been dumped?
		BEQ          QUIT       ; quit if done
	  
	
	  cmpb         #9         ; check counter
	  ble          printcount ; if counter <=9 then go to printcount
	  addb         #6	        ; if counter >9 then add 6 to counter
printcount
	  jsr          out2hex    ; output counter to terminal
	  
	  
	  ldab         #':'       ; out put':' to terminal
	  jsr          putchar

	
		LDAB         0,X        ; get value pointed to by X
		JSR          out2hex    ; ……

		  
LOOP1 
    jsr          getchar	  ; call getchar functio
    cmpb         #$20       ; is it end of string character?
    beq	         LABEL1     ; quit if at end of string
    jmp       	 LOOP1     	; more characters
LABEL1 
    JSR          putchar
     	

		INX                     ; update data pointer
		INC          COUNT      ; update counter
		JMP          LOOP     	; more characters
QUIT	BRA           *       ; wait for reset button press

;-------------------------------------------------------------------
; -subroutines go here
   
        
HEX2D  	
  	
    TFR        A,B     ; COPY A TO B
LT   
    CMPB      #10     ; is B < 10
    BLO       DONE      ; if so we are done
    SUBB      #10     ; B <- B-10
    ADDA     #6       ; A <- A+6
    BRA        LT
DONE 
    RTS
    
    
;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   Vreset
            DC.W  Entry         ; Reset Vector
 