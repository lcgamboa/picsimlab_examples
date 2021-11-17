; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                   CONECTANDO O PIC - RECURSOS AVAN�ADOS                 *
; *                               EXEMPLO 3                                 *
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
;  ESTE EXEMPLO FOI ELABORADO PARA EXPLICAR O FUNCIONAMENTO DO M�DULO DE LCD.
;  FOI CRIADA UMA ROTINA PARA ESCREVER COMANDOS OU CACACTRES NO LCD. EXISTE
;  TAMB�M UMA ROTINA DE INICIALIZA��O NECESS�RIA PARA A CORRETA CONFIGURA��O
;  DO LCD. OS BOT�ES CONTINUAM SENDO MONITORADOS. UMA MENSAGEM � ESCRITA
;  NO LCD PARA CADA UM DOS BOT�ES, QUANDO O MESMO � PRESSIONADO.
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

		TEMPO1
		TEMPO0			; CONTADORES P/ DELAY

		FILTRO_BOTOES		; FILTRO PARA RUIDOS

		FLAG			; FLAG DE USO GERAL

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

FILTRO_TECLA	EQU	.200		; FILTRO P/ EVITAR RUIDOS DOS BOT�ES

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                    DECLARA��O DOS FLAGs DE SOFTWARE                    *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;  A DEFINI��O DE FLAGs AJUDA NA PROGRAMA��O E ECONOMIZA MEM�RIA RAM.

#DEFINE	TELA_PRINCIPAL	FLAG,0		; FLAG P/ INDICAR QUE DEVE MOSTRAR
					; A TELA PRINCIPAL
					; 1-> MOSTRA TELA PRINCIPAL
					; 0-> TELA PRINCIPAL J� FOI MOSTRADA

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                                ENTRADAS                                 *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;  AS ENTRADAS DEVEM SER ASSOCIADAS A NOMES PARA FACILITAR A PROGRAMA��O E
;  FUTURAS ALTERA��ES DO HARDWARE.

#DEFINE	BOTAO_0		PORTB,0		; ESTADO DO BOT�O 0
					; 1 -> LIBERADO
					; 0 -> PRESSIONADO

#DEFINE	BOTAO_1		PORTB,1		; ESTADO DO BOT�O 1
					; 1 -> LIBERADO
					; 0 -> PRESSIONADO

#DEFINE	BOTAO_2		PORTB,2		; ESTADO DO BOT�O 2
					; 1 -> LIBERADO
					; 0 -> PRESSIONADO

#DEFINE	BOTAO_3		PORTB,3		; ESTADO DO BOT�O 3
					; 1 -> LIBERADO
					; 0 -> PRESSIONADO

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
; *                     ROTINA DE DELAY (DE 1MS AT� 256MS)                  *
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
; *               ROTINA DE ESCRITA DA TELA PRINCIPAL                       *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;  ESTA ROTINA ESCREVE A TELA PRINCIPAL DO PROGRAMA, COM AS FRASES:
;  LINHA 1 - " MOSAICO ENG. "
;  LINHA 2 - "CURSO MODULO 2" 

MOSTRA_TELA_PRINCIPAL

	BCF	TELA_PRINCIPAL		; LIMPA FLAG DE MOSTRAR TELA PRINCIPAL

	BCF	RS			; SELECIONA O DISPLAY P/ COMANDOS
	MOVLW	0X01			; ESCREVE COMANDO PARA
	CALL	ESCREVE			; LIMPAR A TELA
	MOVLW	.1
	CALL	DELAY_MS		; DELAY DE 1MS
	
	MOVLW	0X82			; COMANDO PARA POSICIONAR O CURSOR
	CALL	ESCREVE			; LINHA 0 / COLUNA 2
	BSF	RS			; SELECIONA O DISPLAY P/ DADOS

					; COMANDOS PARA ESCREVER AS
					; LETRAS DE "MOSAICO ENG."
	MOVLW	'M'
	CALL	ESCREVE
	MOVLW	'O'
	CALL	ESCREVE
	MOVLW	'S'
	CALL	ESCREVE
	MOVLW	'A'
	CALL	ESCREVE
	MOVLW	'I'
	CALL	ESCREVE
	MOVLW	'C'
	CALL	ESCREVE
	MOVLW	'O'
	CALL	ESCREVE
	MOVLW	' '
	CALL	ESCREVE
	MOVLW	'E'
	CALL	ESCREVE
	MOVLW	'N'
	CALL	ESCREVE
	MOVLW	'G'
	CALL	ESCREVE
	MOVLW	'.'
	CALL	ESCREVE

	BCF	RS			; SELECIONA O DISPLAY P/ COMANDOS
	MOVLW	0XC1			; COMANDO PARA POSICIONAR O CURSOR
	CALL	ESCREVE			; LINHA 1 / COLUNA 0
	BSF	RS			; SELECIONA O DISPLAY P/ DADOS

					; COMANDOS PARA ESCREVER AS
					; LETRAS DE "CURSO MODULO 2"
	MOVLW	'C'
	CALL	ESCREVE
	MOVLW	'U'
	CALL	ESCREVE
	MOVLW	'R'
	CALL	ESCREVE
	MOVLW	'S'
	CALL	ESCREVE
	MOVLW	'O'
	CALL	ESCREVE
	MOVLW	' '
	CALL	ESCREVE
	MOVLW	'M'
	CALL	ESCREVE
	MOVLW	'O'
	CALL	ESCREVE
	MOVLW	'D'
	CALL	ESCREVE
	MOVLW	'U'
	CALL	ESCREVE
	MOVLW	'L'
	CALL	ESCREVE
	MOVLW	'O'
	CALL	ESCREVE
	MOVLW	' '
	CALL	ESCREVE
	MOVLW	'2'
	CALL	ESCREVE
	RETURN

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                CONFIGURA��ES INICIAIS DE HARDWARE E SOFTWARE            *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;  NESTA ROTINA S�O INICIALIZADAS AS PORTAS DE I/O DO MICROCONTROLADOR E AS
;  CONFIGURA��ES DOS REGISTRADORES ESPECIAIS (SFR). A ROTINA INICIALIZA A
;  M�QUINA E AGUARDA O ESTOURO DO WDT.

