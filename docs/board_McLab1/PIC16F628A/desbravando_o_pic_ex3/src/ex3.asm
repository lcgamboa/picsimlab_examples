;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       PISCA-PISCA - EX3                         *
;*                       DESBRAVANDO O PIC                         *
;*       DESENVOLVIDO PELA MOSAICO ENGENHARIA E CONSULTORIA        *
;*      VERS�O: 1.0                             DATA: 30/10/01     *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                      DESCRI��O DO ARQUIVO                       *
;*-----------------------------------------------------------------*
;*  PISCA-PISCA VARI�VEL PARA DEMONSTRAR A IMPLEMENTA��O DE        *
;*  DELAYS E A INVERS�O DE PORTAS.                                 *
;*                                                                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINI��ES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

#INCLUDE <P16F628A.INC>		;ARQUIVO PADR�O MICROCHIP PARA 16F628A
	__CONFIG  _BODEN_ON & _CP_OFF & _PWRTE_ON & _WDT_OFF & _LVP_OFF & _MCLRE_ON & _XT_OSC

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    PAGINA��O DE MEM�RIA                         *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;DEFINI��O DE COMANDOS DE USU�RIO PARA ALTERA��O DA P�GINA DE MEM�RIA

#DEFINE	BANK0	BCF STATUS,RP0	;SETA BANK 0 DE MEM�RIA
#DEFINE	BANK1	BSF STATUS,RP0	;SETA BANK 1 DE MAM�RIA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         VARI�VEIS                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DOS NOMES E ENDERE�OS DE TODAS AS VARI�VEIS UTILIZADAS 
; PELO SISTEMA

	CBLOCK	0x20		;ENDERE�O INICIAL DA MEM�RIA DE
				;USU�RIO

		W_TEMP		;REGISTRADORES TEMPOR�RIOS PARA
		STATUS_TEMP	;INTERRUP��ES
				;ESTAS VARI�VEIS NEM SER�O UTI-
				;LIZADAS
		CONTADOR	;BASE DE TEMPO PARA A PISCADA
		FILTRO		;FILTRAGEM PARA O BOT�O
		TEMPO1		;REGISTRADORES AUXILIARES DE TEMPO
		TEMPO2
		TEMPO3

	ENDC			;FIM DO BLOCO DE MEM�RIA		

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA

MIN		EQU	.10
MAX		EQU	.240
STEP		EQU	.5
MULTIPLO	EQU	.5

;A CONSTANTE DISPLAY REPRESENTA O S�MBOLO QUE APARECER� PISCANDO NO
;DISPLAY. 1=LED LIGADO E 0=LED DESLIGADO. A RELA��O ENTRE BITS E
;SEGMENTOS � A SEGUINTE: 'EDC.BAFG'
;	   a
;     **********
;     *        *
;   f *        * b
;     *    g   *
;     **********
;     *        *
;   e *        * c
;     *    d   *
;     **********  *.

DISPLAY		EQU	B'10101011' ;(LETRA H)
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ENTRADAS                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO ENTRADA
; RECOMENDAMOS TAMB�M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

#DEFINE	BT1	PORTA,1	;BOT�O 1 - INCREMENTA
			; 0 -> PRESSIONADO
			; 1 -> LIBERADO

#DEFINE	BT2	PORTA,2	;BOT�O 2 - DECREMENTA
			; 0 -> PRESSIONADO
			; 1 -> LIBERADO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           SA�DAS                                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO SA�DA
; RECOMENDAMOS TAMB�M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       VETOR DE RESET                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	ORG	0x00	;ENDERE�O INICIAL DE PROCESSAMENTO
	GOTO	INICIO
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    IN�CIO DA INTERRUP��O                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; AS INTERRUP��ES N�O SER�O UTILIZADAS, POR ISSO PODEMOS SUBSTITUIR
; TODO O SISTEMA EXISTENTE NO ARQUIVO MODELO PELO APRESENTADO ABAIXO
; ESTE SISTEMA N�O � OBRIGAT�RIO, MAS PODE EVITAR PROBLEMAS FUTUROS

	ORG	0x04		;ENDERE�O INICIAL DA INTERRUP��O
	RETFIE			;RETORNA DA INTERRUP��O

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        ROTINA DE DELAY                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ESTA ROTINA AGUARDA TANTOS MILISEGUNDOS QUANTO O VALOR PASSADO
; POR W. POR EXEMPLO, SE W = .200, ELA AGUARDAR� 200 MILISEGUNDOS.
;
; O DELAY PRINCIPAL DURA 1ms, POIS POSSUI 5 INSTRU��ES (5us) E �
; RODADO 200 VEZES (TEMPO1). PORTANTO 200 * 5us = 1ms.
; O DELAY PRINCIPAL � RODADO TANTAS VEZES QUANTO FOR O VALOR DE
; TEMPO2, O QUAL � INICIADO COM O VALOR PASSADO EM W.


DELAY
	MOVWF	TEMPO2		;INICIA TEMPO 2 COM O VALOR
				;PASSADO EM W
DL1	
	MOVLW	.200
	MOVWF	TEMPO1

