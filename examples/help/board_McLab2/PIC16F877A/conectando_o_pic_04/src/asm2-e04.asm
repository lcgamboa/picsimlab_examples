; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                   CONECTANDO O PIC - RECURSOS AVAN�ADOS                 *
; *                               EXEMPLO 4                                 *
; *                                                                         *
; *                NICOL�S C�SAR LAVINIA e DAVID JOS� DE SOUZA              *
; *                                                                         *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *   VERS�O : 2.0                                                          *
; *     DATA : 24/02/2003                                                   *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                             DESCRI��O GERAL                             *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;  ESTE EXEMPLO FOI ELABORADO PARA EXPLICAR O FUNCIONAMENTO DO M�DULO DE
;  CONVERS�O ANAL�GICO DIGITAL INTERNO DO PIC. � CONVERTIDO O VALOR ANAL�GICO
;  PRESENTE NO PINO RA2 DO MICROCONTROLADOR, SENDO QUE ESTE VALOR PODE SER
;  ALTERADO ATRAV�S DO POTENCI�METRO P2 DA PLACA MCLAB2. O VALOR DA CONVERS�O
;  A/D � AJUSTADO NUMA ESCALA DE 0 � 5V E MOSTRADO NO LCD.
;  FORAM UTILIZADAS ROTINAS DE MULTIPLICA��O DE 8x8 E DIVIS�O DE 16x16. ESTAS
;  ROTINAS FORAM RETIRADAS DE APLICATION NOTES DA PR�PRIA MICROCHIP.
;
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                         CONFIGURA��ES PARA GRAVA��O                     *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

 __CONFIG _CP_OFF & _CPD_OFF & _DEBUG_OFF & _LVP_OFF & _WRT_OFF & _BODEN_OFF & _PWRTE_ON & _WDT_ON & _XT_OSC

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                            DEFINI��O DAS VARI�VEIS                      *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;  ESTE BLOCO DE VARI�VEIS EST� LOCALIZADO LOGO NO IN�CIO DO BANCO 0

	CBLOCK	0X20			; POSI��O INICIAL DA RAM

		ACCaHI			; ACUMULADOR a DE 16 BITS UTILIZADO
		ACCaLO			; NA ROTINA DE DIVIS�O

		ACCbHI			; ACUMULADOR b DE 16 BITS UTILIZADO
		ACCbLO			; NA ROTINA DE DIVIS�O

		ACCcHI			; ACUMULADOR c DE 16 BITS UTILIZADO
		ACCcLO			; NA ROTINA DE DIVIS�O

		ACCdHI			; ACUMULADOR d DE 16 BITS UTILIZADO
		ACCdLO			; NA ROTINA DE DIVIS�O

		temp			; CONTADOR TEMPOR�RIO UTILIZADO
					; NA ROTINA DE DIVIS�O

		H_byte			; ACUMULADOR DE 16 BITS UTILIZADO
		L_byte			; P/ RETORNAR O VALOR DA ROTINA
					; DE MULTIPLICA��O

		mulplr			; OPERADOR P/ ROTINA DE MUTIPLICA��O
		mulcnd			; OPERADOR P/ ROTINA DE MUTIPLICA��O

		TEMPO0
		TEMPO1			; TEMPORIZADORES P/ ROTINA DE DELAY

		AUX			; REGISTRADOR AUXILIAR DE USO GERAL

		UNIDADE			; ARMAZENA VALOR DA UNIDADE DA TENS�O
		DEZENA			; ARMAZENA VALOR DA DEZENA DA TENS�O

	ENDC

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                DEFINI��O DAS VARI�VEIS INTERNAS DO PIC                  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;  O ARQUIVO DE DEFINI��ES DO PIC UTILIZADO DEVE SER REFERENCIADO PARA QUE
;  OS NOMES DEFINIDOS PELA MICROCHIP POSSAM SER UTILIZADOS, SEM A NECESSIDADE
;  DE REDIGITA��O.

	#INCLUDE <P16F877A.INC>		; MICROCONTROLADOR UTILIZADO

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                      DEFINI��O DOS BANCOS DE RAM                        *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;  OS PSEUDOS-COMANDOS "BANK0" E "BANK1", AQUI DEFINIDOS, AJUDAM A COMUTAR
;  ENTRE OS BANCOS DE MEM�RIA.

