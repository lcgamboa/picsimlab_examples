li a0 EXTERNAL_BUS_0_DIRA
li a1 EXTERNAL_BUS_0_PORTA


        li t0 0xFF0F
        sh t0 0 a0
loop:        
        lb t0 0 a1
        slli t1,t0,4
        sb t1 0 a1 
        j       loop

