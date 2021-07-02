#ifndef BIT_H
#define	BIT_H

//funções de bit
#define bitSet(arg,bit) ((arg) |=  (1<<(bit)))
#define bitClr(arg,bit) ((arg) &= ~(1<<(bit))) 
#define bitFlp(arg,bit) ((arg) ^=  (1<<(bit))) 
#define bitTst(arg,bit) ((arg) &   (1<<(bit)))


#endif	/* XC_HEADER_TEMPLATE_H */