#DEFINE	BANK1	BSF	STATUS,RP0 	; SELECIONA BANK1 DA MEMORIA RAM
#DEFINE	BANK0	BCF	STATUS,RP0	; SELECIONA BANK0 DA MEMORIA RAM

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                           CONSTANTES INTERNAS                           *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;  A DEFINI��O DE CONSTANTES FACILITA A PROGRAMA��O E A MANUTEN��O.

;  ESTE PROGRAMA N�O UTILIZA NENHUMA CONSTANTE.

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                    DECLARA��O DOS FLAGs DE SOFTWARE                    *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;  A DEFINI��O DE FLAGs AJUDA NA PROGRAMA��O E ECONOMIZA MEM�RIA RAM.

;  ESTE PROGRAMA N�O UTILIZA NENHUM FLAG DE USU�RIO

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                                ENTRADAS                                 *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;  AS ENTRADAS DEVEM SER ASSOCIADAS A NOMES PARA FACILITAR A PROGRAMA��O E
;  FUTURAS ALTERA��ES DO HARDWARE.

;  ESTE PROGRAMA UTILIZA APENAS UMA ENTRADA P/ O CONVERSOR A/D.
;  ESTA ENTRADA N�O PRECISA SER DECLARADA, POIS O SOFTWARE NUNCA FAZ
;  REFER�NCIA A ELA DE FORMA DIRETA, POIS O CANAL A/D A SER CONVERTIDO �
;  SELECIONADO NO REGISTRADOS ADCON0 DE FORMA BIN�RIA E N�O ATRAV�S DE
;  DEFINES. POR�M PARA FACILITAR O ENTENDIMENTO DO HARDWARE VAMOS DECLARAR
;  ESTA ENTRADA NORMALMENTE.

#DEFINE	CAD_P2	PORTA,1			; ENTRADA A/D P/ O POTENCI�METRO P2

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                                 SA�DAS                                  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;  AS SA�DAS DEVEM SER ASSOCIADAS A NOMES PARA FACILITAR A PROGRAMA��O E
;  FUTURAS ALTERA��ES DO HARDWARE.

#DEFINE	DISPLAY		PORTD		; BARRAMENTO DE DADOS DO DISPLAY

#DEFINE	RS		PORTE,0		; INDICA P/ O DISPLAY UM DADO OU COMANDO
					; 1 -> DADO
					; 0 -> COMANDO

#DEFINE	ENABLE		PORTE,1		; SINAL DE ENABLE P/ DISPLAY
					; ATIVO NA BORDA DE DESCIDA

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                   VETOR DE RESET DO MICROCONTROLADOR                    *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;  POSI��O INICIAL PARA EXECU��O DO PROGRAMA

	ORG	0X0000			; ENDERE�O DO VETOR DE RESET
	GOTO	CONFIG_			; PULA PARA CONFIG DEVIDO A REGI�O
					; DESTINADA AS ROTINAS SEGUINTES

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                   ROTINA DE DELAY (DE 1MS AT� 256MS)                    *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;  ESTA � UMA ROTINA DE DELAY VARI�VEL, COM DURA��O DE 1MS X O VALOR PASSADO
;  EM WORK (W).

DELAY_MS
	MOVWF	TEMPO1			; CARREGA TEMPO1 (UNIDADES DE MS)
	MOVLW	.250
	MOVWF	TEMPO0			; CARREGA TEMPO0 (P/ CONTAR 1MS)

	CLRWDT				; LIMPA WDT (PERDE TEMPO)
	DECFSZ	TEMPO0,F		; FIM DE TEMPO0 ?
	GOTO	$-2			; N�O - VOLTA 2 INSTRU��ES
					; SIM - PASSOU-SE 1MS
	DECFSZ	TEMPO1,F		; FIM DE TEMPO1 ?
	GOTO	$-6			; N�O - VOLTA 6 INSTRU��ES
					; SIM
	RETURN				; RETORNA

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *               ROTINA DE ESCRITA DE UM CARACTER NO DISPLAY               *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;  ESTA ROTINA ENVIA UM CARACTER PARA O M�DULO DE LCD. O CARACTER A SER
;  ESCRITO DEVE SER COLOCADO EM WORK (W) ANTES DE CHAMAR A ROTINA.

