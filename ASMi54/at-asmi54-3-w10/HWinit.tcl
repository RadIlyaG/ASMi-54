set gaSet(javaLocation) C:\\Program\ Files\\Java\\jre1.8.0_191\\bin\\
set gaSet(testMode) f

if [file exists [info host]/initline_${gaSet(pair)}.tcl] {
  source [info host]/initline_${gaSet(pair)}.tcl
} else {
  set gaSet(ls4_1)     1
  set gaSet(ls4_2)     2
}

switch -exact -- $gaSet(pair) {
  1 {
      set gaSet(comUut1)    2
      set gaSet(comUut2)    3
      set gaSet(comGen1)    6
      set gaSet(comGen2)    7
      set gaSet(comDxc1)    8
      set gaSet(comDxc2)    9
      set gaSet(comDls1)    5
      
      console eval {wm geometry . +1+1}
      console eval {wm title . "Con 1"}   
      set gaSet(rb1) 1; #power main
      set gaSet(rb2) 2; #power red
      set gaSet(mmuxEthShdslPort) 1
      set gaSet(mmuxMassPort)     2    
  }
  2 {
      set gaSet(comUut1)    2
      set gaSet(comUut2)    3
      set gaSet(comGen1)    4
      set gaSet(comGen2)    5
      set gaSet(comDxc1)    6
      set gaSet(comDxc2)    7
      set gaSet(comDls1)    8
      
      console eval {wm geometry . +100+1}
      console eval {wm title . "Con 2"}   
      set gaSet(rb1) 1; #power main
      set gaSet(rb2) 2; #power red
      set gaSet(mmuxEthShdslPort) 3
      set gaSet(mmuxMassPort)     4    
  }
  5 {
      set gaSet(comUut1)    3; #3
      set gaSet(comUut2)    2; #4
      set gaSet(comGen1)    6; #6
      set gaSet(comGen2)    5; #9
      set gaSet(comDxc1)    7; #7
      set gaSet(comDxc2)    8; #8
      set gaSet(comDls1)    9; #2
      
      console eval {wm geometry . +1+1}
      console eval {wm title . "Con 5"}   
      set gaSet(rb1) 1; #power main
      set gaSet(rb2) 2; #power red
      set gaSet(mmuxEthShdslPort) 1
      set gaSet(mmuxMassPort)     2    
  }
}
switch -exact -- $gaSet(pair) {
  1 {
      set gaSet(comUut1)    2
      set gaSet(comUut2)    3
      set gaSet(comGen1)    6
      set gaSet(comGen2)    7
      set gaSet(comDxc1)    8
      set gaSet(comDxc2)    9
      set gaSet(comDls1)    5
      
      console eval {wm geometry . +1+1}
      console eval {wm title . "Con 1"}   
      set gaSet(rb1) 1; #power main
      set gaSet(rb2) 2; #power red
      set gaSet(mmux1Port) 1; #UUT1 ETH Ports 1,2 Select
      set gaSet(mmux2Port) 2; #UUT1 ETH Ports 3,4 Select
      set gaSet(mmux3Port) 3; #UUT2 ETH Ports 1,2 Select
      set gaSet(mmux4Port) 4; #UUT2 ETH Ports 3,4 Select
      set gaSet(mmux5Port) 5; #UUT1 E1 Ports Select
      set gaSet(mmux6Port) 6; #UUT2 E1 Ports Select
      set gaSet(mmux7Port) 7; #UUT1/2 RS232 Control
      set gaSet(mmux8Port) 8; #UUT Main ETH Control 
      set gaSet(mmux9Port) 9; #UUT1/2 SHDSL Ports Mux
  }

}

source lib_PackSour.tcl
