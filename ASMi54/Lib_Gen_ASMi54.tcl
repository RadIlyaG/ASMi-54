
##***************************************************************************
##** OpenRL
##***************************************************************************
proc OpenRL {} {
  global gaSet   gDxc4BufferDebug
  if [info exists gaSet(curTest)] {
    set curTest $gaSet(curTest)
  } else {
    set curTest "1..ID"
  }
  CloseRL
  catch {RLEH::Close}
  
  RLEH::Open
  
  puts "Open PIO [MyTime]"
  set ret [OpenPio]
  set ret1 [OpenComUut]
  if {[string match {*Mac_BarCode*} $gaSet(startFrom)] || [string match {*Leds*} $gaSet(startFrom)] ||\
      [string match {*Memory*} $gaSet(startFrom)]      || [string match {*License*} $gaSet(startFrom)] ||\
      [string match {*FactorySet*} $gaSet(startFrom)]  || [string match {*SaveUserFile*} $gaSet(startFrom)] ||\
      [string match {*FactorySet_Button*} $gaSet(startFrom)]} {
    set openGens 0  
    if {[llength [PairsToTest]]>1 && $gaSet(nextPair)=="begin"} {
      ## inspite of start from a test from end of the list,
      ## but the fact that there is more then one pair to be checked AND
      ## the next pair/s will start from the first test, we should OpenGenerators 
      set openGens 1
    }
  } else {
    set openGens 1
  } 
  if {$openGens==1} {  
    Status "Open ETH GENERATORs"
    set ret2 [OpenEtxGen]    
  } else {
    set ret2 0
  }  
  if {$openGens==1} {
    if {$gaSet(e1) != "NA" || [string match *.D.* $gaSet(DutInitName)]==1} { 	
      Status "Open E1 GENERATORs"
     	set ret3 [OpenDxc4]
      set gDxc4BufferDebug 1
    } else {
      set ret3 0
    }
  } else {
    set ret3 0
  } 
  
  set gaSet(curTest) $curTest
  puts "[MyTime] ret:$ret ret1:$ret1 ret2:$ret2 ret3:$ret3" ; update
  if {$ret1!=0 || $ret2!=0 || $ret3!=0} {
    set gaSet(fail) "Open RL fail"
    return -1
  }
  return 0
}

# ***************************************************************************
# OpenComUut
# ***************************************************************************
proc OpenComUut {} {
  global gaSet
  RLSerial::Open $gaSet(comUut1) 9600 n 8 1
  RLSerial::Open $gaSet(comUut2) 9600 n 8 1
  return 0
}
# ***************************************************************************
# CloseComUut
# ***************************************************************************
proc CloseComUut {} {
  global gaSet
  foreach c "$gaSet(comUut1) $gaSet(comUut2)" {
    catch {RLSerial::Close $c} res
    puts "CloseRL CloseComUut com:$c res:$res" ; update
  }
  return {}
}

#***************************************************************************
#** CloseRL
#***************************************************************************
proc CloseRL {} {
  global gaSet
  set gaSet(serial) ""
  ClosePio
  puts "CloseRL ClosePio" ; update
  CloseComUut
  puts "CloseRL CloseComUut" ; update 
  catch {RLDxc4::CloseAll}
  catch {RLEtxGen::CloseAll}
  catch {RLScotty::SnmpCloseAllTrap}
  catch {RLEH::Close}
}
# ***************************************************************************
# OpenPio
# ***************************************************************************
proc OpenPio {} {
  global gaSet
  
  set gaSet(rb1Id) [RLExPio::Open $gaSet(rb1) RBA]
 	set gaSet(rb2Id) [RLExPio::Open $gaSet(rb2) RBA]
  
  set gaSet(mmux1Id) [RLExMmux::Open $gaSet(mmuxEthShdslPort)]
  set gaSet(mmux2Id) [RLExMmux::Open $gaSet(mmuxMassPort)]
 	
  MassConnect 1
  Power all on
  
  return 0
}