ESCREVE
	MOVWF	DISPLAY			; ATUALIZA DISPLAY (PORTD)
	NOP				; PERDE 1US PARA ESTABILIZA��O
	BSF	ENABLE			; ENVIA UM PULSO DE ENABLE AO DISPLAY
	GOTO	$+1			; .
	BCF	ENABLE			; .

	MOVLW	.1
	CALL	DELAY_MS		; DELAY DE 1MS
	RETURN				; RETORNA

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                                 AJUSTE DECIMAL                          *
; *                W [HEX] =  DEZENA [DEC] ; UNIDADE [DEC]                  *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;  ESTA ROTINA RECEBE UM ARGUMENTO PASSADO PELO WORK E RETORNA NAS VARI�VEIS
;  DEZENA E UNIDADE O N�MERO BCD CORRESPOND�NTE AO PAR�METRO PASSADO.

AJUSTE_DECIMAL
	MOVWF	AUX			; SALVA VALOR A CONVERTER EM AUX
	CLRF	UNIDADE
	CLRF	DEZENA			; RESETA REGISTRADORES

	MOVF	AUX,F
	BTFSC	STATUS,Z		; VALOR A CONVERTER = 0 ?
	RETURN				; SIM - RETORNA
					; N�O
	INCF	UNIDADE,F		; INCREMENTA UNIDADE

	MOVF	UNIDADE,W
	XORLW	0X0A
	BTFSS	STATUS,Z		; UNIDADE = 10d ?
	GOTO	$+3			; N�O
					; SIM
	CLRF	UNIDADE			; RESETA UNIDADE
	INCF	DEZENA,F		; INCREMENTA DEZENA

	DECFSZ	AUX,F			; FIM DA CONVERS�O ?
	GOTO	$-.8			; N�O - VOLTA P/ CONTINUAR CONVERS�O
	RETURN				; SIM

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                           ROTINA DE DIVIS�O                             *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;****************************************************************************
;                       Double Precision Division
;****************************************************************************
;   Division : ACCb(16 bits) / ACCa(16 bits) -> ACCb(16 bits) with
;                                               Remainder in ACCc (16 bits)
;      (a) Load the Denominator in location ACCaHI & ACCaLO ( 16 bits )
;      (b) Load the Numerator in location ACCbHI & ACCbLO ( 16 bits )
;      (c) CALL D_divF
;      (d) The 16 bit result is in location ACCbHI & ACCbLO
;      (e) The 16 bit Remainder is in locations ACCcHI & ACCcLO
;****************************************************************************

D_divF
	MOVLW	.16
	MOVWF	temp			; CARREGA CONTADOR PARA DIVIS�O

	MOVF	ACCbHI,W
	MOVWF	ACCdHI
	MOVF	ACCbLO,W
	MOVWF	ACCdLO			; SALVA ACCb EM ACCd

	CLRF	ACCbHI
	CLRF	ACCbLO			; LIMPA ACCb

	CLRF	ACCcHI
	CLRF	ACCcLO			; LIMPA ACCc

DIV
	BCF	STATUS,C
	RLF	ACCdLO,F
	RLF	ACCdHI,F
	RLF	ACCcLO,F
	RLF	ACCcHI,F
	MOVF	ACCaHI,W
	SUBWF	ACCcHI,W          	;check if a>c
	BTFSS	STATUS,Z
	GOTO	NOCHK
	MOVF	ACCaLO,W
	SUBWF	ACCcLO,W		;if msb equal then check lsb
NOCHK
	BTFSS	STATUS,C		;carry set if c>a
	GOTO	NOGO
	MOVF	ACCaLO,W		;c-a into c
	SUBWF	ACCcLO,F
	BTFSS	STATUS,C
	DECF	ACCcHI,F
	MOVF	ACCaHI,W
	SUBWF	ACCcHI,F
	BSF	STATUS,C		;shift a 1 into b (result)
