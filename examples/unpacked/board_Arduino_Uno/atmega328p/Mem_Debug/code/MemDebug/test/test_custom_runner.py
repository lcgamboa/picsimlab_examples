from platformio.public import TestCase, TestCaseSource, TestStatus, UnityTestRunner

from PICSimLab_rcontrol import PICSimLab_rcontrol

import time,re

class CustomTestRunner(UnityTestRunner):
    def stage_testing(self):
        print("Blink time measure test started ....")
        time.sleep(3)
        try:  
           with PICSimLab_rcontrol(5000) as rc: 
             #rc.debug=1
             rc.cmd_oscshow()
             oscopen= rc.get_cmd_response().split()[0]
             rc.cmd_oscshow(1)
             rc.cmd_oscrdcfg()
             osccfg= re.findall(r'(\d+):"([^"]*)"', rc.get_cmd_response())
             rc.cmd_oscwrcfg(0, "osc_cfg,100,100,0:500.000000,0.000000,1,1,2.500000,3,2,9,7,8")
             rc.cmd_oscwrcfg(1, "osc_ch1,0,0,0:2.000000,0.000000,1,#FF0000,0,19")
             rc.cmd_oscwrcfg(2, "osc_ch2,0,0,0:2.000000,-6.000000,0,#00FF00,0,0")
             cnt = 0
             while cnt < 5:
                time.sleep(0.1)
                cnt = cnt + 0.1
                rc.cmd_oscmeasures(1)
                val = rc.get_cmd_response()
                fcyc = float((val.split('\n')[9]).split()[1])
                if fcyc > 900 :
                   break
             time.sleep(5)
             rc.cmd_oscmeasures(1)
             val= rc.get_cmd_response()
             rc.cmd_oscwrcfg(osccfg[0][0], osccfg[0][1])
             rc.cmd_oscwrcfg(osccfg[1][0], osccfg[1][1])
             rc.cmd_oscwrcfg(osccfg[2][0], osccfg[2][1])
             rc.cmd_oscshow(oscopen)
             pcyc=float((val.split('\n')[7]).split()[1]) 
             ncyc=float((val.split('\n')[8]).split()[1]) 

             print(f"Positive cycle: {pcyc} ms")
             print(f"Negative cycle: {ncyc} ms")

             if  pcyc > 490 and pcyc < 510: 
                 self.test_suite.add_case(
                     TestCase(name="Positive cycle", status=TestStatus.PASSED))
             else :   
                 self.test_suite.add_case(
                     TestCase(name="Positive cycle", 
                              status=TestStatus.FAILED,
                              message=f"Expected 500 ms Was {pcyc} ms",
                              stdout=f"Positive cycle: FAIL: Expected 500 ms Was {pcyc} ms"
                              ))
                 
             if  ncyc > 490 and ncyc < 510: 
                 self.test_suite.add_case(TestCase(name="Negative cycle", status=TestStatus.PASSED))
             else :   
                 self.test_suite.add_case(
                     TestCase(name="Negative cycle", 
                              status=TestStatus.FAILED,
                              message=f"Expected 500 ms Was {ncyc} ms",
                              stdout=f"Negative cycle: FAIL: Expected 500 ms Was {ncyc} ms"
                              ))     

        except ConnectionError as e:
            print(e)
            return -1    
           