CONFIG_
	CLRF	PORTA			; GARANTE AS SA�DAS EM ZERO
	CLRF	PORTB
	CLRF	PORTC
	CLRF	PORTD
	CLRF	PORTE

	BANK1				; SELECIONA BANCO 1 DA RAM

	MOVLW	B'11011111'
	MOVWF	TRISA			; CONFIGURA I/O DO PORTA

	MOVLW	B'11111111'
	MOVWF	TRISB			; CONFIGURA I/O DO PORTB

	MOVLW	B'11111111'
	MOVWF	TRISC			; CONFIGURA I/O DO PORTC

	MOVLW	B'00000000'
	MOVWF	TRISD			; CONFIGURA I/O DO PORTD

	MOVLW	B'00000100'
	MOVWF	TRISE			; CONFIGURA I/O DO PORTE

	MOVLW	B'11011111'
	MOVWF	OPTION_REG		; CONFIGURA OPTIONS
					; PULL-UPs DESABILITADOS
					; INTER. NA BORDA DE SUBIDA DO RB0
					; TIMER0 INCREM. PELO CICLO DE M�QUINA
					; WDT   - 1:128
					; TIMER - 1:1
					
	MOVLW	B'00000000'		
	MOVWF	INTCON			; CONFIGURA INTERRUP��ES
					; DESABILITADA TODAS AS INTERRUP��ES

	MOVLW	B'00000111'
	MOVWF	ADCON1			; CONFIGURA CONVERSOR A/D
					; CONFIGURA PORTA E PORTE COM I/O DIGITAL

	BANK0				; SELECIONA BANCO 0 DA RAM

;  AS INSTRU��ES A SEGUIR FAZEM COM QUE O PROGRAMA TRAVE QUANDO HOUVER UM
;  RESET OU POWER-UP, MAS PASSE DIRETO SE O RESET FOR POR WDT. DESTA FORMA,
;  SEMPRE QUE O PIC � LIGADO, O PROGRAMA TRAVA, AGUARDA UM ESTOURO DE WDT
;  E COME�A NOVAMENTE. ISTO EVITA PROBLEMAS NO START-UP DO PIC.

	BTFSC	STATUS,NOT_TO		; RESET POR ESTOURO DE WATCHDOG TIMER?
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

	BSF	TELA_PRINCIPAL		; INICIALIZA MOSTRANDO TELA PRINCIPAL

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                    CONFIGURA��ES INICIAIS DO DISPLAY                    *
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

	BSF	RS			; SELECIONA O DISPLAY P/ DADOS

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                          VARREDURA DOS BOT�ES                           *
; *                             LOOP PRINCIPAL                              *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;  A ROTINA PRINCIPAL FICA CHECANDO O ESTADO DOS BOT�ES. CASO ALGUM SEJA
;  PRESSIONADO, A ROTINA DE TRATAMENTO DO BOT�O � CHAMADA.

