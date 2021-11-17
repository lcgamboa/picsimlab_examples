;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                  CONTADOR SIMPLIFICADO - EX2                    *
;*                       DESBRAVANDO O PIC                         *
;*       DESENVOLVIDO PELA MOSAICO ENGENHARIA E CONSULTORIA        *
;*      VERS�O: 1.0                             DATA: 30/10/01     *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                      DESCRI��O DO ARQUIVO                       *
;*-----------------------------------------------------------------*
;*  SISTEMA MUITO SIMPLES PARA INCREMENTAR AT� UM DETERMINADO      *
;*  VALOR (MAX) DE DEPOIS DECREMENTAR AT� OUTRO (MIN).             *
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
		CONTADOR	;ARMAZENA O VALOR DA CONTAGEM
		FLAGS		;ARMAZENA OS FLAGS DE CONTROLE
		FILTRO		;FILTRAGEM PARA O BOT�O

	ENDC			;FIM DO BLOCO DE MEM�RIA		

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

#DEFINE	SENTIDO	FLAGS,0		;FLAG DE SENTIDO
				; 0 -> SOMANDO
				; 1 -> SUBTRAINDO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA

MIN		EQU	.10	;VALOR M�NIMO PARA O CONTADOR
MAX		EQU	.30	;VALOR M�XIMO PARA O CONTADOR
T_FILTRO	EQU	.230	;FILTRO PARA BOT�O
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ENTRADAS                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO ENTRADA
; RECOMENDAMOS TAMB�M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

#DEFINE	BOTAO	PORTA,2	;PORTA DO BOT�O
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
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1			;ALTERA PARA O BANCO 1
	MOVLW	B'00000100'
	MOVWF	TRISA		;DEFINE RA2 COMO ENTRADA E DEMAIS
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
	MOVLW	MIN
	MOVWF	CONTADOR	;INICIA CONTADOR = V_INICIAL

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN
	MOVLW	T_FILTRO
	MOVWF	FILTRO		;INICIALIZA FILTRO = T_FILTRO

CHECA_BT
	BTFSC	BOTAO		;O BOT�O EST� PRESSIONADO?
	GOTO	MAIN		;N�O, ENT�O CONTINUA ESPERANDO
				;SIM
	DECFSZ	FILTRO,F	;DECREMENTA O FILTRO DO BOT�O
				;TERMINOU?
	GOTO	CHECA_BT	;N�O, CONTINUA ESPERANDO
				;SIM

TRATA_BT
	BTFSS	SENTIDO		;DEVE SOMAR (SENTIDO=0)?
	GOTO	SOMA		;SIM
				;N�O
SUBTRAI
	DECF	CONTADOR,F	;DECREMENTA O CONTADOR

	MOVLW	MIN		;MOVE O VALOR M�NIMO PARA W
	SUBWF	CONTADOR,W	;SUBTRAI O VALOR DE W (MIN) DE CONTADOR
	BTFSC	STATUS,C	;TESTA CARRY. RESULTADO NEGATIVO?
	GOTO	ATUALIZA	;N�O, ENT�O CONTA >= MIN
				;SIM, ENT�O CONTA < MIN

	INCF	CONTADOR,F	;INCREMENTA CONTADOR NOVAMENTE
				;POIS PASSOU DO LIMITE
	BCF	SENTIDO		;MUDA SENTIDO PARA SOMA
	GOTO	MAIN		;VOLTA AO LOOP PRINCIPAL

SOMA
	INCF	CONTADOR,F	;INCREMENTA O CONTADOR

	MOVLW	MAX		;MOVE O VALOR M�XIMO PARA W
	SUBWF	CONTADOR,W	;SUBTRAI O VALOR DE W (MIN) DE CONTADOR
	BTFSS	STATUS,C	;TESTA CARRY. RESULTADO NEGATIVO?
	GOTO	ATUALIZA	;SIM, ENT�O CONTA < MAX
				;N�O, ENT�O CONTA >= MAX

	BSF	SENTIDO		;MUDA SENTIDO PARA SUBTRA��O
	GOTO	MAIN		;VOLTA AO LOOP PRINCIPAL

ATUALIZA
	MOVF	CONTADOR,W	;COLOCA CONTADOR EM W
	MOVWF	PORTB		;ATUALIZA O PORTB PARA
				;VISUALIZARMOS O VALOR DE CONTADOR

	BTFSS	BOTAO		;O BOT�O CONTINUA PRESSIONADO?
	GOTO	$-1		;SIM, ENT�O ESPERA LIBERA��O PARA
				;QUE O CONTADOR N�O DISPARE
	GOTO	MAIN		;N�O, VOLTA AO LOOP PRINCIPAL

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END			;OBRIGAT�RIO

