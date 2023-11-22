#***************************************************************************
#** UUTsReboot
#***************************************************************************
proc UUTsReboot {} {
  global gaSet buffer
  set ret [UUTsIsUp]
  if {$ret==0} {return 0}
  set ret [Wait "UUTs are Rebooting..." 5 white]
  if {$ret!=0} {return $ret}
  set ret [UUTsUp]
  if {$ret!=0} {return $ret}  
  return $ret
}
# ***************************************************************************
# UUTsIsUp
# ***************************************************************************
proc UUTsIsUp {} {
  global gaSet
  set res1 [UUTIsUp Uut1]
  set res2 [UUTIsUp Uut2]
  puts "UUTsIsUp res1:$res1  res2:$res2"
  if {$res1==0 && $res2==0} {
    return 0
  } else {
    return -1
  }    
}
# ***************************************************************************
# UUTIsUp
# ***************************************************************************
proc UUTIsUp {uut} {
  global gaSet buffer
  puts "UUTIsUp $uut"
  if {$gaSet(act)==0} {return -2}
  Send $gaSet(com$uut) "\r" "exit" 1
  if {[string match {*-exit*} $buffer]} {
    Send $gaSet(com$uut) "!" "tilities"
    set ret 0
  } else {
    set ret -1
  }
  puts "UUTIsUp $uut ret:$ret"
  return $ret
}