VARRE
	CLRWDT				; LIMPA WATCHDOG TIMER

	BTFSS	BOTAO_0			; O BOT�O 0 EST� PRESSIONADO ?
	GOTO	TRATA_BOTAO_0		; SIM - PULA P/ TRATA_BOTAO_0
					; N�O

	BTFSS	BOTAO_1			; O BOT�O 1 EST� PRESSIONADO ?
	GOTO	TRATA_BOTAO_1		; SIM - PULA P/ TRATA_BOTAO_1
					; N�O

	BTFSS	BOTAO_2			; O BOT�O 2 EST� PRESSIONADO ?
	GOTO	TRATA_BOTAO_2		; SIM - PULA P/ TRATA_BOTAO_2
					; N�O

	BTFSS	BOTAO_3			; O BOT�O 3 EST� PRESSIONADO ?
	GOTO	TRATA_BOTAO_3		; SIM - PULA P/ TRATA_BOTAO_3
					; N�O

	MOVLW	FILTRO_TECLA		; CARREGA NO WORK O VALOR DE FILTRO_TECLA
	MOVWF	FILTRO_BOTOES		; SALVA EM FILTRO_BOTOES
					; RECARREGA FILTRO P/ EVITAR RUIDOS

	BTFSS	TELA_PRINCIPAL		; DEVE MOSTRAR TELA PRINCIPAL ?
	GOTO	VARRE			; N�O - VOLTA P/ VARRE
					; SIM
	CALL	MOSTRA_TELA_PRINCIPAL
	GOTO	VARRE			; VOLTA PARA VARRER TECLADO

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                         TRATAMENTO DOS BOT�ES                           *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

; ************************* TRATAMENTO DO BOT�O 0 ***************************

TRATA_BOTAO_0
	MOVF	FILTRO_BOTOES,F
	BTFSC	STATUS,Z		; FILTRO J� IGUAL A ZERO ?
					; (FUN��O J� FOI EXECUTADA?)		
	GOTO	VARRE			; SIM - VOLTA P/ VARREDURA DO TECLADO
					; N�O

	DECFSZ	FILTRO_BOTOES,F		; FIM DO FILTRO ? (RUIDO?)
	GOTO	VARRE			; N�O - VOLTA P/ VARRE
					; SIM - BOT�O PRESSIONADO

;  OS COMANDOS A SEGUIR S�O PARA ESCREVER A FRASE RELACIONADA AO BOT�O 0 

	BCF	RS			; SELECIONA O DISPLAY P/ COMANDOS
	MOVLW	0X01
	CALL	ESCREVE			; COMANDO P/ LIMPAR A TELA
	MOVLW	.1
	CALL	DELAY_MS		; DELAY DE 1MS

	MOVLW	0X80			; COMANDO PARA POSICIONAR O CURSOR
	CALL	ESCREVE			; LINHA 0 / COLUNA 0
	BSF	RS			; SELECIONA O DISPLAY P/ DADOS

					; COMANDOS PARA ESCREVER AS
					; LETRAS DE "TECLA 0"
	MOVLW	'T'
	CALL	ESCREVE
	MOVLW	'E'
	CALL	ESCREVE
	MOVLW	'C'
	CALL	ESCREVE
	MOVLW	'L'
	CALL	ESCREVE
	MOVLW	'A'
	CALL	ESCREVE
	MOVLW	' '
	CALL	ESCREVE
	MOVLW	'0'
	CALL	ESCREVE

	BSF	TELA_PRINCIPAL		; SETA FLAG P/ MOSTRAR TELA PRINCIPAL

	GOTO	VARRE			; VOLTA P/ VARREDURA DOS BOT�ES

; ************************* TRATAMENTO DO BOT�O 1 ***************************

TRATA_BOTAO_1
	MOVF	FILTRO_BOTOES,F
	BTFSC	STATUS,Z		; FILTRO J� IGUAL A ZERO ?
					; (FUN��O J� FOI EXECUTADA?)		
	GOTO	VARRE			; SIM - VOLTA P/ VARREDURA DO TECLADO
					; N�O

	DECFSZ	FILTRO_BOTOES,F		; FIM DO FILTRO ? (RUIDO?)
	GOTO	VARRE			; N�O - VOLTA P/ VARRE
					; SIM - BOT�O PRESSIONADO

;  OS COMANDOS A SEGUIR S�O PARA ESCREVER A FRASE RELACIONADA AO BOT�O 1 

	BCF	RS			; SELECIONA O DISPLAY P/ COMANDOS
	MOVLW	0X01
	CALL	ESCREVE			; COMANDO P/ LIMPAR A TELA
	MOVLW	.1
	CALL	DELAY_MS		; DELAY DE 1MS

	MOVLW	0X88			; COMANDO PARA POSICIONAR O CURSOR
	CALL	ESCREVE			; LINHA 0 / COLUNA 8
	BSF	RS			; SELECIONA O DISPLAY P/ DADOS

					; COMANDOS PARA ESCREVER AS
					; LETRAS DE "TECLA 1"
	MOVLW	'T'
	CALL	ESCREVE
	MOVLW	'E'
	CALL	ESCREVE
	MOVLW	'C'
	CALL	ESCREVE
	MOVLW	'L'
	CALL	ESCREVE
	MOVLW	'A'
	CALL	ESCREVE
	MOVLW	' '
	CALL	ESCREVE
	MOVLW	'1'
	CALL	ESCREVE

	BSF	TELA_PRINCIPAL		; SETA FLAG P/ MOSTRAR TELA PRINCIPAL

	GOTO	VARRE			; VOLTA P/ VARREDURA DOS BOT�ES

