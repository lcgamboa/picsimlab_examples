;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     CONTADOR FINAL - EX6                        *
;*                       DESBRAVANDO O PIC                         *
;*       DESENVOLVIDO PELA MOSAICO ENGENHARIA E CONSULTORIA        *
;*      VERS�O: 1.0                             DATA: 30/10/01     *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                      DESCRI��O DO ARQUIVO                       *
;*-----------------------------------------------------------------*
;*  CONTADOR QUE UTILIZA DOIS BOT�ES PARA INCREMENTAR E DECRE-     *
;*  MENTAR O VALOR CONTROLADO PELA VARI�VEL "CONTADOR". ESTA       *
;*  VARI�VEL EST� LIMITADA PELAS CONSTANTES "MIN" E "MAX".         *
;*  O VALOR DO CONTADOR � MOSTRADO NO DISPLAY E ARMAZENADO NA      *
;*  EEPROM PARA N�O SER PERDIDO MESMO NO CASO DE RESET.            *
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
		CONTADOR	;ARMAZENA O VALOR DA CONTAGEM
		FLAGS		;ARMAZENA OS FLAGS DE CONTROLE
		FILTRO1		;FILTRAGEM PARA O BOT�O 1
		FILTRO2		;FILTRAGEM PARA O BOT�O 2

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

MIN		EQU	.0	;VALOR MINIMO PARA O CONTADOR
MAX		EQU	.15	;VALOR M�XIMO PARA O CONTADOR
T_FILTRO	EQU	.255	;FILTRO PARA BOT�O
POS_MEM		EQU	.0	;ENDERE�O DA EEPROM ONDE SER�
				;ARMAZENADO O VALOR DO CONTADOR
	
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


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    INICIALIZA��O DA EEPROM                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	ORG	H'2100'+POS_MEM	;IN�CIO DA EEPROM
	DE	.5		;VALOR INICIAL PARA CONTADOR = 5
				;VIDE DIRETRIZ "DE" NO AP�NDICE B

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
;*                 ROTINA DE CONVERS�O BIN�RIO -> DISPLAY          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ESTA ROTINA IR� RETORNAR EM W, O SIMBOLO CORRETO QUE DEVE SER
; MOSTRADO NO DISPLAY PARA CADA VALOR DE CONTADOR. O RETORNO J� EST�
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
	MOVF	CONTADOR,W	;COLOCA CONTADOR EM W
	ANDLW	B'00001111'	;MASCARA VALOR DE CONTADOR
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

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                  ROTINA DE LEITURA NA E2PROM                  *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ESTA ROTINA L� O BYTE DO ENDERE�O ACERTADO POR EEADR E COLOCA
; O VALOR EM W.

LE_E2PROM

	BANK1			;BANCO 1
	BSF	EECON1,RD	;PREPARA LEITURA
	MOVF	EEDATA,W	;COLOCA DADO EM W
	BANK0
	RETURN			;RETORNA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                  ROTINA DE ESCRITA NA E2PROM                  *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ESTA ROTINA ESCREVE O DADO PASSSADO EM W NO ENDERE�O ACERTADO
; ANTERIORMENTE EM EEADR

ESCR_E2PROM
	BANK1			;BANCO 1
	MOVWF	EEDATA		;ACERTA DADO PASSADO EM W 
	BCF	INTCON,GIE	;DESABILITA INTERRUP��ES
	BSF	EECON1,WREN	;HABILITA ESCRITA
	MOVLW	0X55		;INICIALIZA��O DA ESCRITA
	MOVWF	EECON2
	MOVLW	0XAA
	MOVWF	EECON2
	BSF	EECON1,WR	;INICIA ESCRITA
	BCF	EECON1,WREN
	BTFSC	EECON1,WR	;ACABOU ESCRITA?
	GOTO	$-1		;N�O, AGUARDA
	BANK0			;SIM, BANCO 0
	BSF	INTCON,GIE	;HABILITA INTERRUP��ES
	RETURN			;RETORNA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*             ROTINA DE LEITURA DO VALOR DO CONTADOR              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ESTA ROTINA L� O VALOR DA MEM�RIA E COLOCA O RESULTADO NA