# ***************************************************************************
# UUTsUp
# ***************************************************************************
proc UUTsUp {} {
  global gaSet
  if {$gaSet(act)==0} {return -2}
  set ret [UUTup Uut1]
  if {$ret!=0} {return $ret}
  set ret [UUTup Uut2]
  if {$ret!=0} {return $ret}
  return $ret
}
# ***************************************************************************
# UUTup
# ***************************************************************************
proc UUTup {uut} {
  global gaSet buffer
  puts "UUTup $uut"
  set com $gaSet(com$uut) 
  set gaSet(fail) "Config of $uut fail"
  set ret [Send $com "\r" "lities" 1]
  if {$ret==0} {
    return $ret
  }
  if {[string match {*-exit*} $buffer]} {
    set ret [Send $com "!" "lities"]
    return $ret
  }
  
  if {[string match {*PASSWORD:*} $buffer]} {
    Send $com \33 "PASSWORD:"
    set ret [Send $com su\r1234\r "lities"]
    return $ret
  }
  if {[string match {*boot*} $buffer] || [string match {*\^\[*} $buffer]} {
    set ret [Send $com @\r "Loading"]
    if {$ret!=0} {return $ret}
    set ret [Wait "Wait for $uut booting.." 30 white]
    if {$ret!=0} {return $ret}
  }
  if {[string match {*Select:*} $buffer]} {
    set ret [Send $com 0 "Loading"]
    if {$ret!=0} {return $ret}
    set ret [Wait "Wait for $uut booting.." 30 white]
    if {$ret!=0} {return $ret}
  }
  if {[string match {(Y/N/C) } $buffer]} {
    Send $com n "stam" 0.5
    set ret [Send $com "!" "lities"]
    return $ret
  }
  
  set ret [5EntersLoop $uut]
  if {$ret==0} {return 0}
  
  Status "$uut is coming up"
  set ret [MyWaitFor $com "PASSWORD" 2.5 30]
  puts "UUTup $uut ret of MyWaitFor: $ret"
  if {$ret==0} {
    Send $com \r\33 stam 1
    if {[string match {*PASSWORD:*} $buffer]} {
      Send $com \33 "PASSWORD:"
      set ret [Send $com su\r1234\r "exit"]
      if {$ret!=0} {
        set ret [5EntersLoop $uut]
      }
    }    
  } else {
    set ret [5EntersLoop $uut]
  }     
  return $ret      
}
# ***************************************************************************
# 5EntersLoop
# ***************************************************************************
proc 5EntersLoop {uut} {
  global gaSet buffer
  set com $gaSet(com$uut)
  puts "5EntersLoop $uut $com" 
  set gaSet(fail) "Config of $uut fail"
  for {set i 1} {$i <= 7} {incr i} {
    Send $com \r stam 2
    if {[string match {*PASSWORD*} $buffer]} {
      set ret [Send $com su\r1234\r "exit"]
      break   
    } elseif {[string match {*Select:*} $buffer]} {
      set ret [Send $com 0 "Loading"]  
      if {[string match {*No active partition selected yet*} $buffer]} {
        set ret 0
        break
      }    
    } elseif {[string match {*exit*} $buffer]} {
      set ret 0     
      break
    } elseif {[string match {*\[boot\]:*} $buffer]} {
      set ret [Send $com @\r "Loading"]
      if {$ret!=0} {return $ret}
      set ret [Wait "Wait for $uut booting.." 30 white]
      if {$ret!=0} {return $ret}     
      #break
    } else {
      set ret -1
    } 
  }
  return $ret
}

# ***************************************************************************
# BootMenu
# ***************************************************************************
proc BootMenu {uut} {
  global gaSet buffer
  Status "Entire to Boot Menu of $uut"
#   set ret [Reset2BootMenu $uut]
#   if {$ret!=0} {return $ret}
  Power $uut off
  RLTime::Delay 2
  Power $uut on
  set res -1
  for {set i 1} {$i <= 10} {incr i 1} {   
    if {$gaSet(act)==0} {return -2} 
    if {$res == -1} {
      for {set k 1} {$k <= 5} {incr k 1} {    
        if {$gaSet(act)==0} {return -2}
#         set res [RLSerial::Send $gaSet(com$uut) "\r" buffer "\[boot" 0.5]
        set res [RLSerial::SendSlow $gaSet(com$uut) \r 50 buffer "\[boot" 0.5]
        puts "1i:$i k:$k res:$res buffer:<$buffer>"; update
        if {$res==0} {
          set res [RLSerial::SendSlow $gaSet(com$uut) \r 50 buffer "\[boot" 0.5]
          puts "1i:$i k:$k res:$res buffer:<$buffer>"; update
          break
        }
      }  
    }  
  }
  
  if {$res == -1} {
    Power $uut off
    RLTime::Delay 2
    Power $uut on
    set res -1
    for {set i 1} {$i <= 10} {incr i 1} {   
      if {$gaSet(act)==0} {return -2} 
      if {$res == -1} {
        for {set k 1} {$k <= 5} {incr k 1} {    
          if {$gaSet(act)==0} {return -2}
          #set res [RLSerial::Send $gaSet(com$uut) "\r" buffer "\[boot" 0.5]
          set res [RLSerial::SendSlow $gaSet(com$uut) \r 50 buffer "\[boot" 0.5]
          puts "2i:$i k:$k res:$res buffer:<$buffer>"; update
          if {$res==0} {
            break
          }
        }
      }  
    }
  }
          
  if {$res == -1} {
    set gaSet(fail) "$uut - Failed to Get Boot Menu"
    return -1		    
  }
  return 0
}  
# ***************************************************************************
# ReadBootVers
# ***************************************************************************
proc ReadBootVers {uut} { 
  global gaSet buffer
  Status "Read Boot Vers of $uut"
  if {[Send $gaSet(com$uut) "\r" "\[boot" 0.2] == 0} {
    Send $gaSet(com$uut) "v\r" "\[boot" 1
    set gaSet(bootScreen$uut) $buffer
    Send $gaSet(com$uut) "dir\r" "\[boot" 1
    append gaSet(bootScreen$uut) $buffer
    Send $gaSet(com$uut) "@\r" "stam" 0.1
  } else {
    set gaSet(fail) "$uut - Failed to Get Boot Version"
  	return -1		    
  }       
  
  return 0
}
# ***************************************************************************
# IDtest
# ***************************************************************************
proc IDtest {uut} {
  global gaSet buffer 
  set gaSet(fail) "Config of $uut fail"
  puts "IDtest $uut"
  set com $gaSet(com$uut)
  
  #set res [regexp {Boot-Manager version:\s+([\d\.]+)\s} $gaSet(bootScreen$uut) - val]
  set res [regexp {Boot[-\s]?[mM]anager version:?\s+([\d\.]+)\s} $gaSet(bootScreen$uut) - val]
  if {$res==0} {
    set gaSet(fail) "Boot Manager version reading of $uut fail"
    AddToLog $gaSet(fail)
    return -1
  }
  if {$val!=$gaSet(bootMngr)} {
    set gaSet(fail) "Boot Manager version of $uut is \'$val\'. Should be $gaSet(bootMngr)"
    AddToLog $gaSet(fail)
    return -1
  }
  
  set res [regexp {Boot version:?\s+([\d\.]+)\s} $gaSet(bootScreen$uut) - val]
  if {$res==0} {
    set gaSet(fail) "Boot version reading of $uut fail"
    AddToLog $gaSet(fail)
    return -1
  }
  if {$val!=$gaSet(bootVer)} {
    set gaSet(fail) "Boot version of $uut is \'$val\'. Should be $gaSet(bootVer)"
    AddToLog $gaSet(fail)
    return -1
  }
  
  
#   set res [regexp {(partition 3[\s\w\d\(\)\:\!\.\_\-\=]+)\#} $gaSet(bootScreen$uut) - p3]
#   if {$res==0} {
#     set gaSet(fail) "Partition 3 reading of $uut fail"
#     AddToLog $gaSet(fail)
#     return -1
#   }
#   if ![string match *empty* $p3] {
#     set gaSet(fail) "The Partition 3 of $uut is not empty"
#     puts $p3
#     AddToLog $gaSet(fail)
#     AddToLog $p3
#     return -1
#   }
  
  set ret [UUTIsUp $uut]
  if {$ret!=0} {
    set ret [UUTup $uut]
    if {$ret!=0} {return $ret}
  }
  set ret [DebugMainMenu  $uut]
    if {$ret!=0} {return $ret}
  Status "$uut identification..."
  
  set ret [Send $com "1\r" "exit"]
  if {$ret!=0} {return $ret}
  
  set res [regexp {\s+([\w\-\s]+)\s+Device} $buffer - val]
  if {$res==0} {
    set gaSet(fail) "Device Type reading of $uut fail"
    AddToLog $gaSet(fail)
    return -1
  }
  ## the ph3.5 device has name 'Asmi 54'. Therefor I cut from "Asmi 54N" the N
  ## all the rest products are not affected from the trimright
  set uutN [string trimright $gaSet(uut) N]
  if {$val!=$uutN} {
    set gaSet(fail) "Device Type of $uut is \'$val\'. Should be $uutN"
    AddToLog $gaSet(fail)
    return -1
  }
  
  set res [regexp {\s+([\w\-\.]+)\s+4001} $buffer - val]
  if {$res==0} {
    set gaSet(fail) "HW version reading of $uut fail"
    AddToLog $gaSet(fail)
    return -1
  }
  if {$val!=$gaSet(hw)} {
    set gaSet(fail) "HW version of $uut is \'$val\'. Should be \'$gaSet(hw)\'"
    AddToLog $gaSet(fail)
    return -1
  }
  
  
  
  
#   set res [regexp {FPGA version[\s\.]+\(([\.\w]+)\)} $buffer - val]
#   if {$res==0} {
#     set gaSet(fail) "FPGA version reading of $uut fail"
#     AddToLog $gaSet(fail)
#     return -1
#   }
#   if {$val!=$gaSet(fpga)} {
#     set gaSet(fail) "FPGA version of $uut is \'$val\'. Should be \'$gaSet(fpga)\'"
#     AddToLog $gaSet(fail)
#     return -1
#   }
  
  if {[string match *.R.tcl $gaSet(DutInitName)]==1 || [string match *.R.HWRev*.tcl $gaSet(DutInitName)]==1} {
    ## phase 3.5 double PS, ASMI-54.4ETH.8W.D.R.tcl
    ## jump to lower line of Inventory to see all 4 SHDSL
    set ret [Send $com "g 11,1\r" "exit" 2]
  }
  set res [regexp -all {(Shdsl|SHDSL) Line} $buffer]
  if {$res==0} {
    set gaSet(fail) "Shdsl Line reading of $uut fail"
    AddToLog $gaSet(fail)
    return -1
  }
  set pairQty [expr {$gaSet(wire) / 2}]
  if {$res!=$pairQty} {
    set gaSet(fail) "Shdsl of $uut is [expr {2 * $res}] wire. Should be $gaSet(wire) wire"
    AddToLog $gaSet(fail)
    return -1
  }
  
  set res [regexp -all {Fast Eth Port} $buffer]
  if {$res==0} {
    set gaSet(fail) "Fast Eth Port reading of $uut fail"
    AddToLog $gaSet(fail)
    return -1
  }
  if {$gaSet(eth)=="1NULL3UTP" || $gaSet(eth)=="2NULL2UTP"} {
    set dutEth 4
  } else {
    set dutEth $gaSet(eth)
  }
  if {$res!=$dutEth} {
    set gaSet(fail) "$uut has $res Fast Eth Port/s. Should have $dutEth port/s"
    AddToLog $gaSet(fail)
    return -1
  }
  
  if {[string match *.R.tcl $gaSet(DutInitName)]==1} {
    ## phase 3.5 double PS, ASMI-54.4ETH.8W.D.R.tcl
    set res [regexp {Supply 1\s+(\w+)\s+Power} $buffer - val]
    if {$res==0} {
      set gaSet(fail) "Power Supply 1 reading of $uut fail"
      AddToLog $gaSet(fail)
      return -1
    }
    if {$val!=$gaSet(ps)} {
      set gaSet(fail) "Power Supply 1 of $uut is \'$val\'. Should be \'$gaSet(ps)\'"
      AddToLog $gaSet(fail)
      return -1
    }
    
    set res [regexp {Supply 2\s+(\w+)\s+Power} $buffer - val]
    if {$res==0} {
      set gaSet(fail) "Power Supply 2 reading of $uut fail"
      AddToLog $gaSet(fail)
      return -1
    }
    if {$val!=$gaSet(ps)} {
      set gaSet(fail) "Power Supply 2 of $uut is \'$val\'. Should be \'$gaSet(ps)\'"
      AddToLog $gaSet(fail)
      return -1
    }
  } else {
    set res [regexp {Supply\s+(\w+)\s+Power} $buffer - val]
    if {$res==0} {
      set gaSet(fail) "Power Supply reading of $uut fail"
      AddToLog $gaSet(fail)
      return -1
    }
    if {$val!=$gaSet(ps)} {
      set gaSet(fail) "Power Supply of $uut is \'$val\'. Should be \'$gaSet(ps)\'"
      AddToLog $gaSet(fail)
      return -1
    }
  }
  
  set ret [Send $com "g 1,8\r" "exit" 2]
  set res [regexp {\[7m([\w\.]+)\s\[m} $buffer - val]
  if {$res==0} {
    set gaSet(fail) "SW version reading of $uut fail"
    AddToLog $gaSet(fail)
    return -1
  }
  if {$val!=$gaSet(sw)} {
    set gaSet(fail) "SW version of $uut is \'$val\'. Should be \'$gaSet(sw)\'"
    AddToLog $gaSet(fail)
    return -1
  }
  
  set ret [Send $com "g 1,1\r" "exit" 2] ; ## jump to left-upper corner
  set b $buffer
  set ret [Send $com "\x04" "exit" 2] ; ## Ctrl+D , jump to left-lower corner
  append b $buffer
  set buffer $b

  set res [regexp -all {E1 port} $buffer]
  if {$gaSet(e1)=="NA" && $res!=0} {
    set gaSet(fail) "E1 Port of $uut appears, but should not"
    AddToLog $gaSet(fail)
    return -1
  }
  if {$gaSet(e1)!="NA"} {
    if {$res==0} {
      set gaSet(fail) "E1 Port reading of $uut fail"
      AddToLog $gaSet(fail)
      return -1
    }
    if {$res!=$gaSet(e1)} {
      set gaSet(fail) "$uut has $res E1 Port/s. Should have $gaSet(e1) port/s"
      AddToLog $gaSet(fail)
      return -1
    }
  }
  
  set ret [Send $com "\33" "ext" 1] 
  if {[regexp {(\d).[ ]+Debug} $buffer - res] != 1} {
    set gaSet(fail) "$uut - Failed to get Debug Menu"
    return -1
  }
  Send $com "$res\r" "ESCc" 1
  
  set res [regexp {Box Type \((\w+)\s} $buffer - val]
  if {$res==0} {
    set gaSet(fail) "Box type reading of $uut fail"
    AddToLog $gaSet(fail)
    return -1
  }
  if {$val!=$gaSet(box)} {
    set gaSet(fail) "Box type of $uut is \'$val\'. Should be \'$gaSet(box)\'"
    AddToLog $gaSet(fail)
    return -1
  }
  
  set gaSet(fail) "Read ETH ports status fail"
  set ret [Send $com "!" "tilities"] 
  set ret [Send $com "3\r" "pplication"]
  if {$ret!=0} {return $ret}
  if {$gaSet(dutFam)=="f35"} {
    set ret [Send $com "1\r" "and Time"]
  } elseif {$gaSet(dutFam)!="f35"} {
    set ret [Send $com "1\r" "Log"]
  }
  if {$ret!=0} {return $ret}
  set ret [Send $com "1\r" "Refresh Table"]
  if {$ret!=0} {return $ret}
  set ethUpQty [regexp -all {Fast Eth Up Up} $buffer]
  puts "ethUpQty:$ethUpQty dutEth:$dutEth"
  if {$ethUpQty!=$dutEth} {
    set gaSet(fail) "Not all $dutEth ETH ports of $uut are UP"
    AddToLog $gaSet(fail)
    return -1
  }
  
  
  set ret [ReadMac $uut]
  if {$ret!=0} {return $ret}    
  
  Status ""
  return 0
}
# ***************************************************************************
# ReadMac    00-20-D2-50-FD-84
# ***************************************************************************
proc ReadMac {uut} {
  global gaSet buffer
  set gaSet(fail) "Config of $uut fail"
  Status "Read MAC at $uut (pair $::pair)"
  set ret [UUTIsUp $uut]
  if {$ret!=0} {
    set ret [UUTup $uut]
    if {$ret!=0} {return $ret}
  }
  set com $gaSet(com$uut)
  set ret [Send $com "!" "exit"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "3\r" "exit"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "1\r" "ext"]
  #if {$ret!=0} {return $ret}
  
  set mac 00-00-00-00-00-00
  regexp {MAC Address\s+\(([\w\-\:]+)\)} $buffer - mac
  if [string match *:* $mac] {
    set mac [join [split $mac :] ""]
  }
  set mac1 [join [split $mac -] ""]
  set mac2 0x$mac1
  puts "mac1:$mac1" ; update
  set min1 0x0020D2200000
  set max1 0x0020D2EFFFFF
  set minT1 00-20-D2-20-00-00
  set maxT1 00-20-D2-EF-FF-FF
  set min2 0x1806F5000000
  set max2 0x1806F5FFFFFF
  set minT2 18-06-F5-00-00-00
  set maxT2 18-06-F5-FF-FF-FF

  if {($mac2<$min1 || $mac2>$max1) && ($mac2<$min2 || $mac2>$max2)} {
    set gaSet(fail) "The MAC of $uut is $mac. It's out of range ${minT1}-${maxT1} or ${minT2}-${maxT2}"
    AddToLog $gaSet(fail)
    return -1
  }
  set gaSet(${::pair}.mac$uut) $mac1
  set logFileID [open tmpFiles/logFile-$gaSet(pair).txt a+]
  puts $logFileID "MAC of $uut: $mac1"
  close $logFileID  
  
  return 0
}

# ***************************************************************************
# FactDefault
# ***************************************************************************
proc FactDefault {uut} {
  global gaSet buffer
  set gaSet(fail) "Config of $uut fail"
  puts "FactDefault $uut" 
  set ret [UUTIsUp $uut]
  if {$ret!=0} {
    set ret [UUTup $uut]
    if {$ret!=0} {return $ret}
  }
  Status "$uut Factory Default"
  set com $gaSet(com$uut)
  Send $com "\r" "ext" 1
  if {[regexp {(\d).[ ]+Configuration} $buffer - res] != 1} {
    set gaSet(fail) "$uut - FactoryDefault Fail - Failed to get Configuration Menu"
    return -1
  }
  Send $com "$res\r" "ESCcc" 1
  if {[regexp {(\d).[ ]+System} $buffer - res] != 1} {
    set gaSet(fail) "$uut - FactoryDefault Fail - Failed to get System Menu"
    return -1
  }
  Send $com "$res\r" "ESCcc" 1  
  if {[regexp {(\d).[ ]+Factory Defaults} $buffer - res] != 1} {
    set gaSet(fail) "$uut - FactoryDefault Fail - Failed to get Factory Default Menu"
    return -1
  }
  Send $com "$res\r" "(Y/N)" 2
  
  if {$gaSet(dutFam)=="54"} {
    set anchWord Decompressing
  } else {
    set anchWord Instantiating
  }   
  if {[Send $gaSet(com$uut) "y" "$anchWord" 60]!= 0} {
    set gaSet(fail) "$uut - FactoryDefault Fail - Failed to Perform Factory Default"
    return -1
  }
	return 0
}
  

# ***************************************************************************
# WaitForSync
# ***************************************************************************
proc WaitForSync {uut tcLayer} {
  global gaSet buffer
  set com $gaSet(com$uut)
  puts "[MyTime] Wait for synchronization $uut $tcLayer" 
  set ret [UUTIsUp $uut]
  if {$ret!=0} {
    set ret [UUTup $uut]
    if {$ret!=0} {return $ret}
  }
  Status "Wait for synchronization"
  if {$gaSet(dutFam)=="LRT"} {
    set syncTime 420
  } else {
    set syncTime 210
  }
  
  set ret -1
  set secStart [clock seconds]
  for {set i $syncTime} {$i > 0} {incr i -1} {
    if {$gaSet(act)==0} {return -2}	 
    
    set secNow  [clock seconds]
    set runTime [expr $secNow - $secStart]
    $gaSet(runTime) configure -text $runTime
    update	 
  
    Send $com 3\r Application
    Send $com 1\r Time
    Send $com 1\r "Refresh Table" ; #"Bridge Port"
    if {$gaSet(dutFam)=="L" || $gaSet(dutFam)=="LRT"} {
      set remShdslQty [regexp -all {Rem SHDSL Port} $buffer]
    } elseif {$gaSet(dutFam)=="f35" || $gaSet(dutFam)=="54"} {
      set remShdslQty [regexp -all {SHDSL Port [\d] Multirate HDSL2 Up Up} $buffer]     
    }
    puts "runTime:$runTime remShdslQty:$remShdslQty" ; update
    
    if {[Send $com "!" "tilities"]!=0} {
      set gaSet(fail) "There is no communication with $uut"
      return -1
    }
    if {$gaSet(act)==0} {return -2}
    
    if {$tcLayer=="HDLC"} {
      if {$remShdslQty==1} {set ret 0; break}
    } else {
      switch -exact -- $gaSet(wire) {
        2 {if {$remShdslQty==1} {set ret 0; break}}
        4 {if {$remShdslQty==2} {set ret 0; break}}
        8 {if {$remShdslQty==4} {set ret 0; break}}
      } 
    }
    if {$runTime>$syncTime} {
      set ret -1
      break
    }
    after 2000
  }  
  if {$ret==0} {
    $gaSet(runTime) configure -text ""
    Status "" white
  } else {
    set gaSet(fail) "The syncronization fail"
  }
  return $ret
}



# ***************************************************************************
# CopyLic
# ***************************************************************************
proc CopyLic {unit com} {
  global gaSet buffer 
  puts "CopyLic $unit $com" 
  set ret [UUTIsUp $unit $com]
  if {$ret!=0} {
    set ret [UUTup $unit $com]
    if {$ret!=0} {return $ret}
  }
  Status "$unit Copy License"
  set gaSet(fail) "Config of $unit fail"
  
  set ret [Send $com "file copy tftp://1.1.1.1/LIC_$gaSet(${::pair}.mac$unit).txt license\r" "license downloaded"]
  if {$ret!=0} {
    set gaSet(fail) "The new license isn't downloaded"
    return $ret
  }
  Send $com "configure system\r" system#
  Send $com "show license\r" stam 1
  set enQty [regexp -all {Flows\s+Enable} $buffer]
  if {$enQty!=1} {
    set gaSet(fail) "There is some feature disabled"
    set ret -1 
  }
  return $ret
}  
# ***************************************************************************
# SaveUDF
# ***************************************************************************
proc SaveUDF {unit com} {
  global gaSet buffer 
  puts "SaveUDF $unit $com" 
  set ret [UutIsUp $unit $com]
  if {$ret!=0} {
    set ret [UUTup $unit $com]
    if {$ret!=0} {return $ret}
  }
  set gaSet(fail) "Config of $unit fail"
  Status "$unit Save User Default File"
  set ret [Send $com "file copy running-config user-default-config\r" 10#]
  if {$ret==0} {
    Send $com "file dir\r" file#
  }
  return $ret
}
# ***************************************************************************
# Reset2BootMenu
# ***************************************************************************
proc Reset2BootMenu {uut} {
  global gaSet buffer 
  Status "Enter to Boot Menu of $uut .."
  set ret [Send $gaSet(com$uut) \r "Boot Prompt" 1]
  if {$ret!=0} {
    set ret [UUTup $uut]
    if {$ret!=0} {return $ret}  
    Send $gaSet(com$uut) "2\r" "ESC"
    Send $gaSet(com$uut) "1\r" "ESC"
    if {[regexp {(\d).[ ]+Reset device} $buffer match res] != 1} {
      set gaSet(fail) "$uut - Reset device Fail"
      return -1
    }
    Send $gaSet(com$uut) "$res\r" "rebooting" 
    
    set ret -1        
    for {set i 1} {$i <= 20} {incr i 1} {    
      if {$ret == -1} {
        set ret [Send $gaSet(com$uut) "\r" "Boot Prompt" 0.1]
      }    
    }
  }
  if {$ret!=0} {
    set gaSet(fail) "Failed to Get Boot Menu in $uut"
  }
  return $ret   
}
# ***************************************************************************
# FormatFlash
# ***************************************************************************
proc FormatFlash {uut} {
  global gaSet buffer 
  puts "FormatFlash $uut" 
  
  Status "Formating all partitions on $uut .."
  
  set ret [BootMenu $uut]
  if {$ret == -1} {
    set gaSet(fail) "$uut - Failed to Get Boot Menu"
    return -1		    
  }
  set res [Send $gaSet(com$uut) "\r" "\[boot" ]        
  if {$res == -1} {
    set gaSet(fail) "$uut - Failed to Get Boot Menu"
    return -1		    
  }
  set ret [Send $gaSet(com$uut) "format all\r" y/n]
  if {$ret == -1} {
    set gaSet(fail) "$uut - Failed to Format Flash"
    return -1		    
  }
  set ret [Send $gaSet(com$uut) "y\r" "Segment"]  
  if {$ret!=0} {
    set gaSet(fail) "$uut - Failed to Format All"   
    return $ret     
  }  
  #set ret [Send $gaSet(com$uut) "\r\r" "\[boot" ]       
  return $ret
}    
    
# ***************************************************************************
# LoadAppl
# ***************************************************************************
proc LoadAppl {uut applfile fil} {
  global gaSet buffer 
  puts "LoadAppl $uut $applfile $fil"    
  Status "$uut Load Application" 
  set gaSet(fail) "Config of $uut fail"
  
  set com $gaSet(com$uut)
  set unit [string index $uut end]
  set ip 1.1.1.[set gaSet(pair)][set unit]
  set pa c:/download/temp/[set gaSet(pair)][set uut]_[file tail $applfile]
  puts "LoadAppl pa:$pa"
  file copy -force $gaSet($fil) $pa
  
  set ret [BootMenu $uut]
  if {$ret!=0} {return $ret}
  
  if {$gaSet(dutFam)=="f35" || $gaSet(dutFam)=="LRT"} {
    set ret [ConfigBoot4Dwnl $uut]
    if {$ret!=0} {return $ret}
  } else {
    set ret [Send $com "c g\r" "stam" 0.5]
    set ret [Send $com "1.1.1.1\r" ":" 1]
    if {$ret!=0} {
      set gaSet(fail) "$uut - Config gateway IP fail"
      return $ret
    }
      
    set ret [Send $com "c dm\r" "stam" 0.5]
    set ret [Send $com "255.255.255.0\r" "\[boot" 1]
    if {$ret!=0} {
      set gaSet(fail) "$uut - Config device IP fail"
      return $ret
    }
    
    set ret [Send $com "c ip\r" "stam" 0.5]
    set ret [Send $com "$ip\r" "\[boot" 1]
    if {$ret!=0} {
      set gaSet(fail) "$uut - Config device IP fail"
      return $ret
    }
    
    set ret [Send $com "c sip\r" "stam" 0.5]
    set ret [Send $com "1.1.1.1\r" ":" 1]
    if {$ret!=0} {
      set gaSet(fail) "$uut - Config server IP fail"
      return $ret
    }
    
    set ret [Send $com "c p\r" "stam" 0.5]
    set ret [Send $com "tftp\r" ":" 1]
    if {$ret!=0} {
      set gaSet(fail) "$uut - Config TFTP fail"
      return $ret
    }
  }
   
  Status "Loading the app in $uut"
  set ret [Send $com "dl [file tail $pa]\r" "\[boot" 90]
  if {$ret!=0} {
    set gaSet(fail) "$uut - Download fail"
    return $ret
  }
  if [string match *Error* $buffer] {
    set gaSet(fail) "$uut - Download fail"
    return -1  
  }
  
  set ret [Send $com @\r "Starting" 10]
  if {$ret!=0} {
    set gaSet(fail) "$uut - Starting after download fail"
    return $ret
  }   
  file delete $pa
  return $ret
}

# ***************************************************************************
# LoadUserConf
# ***************************************************************************
proc LoadUserConf {uut} {
  global gaSet buffer
  puts "LoadUserConf $uut"
  set ret [UUTIsUp $uut]
  if {$ret!=0} {
    set ret [UUTup $uut]
    if {$ret!=0} {return $ret}
  }
  set gaSet(fail) "Config of uut fail"
  Status "uut Load User Configuration File"
  
  set pa c:/download/[set gaSet(pair)][set unit]_[file tail $gaSet(udf)]
  file copy -force $gaSet(udf) $pa
  
  set id [open $pa r]      
  after 1000
  while {[gets $id line] >= 0} {
    if {$gaSet(act)==0} {break}
    if {[string length $line]>1 && [string match *##* $line]==0} {
      Send $com "$line\r" UUT 3
    }
  }
  close $id  
  file delete $pa
  return $ret
}  

# ***************************************************************************
# ConfigUutsDsl
# ***************************************************************************
proc ConfigUutsDsl {stuC tcLayer rate {confType all}} {
  puts "[MyTime] ConfigUutsDsl $stuC $tcLayer $rate $confType"
	global gaSet buffer
  if {$gaSet(dutFam)=="L" || $gaSet(dutFam)=="LRT" || $gaSet(dutFam)=="54"} {
    if {$confType != "skipTcLayer"} {
      foreach {uut uutNum} {Uut1 1 Uut2 2} {
        set ret$uutNum [TcLayerCfg $uut $tcLayer]
        if {[set ret$uutNum] < 0} {
          RLTime::Delay 5
          set ret$uutNum [TcLayerCfg $uut $tcLayer]
          if {[set ret$uutNum] < 0} {
            return $ret
          }
        }    
      }
      if {$ret1 == 1 || $ret2 == 1} {
        set ret [Wait "Wait for Reset after TC-Layer/WireMode Configuration" 10]
        if {$ret!=0} {return $ret} 
      } 
    }
    if {$confType == "tcLayerOnly"} {
      return 0
    } 
  } elseif {$gaSet(dutFam)=="f35"} {
    ## do nothing
  }
    
  foreach {uut} {Uut1 Uut2} {
#     set ret [MainMenu $gaSet(com$uut)]
#     if {$ret != 0} {
#     		set gaSet(fail) "$uut - ConfigUutsDsl Fail - Failed to Get Main Menu"
#     		return $ret          
#     }     
    if {$gaSet(dutFam)=="L" || $gaSet(dutFam)=="LRT" || $gaSet(dutFam)=="54"} {
      if {$tcLayer=="HDLC"} {
        set ret [WireModeCfg $uut $gaSet(wire)]
        if {$ret != 0} {return $ret}
      }
    } elseif {$gaSet(dutFam)=="f35"} {
      ## do nothing
    }
    
    if {$stuC == $uut} {
      set stu Central
    } else {
      set stu Remote
    }
  
    set ret [StuCfg $uut $stu]
    if {$ret != 0} {return $ret}
    
    if {$stuC == $uut} {
      set ret [LineProbeRateCfg $uut $tcLayer $rate]
      if {$ret != 0} {return $ret}
    }
  }

  
	return 0
}

# ***************************************************************************
# TcLayerCfg
# ***************************************************************************
proc TcLayerCfg {uut tcLayer {type config}} {
	global gaSet buffer
  if {$gaSet(act)==0} {return -2}
  Status "TcLayerCfg $uut $tcLayer $type"
  set ret [GotoSetShdsl $uut]
  if {$ret!=0} {return $ret}

  if {[regexp {TC Layer[ ]+\((HDLC|64-65-octet)} $buffer match tcRes] != 1} {
    set gaSet(fail) "$uut - TcLayerCfg Fail - Failed to get TC Layer Menu"
    return -1
  }
  if {$tcRes != $tcLayer} {      
    if {$type == "config"} {
      if {[regexp {(\d).[ ]+TC Layer[ ]+\((HDLC|64-65-octet)} $buffer match res res1] != 1} {
        ##  if line-1 is not active (4 and 8 wire) after rate config,
        ## i just forward it to next (actually first) line
        Send $gaSet(com$uut) f stam 1
        if {[regexp {(\d).[ ]+TC Layer[ ]+\((HDLC|64-65-octet)} $buffer match res res1] != 1} {
          set gaSet(fail) "$uut - TcLayerCfg Fail - Failed to get TC Layer Menu"
          return -1
        }
      }
      if {$res1 != $tcLayer} {
        if {[Send $gaSet(com$uut) "$res\r" "proceed?" 3] != 0} {
          set gaSet(fail) "$uut - TcLayerCfg Fail - Failed to Configure TC Layer"
          return -1    
        }
        Send $gaSet(com$uut) "y" "exit" 
        if {$gaSet(dutFam)=="54"} {
          set ret [Send $gaSet(com$uut) "s" "Loading" 30]
        } else {
          set ret [Send $gaSet(com$uut) "s" "Instantiating" 30]
        }  
        if {$ret!=0} {
          set gaSet(fail) "$uut - TcLayerCfg Fail - Failed to Configure TC Layer"
          return -1 
        }
        return 1
      }
    } elseif {$type == "verify"} {
      set gaSet(fail) "$uut - TcLayerCfg Fail - Failed to Configure TC Layer to $tcLayer"
      return -1 
    }     
  }
  if {$gaSet(act)==0} {return -2}
  return 0    
}

# ***************************************************************************
# DslAdminStatus
# ***************************************************************************
proc DslAdminStatus {uut {type start}} {
  global gaSet buffer
  if {$gaSet(act)==0} {return -2}
  puts "[MyTime]"
  Status "DslAdminStatus $uut $type"
	if {$type == "start"} {
    set ret [UUTIsUp $uut]
    if {$ret!=0} {
      set ret [UUTup $uut]
      if {$ret!=0} {return $ret}
    }
    
    Send $gaSet(com$uut) "\r" "ESC" 2
    if {[regexp {(\d).[ ]+Configuration} $buffer match res] != 1} {
      set gaSet(fail) "$uut - DslAdminStatus Fail - Failed to get Configuration Menu"
      return -1
    }
    Send $gaSet(com$uut) "$res\r" "ESC" 2
    if {[regexp {(\d).[ ]+Physical Layer} $buffer match res] != 1} {
      set gaSet(fail) "$uut - DslAdminStatus Fail - Failed to get Physical Layer Menu"
      return -1
    }
    Send $gaSet(com$uut) "$res\r" "ESC" 2
    if {[regexp {(\d).[ ]+SHDSL} $buffer match res] != 1} {
      set gaSet(fail) "$uut - DslAdminStatus Fail - Failed to get SHDSL Menu"
      return -1
    }
    Send $gaSet(com$uut) "$res\r" "ESC" 2
    if {[regexp {(\d).[ ]+Local Port} $buffer match res] != 1} {
      set gaSet(fail) "$uut - DslAdminStatus Fail - Failed to get Local Port Menu"
      return -1
    }
    Send $gaSet(com$uut) "$res\r" "ESC" 2
  }
  Send $gaSet(com$uut) "\r" "ESC" 2
  set res ""
  set res1 ""
  regexp {(\d).[ ]+Administrative[ ]+[\w]+[ ]+\(SHDSL (UP|DOWN)} $buffer match res res1
  if {$res1 != "UP"} {  
    Send $gaSet(com$uut) "$res\r" "ESC" 2
    RLTime::Delay 3  
    Send $gaSet(com$uut) "\r" "ESC" 2
    if {[regexp {(\d).[ ]+DslAdminStatus[ ]+\(SHDSL (UP|DOWN)} $buffer match res res1] != 1} {
      set gaSet(fail) "$uut - DslAdminStatus Fail - Failed to config DSL Admin Status to UP"
      return -1
    }
  }
  if {$gaSet(act)==0} {return -2}
  return 0    
}

#*************************************************************************
#** StuCfg
#***********************************************************
proc StuCfg {uut stu} {
  global gaSet buffer 
  if {$gaSet(act)==0} {return -2}
  puts "[MyTime]"
  Status "StuCfg $uut $stu"
  set ret [GotoSetShdsl $uut]
  if {$ret!=0} {return $ret}
  Send $gaSet(com$uut) "\r" "(N)"
  foreach line {1 2 3 4} {
    puts "set line $line"; update
    
    if {[regexp {(\d).[ ]+STU[ ]+\((Central|Remote)} $buffer match res res1] != 1} {
      set gaSet(fail) "$uut - StuCfg Fail - Failed to get STU Mode Menu"
      return -1
    }
    if {$res1 != $stu} {  
      if {$gaSet(dutFam)=="L" || $gaSet(dutFam)=="LRT"} {
        Send $gaSet(com$uut) "$res\r" "stam" 0.5
        Send $gaSet(com$uut) "s" "stam" 0.5
      } elseif {$gaSet(dutFam)=="f35" || $gaSet(dutFam)=="LRT" || $gaSet(dutFam)=="54"} {
        Send $gaSet(com$uut) "$res\r" "(N)"
        Send $gaSet(com$uut) "s" "(N)"
      }
      if {[string match *(Y/N)* $buffer]} {
        set ret [Send $gaSet(com$uut) "y" "rebooting system" 25]
        if {$ret != 0} {
          set gaSet(fail) "$uut - StuCfg Fail - Failed to Configure STU Mode to $stu"
          return -1
        }    
      } else {
        set ret 0
      }
    } else {
      set ret 0
    }
    
    if {$gaSet(act)==0} {return -2}
    if {$gaSet(dutFam)=="L" || $gaSet(dutFam)=="LRT" || $gaSet(dutFam)=="54"} {
      break
    } elseif {$gaSet(dutFam)=="f35"} {
      Send $gaSet(com$uut) "f" "(N)" 2; #"Line Probe"
    }     
  }
  return $ret    
}

#*************************************************************************
#** WireModeCfg
#***********************************************************
proc WireModeCfg {uut wires} {
  global gaSet buffer
  if {$gaSet(act)==0} {return -2}
  Status "WireModeCfg $uut $wires"
  set ret [GotoSetShdsl $uut]
  if {$ret!=0} {return $ret}

  if {[regexp {Wire Mode[ ]+>[ ]+\((2|4|8)[ ]+Wire} $buffer match wireRes] != 1} {
    set gaSet(fail) "$uut - WireMode Fail - Failed to get Wire Mode Menu"
    return -1
  }
  if {$wireRes != $wires} {
    if {[regexp {(\d).[ ]+Wire Mode[ ]+>[ ]+\((2|4|8)[ ]+Wire} $buffer match lineRes wireRes] != 1} {
      set gaSet(fail) "$uut - WireMode Fail - Failed to get Wire Mode Line Number"
      return -1
    }
  }
  if {$wireRes != $wires} {
    Send $gaSet(com$uut) "$lineRes\r" "ESC" 
    if {$wires == 2} {
      Send $gaSet(com$uut) "1\r" "ESC" 
    } elseif {$wires == 4} {
      Send $gaSet(com$uut) "2\r" "ESC" 
    } elseif {$wires == 8} {
      Send $gaSet(com$uut) "3\r" "ESC" 
    }
    Send $gaSet(com$uut) "s" "ESC" 2
    if {[regexp {(\d).[ ]+Wire Mode[ ]+>[ ]+\((2|4|8)[ ]+Wire} $buffer match lineRes wireRes] != 1} {
      set gaSet(fail) "$uut - WireMode Fail - Failed to Configure Wire Mode"
      return -1
    }
    if {$wireRes != $wires} {
      set gaSet(fail) "$uut - WireMode Fail - Failed to Configure Wire Mode"
      return -1
    }
  }   
  if {$gaSet(act)==0} {return -2} 
  return 0    
}


#*************************************************************************
#** LineProbeRateCfg
#***********************************************************
proc LineProbeRateCfg {uut tcLayer rate} {
  global gaSet buffer
  if {$gaSet(act)==0} {return -2}
  puts "[MyTime]"
  set lineProbe disable
  Status "LineProbeRateCfg $uut $tcLayer $rate"
  set ret [GotoSetShdsl $uut]
  if {$ret!=0} {return $ret}
  Send $gaSet(com$uut) "\r" "(N)"
  foreach line {1 2 3 4} {
    puts "set line $line"; update    
    if {[regexp {(\d).[ ]+Line Probe[ ]+\((Enable|Disable)} $buffer match res res1] != 1} {
      set gaSet(fail) "$uut - LineProbeCfg Fail - Failed to get Line Probe Mode Menu"
      return -1
    }
    if {$res1 != "Disable"} {  
      Send $gaSet(com$uut) "$res\r" (N); #"kbps"
      Send $gaSet(com$uut) "s" (N); #"kbps"
      if {[regexp {(\d).[ ]+Line Probe[ ]+\((Enable|Disable)} $buffer match res res1] != 1} {
        set gaSet(fail) "$uut - LineProbeCfg Fail - Failed to get Line Probe Mode Menu"
        return -1
      }
      if {$res1 != "Disable"} {
        set gaSet(fail) "$uut - LineProbeCfg Fail - Failed to Configure Line Probe Mode to Disable"
        return -1
      }    
    }
    
#     if {[regexp {(\d).[ ]+Payload Rate} $buffer match res] != 1} {
#       Send $gaSet(com$uut) "n" "stam" 0.5 
#     }
    set exp "\\($rate"
    if {[regexp $exp $buffer match res] != 1} {
      if {[regexp {(\d).[ ]+Payload Rate} $buffer match res] != 1} {
        set gaSet(fail) "$uut - RateConfig Fail - Failed to get PayLoad Rate Menu"
        return -1    
      }
      Send $gaSet(com$uut) "$res\r" "\]" 
      Send $gaSet(com$uut) "$rate\r" "(N)"
      Send $gaSet(com$uut) "s" "(N)"
      if {[regexp $exp $buffer match res] != 1} {
        set gaSet(fail) "$uut - RateConfig Fail - Failed to Config PayLoad Rate to $rate"
        return -1
      } else {
        set ret 0
      }
    }
    if {$gaSet(act)==0} {return -2}
    if {($gaSet(dutFam)=="L" || $gaSet(dutFam)=="LRT" || $gaSet(dutFam)=="54") && $tcLayer=="HDLC"} {
      break  
    } else {
      if {$gaSet(wire)=="2" && $line=="1"} {
        break
      }
      if {$gaSet(wire)=="4" && $line=="2"} {
        break
      }
    }
    Send $gaSet(com$uut) "f" "(N)"
  }
  
  return 0    
}

#*************************************************************************
#** RateConfig
#***********************************************************
proc RateConfig {uut rate} {
  global gaSet buffer
  if {$gaSet(act)==0} {return -2}
  puts "[MyTime]"
  Status "RateConfig $uut $rate"
	Send $gaSet(com$uut) "\r" "ssttaamm" 1
  Send $gaSet(com$uut) "\r" "ssttaamm" 1
  if ![string match {*Configuration>Physical Layer>SHDSL>Line*} $buffer] {
    set ret [UUTIsUp $uut]
    if {$ret!=0} {
      set ret [UUTup $uut]
      if {$ret!=0} {return $ret}
    }
    Send $gaSet(com$uut) "\r" "tilities"
    if {[regexp {(\d).[ ]+Configuration} $buffer match res] != 1} {
      set gaSet(fail) "$uut - RateConfig Fail - Failed to get Configuration Menu"
      return -1
    }
    Send $gaSet(com$uut) "$res\r" "Applications"
    if {[regexp {(\d).[ ]+Physical Layer} $buffer match res] != 1} {
      set gaSet(fail) "$uut - RateConfig Fail - Failed to get Physical Layer Menu"
      return -1
    }
    Send $gaSet(com$uut) "$res\r" "SHDSL" 
    if {[regexp {(\d).[ ]+SHDSL} $buffer match res] != 1} {
      set gaSet(fail) "$uut - RateConfig Fail - Failed to get SHDSL Menu"
      return -1
    }
    Send $gaSet(com$uut) "$res\r" "Line"
    if {[regexp {(\d).[ ]+Local Port} $buffer match res] != 1} {
      set gaSet(fail) "$uut - RateConfig Fail - Failed to get Local Port Menu"
      return -1
    }
    Send $gaSet(com$uut) "$res\r" "stam" 0.5
  }
  Send $gaSet(com$uut) "\r" "stam" 0.5
  set exp "\\($rate"
  if {[regexp $exp $buffer match res] != 1} {
    if {[regexp {(\d).[ ]+Payload Rate} $buffer match res] != 1} {
      set gaSet(fail) "$uut - RateConfig Fail - Failed to get PayLoad Rate Mode Menu"
      return -1    
    }
    Send $gaSet(com$uut) "$res\r" "stam" 0.5 
    Send $gaSet(com$uut) "$rate\r" "stam" 0.5 
    if {[regexp $exp $buffer match res] != 1} {
      set gaSet(fail) "$uut - RateConfig Fail - Failed to Config PayLoad Rate to $rate"
      return -1
    }
  }
  if {$gaSet(act)==0} {return -2}
  return 0    
}

#*************************************************************************
#** ConfigUutsE1
# Looped    Transparent
#*********************************************************** 
proc ConfigUutsE1 {stuC ts ts0 masterClk} {
  puts "[MyTime] ConfigUutsE1 $stuC $ts $ts0 $masterClk"
	global gaSet buffer
  foreach {uut} {Uut1 Uut2} {
    if {$gaSet(act)==0} {return -2}
    Status "Config $uut E1 Port"    
    set ret [UUTIsUp $uut]
    if {$ret!=0} {
      set ret [UUTup $uut]
      if {$ret!=0} {return $ret}
    }
    Send $gaSet(com$uut) "\r" "tilities"
    if {[regexp {(\d).[ ]+Configuration} $buffer match res] != 1} {
      set gaSet(fail) "$uut - ConfigUutsE1 Fail - Failed to get Configuration Menu"
      return -1
    }
    Send $gaSet(com$uut) "$res\r" "pplications"
    if {[regexp {(\d).[ ]+Physical Layer} $buffer match res] != 1} {
      set gaSet(fail) "$uut - ConfigUutsE1 Fail - Failed to get Physical Layer Menu"
      return -1
    }
    Send $gaSet(com$uut) "$res\r" "SHDSL"
    if {[regexp {(\d).[ ]+E1} $buffer match res] != 1} {
      set gaSet(fail) "$uut - ConfigUutsE1 Fail - Failed to get Configuration Menu"
      return -1
    }
    Send $gaSet(com$uut) "$res\r" "Alarms"
    
    foreach line {1 2 3 4} {
      puts "set line $line"; update
      Send $gaSet(com$uut) "\r" "Alarms"
      if {[regexp {(\d).[ ]+Administrative Sta(.*)\(Up\)} $buffer match res res1] != 1} {
        regexp {(\d).[ ]+Administrative Sta} $buffer match res
        Send $gaSet(com$uut) "$res\r" "Alarms"
        Send $gaSet(com$uut) "s" "Alarms"
        if {[regexp {(\d).[ ]+Administrative Sta(.*)\(Up\)} $buffer match res res1] != 1} {      
          set gaSet(fail) "$uut - ConfigUutsE1 Fail - Failed to Configure E1 Admin Status to Up"
          return -1
        }
      }
      
      if {$gaSet(dutFam)=="L" || $gaSet(dutFam)=="54" || $gaSet(dutFam)=="LRT"} {
        Send $gaSet(com$uut) "\33" "SHDSL" 
        if {[regexp {(\d).[ ]+SHDSL} $buffer match res] != 1} {
          set gaSet(fail) "$uut - ConfigUutsE1 Fail - Failed to get SHDSL Menu"
          return -1
        }
        
        Send $gaSet(com$uut) "$res\r" "DS1"
        if {[regexp {(\d).[ ]+Internal DS1} $buffer match res] != 1} {
          set gaSet(fail) "$uut - ConfigUutsE1 Fail - Failed to get Internal DS1 Menu"
          return -1
        }
        Send $gaSet(com$uut) "$res\r" Mode
        set lastWord Mode
      } elseif {$gaSet(dutFam)=="f35"} {
        set lastWord Assignment
        
        if {$uut==$stuC && $masterClk!="-" && [string match *$masterClk* $buffer]==0} {
          if {[regexp {(\d).[ ]+Transmit} $buffer match res] != 1} {
            set gaSet(fail) "$uut - ConfigUutsE1 Fail - Failed to get Transmit Clock Menu"
            return -1
          }
          set gaSet(fail) "$uut - ConfigUutsE1 Fail - Failed to set Transmit Clock to $masterClk"
          Send $gaSet(com$uut) "$res\r" Time
          regexp "\(\\d\).\[ \]+$masterClk" $buffer match res
          Send $gaSet(com$uut) "$res\r" $lastWord
          set ret [Send $gaSet(com$uut) "s" "Alarms"]
          if {$ret!=0} {return $ret}
        }
      }
      
      if {[string match *$ts0* $buffer] != 1} {
        regexp {(\d).[ ]+TS0 Mode} $buffer match res
        Send $gaSet(com$uut) "$res\r" $lastWord
        Send $gaSet(com$uut) "s" $ts0
        if {[string match *$ts0* $buffer] != 1} {      
          set gaSet(fail) "$uut - ConfigUutsE1 Fail - Failed to Configure E1 TS0 mode to $ts0"
          return -1
        }
      }
      if {[regexp {(\d+).[ ]+TS Assignment} $buffer match res] != 1} {
        set gaSet(fail) "$uut - ConfigUutsE1 Fail - Failed to get TS Assignment Menu"
        return -1
      }
      Send $gaSet(com$uut) "$res\r" Clear
      if {$ts == "full" || $ts == "31"} {
        Send $gaSet(com$uut) "32\r" Clear
        set ret [Send $gaSet(com$uut) "s" Clear]
      } elseif {$ts == "0"} {
        Send $gaSet(com$uut) "33\r" Clear
        set ret [Send $gaSet(com$uut) "s" Clear]
      } else {
        set DataQty [regexp -all Data $buffer]
        if {$DataQty != $ts} {
          Send $gaSet(com$uut) "33\r" Clear
          for {set tsLoop 1} {$tsLoop <= $ts} {incr tsLoop 1} {
            Send $gaSet(com$uut) "$tsLoop\r" "ESC" 5
          }
          set ret [Send $gaSet(com$uut) "s" Clear]
        } else {
          set ret 0
        }             
      }
      
      if {$ret!=0} {
        set gaSet(fail) "$uut - ConfigUutsE1 Fail - Failed to Save TS Assignment"
        return $ret
      }
      
      if {$gaSet(act)==0} {return -2}
      if {$gaSet(dutFam)=="L" || $gaSet(dutFam)=="54" || $gaSet(dutFam)=="LRT"} {
        break
      } elseif {$gaSet(dutFam)=="f35"} {
        set ret [Send $gaSet(com$uut) "\33" "Alarms"]
        if {$ret!=0} {return $ret}
        Send $gaSet(com$uut) "f" "Assignment"
        if {$ret!=0} {return $ret}
      } 
    }
  }   
    
	return $ret
}


#*************************************************************************
#** CheckSync
#***********************************************************
proc _CheckSync {uut sync} {
  global gaSet buffer
  puts "[MyTime] CheckSync $uut $sync"
	global gaSet gLog
  Send $gaSet(com$uut) "!" "tilities"
  set ret [UUTIsUp $uut]
  if {$ret!=0} {
    set ret [UUTup $uut]
    if {$ret!=0} {return $ret}
  }
  Send $gaSet(com$uut) "\r" "tilities"
  
  if {[regexp {(\d).[ ]+Monitoring} $buffer match res] != 1} {
    set gaSet(fail) "$uut - CheckSync Fail - Failed to get Configuration Menu"
    return -1
  }
  Send $gaSet(com$uut) "$res\r" "Application"
  
  if {[regexp {(\d).[ ]+Physical Layer} $buffer match res] != 1} {
    set gaSet(fail) "$uut - CheckSync Fail - Failed to get Physical Layer Menu"
    return -1
  }
  Send $gaSet(com$uut) "$res\r" "SHDSL"
  
  if {[regexp {(\d).[ ]+SHDSL} $buffer match res] != 1} {
    set gaSet(fail) "$uut - CheckSync Fail - Failed to get SHDSL Menu"
    return -1
  }
  Send $gaSet(com$uut) "$res\r" "Statistics"
  
  if {[regexp {(\d).[ ]+Status} $buffer match res] != 1} {
    set gaSet(fail) "$uut - CheckSync Fail - Failed to get Status Menu"
    return -1
  }
  Send $gaSet(com$uut) "$res\r" "2."
  
  if {[regexp {(\d).[ ]+Line} $buffer match res] != 1} {
    set gaSet(fail) "$uut - CheckSync Fail - Failed to get Line Menu"
    return -1
  }
  Send $gaSet(com$uut) "$res\r" "(N)"
  
  foreach line {1 2 3 4} {
    set ret [regexp {Operation Status\s+\((\w+)} $buffer match res]
    if {$ret != 1} {
      set gaSet(fail) "$uut - CheckSync Fail - Failed to read Synch Status "
      return -1
    }
  puts "sync:$sync res:$res" ; update
  }
  if {($sync == "yes" && $res != "Data") || ($sync == "no" && $res != "PreActivation")} {
    set gaSet(fail) "$uut - CheckSync Fail - SHDSL should be $sync but status is $res"
    return -1
  }
  return 0    
}

# ***************************************************************************
# MainMenu
# ***************************************************************************
proc MainMenu {com} {
	global gaSet buffer 
  puts "[MyTime] MainMenu $com"
  Send $com "\33" "USER NAME:" 1
	set ret [Send $com "\33\33!" "Main Menu" 2] 
  if {$ret != 0} {   
    for {set i 1} {$i <= 5} {incr i 1} {
      set ret [Send $com "\33" "USER NAME:" 2]
      if {$ret == 0} {
        break
      }
    } 
    if {$i > 5} {
      return -1
    }
    Send $com "su\r" stam 0.25
    RLTime::Delayms 500
    set ret [Send $com "1234\r" "Main Menu" 2]   
    if {$ret != 0} {
      return -1
    }    
  }
	return 0
}
# ***************************************************************************
# DebugMainMenu
# ***************************************************************************
proc DebugMainMenu {uut} {
  puts "[MyTime] DebugMainMenu $uut"
	global gaSet buffer 
  set gaSet(fail) "$uut fail enter to Debug Menu"
  set com $gaSet(com$uut)
#   Send $com \r stam 1
#   if ![string match *Debug* $buffer] {
#     Send $com \r stam 1
#     if [string match *Debug* $buffer] {
#       return 0  
#     }
#   } else {
#     return 0
#   }
#   Send $com "\33\r\r\r\r\r\r" stam 0.1   
  Send $com "&" stam 0.1  
  RLTime::Delayms 500  
  for {set i 1} {$i <= 8} {incr i 1} {
#     puts "DebugMainMenu $i" ; update
#     Send $com "&" stam 1
#     RLTime::Delayms 500  
    set ret [Send $com "\33" "USER NAME:" 2]
    if {$ret == 0} {
      break
    }
  } 
  if {$i > 8} {
    return -1
  }
  Send $com "debug\r" stam 0.1  
  RLTime::Delayms 500
  set ret [Send $com "panic\r" "Debug" 2]   
  if {$ret != 0} {
    return -1
  }    
  return 0
}

# ***************************************************************************
# ActivateLedTest
# ***************************************************************************
proc ActivateLedTest {uut} {
  global gaSet buffer
  Status "Activate LedTest $uut"
  set com $gaSet(com$uut)
  Send $com & stam 0.5
  set ret [Send $com \r debug 2]
  if {$ret!=0} {
    after 1000
    Send $com & stam 0.5
    set ret [Send $com \r debug 2]
    if {$ret!=0} {
      after 1000
      Send $com & stam 0.5
      set ret [Send $com \r debug 2]
      if {$ret!=0} {
        set gaSet(fail) "Activation of LedTest in $uut fail"
        return $ret
      }
    }
  }
  Send $com debug\r stam 0.5
  Send $com 1234\r debug
  Send $com 5\r debug
  Send $com 7\r debug 0.5
  return 0
}

# ***************************************************************************
# PagesInit
# ***************************************************************************
proc PagesInit {uut} {
  global gaSet buffer
  set pair $::pair
  Status "PagesInit $uut of pair $pair."
  set ret [BootMenu $uut]
  if {$ret==0} {
    set barcode $gaSet($pair.barcode$uut)
    if {$gaSet(readTrace)==0} {
      set ret [GetPageFile $barcode]
    } elseif {$gaSet(readTrace)==1} {
#       set trac $gaSet($pair.trace$uut)
#       set trac $gaSet(entTrace)
      set trac $gaSet(TraceID)
      set ret [GetPageFile $barcode $trac]
    }
  }
  if {$ret==0} {
    set ret [WritePages $uut] 
  }
  if {$ret==0} {
    Send $gaSet(com$uut) "@\r" stam 3
    catch {unset gaSet(pageFilePath)}
  }
  if {$ret==0} {
    if {$gaSet(readTrace)==0} {
      SavePageFile $ret $barcode
    } elseif {$gaSet(readTrace)==1} {
      SavePageFile $ret $barcode $trac
    }
  }
  return $ret
}
# ***************************************************************************
# MasterClock
# ***************************************************************************
proc MasterClock {uut masterClk} {
  global gaSet buffer  
  if {$gaSet(act)==0} {return -2}
  Status "MasterClock $uut $masterClk"
	set ret [UUTIsUp $uut]
  if {$ret!=0} {
    set ret [UUTup $uut]
    if {$ret!=0} {return $ret}
  }
  Send $gaSet(com$uut) "\r" "tilities"
  
  if {[regexp {(\d).[ ]+Configuration} $buffer match res] != 1} {
    set gaSet(fail) "$uut - MasterClock Fail - Failed to get Configuration Menu"
    return -1
  }
  Send $gaSet(com$uut) "$res\r" "Applications"
  
  if {[regexp {(\d).[ ]+System} $buffer match res] != 1} {
    set gaSet(fail) "$uut - MasterClock Fail - Failed to get System Menu"
    return -1
  }
  Send $gaSet(com$uut) "$res\r" "Defaults"
  
  if {[regexp {(\d).[ ]+Clock} $buffer match res] != 1} {
    set gaSet(fail) "$uut - MasterClock Fail - Failed to get Clock Menu"
    return -1
  }
  Send $gaSet(com$uut) "$res\r" " Clock"
  
  if {[regexp {(\d).[ ]+Master Clock} $buffer match res] != 1} {
    set gaSet(fail) "$uut - MasterClock Fail - Failed to get Clock Menu"
    return -1
  }
  Send $gaSet(com$uut) "$res\r" "Source"
  if {[string match *$masterClk* $buffer]} {
    return 0
  } else {
    Send $gaSet(com$uut) "1\r" stam 1
    Send $gaSet(com$uut) "s" "Source"
    if {![string match *$masterClk* $buffer]} {
      set gaSet(fail) "$uut - MasterClock Fail - Failed to set Clock to $masterClk"
      return -1
    } else {
      return 0
    }
  }
  return ""
}  
# ***************************************************************************
# DhcpDisable
# ***************************************************************************
proc DhcpDisable {uut} {
  global gaSet buffer
  if {$gaSet(dutFam)=="f35"  || $gaSet(dutFam)=="54" || $gaSet(dutFam)=="LRT"} {
    return 0
  }
  set gaSet(fail) "Config of Dhcp Disable in $uut fail"
  Status "Config Dhcp Disable at $uut"
  set ret [UUTIsUp $uut]
  if {$ret!=0} {
    set ret [UUTup $uut]
    if {$ret!=0} {return $ret}
  }
  set com $gaSet(com$uut)
  set ret [Send $com "!" "tilities"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "2\r" "plications"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "1\r" "efaults"]
  if {$ret!=0} {return $ret}
  regexp {(\d)\.\s+Management} $buffer - linNum
  set ret [Send $com "$linNum\r" "Access"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "2\r" "DHCP"]
  if {$ret!=0} {return $ret}
  regexp {(\d)\.\s+DHCP} $buffer - linNum
  set ret [Send $com "$linNum\r" ")"]
  if {$ret!=0} {return $ret}
  if {[string match *Enable* $buffer]} {
    set ret [Send $com "1\r" ")"]
    if {$ret!=0} {return $ret}
    set ret [Send $com "s" ")"]
    if {$ret!=0} {return $ret}
    set ret [Send $com "\r" ")"]
    if {$ret!=0} {return $ret}
  }
  return 0
}  
# ***************************************************************************
# GotoSetShdsl
# ***************************************************************************
proc GotoSetShdsl {uut} {
  global gaSet buffer
  if {$gaSet(act)==0} {return -2}
  puts "[MyTime] GotoSetShdsl $uut called by [lindex [info level -1] 0]"
  Send $gaSet(com$uut) "\r" "ssttaamm" 1
  Send $gaSet(com$uut) "\r" "ssttaamm" 1
  if {$gaSet(dutFam)=="L" || $gaSet(dutFam)=="LRT" || $gaSet(dutFam)=="54"} {
    set rightPlace [string match {*Configuration>Physical Layer>SHDSL>Line*} $buffer]
  } elseif {$gaSet(dutFam)=="f35"} {
    set rightPlace [string match {*Configuration>Physical Layer>SHDSL*} $buffer]
  }
  if {$rightPlace==0} {
    set ret [UUTIsUp $uut]
    if {$ret!=0} {
      set ret [UUTup $uut]
      if {$ret!=0} {return $ret}
    }
    Send $gaSet(com$uut) "\r" "tilities"
    if {[regexp {(\d).[ ]+Configuration} $buffer match res] != 1} {
      set gaSet(fail) "$uut - Failed to get Configuration Menu"
      return -1
    }
    Send $gaSet(com$uut) "$res\r" "Applications"
    if {[regexp {(\d).[ ]+Physical Layer} $buffer match res] != 1} {
      set gaSet(fail) "$uut - Failed to get Physical Layer Menu"
      return -1
    }
    Send $gaSet(com$uut) "$res\r" "SHDSL" 
    if {[regexp {(\d).[ ]+SHDSL} $buffer match res] != 1} {
      set gaSet(fail) "$uut - Failed to get SHDSL Menu"
      return -1
    }
    if {$gaSet(dutFam)=="L" || $gaSet(dutFam)=="LRT" || $gaSet(dutFam)=="54"} {
      Send $gaSet(com$uut) "$res\r" "Line"
    } elseif {$gaSet(dutFam)=="f35"} {
      Send $gaSet(com$uut) "$res\r" "(N)"
    }  
      
    if {$gaSet(dutFam)=="L" || $gaSet(dutFam)=="LRT" || $gaSet(dutFam)=="54"} {
      if {[regexp {(\d).[ ]+Line} $buffer match res] != 1} {
        set gaSet(fail) "$uut - Failed to get Line Menu"
        return -1
      }
      set ret [Send $gaSet(com$uut) "$res\r" "(N)"]
    } elseif {$gaSet(dutFam)=="f35"} {
      ## do nothing
      set ret 0
    }
    
  } else {
    set ret 0
  }
  return $ret
}
# ***************************************************************************
# IpConfig
# ***************************************************************************
proc IpConfig {uut} {
  global gaSet buffer
  puts "IpConfig $uut"
  set ip 1.1.1.[set gaSet(pair)][string index $uut end]
  set gaSet(fail) "Config of IP in $uut fail"
  Status "Config IP $ip at $uut"
  
  set ret [UUTIsUp $uut]
  if {$ret!=0} {
    set ret [UUTup $uut]
    if {$ret!=0} {return $ret}
  }
  set com $gaSet(com$uut)
  set ret [Send $com "!" "tilities"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "2\r" "plications"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "1\r" "efaults"]
  if {$ret!=0} {return $ret}
  regexp {(\d)\.\s+Management} $buffer - linNum
  set ret [Send $com "$linNum\r" "Access"]
  if {$ret!=0} {return $ret}   
  regexp {(\d)\.\s+Host} $buffer - linNum 
  set ret [Send $com "$linNum\r" "Trap Community"]
  if {$ret!=0} {return $ret}
  regexp {(\d)\.\s+IP} $buffer - linNum
  set ret [Send $com "$linNum\r$ip\r" "Trap Community"]
  if {$ret!=0} {return $ret}
  regexp {(\d)\.\s+Default Gateway} $buffer - linNum
  set ret [Send $com "$linNum\r1.1.1.1\r" "Trap Community"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "s" "Trap Community"]
  if {$ret!=0} {return $ret}
  
  set gaSet(fail) "Config of Manager in $uut fail"
  set ret [Send $com "\33" "Access"]
  if {$ret!=0} {return $ret}
  regexp {(\d)\.\s+Managers} $buffer - linNum
  set ret [Send $com "$linNum\r" ")"]
  if {$ret!=0} {return $ret}
  Send $com 1\r1.1.1.1\r ")"
  if {$ret!=0} {return $ret}
  set ret [Send $com "\33" "Access"]
  if {$ret!=0} {return $ret}
  return 0
}  
# ***************************************************************************
# IpCheck
# ***************************************************************************
proc IpCheck {uut} {
  global gaSet buffer
  puts "IpCheck $uut"
  set ip 1.1.1.[set gaSet(pair)][string index $uut end]
  set gaSet(fail) "Check IP in $uut fail"
  Status "Check IP $ip at $uut"
  
  set ret [UUTIsUp $uut]
  if {$ret!=0} {
    set ret [UUTup $uut]
    if {$ret!=0} {return $ret}
  }
  set com $gaSet(com$uut)
  set ret [Send $com "!" "tilities"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "2\r" "plications"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "1\r" "efaults"]
  if {$ret!=0} {return $ret}
  regexp {(\d)\.\s+Management} $buffer - linNum
  set ret [Send $com "$linNum\r" "Access"]
  if {$ret!=0} {return $ret}
  regexp {(\d)\.\s+Host} $buffer - linNum
  set ret [Send $com "$linNum\r" "Trap Community"]
  if {$ret!=0} {return $ret}
  regexp {IP Address[\s\.]+\(([\d\.]+)\)} $buffer - val
  if {$val==$ip} {
    set ret 0
  } else {
    set gaSet(fail) "The IP of $uut is $val. Should be $ip."
    set ret -1
  }
  return $ret
}  

# ***************************************************************************
# Eth1Toggle
# ***************************************************************************
proc Eth1Toggle {uut} {
  global gaSet buffer
  Status "Eth1 Toggle $uut"
  
  set ret [UUTIsUp $uut]
  if {$ret!=0} {
    set ret [UUTup $uut]
    if {$ret!=0} {return $ret}
  }
  set gaSet(fail) "Eth1 Toggle of $uut fail"
  set com $gaSet(com$uut)
  set ret [Send $com "!" "tilities"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "2\r" "plications"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "2\r" "SHDSL"]
  if {$ret!=0} {return $ret}
  if {$gaSet(dutFam)=="L"} {
    set lastWord "Types"
  } else {
    set lastWord "Alarms"
  }
  set ret [Send $com "1\r" $lastWord]
  if {$ret!=0} {return $ret}
  set ret [Send $com "2\r" $lastWord]
  if {$ret!=0} {return $ret}
  set ret [Send $com "s" $lastWord]
  if {$ret!=0} {return $ret}
  after 2000
  set ret [Send $com "2\r" $lastWord]
  if {$ret!=0} {return $ret}
  set ret [Send $com "s" $lastWord]
  return $ret
}

# ***************************************************************************
# LedTest
# ***************************************************************************
proc LedTest {lin} {
  global gaSet buffer
  puts "[MyTime] LedTest \"$lin\""
  foreach uut {Uut1 Uut2} {
    set gaSet(fail) "LED TEST of $uut fail"
    Send $gaSet(com$uut) "\r" "Debug" 
    if ![string match {*LED Test Yellow*} $buffer] {
      if {[regexp {(\d).[ ]+Debug} $buffer match res] != 1} {
        return -1
      }    
      Send $gaSet(com$uut) "$res\r" "(N)"
      Send $gaSet(com$uut) "n" "(N)" 1
    }
    if {[regexp "\(\\d+\).\[ \]+$lin" $buffer match res] != 1} {
      return -1
    }
  }  
  
  for {set i 1} {$i <= 2} {incr i 1} {
    foreach uut {Uut1 Uut2} {
      set gaSet(fail) "LED TEST of $uut fail"
      Send $gaSet(com$uut) "$res\r" (N) 0.125
    }
    RLTime::Delayms 350  
  }
  return 0
}

# ***************************************************************************
# FactDefaultBln
# ***************************************************************************
proc FactDefaultBln {uut} {
  global gaSet buffer
  set gaSet(fail) "BeeLine configuration of $uut fail"
  puts "BeeLine configuration $uut" 
  set ret [UUTIsUp $uut]
  if {$ret!=0} {
    set ret [UUTup $uut]
    if {$ret!=0} {return $ret}
  }
  Status "$uut BeeLine configuration"
  set com $gaSet(com$uut)
  Send $com "\r" "exit" 2
  set ret [DebugMainMenu $uut]
  if {$ret!=0} {return $ret}
  
  set ret [Send $com "5\n" "Statistics"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "n" "stam" 1]
  #if {$ret!=0} {return $ret}  
  set ret [Send $com "15\n" "BeeLine"]
  if {$ret!=0} {return $ret}  
  set ret [Send $com "3\n" "BeeLine"]
  set ret 0
  return $ret
}  
# ***************************************************************************
# BeeLine_DefaultCheck
# ***************************************************************************
proc BeeLine_DefaultCheck {pair} {
  global gaSet buffer
  puts "\n[MyTime] Pair $pair. BeeLine_DefaultCheck"
  MassConnect $pair
  foreach uut {Uut1 Uut2} {
    set gaSet(fail) "Check BeeLine configuration of $uut fail"
    puts "BeeLine_DefaultCheck $uut" 
    set ret [UUTIsUp $uut]
    if {$ret!=0} {
      set ret [UUTup $uut]
      if {$ret!=0} {return $ret}
    }
    Status "$uut. Check BeeLine Factory Default"
    set com $gaSet(com$uut)
    set ret [Send $com "!" "tilities"]
    if {$ret!=0} {return $ret}
    set ret [Send $com "2\r" "plications"]
    if {$ret!=0} {return $ret}
    set ret [Send $com "1\r" "efaults"]
    if {$ret!=0} {return $ret}
    regexp {(\d)\.\s+Management} $buffer - linNum
    set ret [Send $com "$linNum\r" "Access"]
    if {$ret!=0} {return $ret}   
    regexp {(\d)\.\s+Host} $buffer - linNum 
    set ret [Send $com "$linNum\r" "Trap Community"]
    if {$ret!=0} {return $ret}
    
    set ret 0
    set res1 [regexp {Address[\.\s]+\(([\d\.]+)\)\s} $buffer - dutIp]
    set res2 [regexp {Mask[\.\s]+\(([\d\.]+)\)\s} $buffer - dutMa]
    set res3 [regexp {Gateway[\.\s]+\(([\d\.]+)\)\s} $buffer - dutGw]
    if {$res1==0 || $res2==0 || $res3==0} {
      set gaSet(fail) "Read Host parameters of $uut fail"
      return -1
    }
    set dutIp [string trim $dutIp]
    set dutMa [string trim $dutMa]
    set dutGw [string trim $dutGw]
    puts "$uut dutIp:<$dutIp> dutMa:<$dutMa> dutGw:<$dutGw>"
    
    set ipSB "192.168.1.254"
    if {$dutIp!=$ipSB} {
      set gaSet(fail) "In $uut IP is $dutIp. Should be $ipSB"
      set ret -1
    }
    
    if {$ret==0} {
      set maSB "255.255.255.0"
      if {$dutMa!=$maSB} {
        set gaSet(fail) "In $uut Mask is $dutMa. Should be $maSB"
        set ret -1
      }
    }
    
    if {$ret==0} {
      set gwSB "192.168.1.1"
      if {$dutGw!=$gwSB} {
        set gaSet(fail) "In $uut GateWay is $dutGw. Should be $gwSB"
        set ret -1
      }
    }  
    puts "BeeLine_DefaultCheck $uut ret:<$ret>"
    if {$ret!=0} {break}
  }
  return $ret
}   

# ***************************************************************************
# LicenseDownload
# ***************************************************************************
proc LicenseDownload {uut fil} {
  global gaSet buffer
  puts "\n[MyTime] Download License ($fil) to $uut"
  set ret [UUTIsUp $uut]
  if {$ret!=0} {
    set ret [UUTup $uut]
    if {$ret!=0} {return $ret}
  }
  Status "Download License to $uut"
  set com $gaSet(com$uut)
  set ret [Send $com "!" "tilities"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "4\r" "eset PCS"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "1\r" "Clear Statistics"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "2\r" "ommand"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "1\r" "License Download"]
  if {$ret!=0} {return $ret}
  
  set ret [Send $com "6\r" "ommand"]
  if {$ret!=0} {return $ret}
  
  catch {RLSerial::Close $com} res
  after 500
  RLCom::Open $com 9600 8 NONE 1
  set ret [RLCom::DownLoad $com $fil]
  puts "ret after rldownload:<$ret>" ; update
  RLCom::Close $com
  after 500
  RLSerial::Open $com 9600 n 8 1 
  
  return $ret
}
# ***************************************************************************
# VerifyLicense
# ***************************************************************************
proc VerifyLicense {uut} {
  global gaSet buffer
  puts "\n[MyTime] Verify License on $uut"
  set ret [UUTIsUp $uut]
  if {$ret!=0} {
    set ret [UUTup $uut]
    if {$ret!=0} {return $ret}
  }
  Status "Verify License on $uut"
  set com $gaSet(com$uut)
  set ret [Send $com "!" "tilities"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "4\r" "eset PCS"]
  if {$ret!=0} {return $ret}
  set ret [Send $com "2\r" "Status"]
  if {$ret!=0} {return $ret}
  if {[regexp {(\d).[ ]+Feature Status} $buffer - res] != 1} {
    set gaSet(fail) "Reading Feature Status in $uut fail"
    return -1
  }
  Send $com "$res\r" "stam" 2
  set res [regexp {Rate[\s\.]+\((\w+)\)} $buffer ma stat] 
  if {$res==0} {
    set gaSet(fail) "Reading Feature Status in $uut  fail"
    return -1
  }
  puts "ma:<$ma> stat:<$stat>"; update
  if {$stat!="Enabled"} {
    set gaSet(fail) "SHDSL Extended Rate in $uut is $stat. Showld be Enabled"
    return -1
  } else {
    set ret 0
  }
  
  return $ret
}
# ***************************************************************************
# PoRst
# ***************************************************************************
proc PoRst {pair} {
  global gaSet buffer
  foreach uut {Uut1 Uut2} {
    while 1 {
      Status "Power Reset on pair $pair / $uut"
      set ret [UUTIsUp $uut]
      if {$ret!=0} {
        set ret [UUTup $uut]
        if {$ret!=0} {return $ret}
      }
      Status "Power Reset on pair $pair / $uut"
      set com $gaSet(com$uut)
      set ret [Send $com "!" "tilities"]
      if {$ret!=0} {return $ret}
      
      set ret [DebugMainMenu $uut]
      if {$ret!=0} {return $ret}
      
      set ret [Send $com "5\n" "Statistics"]
      if {$ret!=0} {return $ret}
      set ret [Send $com "3\n" "Content"]
      if {$ret!=0} {return $ret}  
      set ret [Send $com "1\nFF000956\n" "Content"]
      if {$ret!=0} {return $ret}  
      set ret [Send $com "2\n2\n" "Content"]
      if {$ret!=0} {return $ret} 
      set ret [Send $com "4\n00000A12\n" "Content"]
      if {$ret!=0} {return $ret} 
      
      RLSound::Play beep
      set mes "After pressing OK verify POWER Led of $uut of pair $pair \nis turned OFF and ON"
      set res [DialogBox -type "OK Stop" -icon images/question \
          -title "LED Test of pair $pair" -message $mes]
      update
      if {$res=="Stop"}  {
        set gaSet(fail) "User stop"
        return -2
      } else {
        set ret 0
      }
      Send $com "5\n" "stam" 1
      
      RLSound::Play beep
      set mes "If leds are working properly?"
      set res [DialogBox -type "Yes No Repeat Stop" -icon images/question \
          -title "LED Test of pair $pair" -message $mes]
      update
      if {$res=="No"} {
        set gaSet(fail) "LED Test of pair $pair fail"
        return -1
      } elseif {$res=="Yes"}  {
        set ret 0
        break ; # break the while
      } elseif {$res=="Stop"}  {
        return -2
      } elseif {$res=="Repeat"}  {
        ## repeat the test
      }
    }
  }
  return $ret 
}