; ************************* TRATAMENTO DO BOT�O 2 ***************************

TRATA_BOTAO_2
	MOVF	FILTRO_BOTOES,F
	BTFSC	STATUS,Z		; FILTRO J� IGUAL A ZERO ?
					; (FUN��O JA FOI EXECUTADA?)		
	GOTO	VARRE			; SIM - VOLTA P/ VARREDURA DO TECLADO
					; N�O

	DECFSZ	FILTRO_BOTOES,F		; FIM DO FILTRO ? (RUIDO?)
	GOTO	VARRE			; N�O - VOLTA P/ VARRE
					; SIM - BOT�O PRESSIONADO

;  OS COMANDOS A SEGUIR S�O PARA ESCREVER A FRASE RELACIONADA AO BOT�O 2 

	BCF	RS			; SELECIONA O DISPLAY P/ COMANDOS
	MOVLW	0X01			
	CALL	ESCREVE			; COMANDO P/ LIMPAR A TELA
	MOVLW	.1
	CALL	DELAY_MS		; DELAY DE 1MS

	MOVLW	0XC0			; COMANDO PARA POSICIONAR O CURSOR
	CALL	ESCREVE			; LINHA 1 / COLUNA 0
	BSF	RS			; SELECIONA O DISPLAY P/ DADOS

					; COMANDOS PARA ESCREVER AS
					; LETRAS DE "TECLA 2"
	MOVLW	'T'
	CALL	ESCREVE
	MOVLW	'E'
	CALL	ESCREVE
	MOVLW	'C'
	CALL	ESCREVE
	MOVLW	'L'
	CALL	ESCREVE
	MOVLW	'A'
	CALL	ESCREVE
	MOVLW	' '
	CALL	ESCREVE
	MOVLW	'2'
	CALL	ESCREVE

	BSF	TELA_PRINCIPAL		; SETA FLAG P/ MOSTRAR TELA PRINCIPAL

	GOTO	VARRE			; VOLTA P/ VARREDURA DOS BOT�ES

; ************************* TRATAMENTO DO BOT�O 3 ***************************

TRATA_BOTAO_3
	MOVF	FILTRO_BOTOES,F
	BTFSC	STATUS,Z		; FILTRO J� IGUAL A ZERO ?
					; (FUN��O JA FOI EXECUTADA?)		
	GOTO	VARRE			; SIM - VOLTA P/ VARREDURA DO TECLADO
					; N�O

	DECFSZ	FILTRO_BOTOES,F		; FIM DO FILTRO ? (RUIDO?)
	GOTO	VARRE			; N�O - VOLTA P/ VARRE
					; SIM - BOT�O PRESSIONADO

;  OS COMANDOS A SEGUIR S�O PARA ESCREVER A FRASE RELACIONADA AO BOT�O 3 

	BCF	RS			; SELECIONA O DISPLAY P/ COMANDOS
	MOVLW	0X01
	CALL	ESCREVE			; COMANDO P/ LIMPAR A TELA
	MOVLW	.1
	CALL	DELAY_MS		; DELAY DE 1MS

	MOVLW	0XC8			; COMANDO PARA POSICIONAR O CURSOR
	CALL	ESCREVE			; LINHA 1 / COLUNA 8
	BSF	RS			; SELECIONA O DISPLAY P/ DADOS

					; COMANDOS PARA ESCREVER AS
					; LETRAS DE "TECLA 3"
	MOVLW	'T'
	CALL	ESCREVE
	MOVLW	'E'
	CALL	ESCREVE
	MOVLW	'C'
	CALL	ESCREVE
	MOVLW	'L'
	CALL	ESCREVE
	MOVLW	'A'
	CALL	ESCREVE
	MOVLW	' '
	CALL	ESCREVE
	MOVLW	'3'
	CALL	ESCREVE

	BSF	TELA_PRINCIPAL		; SETA FLAG P/ MOSTRAR TELA PRINCIPAL

	GOTO	VARRE			; VOLTA P/ VARREDURA DOS BOT�ES

; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; *                              FIM DO PROGRAMA                            *
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END				; FIM DO PROGRAMA