# ***************************************************************************
# ClosePio
# ***************************************************************************
proc ClosePio {} {
  global gaSet
  set ret 0
  catch {RLExPio::Close $gaSet(rb1Id)}
	catch {RLExPio::Close $gaSet(rb2Id)}
  catch {RLExMmux::Close $gaSet(mmux1Id)}
  catch {RLExMmux::Close $gaSet(mmux2Id)}
  
  return $ret
}
# ***************************************************************************
# MassConnect
# ***************************************************************************
proc MassConnect {massNum} {
	global gaSet 
	set gaSet(massNum) $massNum
	RLExMmux::AllNC $gaSet(mmux2Id)
  after 500
  RLExMmux::ChsCon $gaSet(mmux2Id) 14,$massNum,28,[expr $massNum + 14]
  return 0
  
	RLExMmux::AllNC $gaSet(mmux3Id)
  RLExMmux::AllNC $gaSet(mmux4Id)
	RLExMmux::AllNC $gaSet(mmux5Id)
	RLExMmux::AllNC $gaSet(mmux6Id)
	RLExMmux::AllNC $gaSet(mmux7Id)
	#RLExMmux::AllNC $gaSet(mmux8Id)
	RLExMmux::AllNC $gaSet(mmux9Id)
  RLTime::Delay 1
  if {$eth=="gen"} {
    ## etx generator-1 is connected to port 14 and 28 of mmux-1,2
    ## etx generator-2 is connected to port 14 and 28 of mmux-3,4
    RLExMmux::ChsCon $gaSet(mmux1Id) 14,$massNum,28,[expr $massNum + 14]
    RLExMmux::ChsCon $gaSet(mmux2Id) 14,$massNum,28,[expr $massNum + 14]
    RLExMmux::ChsCon $gaSet(mmux3Id) 14,$massNum,28,[expr $massNum + 14]
    RLExMmux::ChsCon $gaSet(mmux4Id) 14,$massNum,28,[expr $massNum + 14]
  } elseif {$eth=="pc"} {
    ## PC via eth-switch is connected to CH-13 of mmux-1 and mmux-3
    RLExMmux::ChsCon $gaSet(mmux1Id) 13,$massNum
    RLExMmux::ChsCon $gaSet(mmux3Id) 13,$massNum
  } 
  RLExMmux::ChsCon $gaSet(mmux5Id) 14,$massNum,28,[expr $massNum + 14]
  RLExMmux::ChsCon $gaSet(mmux6Id) 14,$massNum,28,[expr $massNum + 14]
  RLExMmux::ChsCon $gaSet(mmux7Id) 14,$massNum,28,[expr $massNum + 14]
  #RLExMmux::ChsCon $gaSet(mmux8Id) 14,$massNum,28,[expr $massNum + 14]
  RLExMmux::ChsCon $gaSet(mmux9Id) 14,$massNum,28,[expr $massNum + 14]
#   if {$eth != "none"} {
#     RLExMmux::ChsCon $gaSet(mmux8Id) 28,[expr 21 + 1],21,[expr 14 + 1]
#   } 
#   if {$eth == "none"} {
#     RLExMmux::ChsCon $gaSet(mmux8Id) 28,26,14,12
#   }                 
	return 0
}


# ***************************************************************************
# ToolsMassConnect
# ***************************************************************************
proc ToolsMassConnect {massNum} {
	global gaSet
	set gaSet(mmux2Id) [RLExMmux::Open $gaSet(mmuxMassPort)]
  
	MassConnect $massNum
  RLExMmux::Close $gaSet(mmux2Id)
  
  return 0
}

# ***************************************************************************
# ComConnect
# ***************************************************************************
proc neComConnect {massNum} {
	global gaSet
	puts "ComConnect $massNum"
	RLExMmux::AllNC $gaSet(mmux7Id) 
  RLExMmux::ChsCon $gaSet(mmux7Id) 14,$massNum,28,[expr $massNum + 14] 
	return 0
}
# ***************************************************************************
# SwEth
#  SwEth disconnect
# ***************************************************************************
proc SwEth {mode} {
	global gaSet
	puts "SwEth $mode"
  #RLExMmux::ChsDis $gaSet(mmux1Id) 1,6,7,8,13,14
  RLExMmux::ChsDis $gaSet(mmux1Id) 1-14
  after 500
  if {$mode=="pc"} {
    RLExMmux::ChsCon $gaSet(mmux1Id) 1,6,8,13
  } elseif {$mode=="gen"} {
    RLExMmux::ChsCon $gaSet(mmux1Id) 1,7,8,14
  } elseif {$mode=="disconnect"} {
    ## do nothing, already disconnected
  }
	#RLExMmux::AllNC $gaSet(mmux7Id) 
   
	return 0
}
# ***************************************************************************
# SwShdsl
# ***************************************************************************
proc SwShdsl {mode} {
	global gaSet
	puts "SwShdsl $mode"
  #RLExMmux::ChsDis $gaSet(mmux1Id) 15,19,20,21,22,26,27,28
  RLExMmux::ChsDis $gaSet(mmux1Id) 15-28
  after 500
  if {$mode=="range"} {
    RLExMmux::ChsCon $gaSet(mmux1Id) 15,21,22,28
  } elseif {$mode=="relay"} {
    RLExMmux::ChsCon $gaSet(mmux1Id) 15,20,22,27
  } elseif {$mode=="short"} {
    RLExMmux::ChsCon $gaSet(mmux1Id) 15,19,22,26
  } elseif {$mode=="disconnect"} {
    ## do nothing, already disconnected
  }
	 
	return 0
}



# ***************************************************************************
# ToolsComConnect
# ***************************************************************************
proc neToolsComConnect {massNum} {
	global gaSet
	set gaSet(mmux7Id) [RLExMmux::Open $gaSet(mmux7Port)]	
	neComConnect $massNum
	RLExMmux::Close $gaSet(mmux7Id)	
  return 0  
}

#*************************************************************************
#** DslConnect
#** Usage: DslConnect connect/disconnect
#***********************************************************
proc neDslConnect {massNum con} {
	global gaSet gLog gaTest
	if {$con =="range"} {
    RLExMmux::AllNC $gaSet(mmux9Id)	
    RLExMmux::ChsCon $gaSet(mmux9Id) 14,$massNum,28,[expr 14+$massNum]
	} elseif {$con =="disconnect"} {
    RLExMmux::AllNC $gaSet(mmux9Id)
	} elseif {$con =="short"} {
    RLExMmux::AllNC $gaSet(mmux9Id)	
    RLExMmux::ChsCon $gaSet(mmux9Id) 13,$massNum,27,[expr 14+$massNum]
	} elseif {$con =="relay"} {
    RLExMmux::AllNC $gaSet(mmux9Id)	
    RLExMmux::ChsCon $gaSet(mmux9Id) 12,$massNum,26,[expr 14+$massNum]
	} 
	return 0
}

# ***************************************************************************
# ToolsDslConnect
# ***************************************************************************
proc ToolsDslConnect {mode} {
	global gaSet
	set gaSet(mmux1Id) [RLExMmux::Open $gaSet(mmux1Port)]
	SwShdsl $mode
	RLExMmux::Close $gaSet(mmux1Id)
  return 0
}



