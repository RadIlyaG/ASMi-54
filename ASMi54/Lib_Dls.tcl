#***************************************************************************
#** SetLine
#***************************************************************************
proc SetLine {range6700} {
  global gaSet buffer gaGui
  #return 0
  Status "Set line to $range6700" ; update
  set range6300 $range6700
  #puts "Set line $gaSet(dlsLine$dls) to $range FT" ; update
  set dlsType $gaSet(ls4_DLS6x)
  puts "dlsType:$dlsType"
  if {$dlsType=="6800"} {
    set maxDlsRange 4950    
  } else {
    set maxDlsRange 24000
  }
  if {($dlsType=="6300" || $dlsType=="6700") && $gaSet(ls4_APD)=="RSD10"} {
    RLSerial::Open $gaSet(comDls1) 9600 n 8 1
   	set ret [SetLine6700rsd $range6700]
   	RLSerial::Close $gaSet(comDls1) 	  
          
  } elseif {$dlsType=="6100"} {
    set ret [SetLine6100 range6700]
  }  
  return $ret
}

#***************************************************************************
#** SetLine6100
#***************************************************************************
proc SetLine6100 {inRange} {
  global gaSet buffer
 	switch $gaSet(dsl) {
    "2W" {set dslNum 1}
    "4W" {set dslNum 2}
    "8W" {set dslNum 4}
  }  
  foreach {com} "$gaSet(comDls1) $gaSet(comDls2) $gaSet(comDls3) $gaSet(comDls4)" {
    RLSerial::Open $com
  }
  RLTime::Delay 1
  foreach {com link} "$gaSet(comDls1) 1 $gaSet(comDls2) 2 $gaSet(comDls3) 3 $gaSet(comDls4) 4" {
    if {$link > $dslNum} {
      break
    }
    RLSerial::Send $com "\n"
    RLSerial::Send $com "*ESR?\n"
#     set ret [RLSerial::Send $com "\n:set:chan:len?\n" buffer "FT" 3]
#     puts "setline before: link:$link inRange:$inRange ret:$ret ,  buffer:$buffer"
#     update
#     if {$ret!=0} {
#       set ret [RLSerial::Send $com "\n:set:chan:len?\n" buffer "FT" 3]
#       puts "setline before: link:$link inRange:$inRange ret:$ret ,  buffer:$buffer"
#       update
#       if {$ret!=0} {
#         set gaSet(fail) "Unable to set $inRange Ft at link $link"
#         break
#       }
#     }
# 
#     if {$inRange==[lindex $buffer 0]} {
#       puts "setline  $inRange==[lindex $buffer 0]"
#       update
#     }

    RLSerial::Send $com "\n:set:chan:len $inRange ft\n"
#     Status "Change the range of link $link to $inRange Ft"
    RLTime::Delay 1
    set ret [RLSerial::Send $com "\n:set:chan:len?\n" buffer "$inRange FT" 3]
    puts "setline link:$link inRange:$inRange ret:$ret ,  buffer:$buffer"
    update

    if {$ret!=0} {
#       Status "Change the range of link $link to $inRange Ft"
      RLTime::Delay 1    
      RLSerial::Send $com "\n:set:chan:len $inRange ft\n"
#       Status "Change the range of link $link to $inRange Ft"
      RLTime::Delay 1
      set ret [RLSerial::Send $com "\n:set:chan:len?\n" buffer "$inRange FT" 3]
      puts "setline link:$link , inRange:$inRange , ret:$ret , buffer:$buffer"
      update
      if {$ret!=0} { 
        set gaSet(fail) "Unable to set $inRange Ft at link $link"
		    break
      } 
    }
  }  
  foreach {com} "$gaSet(comDls1) $gaSet(comDls2) $gaSet(comDls3) $gaSet(comDls4)" {
    RLSerial::Close $com
  }
  return $ret
}


#***************************************************************************
#** SetLineType -- 
#**
#** Abstract:
#**
#** Inputs:
#** Outputs:
#** Returned code:
#***************************************************************************
proc SetLineType {} {
  global gaSet gaGui
  $gaGui(dlsTypeA) configure -text " Line 1 : $gaSet(dlsLine1) "
  #$gaGui(dlsTypeB) configure -text " Line 2 : $gaSet(dlsLine2) "
  update
  SaveInit
}

# ***************************************************************************
# SetLine6700
# ***************************************************************************
proc SetLine6700 {inRange} {
  global gaSet buffer
  set com $gaSet(comDls1)
  #catch {RLCom::Close $com}
  #RLTime::Delay 1
  RLSerial::Open $com
  RLTime::Delay 1
  foreach port "$gaSet(ls4_1) $gaSet(ls4_2)" {
    Status "SetLine6700 port:$port to $inRange FT" ; update  
    for {set i 1} {$i <= 20} {incr i} {
      if {$gaSet(act)==0} {set ret -2; break}
      RLSerial::Send $com "\n"
      RLSerial::Send $com "*ESR?\n"    
      RLSerial::Send $com "\n:set:chan:line $port,$inRange ft\n"
      #Wait "Change the range of port $port to $inRange Ft. $i" 1 white
      #puts "Change the range of port $port to $inRange Ft. $i"
      RLTime::Delay 1
      set ret [RLSerial::Send $com "\n:set:chan:line ?\n" buffer "$inRange FT" 3]
      puts "setline DLS6700 port:$port inRange:$inRange ret:$ret $i,  buffer:$buffer"
      update
      if {$ret==0} {break}
    }
    if {$ret!=0} { 
      set gaSet(fail) "Unable to set $inRange Ft at port $port"
      break
    }  
    if {$gaSet(wire)=="2"} {
      # Link 2 will be disconnected
      set inRange 24000
    }
  }      
  
  RLSerial::Close $com
  return $ret
}

#***************************************************************************
#** SetLine6700rsd
#***************************************************************************
proc SetLine6700rsd {inRange } {
  #return 0
  global gaSet buffer
 	
  set com $gaSet(comDls1)
  foreach link "1 2 3 4" port "$gaSet(ls4_1) $gaSet(ls4_2) $gaSet(ls4_3) $gaSet(ls4_4)" {
    for {set i 1} {$i <= 10} {incr i} { 
      RLSerial::Send $com "\n"
      RLSerial::Send $com "*ESR?\n"    
      #after 2000
      RLSerial::Send $com "\n:set:chan:line $port,$inRange ft\n"
      #after 2000
      set ret [RLSerial::Send $com "\n:set:chan:line ?\n" buffer "$port,$inRange FT" 1]
      puts "setline link:$link port:$port inRange:$inRange ret:$ret , buffer:<$buffer>"
      update
      #after 500
      if {$ret==0} {break}  
    }
    if {$ret!=0} { 
      set gaSet(fail) "Unable to set $inRange Ft at link $link"
      break
    }     
    if {$gaSet(wire)=="2"} {
      # Links 2,3,4 will be disconnected
      set inRange 24000
    }
    if {$gaSet(wire)=="4" && $link==2} {
      # Links 3,4 will be disconnected
      set inRange 24000
    }
    
  }  
  return $ret
}