NOGO
	RLF	ACCbLO,F
	RLF	ACCbHI,F

	DECFSZ	temp,F			; FIM DA DIVIS�O ?
	GOTO	DIV			; N�O - VOLTA P/ DIV
					; SIM
	RETURN				; RETORNA


; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                           ROTINA DE MULTIPLICA��O                       *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;****************************************************************************
;                   8x8 Software Multiplier
;               ( Fast Version : Straight Line Code )
;****************************************************************************
;
;   The 16 bit result is stored in 2 bytes
; Before calling the subroutine " mpy ", the multiplier should
; be loaded in location " mulplr ", and the multiplicand in
; " mulcnd " . The 16 bit result is stored in locations
; H_byte & L_byte.
;       Performance :
;                       Program Memory  :  37 locations
;                       # of cycles     :  38
;                       Scratch RAM     :   0 locations
;*******************************************************************

; ********************************************
;  Define a macro for adding & right shifting
; ********************************************

mult    MACRO   bit			; Begin macro

	BTFSC	mulplr,bit
	ADDWF	H_byte,F
	RRF	H_byte,F
	RRF	L_byte,F

	ENDM				; End of macro

; *****************************
;   Begin Multiplier Routine
; *****************************

mpy_F
	CLRF	H_byte
	CLRF	L_byte
	MOVF	mulcnd,W		; move the multiplicand to W reg.
	BCF	STATUS,C		; Clear carry bit in the status Reg.

	mult    0
	mult    1
	mult    2
	mult    3
	mult    4
	mult    5
	mult    6
	mult    7

	RETURN				; RETORNA

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                CONFIGURA��ES INICIAIS DE HARDWARE E SOFTWARE            *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;  NESTA ROTINA S�O INICIALIZADAS AS PORTAS DE I/O DO MICROCONTROLADOR E AS
;  CONFIGURA��ES DOS REGISTRADORES ESPECIAIS (SFR). A ROTINA INICIALIZA A
;  M�QUINA E AGUARDA O ESTOURO DO WDT.

CONFIG_
	CLRF	PORTA			; GARANTE TODAS AS SA�DAS EM ZERO
	CLRF	PORTB
	CLRF	PORTC
	CLRF	PORTD
	CLRF	PORTE

	BANK1				; SELECIONA BANCO 1 DA RAM

	MOVLW	B'11111111'
	MOVWF	TRISA			; CONFIGURA I/O DO PORTA

	MOVLW	B'11111111'
	MOVWF	TRISB			; CONFIGURA I/O DO PORTB

	MOVLW	B'11111111'
	MOVWF	TRISC			; CONFIGURA I/O DO PORTC

	MOVLW	B'00000000'
	MOVWF	TRISD			; CONFIGURA I/O DO PORTD
	MOVLW	B'00000100'
	MOVWF	TRISE			; CONFIGURA I/O DO PORTE

	MOVLW	B'11011011'
	MOVWF	OPTION_REG		; CONFIGURA OPTIONS
					; PULL-UPs DESABILITADOS
					; INTER. NA BORDA DE SUBIDA DO RB0
					; TIMER0 INCREM. PELO CICLO DE M�QUINA
					; WDT   - 1:8
					; TIMER - 1:1
					
	MOVLW	B'00000000'		
	MOVWF	INTCON			; CONFIGURA INTERRUP��ES
					; DESABILITA TODAS AS INTERRUP��ES

	MOVLW	B'00000100'
	MOVWF	ADCON1			; CONFIGURA CONVERSOR A/D
					; RA0, RA1 E RA3 COMO ANAL�GICO
					; RA2, RA4 E RA5 COMO I/O DIGITAL
					; PORTE COMO I/O DIGITAL
					; JUSTIFICADO � ESQUERDA
					; 8 BITS EM ADRESH E 2 BITS EM ADRESL
					; Vref+ = VDD (+5V)
					; Vref- = GND ( 0V)

	BANK0				; SELECIONA BANCO 0 DA RAM

	MOVLW	B'01001001'
	MOVWF	ADCON0			; CONFIGURA CONVERSOR A/D
					; VELOCIDADE -> Fosc/8
					; CANAL 1
					; M�DULO LIGADO