# ***************************************************************************
# SaveUutInit
# ***************************************************************************
proc SaveUutInit {fil} {
  global gaSet
  set id [open $fil w]
  puts $id "set gaSet(uut)       \"$gaSet(uut)\""
  puts $id "set gaSet(sw)        \"$gaSet(sw)\""
  puts $id "set gaSet(hw)        \"$gaSet(hw)\""
  puts $id "set gaSet(wire)      \"$gaSet(wire)\""
  puts $id "set gaSet(licEn)     \"$gaSet(licEn)\""
  puts $id "set gaSet(udfEn)     \"$gaSet(udfEn)\""
  if [info exists gaSet(udf)] {
    puts $id "set gaSet(udf)       \"$gaSet(udf)\""
  }
  puts $id "set gaSet(uaf)       \"$gaSet(uaf)\""
  puts $id "set gaSet(uafEn)     \"$gaSet(uafEn)\""
  puts $id "set gaSet(firstPair) \"$gaSet(firstPair)\""
  puts $id "set gaSet(lastPair)  \"$gaSet(lastPair)\""
  
  puts $id "set gaSet(bootVer)        \"$gaSet(bootVer)\""
  puts $id "set gaSet(bootMngr)       \"$gaSet(bootMngr)\""
#   puts $id "set gaSet(soc)            \"$gaSet(soc)\""
#   puts $id "set gaSet(fpga)           \"$gaSet(fpga)\""
  puts $id "set gaSet(box)            \"$gaSet(box)\""
  puts $id "set gaSet(ps)             \"$gaSet(ps)\""
  puts $id "set gaSet(eth)            \"$gaSet(eth)\""
  puts $id "set gaSet(e1)             \"$gaSet(e1)\""
  puts $id "set gaSet(sfp)            \"$gaSet(sfp)\""
  puts $id "set gaSet(plEn)           \"$gaSet(plEn)\""
  if [info exists gaSet(pl)] {
    puts $id "set gaSet(pl)       \"$gaSet(pl)\""
  }
  if [info exists gaSet(licDir)] {
    puts $id "set gaSet(licDir)   \"$gaSet(licDir)\""
  }
  if {[info exists gaSet(iprelay)]} {
    puts $id "set gaSet(iprelay)   \"$gaSet(iprelay)\""
  }
  if [info exists gaSet(DutFullName)] {
    puts $id "set gaSet(DutFullName) \"$gaSet(DutFullName)\""
  }
  if [info exists gaSet(DutInitName)] {
    puts $id "set gaSet(DutInitName) \"$gaSet(DutInitName)\""
  }
  #puts $id "set gaSet(macIC)      \"$gaSet(macIC)\""
  close $id
}  
# ***************************************************************************
# SaveInit
# ***************************************************************************
proc SaveInit {} {
  global gaSet  
  set id [open [info host]/init$gaSet(pair).tcl w]
  puts $id "set gaGui(xy) +[winfo x .]+[winfo y .]"
  if [info exists gaSet(DutFullName)] {
    puts $id "set gaSet(entDUT) \"$gaSet(DutFullName)\""
  }
  if [info exists gaSet(DutInitName)] {
    puts $id "set gaSet(DutInitName) \"$gaSet(DutInitName)\""
  }
    
  puts $id "set gaSet(performShortTest) \"$gaSet(performShortTest)\""
  
  if ![info exists gaSet(readTrace)] {
    set gaSet(readTrace) 1
  }
  puts $id "set gaSet(readTrace) \"$gaSet(readTrace)\""
  
  if {[info exists gaSet(TraceID)] && $gaSet(TraceID)!=""} {
    puts $id "set gaSet(TraceID) \"$gaSet(TraceID)\""  
  }
   
  if {[info exists gaSet(DutID)] && $gaSet(DutID)!=""} {
    puts $id "set gaSet(DutID) \"$gaSet(DutID)\""
  }
   
  
  close $id
  
  set id [open [info host]/initline_$gaSet(pair).tcl w]
  puts $id "set gaSet(ls4_1)      \"$gaSet(ls4_1)\""
  puts $id "set gaSet(ls4_2)      \"$gaSet(ls4_2)\""
  puts $id "set gaSet(ls4_3)      \"$gaSet(ls4_3)\""
  puts $id "set gaSet(ls4_4)      \"$gaSet(ls4_4)\""
  puts $id "set gaSet(ls4_DLS6x)  \"$gaSet(ls4_DLS6x)\""
  puts $id "set gaSet(ls4_APD)    \"$gaSet(ls4_APD)\""  
  close $id
}

#***************************************************************************
#** MyTime
#***************************************************************************
proc MyTime {} {
  return [clock format [clock seconds] -format "%T   %d/%m/%Y"]
}

