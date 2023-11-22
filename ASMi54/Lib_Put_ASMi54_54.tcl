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
  
  set gaSet(bootScreen$uut) ""
  set res -1
  for {set i 1} {$i <= 20} {incr i 1} {    
    if {$gaSet(act)==0} {return -2}
    if {$res == -1} {
      set res [RLSerial::Send $gaSet(com$uut) "\r" buffer "Select:" 0.5]
      puts "1i:$i res:$res buffer:<$buffer>"; update
      #set res [Send $gaSet(com$uut) "\r" "Select:" 0.25]
      append gaSet(bootScreen$uut) $buffer
      if {$res==0} {
        break
      }
    }  
  }
  
  if {$res == -1} {
    Power $uut off
    RLTime::Delay 2
    Power $uut on
    
    set gaSet(bootScreen$uut) ""
    set res -1
    for {set i 1} {$i <= 20} {incr i 1} {    
      if {$gaSet(act)==0} {return -2}
      if {$res == -1} {
        set res [RLSerial::Send $gaSet(com$uut) "\r" buffer "Select:" 0.5]
        puts "2i:$i res:$res buffer:<$buffer>"; update
        #set res [Send $gaSet(com$uut) "\r" "Select:" 0.25]
        append gaSet(bootScreen$uut) $buffer
        if {$res==0} {
          break
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
  ## the boot's detailt are read in proc BootMenu
  Send $gaSet(com$uut) "0" "stam" 1
  return 0
#   if {[Send $gaSet(com$uut) "\r" "Select:" 0.5] == 0} {
#     set gaSet(bootScreen$uut) $buffer
#     Send $gaSet(com$uut) "0\r" "stam" 1
#   } else {
#     set gaSet(fail) "$uut - Failed to Get Boot Version"
#   	return -1		    
#   }       
#   
#   return 0
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
  set res [Send $gaSet(com$uut) "\r" "Select:" ]        
  if {$res == -1} {
    set gaSet(fail) "$uut - Failed to Get Boot Menu"
    return -1		    
  }
  set ret [Send $gaSet(com$uut) "5" y/n]
  if {$ret == -1} {
    set gaSet(fail) "$uut - Failed to Format Flash"
    return -1		    
  }
  set ret [Send $gaSet(com$uut) "y" "Select:" 30]  
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
  
  set ret [Send $com "8" "\]:" ]
  set ret [Send $com "$ip\r" "\]:" ]
  if {$ret!=0} {
    set gaSet(fail) "$uut - Config device IP fail"
    return $ret
  }
  set ret [Send $com "255.255.255.0\r" "\]:" ]
  if {$ret!=0} {
    set gaSet(fail) "$uut - Config device IP Mask fail"
    return $ret
  }
  set ret [Send $com "\r" "Select:" ]
  if {$ret!=0} {
    set gaSet(fail) "$uut - Config System Configuration fail"
    return $ret
  }
  
  set ret [Send $com "9" "\]:" ]
  set ret [Send $com "\r" "\]:" ]
  if {$ret!=0} {
    set gaSet(fail) "$uut - Config TFTP Timeout fail"
    return $ret
  }
  set ret [Send $com "[file tail $pa]\r" "\]:"]
  if {$ret!=0} {
    set gaSet(fail) "$uut - Config file name fail"
    return $ret
  }
  set ret [Send $com "1.1.1.1\r" "apllication file"]
  if {$ret!=0} {
    set gaSet(fail) "$uut - Config server IP fail"
    return $ret
  }
  if [string match *Error* $buffer] {
    set gaSet(fail) "$uut - Download fail"
    return -1  
  }
  set ret [Send $com "1" "( 0 1 )"]
  if {$ret!=0} {
    set gaSet(fail) "$uut - Config copy number fail"
    return $ret
  }
  if [string match *Error* $buffer] {
    set gaSet(fail) "$uut - Download fail"
    return -1  
  }
  set ret [Send $com "0" "Select:" 60]
  if {$ret!=0} {
    set gaSet(fail) "$uut - Config copy number fail"
    return $ret
  }
  if [string match *Error* $buffer] {
    set gaSet(fail) "$uut - Download fail"
    return -1  
  }
  
  set ret [Send $com 0 "Loading" 10]
  if {$ret!=0} {
    set gaSet(fail) "$uut - Starting after download fail"
    return $ret
  }   
  file delete $pa
  return $ret
}  
 
