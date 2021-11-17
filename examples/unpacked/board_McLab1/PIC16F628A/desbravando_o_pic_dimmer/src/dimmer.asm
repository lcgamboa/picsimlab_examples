;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    CONTADOR MELHORADO - EX4                     *
;*                       DESBRAVANDO O PIC                         *
;*       DESENVOLVIDO PELA MOSAICO ENGENHARIA E CONSULTORIA        *
;*      VERS�O: 1.0                             DATA: 11/06/99     *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                      DESCRI��O DO ARQUIVO                       *
;*-----------------------------------------------------------------*
;*  CONTADOR QUE UTILIZA DOIS BOT�ES PARA INCREMENTAR E DECRE-     *
;*  MENTAR O VALOR CONTROLADO PELA VARI�VEL "CONTADOR". ESTA       *
;*  VARI�VEL EST� LIMITADA PELAS CONSTANTES "MIN" E "MAX".         *
;*  O VALOR DO CONTADOR � MOSTRADO NO DISPLAY.                     *
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
		INTENSIDADE	;ARMAZENA O VALOR DA CONTAGEM
		FLAGS		;ARMAZENA OS FLAGS DE CONTROLE
		FILTRO11	;FILTRAGEM  1 PARA O BOT�O 1
		FILTRO12	;FILTRAGEM  2 PARA O BOT�O 1
		FILTRO21	;FILTRAGEM  1 PARA O BOT�O 2
		FILTRO22	;FILTRAGEM  2 PARA O BOT�O 2
		TEMPO           ;INTERVALOS DE 1 MS

	ENDC			;FIM DO BLOCO DE MEM�RIA		

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

#DEFINE	ST_BT1	FLAGS,0		;STATUS DO BOT�O 1
#DEFINE	ST_BT2	FLAGS,1		;STATUS DO BOT�O 2

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA

MIN		EQU	.0	;VALOR M�NIMO PARA O INTENSIDADE
MAX		EQU	.15	;VALOR M�XIMO PARA O INTENSIDADE
T_FILTRO	EQU	.20	;FILTRO PARA BOT�O
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ENTRADAS                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO ENTRADA
; RECOMENDAMOS TAMB�M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

#DEFINE	BOTAO1	PORTA,1	;PORTA DO BOT�O
			; 0 -> PRESSIONADO
			; 1 -> LIBERADO

#DEFINE	BOTAO2	PORTA,2	;PORTA DO BOT�O
			; 0 -> PRESSIONADO
			; 1 -> LIBERADO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           SA�DAS                                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO SA�DA
; RECOMENDAMOS TAMB�M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

#DEFINE	LAMPADA	PORTA,0	;DEFINE LAMPADA NO PINO17
			;0 LAMP. APAGADA
			;1 LAMP. ACESA

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
	MOVWF	W_TEMP		;SALVA W EM W_TEMP
	SWAPF	STATUS,W	
	MOVWF	STATUS_TEMP	;SALVA STATUS EM STATUS_TEMP

	BTFSS	INTCON,T0IF	;� INTERRUP��O DE TMR0?
	GOTO	SAI_INT		;N�O, SAI SE A��O	
				;SIM

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              TRATAMENTO DA INTERRUP��O DE TMR0                  *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ESTA ROTINA IR� CONTAR O TEMPO, E QUANDO PASSAR 1 SEGUNDO, A VARI-
; �VEL "TEMPO" SER� DECREMENTADA.
; 1 SEGUNDO = 64us (PRESCALER) X 125 (TMR0) X 125 (TEMP1)

	BCF	INTCON,T0IF	;LIMPA FLAG DA INT.

	MOVLW	.256-.250	;SETA TIMER P250MS
	MOVWF	TMR0		;REINICIA TMR0

	INCF	TEMPO,F		;INCREMENTA TEMPO
	
	MOVLW	.16		;COLOCA 16 EM WORK
	XORWF	TEMPO,W		;COMPARA TEMPO COM 16
	BTFSC	STATUS,Z	;TESTA BIT Z DO REG. STATUS
	CLRF	TEMPO		;ZERA TEMPO

	MOVLW	.15		;COLOCA 15 EM W
	XORWF	INTENSIDADE,W	;COMPARA INTENSIDADE COM 15
	BTFSC	STATUS,Z	;TESTA BIT Z DO REG. STATUS
	GOTO	LIGA_LAMPADA

	MOVF	INTENSIDADE,W	;MOVE INTENSIDADE PARA W
	SUBWF	TEMPO,W		;SUBTRAI TEMPO DE INTENSIDADE
	BTFSS	STATUS,C	;TESTA BIC C DO REG. STATUS
				;VERIFICA SE TEMPO E MENOR QUE INTENSIDADE
	GOTO	LIGA_LAMPADA	

	BCF	LAMPADA		;DESLIGA LAMPADA
	GOTO	SAI_INT