;  AS INSTRU��ES A SEGUIR FAZEM COM QUE O PROGRAMA TRAVE QUANDO HOUVER UM
;  RESET OU POWER-UP, MAS PASSE DIRETO SE O RESET FOR POR WDT. DESTA FORMA,
;  SEMPRE QUE O PIC � LIGADO, O PROGRAMA TRAVA, AGUARDA UM ESTOURO DE WDT
;  E COME�A NOVAMENTE. ISTO EVITA PROBLEMAS NO START-UP DO PIC.

	BTFSC	STATUS,NOT_TO		; RESET POR ESTOURO DE WATCHDOG TIMER ?
	GOTO	$			; N�O - AGUARDA ESTOURO DO WDT
					; SIM

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                         INICIALIZA��O DA RAM                            *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;  ESTA ROTINA IR� LIMPAR TODA A RAM DO BANCO 0, INDO DE 0X20 A 0X7F.
;  EM SEGUIDA, AS VARI�VEIS DE RAM DO PROGRAMA S�O INICIALIZADAS.

	MOVLW	0X20
	MOVWF	FSR			; APONTA O ENDERE�AMENTO INDIRETO PARA
					; A PRIMEIRA POSI��O DA RAM
LIMPA_RAM
	CLRF	INDF			; LIMPA A POSI��O
	INCF	FSR,F			; INCREMENTA O PONTEIRO P/ A PR�X. POS.
	MOVF	FSR,W
	XORLW	0X80			; COMPARA O PONTEIRO COM A �LT. POS. +1
	BTFSS	STATUS,Z		; J� LIMPOU TODAS AS POSI��ES?
	GOTO	LIMPA_RAM		; N�O - LIMPA A PR�XIMA POSI��O
					; SIM

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *			  CONFIGURA��ES INICIAIS DO DISPLAY		    *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ESTA ROTINA INICIALIZA O DISPLAY P/ COMUNICA��O DE 8 VIAS, DISPLAY PARA 2
; LINHAS, CURSOR APAGADO E DESLOCAMENTO DO CURSOR � DIREITA. 

INICIALIZACAO_DISPLAY
	BCF	RS			; SELECIONA O DISPLAY P/ COMANDOS

	MOVLW	0X30			; ESCREVE COMANDO 0X30 PARA
	CALL	ESCREVE			; INICIALIZA��O
	MOVLW	.3
	CALL	DELAY_MS		; DELAY DE 3MS (EXIGIDO PELO DISPLAY)

	MOVLW	0X30			; ESCREVE COMANDO 0X30 PARA
	CALL	ESCREVE			; INICIALIZA��O

	MOVLW	0X30			; ESCREVE COMANDO 0X30 PARA
	CALL	ESCREVE			; INICIALIZA��O

	MOVLW	B'00111000'		; ESCREVE COMANDO PARA
	CALL	ESCREVE			; INTERFACE DE 8 VIAS DE DADOS

	MOVLW	B'00000001'		; ESCREVE COMANDO PARA
	CALL	ESCREVE			; LIMPAR TODO O DISPLAY

	MOVLW	.1
	CALL	DELAY_MS		; DELAY DE 1MS

	MOVLW	B'00001100'		; ESCREVE COMANDO PARA
	CALL	ESCREVE			; LIGAR O DISPLAY SEM CURSOR

	MOVLW	B'00000110'		; ESCREVE COMANDO PARA INCREM.
	CALL	ESCREVE			; AUTOM�TICO � DIREITA

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *		  ROTINA DE ESCRITA DA TELA PRINCIPAL                     *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;  ESTA ROTINA ESCREVE A TELA PRINCIPAL DO PROGRAMA, COM AS FRASES:
;  LINHA 1 - " A/D Int.  (P2) "
;  LINHA 2 - "        Volts   "

	MOVLW	0X81			; COMANDO PARA POSICIONAR O CURSOR
	CALL	ESCREVE			; LINHA 0 / COLUNA 1

	BSF	RS			; SELECIONA O DISPLAY P/ DADOS

					; COMANDOS PARA ESCREVER AS
					; LETRAS DE "A/D Int.  (P2)"
	MOVLW	'A'
	CALL	ESCREVE
	MOVLW	'/'
	CALL	ESCREVE
	MOVLW	'D'
	CALL	ESCREVE
	MOVLW	' '
	CALL	ESCREVE
	MOVLW	'I'
	CALL	ESCREVE
	MOVLW	'n'
	CALL	ESCREVE
	MOVLW	't'
	CALL	ESCREVE
	MOVLW	'.'
	CALL	ESCREVE
	MOVLW	' '
	CALL	ESCREVE
	MOVLW	' '
	CALL	ESCREVE
	MOVLW	'('
	CALL	ESCREVE
	MOVLW	'P'
	CALL	ESCREVE
	MOVLW	'2'
	CALL	ESCREVE
	MOVLW	')'
	CALL	ESCREVE

	BCF	RS			; SELECIONA O DISPLAY P/ COMANDOS
	MOVLW	0XC7			; COMANDO PARA POSICIONAR O CURSOR
	CALL	ESCREVE			; LINHA 1 / COLUNA 7
	BSF	RS			; SELECIONA O DISPLAY P/ DADOS
					; COMANDOS PARA ESCREVER AS
					; LETRAS DE "Volts"
	MOVLW	'V'
	CALL	ESCREVE
	MOVLW	'o'
	CALL	ESCREVE
	MOVLW	'l'
	CALL	ESCREVE
	MOVLW	't'
	CALL	ESCREVE
	MOVLW	's'
	CALL	ESCREVE

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                             LOOP PRINCIPAL                              *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;  A ROTINA PRINCIPAL FICA CONVERTENDO O CANAL A/D, CALCULANDO O VALOR EM
;  VOLTS E MOSTRANDO NO DISPLAY.

