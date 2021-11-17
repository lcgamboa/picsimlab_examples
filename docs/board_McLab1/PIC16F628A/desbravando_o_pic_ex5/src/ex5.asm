;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    TIMER DE SEGUNDOS - EX5                      *
;*                       DESBRAVANDO O PIC                         *
;*       DESENVOLVIDO PELA MOSAICO ENGENHARIA E CONSULTORIA        *
;*      VERS�O: 1.0                             DATA: 30/10/01     *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                      DESCRI��O DO ARQUIVO                       *
;*-----------------------------------------------------------------*
;*  TIMER DECRESCENTE EM SEGUNDOS. O VALOR INICIAL � DETERMINADO   *
;*  PELA CONSTANTE V_INICIO E PODE ESTAR ENTRE 1 E 9 SEGUNDOS.     *
;*  O BOT�O 1 DISPARA O TIMER, MOSTRANDO O TEMPO RESTANTE NO       *
;*  DISPLAY. O BOT�O 2 PARALIZA O TIMER. O LED � UTILIZADO PARA    *
;* INDICAR O ESTADO ATUAL DO TIMER: ACESO=RODANDO E APAGADO=PARADO *
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
		TEMPO		;ARMAZENA O VALOR DO TEMPO
		FLAGS		;ARMAZENA OS FLAGS DE CONTROLE
		TEMP1		;REGISTRADORES AUXILIARES
		TEMP2
		FILTRO1		;FILTROS DOS BOT�ES
		FILTRO2	

	ENDC			;FIM DO BLOCO DE MEM�RIA		

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

#DEFINE	F_FIM	FLAGS,0		;FLAG DE FIM DE TEMPO
#DEFINE	ST_BT1	FLAGS,1		;STATUS DO BOT�O 1
#DEFINE	ST_BT2	FLAGS,2		;STATUS DO BOT�O 2

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA

V_INICIO	EQU	.15	;VALOR INICIAL DO TIMER (1 A 15 SEG.)
T_FILTRO	EQU	.255	;VALOR DO FILTRO DOS BOT�ES
	
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

#DEFINE	LED	PORTA,3	;LED
			;0 -> DESLIGADO
			;1 -> LIGADO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       VETOR DE RESET                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	ORG	0x00	;ENDERE�O INICIAL DE PROCESSAMENTO
	GOTO	INICIO
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    IN�CIO DA INTERRUP��O                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; UTILIZAREMOS SOMENTE A INTERRU��O DE TMR0, MAS EFETUAREMOS O TESTE
; PARA TERMOS CERTEZA DE QUE NENHUM PROBLEMA ACONTECEU. � NECESS�RIO
; SALVAR E RECUPERAR OS VALOR DE W E STATUS.

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
	MOVLW	.256-.125	
	MOVWF	TMR0		;REINICIA TMR0
	DECFSZ	TEMP1,F		;DECREMENTA CONTADOR AUXILIAR. ACABOU?
	GOTO	SAI_INT		;N�O, SAI SEM A��O
				;SIM
	MOVLW	.125
	MOVWF	TEMP1		;REINICIALIZA TEMPO AUXILIAR
	BTFSC	F_FIM		;J� CHEGOU AO FIM?
	GOTO	SAI_INT		;SIM, ENT�O N�O DECREMENTA O TEMPO
				;N�O
	DECFSZ	TEMPO,F		;DECREMENTA TEMPO. ACABOU?
	GOTO	SAI_INT		;N�O, SAI DA INTERRU��O
				;SIM
	BSF	F_FIM		;MARCA FIM DO TEMPO
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
	MOVF	TEMPO,W		;COLOCA CONTADOR EM W
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

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                 ROTINA DE ATUALIZA��O DO DISPLAY                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ESTA ROTINA CONVERTE O VALOR DE TEMPO ATRAV�S DA ROTINA CONVERTE
; E ATUALIZA O PORTB PARA ACENDER O DISPLAY CORRETAMENTE