LIGA_LAMPADA
	
	BSF	LAMPADA		;LIGA LAMPADA

	GOTO	SAI_INT		;SAI DA INTERRUP��O

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DA INTERRUP��O                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
SAI_INT
	SWAPF	STATUS_TEMP,W
	MOVWF	STATUS		;RECUPERA STATUS
	SWAPF	W_TEMP,F
	SWAPF	W_TEMP,W	;RECUPERA W
	RETFIE			;RETORNA DA INTERRUP��O

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                 ROTINA DE CONVERS�O BIN�RIO -> DISPLAY          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ESTA ROTINA IR� RETORNAR EM W, O SIMBOLO CORRETO QUE DEVE SER
; MOSTRADO NO DISPLAY PARA CADA VALOR DE INTENSIDADE. O RETORNO J� EST�
; FORMATADO PARA AS CONDI��ES DE LIGA��O DO DISPLAY AO PORTB.
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

CONVERTE
	MOVF	INTENSIDADE,W	;COLOCA INTENSIDADE EM W
	ANDLW	B'00001111'	;MASCARA VALOR DE INTENSIDADE
				;CONSIDERAR SOMENTE AT� 15
	ADDWF	PCL,F

;		B'EDC.BAFG'	; POSI��O CORRETA DOS SEGUIMENTOS
	RETLW	B'11101110'	; 00 - RETORNA S�MBOLO CORRETO 0
	RETLW	B'00101000'	; 01 - RETORNA S�MBOLO CORRETO 1
	RETLW	B'11001101'	; 02 - RETORNA S�MBOLO CORRETO 2
	RETLW	B'01101101'	; 03 - RETORNA S�MBOLO CORRETO 3
	RETLW	B'00101011'	; 04 - RETORNA S�MBOLO CORRETO 4	
	RETLW	B'01100111'	; 05 - RETORNA S�MBOLO CORRETO 5	
	RETLW	B'11100111'	; 06 - RETORNA S�MBOLO CORRETO 6	
	RETLW	B'00101100'	; 07 - RETORNA S�MBOLO CORRETO 7	
	RETLW	B'11101111'	; 08 - RETORNA S�MBOLO CORRETO 8	
	RETLW	B'01101111'	; 09 - RETORNA S�MBOLO CORRETO 9	
	RETLW	B'10101111'	; 10 - RETORNA S�MBOLO CORRETO A	
	RETLW	B'11100011'	; 11 - RETORNA S�MBOLO CORRETO b	
	RETLW	B'11000110'	; 12 - RETORNA S�MBOLO CORRETO C	
	RETLW	B'11101001'	; 13 - RETORNA S�MBOLO CORRETO d	
	RETLW	B'11000111'	; 14 - RETORNA S�MBOLO CORRETO E	
	RETLW	B'10000111'	; 15 - RETORNA S�MBOLO CORRETO F	

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
	MOVLW	B'10000001'
	MOVWF	OPTION_REG	;PRESCALER 1:4 NO TMR0
				;PULL-UPS DESABILITADOS
				;AS DEMAIS CONFG. S�O IRRELEVANTES
	MOVLW	B'10100000'
	MOVWF	INTCON		;CHAVE GERAL E TMR0 ATIVADAS
	BANK0			;RETORNA PARA O BANCO 0

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZA��O DAS VARI�VEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	CLRF	PORTA		;LIMPA O PORTA
	CLRF	PORTB		;LIMPA O PORTB
	CLRF	FLAGS		;LIMPA TODOS OS FLAGS
	MOVLW	MIN
	MOVWF	INTENSIDADE	;INICIA INTENSIDADE = MIN
	MOVLW	.256-.250	;SETA TIMER P250MS
	MOVWF	TMR0		;REINICIA TMR0
	GOTO	ATUALIZA	;ATUALIZA O DISPLAY INICIALMENTE

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN
	CLRF	FILTRO11
	CLRF	FILTRO21
	MOVLW	T_FILTRO
	MOVWF	FILTRO12	;INICIALIZA FILTRO1 = T_FILTRO
	MOVWF	FILTRO22	;INICIALIZA FILTRO2 = T_FILTRO