#***************************************************************************
#** Send
#** #set ret [RLCom::SendSlow $com $toCom 150 buffer $fromCom $timeOut]
#** #set ret [RLCom::Send $com $toCom buffer $fromCom $timeOut]
#** 
#***************************************************************************
proc Send {com sent expected {timeOut 8}} {
  global buffer gaSet
  if {$gaSet(act)==0} {return -2}

  #puts "sent:<$sent>"
  regsub -all {[ ]+} $sent " " sent
  #puts "sent:<[string trimleft $sent]>"
  ##set cmd [list RLSerial::SendSlow $com $sent 50 buffer $expected $timeOut]
  set cmd [list RLSerial::Send $com $sent buffer $expected $timeOut]
  if {$gaSet(act)==0} {return -2}
  set tt "[expr {[lindex [time {set ret [eval $cmd]}] 0]/1000000.0}]sec"
  regsub -all -- {\x1B\x5B..\;..H} $buffer " " b1
  regsub -all -- {\x1B\x5B..\;..r} $b1 " " b1
  regsub -all -- {\x1B\x5B.J} $b1 " " b1
  set re \[\x1B\x0D\]
  regsub -all -- $re $b1 " " b2
  #regsub -all -- ..\;..H $b1 " " b2
  regsub -all {\s+} $b2 " " b3
  regsub -all {\-+} $b3 "-" b3
  set buffer $b3
  if $gaSet(puts) {
    #puts "\nsend: ---------- [clock format [clock seconds] -format %T] ---------------------------"
    puts "\nsend: ---------- [MyTime] ---------------------------"
    puts "send: com:$com, ret:$ret tt:$tt, sent=$sent,  expected=$expected, buffer=$buffer"
    puts "send: ----------------------------------------\n"
    update
  }
  
  RLTime::Delayms 50
  return $ret
}

#***************************************************************************
#** Status
#***************************************************************************
proc Status {txt {color white}} {
  global gaSet gaGui
  #set gaSet(status) $txt
  #$gaGui(labStatus) configure -bg $color
  $gaSet(sstatus) configure -bg $color  -text $txt
  if {$txt!=""} {
    puts "\n ..... $txt ..... /* [MyTime] */ \n"
  }
  update
}

##***************************************************************************
##** Wait
##***************************************************************************
proc Wait {txt count {color white}} {
  global gaSet
  puts "\nStart Wait $txt $count.....[MyTime]"; update
  Status $txt $color 
  for {set i $count} {$i > 0} {incr i -1} {
    if {$gaSet(act)==0} {return -2}
	 $gaSet(runTime) configure -text $i
	 RLTime::Delay 1
  }
  $gaSet(runTime) configure -text ""
  Status "" 
  puts "Finish Wait $txt $count.....[MyTime]\n"; update
  return 0
}

# ***************************************************************************
# InitDXC
# ***************************************************************************
proc InitDXC {} {	 
  global gaSet
  CloseRL
  RLEH::Open
  set gaSet(idDxc)  [RLDxc4::Open $gaSet(comDXC) -package RLCom]
  set ret [InitFBE1_Framed]
  catch {RLDxc4::Close $gaSet(idDxc)}
  if {$ret!=0} {
    return $ret
  }
  Status "The DXC is configurated" green
}


#***************************************************************************
#** Init_UUT
#***************************************************************************
proc Init_UUT {init} {
  global gaSet
  set gaSet(curTest) $init
  Status ""
  OpenRL
  $init
  CloseRL
  set gaSet(curTest) ""
  Status "Done"
}


# ***************************************************************************
# PerfSet
# ***************************************************************************
proc PerfSet {state} {
  global gaSet gaGui
  set gaSet(perfSet) $state
  puts "PerfSet state:$state"
  switch -exact -- $state {
    1 {$gaGui(noSet) configure -relief raised -image [Bitmap::get images/Set] -helptext "Run with the UUTs Setup"}
    0 {$gaGui(noSet) configure -relief sunken -image [Bitmap::get images/noSet] -helptext "Run without the UUTs Setup"}
    swap {
      if {[$gaGui(noSet) cget -relief]=="raised"} {
        PerfSet 0
      } elseif {[$gaGui(noSet) cget -relief]=="sunken"} {
        PerfSet 1
      }
    }  
  }
}
# ***************************************************************************
# MyWaitFor
# ***************************************************************************
proc MyWaitFor {com expected testEach timeout} {
  global buffer gaGui gaSet
  #Status "Waiting for \"$expected\""
  if {$gaSet(act)==0} {return -2}
  puts [MyTime] ; update
  set startTime [clock seconds]
  set runTime 0
  while 1 {
    #set ret [RLCom::Waitfor $com buffer $expected $testEach]
    #set ret [RLCom::Waitfor $com buffer stam $testEach]
    set ret [Send $com \r stam $testEach]
    foreach expd $expected {
      puts "buffer:$buffer expected:\"$expected\" expd:$expd ret:$ret runTime:$runTime" ; update
#       if {$expd=="PASSWORD"} {
#         ## in old versiond you need a few enters to get the uut respond
#         Send $com \r stam 0.25
#       }
      if [string match *$expd* $buffer] {
        set ret 0
        break
      }
    }
    #set ret [Send $com \r $expected $testEach]
    set nowTime [clock seconds]; set runTime [expr {$nowTime - $startTime}] 
    $gaSet(runTime) configure -text $runTime
    #puts "i:$i runTime:$runTime ret:$ret buffer:_${buffer}_" ; update
    if {$ret==0} {break}
    if {$runTime>$timeout} {break }
    if {$gaSet(act)==0} {set ret -2 ; break}
    update
  }
  puts "[MyTime] runTime:$runTime"
  $gaSet(runTime) configure -text ""
  Status ""
  return $ret
}

# ***************************************************************************
# CreateLicCfg
# ***************************************************************************
proc CreateLicCfg {unit liccfg} {
  global gaSet
  Status "CreateLicCfg $unit $liccfg"
  set id [open $liccfg w]
  puts $id "* License generator Parameters file"
  puts $id "************************************"
  puts $id "* One or more Features"
  puts $id "S.PACK = 11"
  puts $id "TYPE = FULL"
  puts $id "* One or more MAC addresses"
  puts $id "MAC = $gaSet(${::pair}.mac$unit)"
  puts $id "END"
  close $id
  return 0
}