DL2				;ESTE DELAY DURA 1ms (5*200)
	NOP
	NOP
	DECFSZ	TEMPO1,F	;DECREMENTA TEMPO1. ACABOU?
	GOTO	DL2		;N�O, CONTINUA AGUARDANDO
				;SIM

	DECFSZ	TEMPO2,F	;DECREMENTA TEMPO2. ACABOU?
	GOTO	DL1		;N�O, CONTINUA AGUARDANDO
				;SIM
	RETURN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK0			;ALTERA PARA O BANCO 0
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERA��O DO COMPARADOR ANAL�GICO

	BANK1			;ALTERA PARA O BANCO 1
	MOVLW	B'00000110'
	MOVWF	TRISA		;DEFINE RA1 E 2 COMO ENTRADA E DEMAIS
				;COMO SA�DAS
	MOVLW	B'00000000'
	MOVWF	TRISB		;DEFINE TODO O PORTB COMO SA�DA
	MOVLW	B'10000000'
	MOVWF	OPTION_REG	;PRESCALER 1:2 NO TMR0
				;PULL-UPS DESABILITADOS
				;AS DEMAIS CONFG. S�O IRRELEVANTES
	MOVLW	B'00000000'
	MOVWF	INTCON		;TODAS AS INTERRUP��ES DESLIGADAS
	BANK0			;RETORNA PARA O BANCO 0

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZA��O DAS VARI�VEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	CLRF	PORTA		;LIMPA O PORTA
	MOVLW	DISPLAY
	MOVWF	PORTB		;ACENDE O VALOR CERTO NO DISPLAY
	MOVLW	MIN
	MOVWF	CONTADOR	;INICIA CONTADOR COM VALOR MIN.


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN
	MOVLW	MULTIPLO
	MOVWF	TEMPO3		;INICIA COMTADOR DE MULTIPLICA��O,
				;POIS OS TEMPOS GERADOS POR DELAY
				;S�O MUITO PEQUENOS, GERANDO FREQ.
				;MUITO ALTAS PARA A VISUALIZA��O.
MAIN1
	MOVF	CONTADOR,W	;COLOCA CONTADOR EM W
				;PARA CHAMAR A ROTINA DE DELAY
	CALL	DELAY		;CHAMA ROTINA DE DELAY

	BTFSS	BT1		;BOT�O 1 PRESSIONADO?
	GOTO	INCREMENTA	;SIM, DEVE INCREMENTAR
				;N�O

	BTFSS	BT2		;BOT�O 2 PRESSIONADO?
	GOTO	DECREMENTA	;SIM, DEVE DECREMENTAR
				;N�O

	DECFSZ	TEMPO3,F	;DECREMENTA CONTADOR DE MULT. ACABOU?
	GOTO	MAIN1		;N�O, CONTINUA AGUARDANDO
				;SIM	

	MOVLW	DISPLAY		;AP�S TRANSCORRIDO O TEMPO, IR�
				;INVERTER OS LEDS CORRETOS ATRAV�S
				;DA M�SCARA "DISPLAY" E DA OPERA��O
				;XOR
	XORWF	PORTB,F		;INVERTE LEDS -> PISCA

	GOTO	MAIN		;COME�A NOVAMENTE


DECREMENTA
	MOVLW	STEP
	SUBWF	CONTADOR,F	;DECREMENTA O CONTADOR EM STEP

	MOVLW	MIN		;MOVE O VALOR M�NIMO PARA W
	SUBWF	CONTADOR,W	;SUBTRAI O VALOR DE W (MIN) DE CONTADOR
	BTFSC	STATUS,C	;TESTA CARRY. RESULTADO NEGATIVO?
	GOTO	MAIN		;N�O, ENT�O CONTA >= MIN
				;SIM, ENT�O CONTA < MIN

	MOVLW	MIN
	MOVWF	CONTADOR	;ACERTA CONTADOR NO M�NIMO, POIS
				;PASSOU DO VALOR

	BTFSS	BT2		;BOT�O 2 CONTINUA PRESSIONADO?
	GOTO	$-1		;SIM, AGUARDA LIBERA��O
				;N�O
	GOTO	MAIN		;VOLTA AO LOOP PRINCIPAL

INCREMENTA
	MOVLW	STEP
	ADDWF	CONTADOR,F	;INCREMENTA O CONTADOR EM STEP

	MOVLW	MAX		;MOVE O VALOR M�XIMO PARA W
	SUBWF	CONTADOR,W	;SUBTRAI O VALOR DE W (MIN) DE CONTADOR
	BTFSS	STATUS,C	;TESTA CARRY. RESULTADO NEGATIVO?
	GOTO	MAIN		;SIM, ENT�O CONTA < MAX
				;N�O, ENT�O CONTA >= MAX
	MOVLW	MAX
	MOVWF	CONTADOR	;ACERTA CONTADOR NO M�XIMO, POIS
				;PASSOU DO VALOR
	BTFSS	BT1		;BOT�O 1 CONTINUA PRESSIONADO?
	GOTO	$-1		;SIM, AGUARDA LIBERA��O
				;N�O
	GOTO	MAIN		;VOLTA AO LOOP PRINCIPAL


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END			;OBRIGAT�RIO