ATUALIZA
	CALL	CONVERTE	;CONVERTE CONTADOR NO N�MERO DO
				;DISPLAY
	MOVWF	PORTB		;ATUALIZA O PORTB PARA
				;VISUALIZARMOS O VALOR DE CONTADOR
				;NO DISPLAY
	RETURN			;N�O, RETORNA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                 ROTINA DE DESLIGAR O TIMER                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ESTA ROTINA EXECUTA AS A��ES NECESS�RIAS PARA DESLIGAR O TIMER

DESL_TIMER
	BCF	INTCON,GIE	;DESLIGA CHAVE GERAL DE INT.
	BCF	LED		;APAGA O LED
	RETURN			;RETORNA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                 ROTINA DE LIGAR O TIMER                         *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ESTA ROTINA EXECUTA AS A��ES NECESS�RIAS PARA LIGAR O TIMER

LIGA_TIMER
	BTFSC	INTCON,GIE	;TIMER J� ESTA LIGADO?
	RETURN			;SIM, RETORNA DIRETO
				;N�O
	BCF	INTCON,T0IF	;LIMPA FLAG DE INT. DE TMR0
	MOVLW	.256-.125
	MOVWF	TMR0		;INICIA TMR0 CORRETAMENTE
	MOVLW	.125
	MOVWF	TEMP1		;INICIA TEMP1 CORRETAMENTE
	BSF	INTCON,GIE	;LIGA CHAVE GERAL DE INTERRUP��ES
	BSF	LED		;ACENDE O LED
	RETURN			;RETORNA

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
	MOVLW	B'10000101'
	MOVWF	OPTION_REG	;PRESCALER 1:64 NO TMR0
				;PULL-UPS DESABILITADOS
				;AS DEMAIS CONFG. S�O IRRELEVANTES
	MOVLW	B'00100000'
	MOVWF	INTCON		;HABILITADA SOMENTE A INTERRUP��O TMR0
				;CHAVE GERAL DAS INTERRU��ES DESLIGADAS
	BANK0			;RETORNA PARA O BANCO 0

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZA��O DAS VARI�VEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *


	CLRF	PORTA		;LIMPA O PORTA
	CLRF	PORTB		;LIMPA O PORTB
	CLRF	FLAGS		;LIMPA TODOS OS FLAGS
	MOVLW	V_INICIO
	MOVWF	TEMPO		;INICIA TEMPO = V_INICIO
	CALL	ATUALIZA	;ATUALIZA O DISPLAY INICIALMENTE

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN
	BTFSC	F_FIM		;CHEGOU AO FIM?
	CALL	DESL_TIMER	;SIM, ENT�O DESLIGA O TIMER
				;N�O
	CALL	ATUALIZA	;ATUALIZA O DISPLAY
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
	GOTO	ACAO_BT1	;N�O, EXECUTA A��O DO BOT�O
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
	GOTO	ACAO_BT2	;N�O, EXECUTA A��O DO BOT�O
	GOTO	MAIN		;SIM, VOLTA AO LOOPING

BT2_LIB
	BCF	ST_BT2		;MARCA BOT�O 2 COMO LIBERADO
	GOTO	MAIN		;RETORNA AO LOOPING

ACAO_BT1			;A��O PARA O BOT�O 1
	BSF	ST_BT1		;MARCA BOT�O 1 COMO J� PRESSIONADO
	CALL	LIGA_TIMER	;LIGA O TIMER
	GOTO	MAIN

ACAO_BT2			;A��O PARA O BOT�O 2
	BSF	ST_BT2		;MARCA BOT�O 2 COMO J� PRESSIONADO
	CALL	DESL_TIMER	;DESLIGA O TIMER
	GOTO	MAIN		;N�O, VOLTA AO LOOP PRINCIPAL

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END			;OBRIGAT�RIO