#***************************************************************************
#** SwMMux
#***************************************************************************
proc SwMmux {pair} {
  global gaSet
  puts "SwMmux pair $pair" 
	RLExMmux::AllNC $gaSet(idMmux)
	RLTime::Delay 1
	RLExMmux::ChsCon	$gaSet(idMmux) "${pair},28"
  RLTime::Delay 1
}

# ***************************************************************************
# ConnectMultiMux
# ***************************************************************************
proc ConnectMultiMux {} {
  global gaSet
  RLExMmux::ChsDis $gaSet(idMmux) 1-28
  RLTime::Delay 1
  RLExMmux::ChsCon $gaSet(idMmux) 1  
  RLTime::Delay 1
}



#***************************************************************************
#** Power
#***************************************************************************
proc Power {{uut all} state} {
  global gaSet gaGui  
  set ret 0
  $gaGui(tbrun)  configure -state disabled  
  $gaGui(tbstop) configure -state disabled 
  switch -exact -- $state {
    off {puts "POWER OFF $uut"; set bit 0}
    on  {puts "POWER ON $uut";  set bit 1}
  }  
  if {$uut == "Uut1"} {
		RLExPio::Set $gaSet(rb1Id) $bit
  } elseif {$uut == "Uut2"} {
		RLExPio::Set $gaSet(rb2Id) $bit
	} elseif {$uut == "all"} {
		RLExPio::Set $gaSet(rb1Id) $bit
		RLExPio::Set $gaSet(rb2Id) $bit
	}
  
  $gaGui(tbrun)  configure -state disabled 
  $gaGui(tbstop) configure -state normal
  #Status ""
  update
  return $ret
}

#***************************************************************************
#** PowerOffOn
#***************************************************************************
proc PowerOffOn {} {
  Power all off
  RLTime::Delay 5
  Power all on
}
# ***************************************************************************
# ToolsPowerOn
# ***************************************************************************
proc ToolsPower {{uut all} state} {
	global gaSet
  
	set gaSet(rb1Id) [RLExPio::Open $gaSet(rb1) RBA]
	set gaSet(rb2Id) [RLExPio::Open $gaSet(rb2) RBA]
  switch -exact -- $state {
    off {puts "POWER OFF"; set bit 0}
    on  {puts "POWER ON";  set bit 1}
  } 
	if {$uut == "uut1" || $uut == "all"} {
		RLExPio::Set $gaSet(rb1Id) $bit
	}
  if {$uut == "uut2" || $uut =="all"} {
		RLExPio::Set $gaSet(rb2Id) $bit
	}
	RLExPio::Close $gaSet(rb1Id)
	RLExPio::Close $gaSet(rb2Id)
	return 0
}

#***************************************************************************
#** Wait
#***************************************************************************
proc _Wait {ip_time ip_msg {ip_cmd ""}} {
  global gaSet 
  Status $ip_msg 

  for {set i $ip_time} {$i >= 0} {incr i -1} {       	 
	 if {$ip_cmd!=""} {
      set ret [eval $ip_cmd]
		if {$ret==0} {
		  set ret $i
		  break
		}
	 } elseif {$ip_cmd==""} {	   
	   set ret 0
	 }

	 #user's stop case
	 if {$gaSet(act)==0} {		 
      return -2
	 }
	 
	 RLTime::Delay 1	 
    $gaSet(runTime) configure -text " $i "
	 update	 
  }
  $gaSet(runTime) configure -text ""
  update   
  return $ret  
}

# ***************************************************************************
# AddToLog
# ***************************************************************************
proc AddToLog {line} {
  global gaSet
  #set logFileID [open tmpFiles/logFile-$gaSet(pair).txt a+]
  set logFileID [open $gaSet(logFile.$gaSet(pair)) a+] 
  puts $logFileID "..[MyTime]..$line"
  close $logFileID
}
# ***************************************************************************
# AddToPairLog
# ***************************************************************************
proc AddToPairLog {pair line}  {
  global gaSet
  set logFileID [open $gaSet(log.$pair) a+]
  puts $logFileID "..[MyTime]..$line"
  close $logFileID
}

# ***************************************************************************
# ShowLog
# ***************************************************************************
proc ShowLog {} {
	global gaSet
	#exec notepad tmpFiles/logFile-$gaSet(pair).txt &
  if {[info exists gaSet(logFile.$gaSet(pair))] && [file exists $gaSet(logFile.$gaSet(pair))]} {
    exec notepad $gaSet(logFile.$gaSet(pair)) &
  }
}

