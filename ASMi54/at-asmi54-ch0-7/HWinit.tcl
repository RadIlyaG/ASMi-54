set gaSet(javaLocation) C:\\Program\ Files\\Java\\jre1.8.0_181\\bin\\
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
      set gaSet(comUut2)    4
      set gaSet(comGen1)    5
      set gaSet(comGen2)    6
      set gaSet(comDxc1)    7
      set gaSet(comDxc2)    10
      set gaSet(comDls1)    9
      
      console eval {wm geometry . +1+1}
      console eval {wm title . "Con 1"}   
      set gaSet(rb1) 1; #power main
      set gaSet(rb2) 2; #power red
      set gaSet(mmuxEthShdslPort) 1
      set gaSet(mmuxMassPort)     2      
  }
  2 {
      set gaSet(comUut1)    11
      set gaSet(comUut2)    12
      set gaSet(comGen1)    14
      set gaSet(comGen2)    13
      set gaSet(comDxc1)    17
      set gaSet(comDxc2)    16
      set gaSet(comDls1)    15
      
      console eval {wm geometry . +100+1}
      console eval {wm title . "Con 2"}   
      set gaSet(rb1) 3; #power main
      set gaSet(rb2) 4; #power red
      set gaSet(mmuxEthShdslPort) 3
      set gaSet(mmuxMassPort)     4      
  }
  5 {
      set gaSet(comUut1)    2
      set gaSet(comUut2)    3
      set gaSet(comGen1)    4
      set gaSet(comGen2)    5
      set gaSet(comDxc1)    6
      set gaSet(comDxc2)    7
      set gaSet(comDls1)    8
      
      console eval {wm geometry . +1+1}
      console eval {wm title . "Con 5"}   
      set gaSet(rb1) 1; #power main
      set gaSet(rb2) 2; #power red
      set gaSet(mmuxEthShdslPort) 1
      set gaSet(mmuxMassPort)     2      
  }
}
   
source lib_PackSour.tcl