LOOP
	CLRWDT				; LIMPA WATCHDOG TIMER

	BSF	ADCON0,GO		; INICIA CONVERS�O A/D
	BTFSC	ADCON0,GO		; FIM DA CONVERS�O ?
	GOTO	$-1			; N�O - VOLTA 1 INSTRU��O
					; SIM
	MOVF	ADRESH,W		; SALVA VALOR DA CONVERS�O NO WORK
	MOVWF	mulplr			; CARREGA WORK EM mulplr

	MOVLW	.50
	MOVWF	mulcnd			; CARREGA 50d EM mulcnd

	CALL	mpy_F			; CHAMA ROTINA DE MULTIPLICA��O

	MOVF	H_byte,W
	MOVWF	ACCbHI			; SALVA VALOR DA MULTIPLICA��O
	MOVF	L_byte,W		; EM ACCb PARA SER UTILIZADO NA
	MOVWF	ACCbLO			; ROTINA DE DIVIS�O

	CLRF	ACCaHI			; CARREGA ACCa COM 255d (FUNDO DE
	MOVLW	.255			; ESCALA DO CONVERSOR A/D)
	MOVWF	ACCaLO			; (EST�O SENDO UTILIZADOS 8 BITS)

	CALL	D_divF			; CHAMA ROTINA DE DIVIS�O

	MOVF	ACCbLO,W		; FAZ O AJUSTE DECIMAL PARA
	CALL	AJUSTE_DECIMAL		; MOSTRAR NO DISPLAY (LCD)

	BCF	RS			; SELECIONA O DISPLAY P/ COMANDOS
	MOVLW	0XC3			; COMANDO PARA POSICIONAR O CURSOR
	CALL	ESCREVE			; LINHA 1 / COLUNA 3
	BSF	RS			; SELECIONA O DISPLAY P/ DADOS

	MOVF	DEZENA,W
	ADDLW	0X30			; CONVERTE BCD DA DEZENA EM ASCII
	CALL	ESCREVE			; ENVIA AO LCD

	MOVLW	','
	CALL	ESCREVE			; ESCREVE UMA VIRGULA NO LCD

	MOVF	UNIDADE,W
	ADDLW	0X30			; CONVERTE BCD DA UNIDADE EM ASCII
	CALL	ESCREVE			; ENVIA AO LCD

	GOTO	LOOP			; VOLTA PARA LOOP

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                              FIM DO PROGRAMA                            *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END				; FIM DO PROGRAMA