# ***************************************************************************
# mparray
# ***************************************************************************
proc mparray {a {pattern *}} {
  upvar 1 $a array
  if {![array exists array]} {
	  error "\"$a\" isn't an array"
  }
  set maxl 0
  foreach name [lsort -dict [array names array $pattern]] {
	  if {[string length $name] > $maxl} {
	    set maxl [string length $name]
  	}
  }
  set maxl [expr {$maxl + [string length $a] + 2}]
  foreach name [lsort -dict [array names array $pattern]] {
	  set nameString [format %s(%s) $a $name]
	  puts stdout [format "%-*s = %s" $maxl $nameString $array($name)]
  }
  update
}
# ***************************************************************************
# GetDbrName
# ***************************************************************************
proc GetDbrName {} {
  global gaSet gaGui gaGet   
  pack forget $gaGui(frFailStatus)  
  catch {unset gaSet(TraceID)}
  catch {unset gaSet(DutID)}
  puts "[MyTime] GetDbrName $gaSet(entDUT) $gaSet(entTrace)" ; update
  set barcode $gaSet(entDUT)
  set ::barcode $barcode
  Status "Wait for receiving data from DBR"
  if [file exists MarkNam_$barcode.txt] {
    file delete -force MarkNam_$barcode.txt
  }
  wm title . "$gaSet(pair) : "
  after 500
  
  catch {exec java -jar $::RadAppsPath/OI4Barcode.jar $barcode} b
  set fileName MarkNam_$barcode.txt
  after 1000
  if ![file exists MarkNam_$barcode.txt] {
    set gaSet(fail) "File $fileName is not created. Verify the Barcode"
    #exec C:\\RLFiles\\Tools\\Btl\\failbeep.exe &
    RLSound::Play failbeep
	  Status "Test FAIL"  red
    DialogBox -aspect 2000 -type Ok -message $gaSet(fail) -icon images/error
    pack $gaGui(frFailStatus)  -anchor w
	  $gaSet(runTime) configure -text ""
  	return -1
  }
  
  set fileId [open "$fileName"]
    seek $fileId 0
    set res [read $fileId]    
  close $fileId
  
  #set txt "$barcode $res"
  set txt "[string trim $res]"
  #set gaSet(entDUT) $txt
  ##set gaSet(entDUT) ""
  ##set gaSet(entTrace) ""
  puts <$txt>
  
  set initName [regsub -all / $res .]
  set gaSet(DutFullName) $res
  set gaSet(DutInitName) $initName.tcl
  SaveInit
  
  file delete -force MarkNam_$barcode.txt
  #file mkdir [regsub -all / $res .]
}  
# ***************************************************************************
# SourceInitFile
# ***************************************************************************
proc SourceInitFile {} {  
  global gaSet gaGui
  if {[file exists uutInits/$gaSet(DutInitName)]} {   
    source uutInits/$gaSet(DutInitName)  
    puts "SourceInitFile uutInits/$gaSet(DutInitName)"
    UpdateAppsHelpText  
  } else {
    if [string match *HWRev* $gaSet(DutInitName)  ] {
       regexp {(.+)\.HWR} $gaSet(DutInitName) ma ini
       set iniFile $ini.tcl
       if [file exists uutInits/$iniFile] {
         set refId [open uutInits/$iniFile r]
         set iniId [open uutInits/$gaSet(DutInitName) w]
         puts "ref:<uutInits/$iniFile> ini:<uutInits/$gaSet(DutInitName)>"
         while {[gets $refId line]>=0} { 
           if {[string match *DutInitName* $line]} {
             ## don't copy DutInitName 
           } else {
             puts "line:<$line>"
             puts $iniId $line
           }
         }
         update
         close $refId
         close $iniId
         after 100
         source uutInits/$iniFile
       }
    } else {
      ## if the init file doesn't exist, fill the parameters by ? signs
      puts "SourceInitFile fill parameters for uutInits/$gaSet(DutInitName) by ???"
      foreach v {sw hw bootVer uut ps eth e1 wire} {
        set gaSet($v) ???
      }
      
      foreach en {licEn uafEn udfEn plEn} {
        set gaSet($en) 0
      } 
    }
  } 
  wm title . "$gaSet(pair) : $gaSet(DutFullName)"
  
#  06/11/2018 16:26:08 set gaSet(entDUT) ""
#   set gaSet(entTrace) ""
  pack forget $gaGui(frFailStatus)   
  Status "Done"
  update
  set gaSet(TestMode) "long"
  BuildTests
  #focus -force $gaGui(tbrun)
}
# ***************************************************************************
# GetHWrevFromPage
# ***************************************************************************
proc GetHWrevFromPage {} {
  Status "Wait for receiving Pages from DBR"
  global gaSet gaGet
  array unset gaSet pageHW
  after 100
    
  if {$gaSet(readTrace)==1} {
    set ret [GetPageFile $gaSet(entDUT) $gaSet(entTrace)]
  } elseif {$gaSet(readTrace)==0} {
    set ret [GetPageFile $gaSet(entDUT)]
  } 
  puts "ret of GetPageFile:<$ret>"; update
  if {$ret==0} {
    catch {unset gaSet(pageFilePath)}
  }
  if {$gaSet(readTrace)==0} {
    SavePageFile $ret $gaSet(entDUT)
  } elseif {$gaSet(readTrace)==1} {
    SavePageFile $ret $gaSet(entDUT) $gaSet(entTrace)
  }
  
  set gaSet(TraceID) $gaSet(entTrace)
  set gaSet(DutID) $gaSet(entDUT)
  set gaSet(entDUT) ""
  set gaSet(entTrace) ""

  if {$ret!=0} {
    Finish $ret
    return $ret
  } 
      
  set gaSet(pageHWRev) [lindex [split $gaGet(page2)] 12] 
  set uutHWRev [ParsePageHWrev2UutHWrev $gaSet(pageHWRev)]
  
  set initName [file rootname $gaSet(DutInitName)]
  set gaSet(DutInitName) $initName.HWRev${uutHWRev}.tcl
  puts "pageHWRev:<$gaSet(pageHWRev)>"; update

  SourceInitFile
  Status "Done"
  SaveInit
  return 0
}
  

# ***************************************************************************
# DelMarkNam
# ***************************************************************************
proc DelMarkNam {} {
  if {[catch {glob MarkNam*} MNlist]==0} {
    foreach f $MNlist {
      file delete -force $f
    }  
  }
}