CHECA_BT1

	BTFSC	BOTAO1		;O BOT�O 1 EST� PRESSIONADO?
	GOTO	BT1_LIB		;N�O, ENT�O TRATA COMO LIBERADO
				;SIM

	DECFSZ	FILTRO11,F	;DECREMENTA O FILTRO DO BOT�O
				;TERMINOU?
	GOTO	CHECA_BT1	;N�O, CONTINUA ESPERANDO
				;SIM

	DECFSZ	FILTRO12,F	;DECREMENTA O FILTRO DO BOT�O
				;TERMINOU?
	GOTO	CHECA_BT1	;N�O, CONTINUA ESPERANDO
				;SIM

	BTFSS	ST_BT1		;BOT�O J� ESTAVA PRESSIONADO?
	GOTO	DEC		;N�O, EXECUTA A��O DO BOT�O
	GOTO	CHECA_BT2	;SIM, CHECA BOT�O 2

BT1_LIB
	BCF	ST_BT1		;MARCA BOT�O 1 COMO LIBERADO

CHECA_BT2

	BTFSC	BOTAO2		;O BOT�O 2 EST� PRESSIONADO?
	GOTO	BT2_LIB		;N�O, ENT�O TRATA COMO LIBERADO
				;SIM

	DECFSZ	FILTRO21,F	;DECREMENTA O FILTRO DO BOT�O
				;TERMINOU?
	GOTO	CHECA_BT2	;N�O, CONTINUA ESPERANDO
				;SIM

	DECFSZ	FILTRO22,F	;DECREMENTA O FILTRO DO BOT�O
				;TERMINOU?
	GOTO	CHECA_BT2	;N�O, CONTINUA ESPERANDO
				;SIM

	BTFSS	ST_BT2		;BOT�O J� ESTAVA PRESSIONADO?
	GOTO	INC		;N�O, EXECUTA A��O DO BOT�O
	GOTO	MAIN		;SIM, VOLTA AO LOOPING

BT2_LIB
	BCF	ST_BT2		;MARCA BOT�O 2 COMO LIBERADO
	GOTO	MAIN		;RETORNA AO LOOPING

DEC				;A��O DE DECREMENTAR
	BSF	ST_BT1		;MARCA BOT�O 1 COMO J� PRESSIONADO
	MOVF	INTENSIDADE,W	;COLOCA INTENSIDADE EM W
	XORLW	MIN		;APLICA XOR ENTRE INTENSIDADE E MIN
				;PARA TESTAR IGUALDADE. SE FOREM
				;IGUAIS, O RESULTADO SER� ZERO
	BTFSC	STATUS,Z	;RESULTOU EM ZERO?
	GOTO	MAIN		;SIM, RETORNA SEM AFETAR CONT.
				;N�O
	DECF	INTENSIDADE,F	;DECREMENTA O INTENSIDADE
	GOTO	ATUALIZA	;ATUALIZA O DISPLAY

INC				;A��O DE INCREMENTAR
	BSF	ST_BT2		;MARCA BOT�O 2 COMO J� PRESSIONADO
	MOVF	INTENSIDADE,W	;COLOCA INTENSIDADE EM W
	XORLW	MAX		;APLICA XOR ENTRE INTENSIDADE E MAX
				;PARA TESTAR IGUALDADE. SE FOREM
				;IGUAIS, O RESULTADO SER� ZERO
	BTFSC	STATUS,Z	;RESULTOU EM ZERO?
	GOTO	MAIN		;SIM, RETORNA SEM AFETAR CONT.
				;N�O
	INCF	INTENSIDADE,F	;INCREMENTA O INTENSIDADE
	GOTO	ATUALIZA	;ATUALIZA O DISPLAY

ATUALIZA
	CALL	CONVERTE	;CONVERTE INTENSIDADE NO N�MERO DO
				;DISPLAY
	MOVWF	PORTB		;ATUALIZA O PORTB PARA
				;VISUALIZARMOS O VALOR DE INTENSIDADE
				;NO DISPLAY
	GOTO	MAIN		;N�O, VOLTA AO LOOP PRINCIPAL

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END			;OBRIGAT�RIO