; VARI�VEL "CONTADOR".

LE_CONTA

	MOVLW	POS_MEM
	BANK1
	MOVWF	EEADR		;ACERTA O ENDERE�O PARA LEITURA
	CALL	LE_E2PROM	;EFETUA A LEITURA DA EEPROM
	MOVWF	CONTADOR	;ATUALIZA O CONTADOR
	RETURN			;RETORNA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*             ROTINA DE ESCRITA DO VALOR DO CONTADOR              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ESTA ROTINA ESCREVE O VALOR ATUAL DE CONTADOR NA MEM�RIA EEPROM

ESCR_CONTA

	MOVLW	POS_MEM
	BANK1
	MOVWF	EEADR		;ACERTA O ENDERE�O PARA LEITURA
	BANK0
	MOVF	CONTADOR,W	;COLOCA CONTADOR EM W
	CALL	ESCR_E2PROM	;EFETUA A ESCRITA EEPROM
	RETURN			;RETORNA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
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
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERA��O DO COMPARADOR ANAL�GICO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZA��O DAS VARI�VEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	CLRF	PORTA		;LIMPA O PORTA
	CLRF	PORTB		;LIMPA O PORTB
	CLRF	FLAGS		;LIMPA TODOS OS FLAGS
	CALL	LE_CONTA	;INICIALIZA CONTADOR COM VALOR
				;DA EEPROM
	GOTO	ATUALIZA	;ATUALIZA O DISPLAY INICIALMENTE

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN
	MOVLW	T_FILTRO

	MOVWF	FILTRO1		;INICIALIZA FILTRO1 = T_FILTRO
	MOVWF	FILTRO2		;INICIALIZA FILTRO2 = T_FILTRO

CHECA_BT1

	BTFSC	BOTAO1		;O BOT�O 1 EST� PRESSIONADO?
	GOTO	BT1_LIB		;N�O, ENT�O TRATA COMO LIBERADO
				;SIM

	DECFSZ	FILTRO1,F	;DECREMENTA O FILTRO DO BOT�O
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
	DECFSZ	FILTRO2,F	;DECREMENTA O FILTRO DO BOT�O
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
	MOVF	CONTADOR,W	;COLOCA CONTADOR EM W
	XORLW	MIN		;APLICA XOR ENTRE CONTADOR E MIN
				;PARA TESTAR IGUALDADE. SE FOREM
				;IGUAIS, O RESULTADO SER� ZERO
	BTFSC	STATUS,Z	;RESULTOU EM ZERO?
	GOTO	MAIN		;SIM, RETORNA SEM AFETAR CONT.
				;N�O
	DECF	CONTADOR,F	;DECREMENTA O CONTADOR
	CALL	ESCR_CONTA	;ATUALIZA O VALOR DE CONTADOR NA 
				;EEPROM
	GOTO	ATUALIZA	;ATUALIZA O DISPLAY

INC				;A��O DE INCREMENTAR
	BSF	ST_BT2		;MARCA BOT�O 2 COMO J� PRESSIONADO
	MOVF	CONTADOR,W	;COLOCA CONTADOR EM W
	XORLW	MAX		;APLICA XOR ENTRE CONTADOR E MAX
				;PARA TESTAR IGUALDADE. SE FOREM
				;IGUAIS, O RESULTADO SER� ZERO
	BTFSC	STATUS,Z	;RESULTOU EM ZERO?
	GOTO	MAIN		;SIM, RETORNA SEM AFETAR CONT.
				;N�O
	INCF	CONTADOR,F	;INCREMENTA O CONTADOR
	CALL	ESCR_CONTA	;ATUALIZA O VALOR DE CONTADOR NA 
				;EEPROM

ATUALIZA			;ATUALIZA��O DO DISPLAY
	CALL	CONVERTE	;CONVERTE CONTADOR NO N�MERO DO
				;DISPLAY
	MOVWF	PORTB		;ATUALIZA O PORTB PARA
				;VISUALIZARMOS O VALOR DE CONTADOR
				;NO DISPLAY
	GOTO	MAIN		;N�O, VOLTA AO LOOP PRINCIPAL

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END			;OBRIGAT�RIO