# ***************************************************************************
# GetInitFile
# ***************************************************************************
proc GetInitFile {} {
  global gaSet gaGui
  set fil [tk_getOpenFile -initialdir [pwd]/uutInits  -filetypes {{{TCL Scripts} {.tcl}}} -defaultextension tcl]
  if {$fil!=""} {
    source $fil
    set gaSet(entDUT) "" ; #$gaSet(DutFullName)
    wm title . "$gaSet(pair) : $gaSet(DutFullName)"
    UpdateAppsHelpText
    pack forget $gaGui(frFailStatus)
    Status ""
    BuildTests
  }
}
# ***************************************************************************
# UpdateAppsHelpText
# ***************************************************************************
proc UpdateAppsHelpText {} {
  global gaSet gaGui
  $gaGui(labPlEn) configure -helptext $gaSet(pl)
  $gaGui(labUafEn) configure -helptext $gaSet(uaf)
  $gaGui(labUdfEn) configure -helptext $gaSet(udf)
}

# ***************************************************************************
# PingTest
# ***************************************************************************
proc PingTest {uut} {
  global gaSet buf
  Status "Ping to $uut"
  set nPings 2
  set ip 1.1.1.[set gaSet(pair)][string index $uut end]
  for {set pingTry 1} {$pingTry <= 5} {incr pingTry 1} {
    if {[catch {exec ping $ip -n $nPings} buf]!=0} {
      puts "1pingTry:$pingTry ****** $buf ********"        
      if {$pingTry == 5} {
        set gaSet(fail) "Ping to $uut failed"
        return -1
      }
    } else {
      #puts "buf:<$buf>"
      break
    }
  }
  puts "2pingTry:$pingTry ip:<$ip> buf:<$buf>" 
  if {[regexp -all "$ip" $buf] != [expr {2+$nPings}] || [regexp -all "TTL" $buf] != $nPings} {
    set gaSet(fail) "Ping to $uut failed"
    return -1
  }
  return 0
}

# ***************************************************************************
# E1Mux
# ***************************************************************************
proc E1Mux {uut massNum} {
  global gaSet
  if {$uut=="Uut1"} {
    set id $gaSet(mmux5Id)  
  } elseif {$uut=="Uut2"} {
    set id $gaSet(mmux6Id)  
  }
  RLExMmux::AllNC $id
  after 500
  RLExMmux::ChsCon $id 14,$massNum,28,[expr $massNum + 14]
}

# ***************************************************************************
# TrapCheck
# ***************************************************************************
proc TrapCheck {uut tmsg str} {
  global gaSet 
  set ip 1.1.1.[set gaSet(pair)][string index $uut end]
  set ::tm $tmsg
  puts "TrapCheck $uut \"$tmsg\" \"$str\""
  if {[string match *$ip* $tmsg] && [string match "*$str*" $tmsg]} {
    return 0
  } else {
    return -1
  }
}
# ***************************************************************************
# wsplit
# ***************************************************************************
proc wsplit {str sep} {
  split [string map [list $sep \0] $str] \0
}

# ***************************************************************************
# OpenTeraTerm
# ***************************************************************************
proc OpenTeraTerm {comName} {
  global gaSet
  set path1 C:\\Program\ Files\\teraterm\\ttermpro.exe
  set path2 C:\\Program\ Files\ \(x86\)\\teraterm\\ttermpro.exe
  if [file exist $path1] {
    set path $path1
  } elseif [file exist $path2] {
    set path $path2  
  } else {
    puts "no teraterm installed"
    return {}
  }
  if {[string match *Uut* $comName] || [string match *Dls* $comName]} {
    set baud 9600
  } else {
    set baud 115200
  }
  regexp {com(\w+)} $comName ma val
  set val Tester-$gaSet(pair).[string toupper $val]  
  exec $path /c=[set $comName] /baud=$baud /W="$val" &
  return {}
}  

# ***************************************************************************
# ParsePageHWrev2UutHWrev 
#  32 -> 2.1
#  F2 -> 14.1
# ***************************************************************************
proc ParsePageHWrev2UutHWrev {pageHWrev} {
  foreach {a b} [split $pageHWrev ""] {
    set uutHWrev [expr {[scan $a %x]-1}].[expr {[scan $b %x]-1}]
  }
  return $uutHWrev
}
# ***************************************************************************
# ParseUutHWrev2PageHWrev 
# 0.1 ->  12
# 14.1 -> F2
# ***************************************************************************
proc ParseUutHWrev2PageHWrev {uutHWrev} {
  foreach {a b} [split $uutHWrev .] {
    set pageHWrev [format %X [expr {$a+1}]][format %X [expr {$b+1}]]
  }
  return $pageHWrev
}
# ***************************************************************************
# RetriveDutFam
# ***************************************************************************
proc RetriveDutFam {} {
  global gaSet
  if {[string match *.D.* $gaSet(DutInitName)]==1 || [string match *.M.* $gaSet(DutInitName)]==1  || [string match *4E1* $gaSet(DutInitName)]==1} {
    ## phase 3.5
    ## ASMI-54N.4ETH.D.8W.tcl
    ## ASMI-54.4ETH.8W.M.tcl
    ## ASMI-54.4ETH.8W.M.ME.tcl
    #ASMI-54.4E1.4ETH_RADBR.ETR.8W.ME.SKD.tcl
    set gaSet(dutFam) f35
  } elseif {[string match *-54L.RT.* $gaSet(DutInitName)]==1} {
    set gaSet(dutFam) LRT
  } elseif {[string match *54L_BLN.* $gaSet(DutInitName)]==1 || [string match *54LM.* $gaSet(DutInitName)]==1 || [string match *-54L.* $gaSet(DutInitName)]==1 || [string match *I54L.* $gaSet(DutInitName)]==1} {
    set gaSet(dutFam) L
  } else {
    set gaSet(dutFam) 54
  }
  return {}
}
# ***************************************************************************
# SavePageFile
# ***************************************************************************
proc SavePageFile {ret barcode {trac ""} } {
  global gaSet
  
  ## don't save good page file
  if {$ret!=0} {
    if {![file exists c:/tmpDir]} {
      file mkdir c:/tmpDir   
    }
    catch {unset gaSet(pageFilePath)}
    set ti [clock format [clock seconds] -format  "%Y.%m.%d_%H.%M.%S"]
    set gaSet(pageFilePath) c:/tmpDir/${ti}_$barcode.txt  
    file copy $barcode.txt $gaSet(pageFilePath)
    after 500
    set id [open $gaSet(pageFilePath) a]
      puts $id ""
      puts $id "ID number: $barcode"
      if {$trac!=""} {
        puts $id "Traceability number: $trac"
      }
      puts $id ""
    close $id
  }
        
  file delete $barcode.txt
}

# ***************************************************************************
# ChoosePageFile
# ***************************************************************************
proc ChoosePageFile {} {
  global gaSet gaGui
  if {$gaSet(pageType)=="Local"} {
    #-initialdir [pwd]/uutInits
    set fil [tk_getOpenFile -initialdir c:/LocalPages -filetypes {{{Page} {.txt}}} -defaultextension txt]
    if {$fil!=""} {
      set gaSet(localPageFile) $fil  
      .menubar.tools entryconfigure 40 -label "Local Page: [file tail $fil]"   
    } else {
      if {$gaSet(localPageFile)==""} {
        set gaSet(pageType) System
        .menubar.tools entryconfigure 40 -label "Local Page"
      }
    }
  } elseif {$gaSet(pageType)=="System"}  {
    .menubar.tools entryconfigure 40 -label "Local Page"
    set gaSet(localPageFile) ""
  }
}
# ***************************************************************************
# CheckMac
# ***************************************************************************
proc CheckMac {barcode pair uut} {
  global gaSet
  puts "CheckMac $barcode pair: $pair uut: $uut" ; update 
  set res [catch {exec $gaSet(javaLocation)/java.exe -jar $::RadAppsPath/checkmac.jar $barcode AABBCCFFEEDD} retChk]
  puts "CheckMac res:<$res> retChk:<$retChk>" ; update
  if {$res=="1" && $retChk=="0"} {
    puts "No Id-MAC link"
    set gaSet($pair.barcode$uut.IdMacLink) "noLink"
  } else {
    puts "Id-Mac link or error"
    set gaSet($pair.barcode$uut.IdMacLink) "link"
  }
  return {}
}

# ***************************************************************************
# UpdateInitsToTesters
# ***************************************************************************
proc UpdateInitsToTesters {} {
  global gaSet
  if {$gaSet(radNet)==0} {return 0}
  set sdl [list]
  set unUpdatedHostsL [list]
  set hostsL [list at-asmi54-2-w10 at-asmi54-3-w10]
  set initsPath ASMi54/uutInits
  #set usDefPath AT-ETX-2i-10G/ConfFiles/DEFAULT
  
  set s1 c:/$initsPath
  #set s2 c:/$usDefPath
  foreach host $hostsL {
    if {$host!=[info host]} {
      set dest //$host/c$/$initsPath
      if [file exists $dest] {
        lappend sdl $s1 $dest
      } else {
        lappend unUpdatedHostsL $host        
      }
      
#       set dest //$host/c$/$usDefPath
#       if [file exists $dest] {
#         lappend sdl $s2 $dest
#       } else {
#         lappend unUpdatedHostsL $host        
#       }
    }
  }
  
  set msg ""
  set unUpdatedHostsL [lsort -unique $unUpdatedHostsL]
  if {$unUpdatedHostsL!=""} {
    append msg "The following PCs are not reachable:\n"
    foreach h $unUpdatedHostsL {
      append msg "$h\n"
    }  
    append msg \n
  }
  if {$sdl!=""} {
    if {$gaSet(radNet)} {
      set emailL {ilya_g@rad.com}
    } else {
      set emailL [list]
    }
    set ret [RLAutoUpdate::AutoUpdate $sdl]
    set updFileL    [lsort -unique $RLAutoUpdate::updFileL]
    set newestFileL [lsort -unique $RLAutoUpdate::newestFileL]
    if {$ret==0} {
      if {$updFileL==""} {
        ## no files to update
        append msg "All files are equal, no update is needed"
      } else {
        append msg "Update is done"
        if {[llength $emailL]>0} {
          RLAutoUpdate::SendMail $emailL $updFileL "file://R:\\IlyaG\\ASMi54"
          if ![file exists R:/IlyaG/ASMi54] {
            file mkdir R:/IlyaG/ASMi54
          }
          foreach fi $updFileL {
            catch {file copy -force $s1/$fi R:/IlyaG/ASMi54 } res
            puts $res
            catch {file copy -force $s2/$fi R:/IlyaG/ASMi54 } res
            puts $res
          }
        }
      }
      tk_messageBox -message $msg -type ok -icon info -title "Tester update" ; #DialogBox icon /images/info
    }
  } else {
    tk_messageBox -message $msg -type ok -icon info -title "Tester update"
  } 
}
