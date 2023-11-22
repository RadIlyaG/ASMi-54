# ***************************************************************************
# BuildTests
# ***************************************************************************
proc BuildTests {} {
  global gaSet gaGui glTests
  
  if {![info exists gaSet(DutInitName)] || $gaSet(DutInitName)==""} {
    puts "\n[MyTime] BuildTests DutInitName doesn't exists or empty. Return -1\n"
    return -1
  }
  puts "\n[MyTime] BuildTests DutInitName:$gaSet(DutInitName)\n"
                                 
#   if {[string match *.D.* $gaSet(DutInitName)]==1 || [string match *.M.* $gaSet(DutInitName)]==1  || [string match *4E1* $gaSet(DutInitName)]==1} {
#     ## phase 3.5
#     ## ASMI-54N.4ETH.D.8W.tcl
#     ## ASMI-54.4ETH.8W.M.tcl
#     ## ASMI-54.4ETH.8W.M.ME.tcl
#     #ASMI-54.4E1.4ETH_RADBR.ETR.8W.ME.SKD.tcl
#     set gaSet(dutFam) f35
#   } elseif {[string match *-54L.RT.* $gaSet(DutInitName)]==1} {
#     set gaSet(dutFam) LRT
#   } elseif {[string match *54L_BLN.* $gaSet(DutInitName)]==1 || [string match *54LM.* $gaSet(DutInitName)]==1 || [string match *-54L.* $gaSet(DutInitName)]==1 || [string match *I54L.* $gaSet(DutInitName)]==1} {
#     set gaSet(dutFam) L
#   } else {
#     set gaSet(dutFam) 54
#   }
  RetriveDutFam
  source Lib_Put_ASMi54_$gaSet(dutFam).tcl
  
  set lTests [list]
  set lTestNames [list]
  if {$gaSet(dutFam)=="L" || $gaSet(dutFam)=="LRT"} {
    ## set Pages at the begining
    lappend lTestNames Pages
  }
  if {$gaSet(plEn)==1 && $gaSet(pl)!=""} {
    lappend lTestNames PreLoadAppl
  }  
  lappend lTestNames Init ID
  
  if {$gaSet(dutFam)=="f35" && [string match *4E1* $gaSet(DutInitName)]==0} {
    ## phase 3.5 no E1
    lappend lTestNames IntRcv_192 RcvInt_2304 IntRcv_3840 RcvInt_5696
  } elseif {$gaSet(dutFam)=="f35" && [string match *4E1* $gaSet(DutInitName)]==1} {
    ## phase 3.5 E1
    lappend lTestNames IntRcv_E1_3840 RcvInt_E1_2304 RcvExt_E1_5696 ExtRcv_E1_192 
  } else {
    lappend lTestNames IntRcv_192
    if {[string match *.E1.* $gaSet(DutInitName)]==0} {
      ## no E1
      lappend lTestNames IntRcv_2304 IntRcv_3840 RcvInt_5696
    } elseif {[string match *.E1.* $gaSet(DutInitName)]==1} {
      ## E1 , ASMI-54L.4ETH.4W.E1.tcl
      lappend lTestNames RcvInt_E1_3840_7808 ExtRcv_E1_5696_11392 RcvExt_E1_192_384
    }
  }
  ##               3     4                   5                     6   
  
  if {[string match *.D.* $gaSet(DutInitName)]==1} {
    lappend lTestNames Relays
  }  
  if {$gaSet(dutFam)=="L"} {
    #if {$gaSet(ps)=="24VDC" || $gaSet(TestMode)=="beeline"} {}
    if {$gaSet(ps)=="24VDC"} {
      lappend lTestNames Memory
    } else {
      lappend lTestNames Memory_DyingGasp
    }  
  } else {
    lappend lTestNames Memory
  }  
  
  #lappend lTestNames FactorySet Mac_BarCode Leds  
  ##UploadAppl License SaveUserFile
  ##                  7          8           9     10          11         12       13
    
  set lTests        "0 1 2 3 4 5 6 7 8"    
  set glTests ""
  if {$gaSet(uafEn)==1} {
    lappend lTestNames UploadAppl  
  } elseif {$gaSet(uafEn)==0} {
    if {[string match *54L_BLN.* $gaSet(DutInitName)]==1} {
      ##lappend lTestNames SwPowerReset BeeLine_Configuration
      ## 29/10/2018 08:44:08  No need to check SwPowerReset - C29593 is cancelled
      lappend lTestNames BeeLine_Configuration
    } else {
      lappend lTestNames FactorySet  
    }
  }
  if {$gaSet(licEn)==1} {
    lappend lTestNames License  CheckLicense
  }
  if {$gaSet(udfEn)==1} {
    lappend lTestNames SaveUserFile
  }
   
  if {[string match *54L_BLN.* $gaSet(DutInitName)]==1} {
    lappend lTestNames FactorySet_Button
  }
  lappend lTestNames Leds
  lappend lTestNames Mac_BarCode

  for {set i 0; set k 1} {$i<[llength $lTestNames]} {incr i; incr k} {
    lappend glTests "$k..[lindex $lTestNames $i]"  
  }
  
  set gaSet(startFrom) [lindex $glTests 0]
  $gaGui(startFrom) configure -values $glTests
  
  UpdateDlsFields
  set gaSet(debugTests) [list]
  return 0
}
# ***************************************************************************
# Testing
# ***************************************************************************
proc Testing {} {
  global gaSet glTests
#   set ret [UUTsReboot] ; # 20
#   if {$ret!=0} {
#     set ret [UUTsUp]
#     if {$ret!=0} {return $ret}
#   }
  
  set startTime [$gaSet(startTime) cget -text]
  set stTestIndx [lsearch $glTests $gaSet(startFrom)]
  set lRunTests [lrange $glTests $stTestIndx end]
  
  set lPassPair [list]
  file delete -force tmpFiles/passPair-$gaSet(pair).tcl
  set passPairID [open tmpFiles/passPair-$gaSet(pair).tcl a+]
  puts -nonewline $passPairID "set lPassPair \[list"
  close $passPairID
  
#   if {[string match {*Mac_BarCode*} $gaSet(startFrom)]} {
#     set passPairID [open tmpFiles/passPair-$gaSet(pair).tcl a+]
#     foreach pair [PairsToTest] {      
#       puts -nonewline $passPairID " $pair"
#     }
#     #puts -nonewline $passPairID " \]"
#     close $passPairID
#     set ret 0
#   }
       
  puts "lRunTests 1: $lRunTests"
    
  foreach pair [PairsToTest] {
    #puts "pair:$pair lRunTests: <$lRunTests>"
    if {$gaSet(pair)=="5"} {
      puts "pair:$pair lRunTests: <$lRunTests>"
    } else {
      puts "pair:$gaSet(pair) lRunTests: <$lRunTests>"
    }
    set ::pair $pair
    if {[string match {*FactorySet_Button*} $gaSet(startFrom)] ||\
        [string match {*Leds*} $gaSet(startFrom)] ||\
        [string match {*Mac_BarCode*} $gaSet(startFrom)] ||\
        [string match {*SwPowerReset*} $gaSet(startFrom)]} {
      ## if we start from Leds, just sign all pairs as goods and do not perform nothing
      set passPairID [open tmpFiles/passPair-$gaSet(pair).tcl a+]
      puts -nonewline $passPairID " $pair"
      close $passPairID
      set ret 0
      continue
    }  
    
    if {$gaSet(act)==0} {break}
    
    if {[lsearch [PairsToTest] $pair]=="-1"} {
      continue
    }
    
    set ::pair $pair
    if {$gaSet(pair)=="5"} {
      puts "\n\n ********* PAIR $pair start *********..[MyTime].."
      Status "PAIR $pair start"
    } else {
      puts "\n\n ********* PAIR $gaSet(pair) start *********..[MyTime].."
      Status "PAIR $gaSet(pair) start"
    }
#     puts "\n\n ********* PAIR $pair start *********..[MyTime].."
#     Status "PAIR $pair start"
    set gaSet(curTest) ""
    PairPerfLab $pair yellow
    MassConnect $pair
    SwEth gen
    SwShdsl range
    update

    puts "RunTests1 gaSet(startFrom):$gaSet(startFrom)"
    
    AddToLog "********* UUT: $gaSet(DutFullName) *********"
    if {$gaSet(pair)=="5"} {
      AddToLog "********* PAIR $pair start *********" 
      AddToPairLog $::pair "********* PAIR $pair start *********"
      AddToPairLog $::pair "$gaSet(relDebMode) mode"
    } else {
      AddToLog "********* PAIR $gaSet(pair) start *********"
      AddToPairLog $gaSet(pair) "********* PAIR $pair start *********"
      AddToPairLog $gaSet(pair) "$gaSet(relDebMode) mode"
    }
    foreach numberedTest $lRunTests {
      if {([string match *54L_BLN.* $gaSet(DutInitName)]==1 && \
          ([string match {*FactorySet_Button*} $numberedTest] || [string match {*SwPowerReset*} $gaSet(startFrom)])) ||\
          ([string match {*Leds*} $numberedTest]) ||
          ([string match {*Mac_BarCode*} $numberedTest]) } {
        ## do not perform the Leds Test and Mac_BarCode together with all tests
        ## it will performed for all passed pairs at end of the proc
        continue
      }  
      set gaSet(curTest) $numberedTest
      puts "\n **** Pair ${pair}. Test $numberedTest start; [MyTime] "
      update
      
      set testName [lindex [split $numberedTest ..] end]
      $gaSet(startTime) configure -text "$startTime ."
      AddToLog "Test $numberedTest start"
      if {$gaSet(pair)=="5"} {
        AddToPairLog $::pair "Test $numberedTest start"
      } else {   
        AddToPairLog $gaSet(pair) "Test $numberedTest start"    
      }
      set ret 0 ; #[UUTsUp]
      if {$ret==0} {
        set ret [$testName 1]
      }
      puts "1 testName:$testName ret:$ret" ; update

      PerfSet 1 
      AddToLog "Test $numberedTest finish. Result: $ret" 
      if {$gaSet(pair)=="5"} {
        set pa $::pair
      } else {   
        set pa $gaSet(pair) 
      }
      AddToPairLog $pa "Test $numberedTest finish. Result: $ret"
      puts "\n **** Pair ${pair}. Test $numberedTest finish;  ret of $numberedTest is: $ret;  [MyTime]\n" 
      update
      if {$ret!=0} {
  #       set gaSet(startFrom) $gaSet(curTest)
  #       update
        if {$ret=="-1"} {
          UnregIdBarcode $pa $gaSet($pa.barcodeUut1)
          UnregIdBarcode $pa $gaSet($pa.barcodeUut2)
        }
        break
      }
      if {$gaSet(oneTest)==1} {
        set ret 0
        break
      }
    }  
    
    if {$ret==0} {
      PairPerfLab $pair #ddffdd ; #$gaSet(halfPassClr) ; # #ccffcc ; #green  ; #ddffdd
      
      set passPairID [open tmpFiles/passPair-$gaSet(pair).tcl a+]
        puts -nonewline $passPairID " $pair"
      close $passPairID
      set retTxt Pass
      set logText "All tests pass"
    } else {
      set logText "Test $numberedTest fail. Reason: $gaSet(fail)" 
      PairPerfLab $pair red
      set retTxt Fail            
    }
              
    if {($ret!=0) && ($pair==[lindex [PairsToTest] end])} {
      ## the test failed and the pair is last (or single) and  - do nothing
    } else {
      if {[string match {*Mac_BarCode*} $gaSet(startFrom)]} {
        # the Tester started with Mac_BarCode, then just perform this test in all pairs
      } else {
        if {$gaSet(nextPair)=="begin"} {
          # the next pair will start from first test
          set gaSet(startFrom) [lindex $glTests 0]
          set startIndx [lsearch $glTests $gaSet(startFrom)]
          set lRunTests [lrange $glTests $startIndx end]
#           set gaSet(startFrom) [lindex $lRunTests 0]
#           set startIndx [lsearch $lRunTests $gaSet(startFrom)]
          puts "glTests:$glTests   lRunTests:$lRunTests"
          update
        } elseif {$gaSet(nextPair)=="same"} {
          ## do nothing
        }
      }  
    }
    
    if {$gaSet(pair)=="5"} {
      set pa $pair
    } else {
      set pa $gaSet(pair)
    }
    puts "********* PAIR $pa finish *********..[MyTime]..\n\n"
    #AddToLog "$logText \n    ********* PAIR $pa $retTxt   *********\n"
    #AddToPairLog $pa "$logText \n    ********* PAIR $pa $retTxt   *********\n"
    if {$ret!=0} {
      AddToLog "$logText \n    ********* PAIR $pa $retTxt   *********\n"
      AddToPairLog $pa "$logText \n    ********* PAIR $pa $retTxt   *********\n"
      file rename $gaSet(log.$pa) [file rootname $gaSet(log.$pa)]-Fail.txt
      set gaSet(runStatus) Fail
      if {$ret!="-2"} {
        SQliteAddLine $::pair; # $pa
      }  
    }
    
    if {$gaSet(nextPair)=="begin"} {
      set gaSet(oneTest) 0
    } elseif {$gaSet(nextPair)=="same"} {
      ## do nothing
    }      
  }
  set gaSet(oneTest) 0
  set passPairID [open tmpFiles/passPair-$gaSet(pair).tcl a+]
  puts -nonewline $passPairID "\]"
  close $passPairID

  source tmpFiles/passPair-$gaSet(pair).tcl
  set lPassPair [lsort -unique -dict $lPassPair]
  puts "lPassPair:<$lPassPair>, llength $lPassPair:[llength $lPassPair]"
  
  if {$gaSet(act)==0} {return -2}
  
  set retLed 0
  set retBeeDefBut 0
  set retMacReg 0
  if {[llength $lPassPair]>0 && $gaSet(TestMode)!="PreloadOnly" && $gaSet(TestMode)!="shortPreLoad" && $gaSet(TestMode)!="short"} {
    
    if {[string match *54L_BLN.* $gaSet(DutInitName)]==1} {
      set sprIndx [lsearch -glob $glTests *SwPowerReset*]
      if {$sprIndx!="-1"} {
        set lBLPORSTfail [list]
        foreach pair $lPassPair {
          if {$gaSet(act)==0} {return -2}
          AddToLog "Pair:$pair Test..BeeLine Power Reset start"  
          if {$gaSet(pair)=="5"} {
            AddToPairLog $pair "Pair $pair Test..BeeLine Power Reset start"
          } else {
            AddToPairLog $gaSet(pair) "Pair $gaSet(pair) Test..BeeLine Power Reset start"
          }
          PairPerfLab $pair yellow  
          set ret [PoRst $pair]
          if {$ret!=0} {
            #set gaSet(fail) "Check BeeLine Default Fail"
            set retBeePORST -1
            AddToLog $gaSet(fail)
            if {$gaSet(pair)=="5"} {
              set pa $pair 
            } else {
              set pa $gaSet(pair)
            }
            AddToPairLog $pa "Pair $pa Test..BeeLine Power Reset finish. Result: -1"
            AddToPairLog $pa "Pair $pa Test..BeeLine Power Reset fail. Reason: $gaSet(fail)"
            
            lappend lBLPORSTfail $pair  
            PairPerfLab $pair red   
            file rename $gaSet(log.$pa) [file rootname $gaSet(log.$pa)]-Fail.txt 
            set gaSet(runStatus) Fail
            if {$ret!="-2"} {
              SQliteAddLine $::pair; #  $pa
              UnregIdBarcode $pa $gaSet($pa.barcodeUut1)
              UnregIdBarcode $pa $gaSet($pa.barcodeUut2)
            }  
          } else {
            AddToLog "Pair:$pair Test..BeeLine Power Reset finish. Result: 0"
            if {$gaSet(pair)=="5"} {
              set pa $pair 
            } else {
              set pa $gaSet(pair)       
            } 
            AddToPairLog $pa "Pair:$pa Test..BeeLine Power Reset finish. Result: 0"  
            PairPerfLab $pair #ddffdd       
          }
           
        }
        if {[llength $lBLPORSTfail]>0} {
          puts "lPassPair1 <$lPassPair> lBLPORSTfail <$lBLPORSTfail>"
          foreach BLPORSTfail $lBLPORSTfail {
            set lPassPair [lreplace $lPassPair [lsearch $lPassPair $BLPORSTfail] [lsearch $lPassPair $BLPORSTfail]]
          }
          #set lPassPair $lPassPair2
          puts "lPassPair2 <$lPassPair>"
        }
      }
      
      set fsbIndx [lsearch -glob $glTests *FactorySet_Button*]
      if {$fsbIndx!="-1" && [llength $lPassPair]>0} {
        Status "Press the \'Set to default\' button"
        set gaSet(curTest) [lindex $glTests $fsbIndx]
        if {[llength $lPassPair]==1} {
          set tx1 pair
        } elseif {[llength $lPassPair]>1} {
          set tx1 pairs
        }
        set txt "On each modem of $tx1 $lPassPair\n\
        press the \'Set to default\' button on the rear panel, wait for 7-10 seconds and then release.\n\
        Be sure modems are rebooted"      
        set res [DialogBox -title "BeeLine Set To Default" -text $txt -type {Ok Cancel}]
        if {$res=="Cancel"} {
          set gaSet(fail) "Set To BeeLine Default Fail"
          AddToLog $gaSet(fail)
          foreach pair $lPassPair {
            if {$gaSet(pair)=="5"} {
              AddToPairLog $pair "Pair $pair $gaSet(fail)"
            } else {
              AddToPairLog $gaSet(pair) "Pair $gaSet(pair) $gaSet(fail)"
            }
          }
          return -2
        }
      }     
       
      set lBLfail [list]
      foreach pair $lPassPair {
        if {$gaSet(act)==0} {return -2}
        AddToLog "Pair:$pair Test..BeeLine Default start"  
        if {$gaSet(pair)=="5"} {
          AddToPairLog $pair "Pair $pair Test..BeeLine Default start"
        } else {
          AddToPairLog $gaSet(pair) "Pair $gaSet(pair) Test..BeeLine Default start"
        }
        PairPerfLab $pair yellow
        set ret [BeeLine_DefaultCheck $pair]
        if {$ret!=0} {
          #set gaSet(fail) "Check BeeLine Default Fail"
          set retBeeDefBut -1
          AddToLog $gaSet(fail)
          if {$gaSet(pair)=="5"} {
            set pa $pair 
          } else {
            set pa $gaSet(pair)
          }
          AddToPairLog $pa "Pair $pa Test..BeeLine Default finish. Result: -1"
          AddToPairLog $pa "Pair $pa Test..BeeLine Default fail. Reason: $gaSet(fail)"
          lappend lBLfail $pair  
          PairPerfLab $pair red   
          file rename $gaSet(log.$pa) [file rootname $gaSet(log.$pa)]-Fail.txt 
          set gaSet(runStatus) Fail
          if {$ret!="-2"} {
            SQliteAddLine  $::pair; # $pa
            UnregIdBarcode $pa $gaSet($pa.barcodeUut1)
            UnregIdBarcode $pa $gaSet($pa.barcodeUut2)
          }  
        } else {
          AddToLog "Pair:$pair Test..BeeLine Default finish. Result: 0"
          if {$gaSet(pair)=="5"} {
            set pa $pair 
          } else {
            set pa $gaSet(pair)       
          } 
          AddToPairLog $pa "Pair:$pa Test..BeeLine Default finish. Result: 0"  
          PairPerfLab $pair #ddffdd       
        }
      }
      
      ## remove fail pairs from lPassPair
      if {[llength $lBLfail]>0} {
        puts "lPassPair1 <$lPassPair> lBLfail <$lBLfail>"
        foreach BLfail $lBLfail {
          set lPassPair [lreplace $lPassPair [lsearch $lPassPair $BLfail] [lsearch $lPassPair $BLfail]]
        }
        #set lPassPair $lPassPair2
        puts "lPassPair2 <$lPassPair>"
      }      
    }
    
    if {$gaSet(act)==0} {return -2}
    
    set ledsIndx [lsearch -glob $glTests *Leds]
    if {$ledsIndx!="-1"} {
      set gaSet(curTest) [lindex $glTests $ledsIndx]
      set lLEDfail [list]
      foreach pair $lPassPair {
        if {$gaSet(act)==0} {return -2}
        AddToLog "Pair:$pair Test..Leds start"  
        if {$gaSet(pair)=="5"} {
          set pa $pair        
        } else {
          set pa $gaSet(pair)
        }
        AddToPairLog $pa "Pair $pa Test..Leds start"
        
        set res [Leds $pair]
        if {$res!=0} {
          set retLed -1
          lappend lLEDfail $pair
          set retTxt Fail 
          PairPerfLab $pair red
          file rename $gaSet(log.$pa) [file rootname $gaSet(log.$pa)]-Fail.txt
          set gaSet(runStatus) Fail
          if {$res!="-2"} {
            SQliteAddLine  $::pair; # $pa
            UnregIdBarcode $pa $gaSet($pa.barcodeUut1)
            UnregIdBarcode $pa $gaSet($pa.barcodeUut2)
          } 
        } elseif {$res==0} {
          ## MACREG will color the cell by green or red
          #PairPerfLab $pair green
          PairPerfLab $pair #ddffdd
          set retTxt Pass
        }
        AddToLog "Pair:$pair Test..Leds finish. Result: $res"
        if {$gaSet(pair)=="5"} {
          set pa $pair
        } else {
          set pa $gaSet(pair)
        }
        AddToPairLog $pa "Pair:$pa Test..Leds finish. Result: $res"
        
        ## MACREG will rename the file to PASS
        #file rename $gaSet(log.$pa) [file rootname $gaSet(log.$pa)]-Pass.txt
        if {$gaSet(act)==0} {return -2}  
        if {$res=="-2"}  {return -2}
        #AddToLog "********* Leds Test finish *********"    
        
        ## remove fail pairs from lPassPair
        if {[llength $lLEDfail]>0} {
          puts "lPassPair1 <$lPassPair> lLEDfail <$lLEDfail>"
          foreach LEDfail $lLEDfail {
            set lPassPair [lreplace $lPassPair [lsearch $lPassPair $LEDfail] [lsearch $lPassPair $LEDfail]]
          }
          #set lPassPair $lPassPair2
          puts "lPassPair2 <$lPassPair>"
        }  
      }
    }
    if {$gaSet(act)==0} {return -2}
  }
  
  set regMacIndx [lsearch -glob $glTests *Mac_BarCode*]
  if {$regMacIndx!="-1"} {
    puts "lPassPair after leds <$lPassPair>"
    set lMRfail [list]
    foreach pair $lPassPair {
      set ::pair $pair
      MassConnect $pair
      if {$gaSet(act)==0} {return -2}
      AddToLog "Pair:$pair Test..Mac_BarCode start"  
      if {$gaSet(pair)=="5"} {
        AddToPairLog $pair "Pair $pair Test..Mac_BarCode start"
      } else {
        AddToPairLog $gaSet(pair) "Pair $gaSet(pair) Test..Mac_BarCode start"
      }
      PairPerfLab $pair yellow
      set ret [Mac_BarCode $pair]
      if {$ret!=0} {
        set retMacReg -1
        AddToLog $gaSet(fail)
        if {$gaSet(pair)=="5"} {
          set pa $pair 
        } else {
          set pa $gaSet(pair)
        }
        AddToPairLog $pa "Pair $pa Test..Mac_BarCode finish. Result: -1"
        AddToPairLog $pa "Pair $pa Test..Mac_BarCode fail. Reason: $gaSet(fail)"
        lappend lMRfail $pair  
        PairPerfLab $pair red   
        file rename $gaSet(log.$pa) [file rootname $gaSet(log.$pa)]-Fail.txt 
        set gaSet(runStatus) Fail
        if {$ret!="-2"} {
          SQliteAddLine  $::pair; # $pa
          UnregIdBarcode $pa $gaSet($pa.barcodeUut1)
          UnregIdBarcode $pa $gaSet($pa.barcodeUut2)
        }   
      } else {
        AddToLog "Pair:$pair Test..Mac_BarCode finish. Result: 0"
        if {$gaSet(pair)=="5"} {
          set pa $pair 
        } else {
          set pa $gaSet(pair)       
        } 
        AddToPairLog $pa "Pair:$pa Test..Mac_BarCode finish. Result: 0"  
        PairPerfLab $pair green
        file rename $gaSet(log.$pa) [file rootname $gaSet(log.$pa)]-Pass.txt 
        set gaSet(runStatus)  Pass
        SQliteAddLine  $::pair; # $pa     
      }      
    }  
  }
  
  if {$ret==0 && $retBeeDefBut==0 && $retLed==0 && $retMacReg==0} {
    set ret 0
  } else {
    set ret -1
  }
  
  #AddToPairLog $gaSet(pair) "WS: $::wastedSecs"
    
  puts "RunTests4 ret:$ret gaSet(startFrom):$gaSet(startFrom)"  
  AddToLog "********* TEST FINISHED  *********" 
  return $ret
}
# ***************************************************************************
# ID
# ***************************************************************************
proc ID {run} {
  #return 0
  global gaSet
  
  foreach uut {Uut1 Uut2} {
    if {[info exist gaSet(bootScreen$uut)]==0 || $gaSet(bootScreen$uut)==""} {
      set ret [BootMenu $uut]
      if {$ret!=0} {return $ret}
      set ret [ReadBootVers $uut]
      if {$ret!=0} {return $ret}
    }
    if {$uut=="Uut2"} {
      set ret [Wait "Wait for up" 10 white]
      if {$ret!=0} {return $ret}
    }
  }
  
  foreach gen {1 2} {
    set id $gaSet(idGen$gen)
    puts "RLEtxGen::PortsConfig $id -updGen all -admStatus up"; update
    RLEtxGen::PortsConfig $id -updGen all -admStatus up
  }
  
  set ret [UUTsUp]
  if {$ret!=0} {return $ret}
  
  set ret [IDtest Uut1]
  if {$ret!=0} {return $ret}
  set ret [IDtest Uut2]
  return $ret
}
# ***************************************************************************
# Init
# ***************************************************************************
proc Init {run} {
  global gaSet
  #return 0
  
  foreach uut {Uut1 Uut2} {
    set ret [FactDefault $uut]
    if {$ret!=0} {return $ret}
    set ret [BootMenu $uut]
    if {$ret!=0} {return $ret}
    set ret [ReadBootVers $uut]
    if {$ret!=0} {return $ret}
  }
  
  set ret [Wait "Wait for reset" 10 white]
  if {$ret!=0} {return $ret}
  set ret [UUTsUp]
  if {$ret!=0} {return $ret}
  foreach uut {Uut1 Uut2} {
    set ret [DhcpDisable $uut]
    if {$ret!=0} {return $ret}
  }  
#   set ret [Wait "Wait for UUT setup" 20 white]
#   if {$ret!=0} {return $ret}
  return $ret
}
# ***************************************************************************
# IntRcv_192
# ***************************************************************************
proc IntRcv_192 {run} {
	global gaSet 
  set procName [info level 0] ; ## IntRcv_192
	puts "[MyTime] $procName $run"
  set tcLayer "64-65-octet" ; # HDLC
  set rate 192
  set stuC Uut1
  set stuR Uut2
  set negState enabled
  set duplex 100FD
  set frameSize 64
  set ts0 -  ; # Transparent Looped
  set ts -
  set masterClk - ; # Internal Receive 
  set dxcSrcClk - ; ## lbt1_lbt1 lbt1_int int_lbt1
  switch -exact $gaSet(wire) {
    "2" {set delay 3048; set pps 328}
    "4" {set delay 1565; set pps 639}
    "8" {
      if {$gaSet(dutFam)=="L" || $gaSet(dutFam)=="54" || $gaSet(dutFam)=="LRT"} {
        set delay 782;  set pps 1278
      } elseif {$gaSet(dutFam)=="f35"} {
        set delay 3377;  set pps 296
      }  
    }
  }
  switch -exact $gaSet(ls4_DLS6x) {
    "6100" {set range 18000}
    "6300" {set range 16000}
    "6700" {set range 18000}    
  }
  set ret [JoinTest $tcLayer $stuC $rate $range $delay $ts $ts0 $masterClk $dxcSrcClk $frameSize $pps] 
  puts "$procName ret after jjointest:$ret" ; update
  if {$ret!=0} {return $ret}
  set ret [SystemTestFull $stuC $stuR $tcLayer $range]
  puts "$procName ret after systemTestFull:$ret" ; update
  return $ret
}
# ***************************************************************************
# IntRcv_E1_3840
# ***************************************************************************
proc IntRcv_E1_3840 {run} {
	global gaSet 
  set procName [info level 0] ; ## IntRcv_192
	puts "[MyTime] $procName $run"
  set tcLayer - ; # HDLC "64-65-octet"
  set rate 3840
  set stuC Uut1
  set stuR Uut2
  set negState enabled
  set duplex 100FD
  set frameSize 64
  set ts0 Transparent  ; # Transparent Looped
  set ts 31
  set masterClk Internal ; # Internal Receive  Loopback
  set dxcSrcClk lbt1_lbt1 ; ## lbt1_lbt1 lbt1_int int_lbt1
  set delay 333;  set pps 3003
  switch -exact $gaSet(ls4_DLS6x) {
    "6100" {set range 8000}
    "6300" {set range 8000}
    "6700" {set range 8000}    
  }
  set ret [JoinTest $tcLayer $stuC $rate $range $delay $ts $ts0 $masterClk $dxcSrcClk $frameSize $pps] 
  puts "$procName ret after jjointest:$ret" ; update
  if {$ret!=0} {return $ret}
  set ret [SystemTestFull $stuC $stuR $tcLayer $range]
  puts "$procName ret after systemTestFull:$ret" ; update
  return $ret
}
# ***************************************************************************
# IntRcv_2304
# ***************************************************************************
proc IntRcv_2304 {run} {
	global gaSet
  set procName [info level 0] ; ## IntRcv_192
	puts "[MyTime] $procName $run"
  set tcLayer "64-65-octet" ; # HDLC
  set rate 2304
  set stuC Uut1
  set stuR Uut2
  set negState enabled
  set duplex 100FD
  set frameSize 64
  set ts0 -  ; # Transparent Looped
  set ts -
  set masterClk - ; # Internal Receive 
  set dxcSrcClk - ; ## lbt1_lbt1 lbt1_int int_lbt1
  switch -exact $gaSet(wire) {
    "2" {set delay 254; set pps 3937}
    "4" {set delay 131; set pps 7633}
    "8" {set delay 66;  set pps 15151}
  }
  switch -exact $gaSet(ls4_DLS6x) {
    "6100" {set range 11000}
    "6300" {set range 10000}
    "6700" {
      set range 10000
      # 14/02/2021 15:03:40 11000
    }    
  }
  set ret [JoinTest $tcLayer $stuC $rate $range $delay $ts $ts0 $masterClk $dxcSrcClk $frameSize $pps] 
  puts "$procName ret after jjointest:$ret" ; update
  if {$ret!=0} {return $ret}
  set ret [SystemTestFull $stuC $stuR $tcLayer $range]
  puts "$procName ret after systemTestFull:$ret" ; update
  return $ret
}
# ***************************************************************************
# IntRcv_3840
# ***************************************************************************
proc IntRcv_3840 {run} {
	global gaSet
  set procName [info level 0] ; ## IntRcv_192
	puts "[MyTime] $procName $run"
  set tcLayer "64-65-octet" ; # HDLC
  set rate 3840
  set stuC Uut1
  set stuR Uut2
  set negState enabled
  set duplex 100FD
  set frameSize 64
  set ts0 -  ; # Transparent Looped
  set ts -
  set masterClk - ; # Internal Receive 
  set dxcSrcClk - ; ## lbt1_lbt1 lbt1_int int_lbt1
  switch -exact $gaSet(wire) {
    "2" {set delay 153; set pps 6535}
    "4" {set delay 79;  set pps 12658}
    "8" {
      if {$gaSet(dutFam)=="L" || $gaSet(dutFam)=="LRT"} {
        set delay 39;  set pps 25520 ; #25641
      } elseif {$gaSet(dutFam)=="f35"} {
        set delay 168;  set pps 5952
      } elseif {$gaSet(dutFam)=="54"} {
        set delay 39;  set pps 25520
      }
    }  
  }
  switch -exact $gaSet(ls4_DLS6x) {
    "6100" {set range 8000}
    "6300" {set range 8000}
    "6700" {
      if {$gaSet(dutFam)=="54" || $gaSet(dutFam)=="LRT" || $gaSet(dutFam)=="L"} {
        set range 7000
      } else {  
        set range 8000
      }  
    }    
  }
  set ret [JoinTest $tcLayer $stuC $rate $range $delay $ts $ts0 $masterClk $dxcSrcClk $frameSize $pps] 
  puts "$procName ret after jjointest:$ret" ; update
  if {$ret!=0} {return $ret}
  set ret [SystemTestFull $stuC $stuR $tcLayer $range]
  puts "$procName ret after systemTestFull:$ret" ; update
  return $ret
}
# ***************************************************************************
# RcvInt_5696
# ***************************************************************************
proc RcvInt_5696 {run} {
	global gaSet
  set procName [info level 0] ; ## IntRcv_192
	puts "[MyTime] $procName $run"
  set tcLayer "64-65-octet" ; # HDLC
  set rate 5696
  set stuC Uut2
  set stuR Uut1
  set negState enabled
  set duplex 100FD
#   if {$gaSet(dutFam)=="L"} {
#     set frameSize 64
#   } elseif {$gaSet(dutFam)=="f35" || $gaSet(dutFam)=="54"} {
#     set frameSize 1518
#   }
  set frameSize 1518
  set ts0 -  ; # Transparent Looped
  set ts -
  set masterClk - ; # Internal Receive 
  set dxcSrcClk - ; ## lbt1_lbt1 lbt1_int int_lbt1
  switch -exact $gaSet(wire) {
    "2" {set delay 2178; set pps 459}
    "4" {set delay 1200; set pps 835}
    "8" {
      if {$gaSet(dutFam)=="L"  || $gaSet(dutFam)=="54" || $gaSet(dutFam)=="LRT"} {
        set delay 564;  set pps 1773
      } elseif {$gaSet(dutFam)=="f35"} {
        set delay 2178; set pps 459
      }
    }  
  }
  switch -exact $gaSet(ls4_DLS6x) {
    "6100" {set range 6000}
    "6300" {
      if {$gaSet(dutFam)=="54"} {
        set range 4000
      } else { 
        set range 6000
      }
    }  
    "6700" {set range 6000}    
  }
  set ret [JoinTest $tcLayer $stuC $rate $range $delay $ts $ts0 $masterClk $dxcSrcClk $frameSize $pps] 
  puts "$procName ret after jjointest:$ret" ; update
  if {$ret!=0} {return $ret}
  set ret [SystemTestFull $stuC $stuR $tcLayer $range]
  puts "$procName ret after systemTestFull:$ret" ; update
  return $ret
}
# ***************************************************************************
# RcvInt_2304
# ***************************************************************************
proc RcvInt_2304 {run} {
	global gaSet
  set procName [info level 0] ; ## IntRcv_192
	puts "[MyTime] $procName $run"
  set tcLayer - ; # HDLC "64-65-octet"
  set rate 2304
  set stuC Uut2
  set stuR Uut1
  set negState enabled
  set duplex 100FD
  set frameSize 64
  set ts0 -  ; # Transparent Looped
  set ts -
  set masterClk - ; # Internal Receive 
  set dxcSrcClk - ; ## lbt1_lbt1 lbt1_int int_lbt1
  set delay 281;  set pps 3558
  switch -exact $gaSet(ls4_DLS6x) {
    "6100" {set range 11000}
    "6300" {set range 10000}
    "6700" {
      set range 10000
      # 14/02/2021 15:03:40 11000
    }    
  }
  set ret [JoinTest $tcLayer $stuC $rate $range $delay $ts $ts0 $masterClk $dxcSrcClk $frameSize $pps] 
  puts "$procName ret after jjointest:$ret" ; update
  if {$ret!=0} {return $ret}
  set ret [SystemTestFull $stuC $stuR $tcLayer $range]
  puts "$procName ret after systemTestFull:$ret" ; update
  return $ret
}
# ***************************************************************************
# RcvInt_E1_3840_7808
# ***************************************************************************
proc RcvInt_E1_3840_7808 {run} {
	global gaSet
  set procName [info level 0] ; ## IntRcv_192
	puts "[MyTime] $procName $run"
  set tcLayer "HDLC"
  switch -exact $gaSet(wire) {
    "2" {set rate 3840}
    "4" {set rate 7808}
    "8" {}
  }
  set stuC Uut2
  set stuR Uut1
  set negState enabled
  set duplex 100FD
  set frameSize 64
  set ts0 Transparent  ; # - Transparent Looped
  set ts 31
  set masterClk Internal ; # - Internal Receive 
  set dxcSrcClk lbt1_lbt1 ; ## - lbt1_lbt1 lbt1_int int_lbt1
  switch -exact $gaSet(wire) {
    "2" {set delay 319; set pps 3134}
    "4" {set delay 100; set pps 10000}
    "8" {}
  }
  switch -exact $gaSet(ls4_DLS6x) {
    "6100" {set range 8000}
    "6300" {set range 6000}
    "6700" {set range 7000}    
  }
  set ret [JoinTest $tcLayer $stuC $rate $range $delay $ts $ts0 $masterClk $dxcSrcClk $frameSize $pps] 
  puts "$procName ret after jjointest:$ret" ; update
  if {$ret!=0} {return $ret}
  set ret [SystemTestFull $stuC $stuR $tcLayer $range]
  puts "$procName ret after systemTestFull:$ret" ; update
  return $ret
} 
# ***************************************************************************
# RcvInt_E1_2304
# ***************************************************************************
proc RcvInt_E1_2304 {run} {
	global gaSet
  set procName [info level 0] ; ## IntRcv_192
	puts "[MyTime] $procName $run"
  set tcLayer -
  set rate 2304
  set stuC Uut2
  set stuR Uut1
  set negState enabled
  set duplex 100FD
  set frameSize 64
  set ts0 Transparent  ; # - Transparent Looped
  set ts 31
  set masterClk Internal ; # - Internal Receive 
  set dxcSrcClk lbt1_lbt1 ; ## - lbt1_lbt1 lbt1_int int_lbt1
  set delay 2532 ; set pps 394
  switch -exact $gaSet(ls4_DLS6x) {
    "6100" {set range 11000}
    "6300" {set range 10000}
    "6700" {set range 11000}    
  }
  set ret [JoinTest $tcLayer $stuC $rate $range $delay $ts $ts0 $masterClk $dxcSrcClk $frameSize $pps] 
  puts "$procName ret after jjointest:$ret" ; update
  if {$ret!=0} {return $ret}
  set ret [SystemTestFull $stuC $stuR $tcLayer $range]
  puts "$procName ret after systemTestFull:$ret" ; update
  return $ret
} 
# ***************************************************************************
# ExtRcv_E1_5696_11392
# ***************************************************************************
proc ExtRcv_E1_5696_11392 {run} {
	global gaSet
  set procName [info level 0] ; ## IntRcv_192
	puts "[MyTime] $procName $run"
  set tcLayer "HDLC"
  switch -exact $gaSet(wire) {
    "2" {set rate 5696}
    "4" {set rate 11392}
    "8" {}
  }
  set stuC Uut1
  set stuR Uut2
  set negState enabled
  set duplex 100FD
  set frameSize 1518 ; #64 18/06/2015 08:00:33
  set ts0 Transparent  ; # - Transparent Looped
  set ts 31
  set masterClk Receive ; # - Internal Receive 
  set dxcSrcClk int_lbt1 ; ## - lbt1_lbt1 lbt1_int int_lbt1
  switch -exact $gaSet(wire) {
    "2" {set delay 3500; set pps 285}
    "4" {set delay 1350; set pps 740}
    "8" {}
  }
  switch -exact $gaSet(ls4_DLS6x) {
    "6100" {set range 6000}
    "6300" {set range 6000}
    "6700" {set range 5000; #6000}    
  }
  set ret [JoinTest $tcLayer $stuC $rate $range $delay $ts $ts0 $masterClk $dxcSrcClk $frameSize $pps] 
  puts "$procName ret after jjointest:$ret" ; update
  if {$ret!=0} {return $ret}
  set ret [SystemTestFull $stuC $stuR $tcLayer $range]
  puts "$procName ret after systemTestFull:$ret" ; update
  return $ret
} 
# ***************************************************************************
# ExtRcv_E1_192
# ***************************************************************************
proc ExtRcv_E1_192 {run} {
	global gaSet
  set procName [info level 0] ; ## IntRcv_192
	puts "[MyTime] $procName $run"
  set tcLayer - ; # "HDLC"
  set rate 192
  set stuC Uut1
  set stuR Uut2
  set negState enabled
  set duplex 100FD
  set frameSize 1518
  set ts0 Looped  ; # - Transparent Looped
  set ts 1
  set masterClk Loopback ; # - Internal Receive Loopback
  set dxcSrcClk int_lbt1 ; ## - lbt1_lbt1 lbt1_int int_lbt1
  set delay 200000; set pps 10
  switch -exact $gaSet(ls4_DLS6x) {
    "6100" {set range 18000}
    "6300" {set range 16000}
    "6700" {set range 18000}    
  }
  set ret [JoinTest $tcLayer $stuC $rate $range $delay $ts $ts0 $masterClk $dxcSrcClk $frameSize $pps] 
  puts "$procName ret after jjointest:$ret" ; update
  if {$ret!=0} {return $ret}
  set ret [SystemTestFull $stuC $stuR $tcLayer $range]
  puts "$procName ret after systemTestFull:$ret" ; update
  return $ret
} 
# ***************************************************************************
# RcvExt_E1_192_384
# ***************************************************************************
proc RcvExt_E1_192_384 {run} {
	global gaSet
  set procName [info level 0] ; ## IntRcv_192
	puts "[MyTime] $procName $run"
  set tcLayer "HDLC"
  switch -exact $gaSet(wire) {
    "2" {set rate 192}
    "4" {set rate 384}
    "8" {}
  }
  set stuC Uut2
  set stuR Uut1
  set negState enabled
  set duplex 100FD
  set frameSize 1518 ; #64 18/06/2015 08:01:46
  set ts0 Looped  ; # - Transparent Looped
  set ts 1
  set masterClk Receive ; # - Internal Receive 
  set dxcSrcClk lbt1_int ; ## - lbt1_lbt1 lbt1_int int_lbt1
  switch -exact $gaSet(wire) {
    "2" {set delay 100000; set pps 10}
    "4" {set delay 50000;  set pps 20}
    "8" {}
  }
  switch -exact $gaSet(ls4_DLS6x) {
    "6100" {set range 18000}
    "6300" {set range 16000}
    "6700" {set range 18000}    
  }
  set ret [JoinTest $tcLayer $stuC $rate $range $delay $ts $ts0 $masterClk $dxcSrcClk $frameSize $pps] 
  puts "$procName ret after jjointest:$ret" ; update
  if {$ret!=0} {return $ret}
  set ret [SystemTestFull $stuC $stuR $tcLayer $range]
  puts "$procName ret after systemTestFull:$ret" ; update
  return $ret
} 
# ***************************************************************************
# RcvExt_E1_5696
# ***************************************************************************
proc RcvExt_E1_5696 {run} {
	global gaSet
  set procName [info level 0] ; ## IntRcv_192
	puts "[MyTime] $procName $run"
  set tcLayer - ; #"HDLC"
  set rate 5696
  set stuC Uut2
  set stuR Uut1
  set negState enabled
  set duplex 100FD
  set frameSize 1518
  set ts0 Transparent  ; # - Transparent Looped
  set ts 31
  set masterClk Loopback ; # - Internal Receive  Loopback
  set dxcSrcClk lbt1_int ; ## - lbt1_lbt1 lbt1_int int_lbt1
  set delay 3500; set pps 285
  switch -exact $gaSet(ls4_DLS6x) {
    "6100" {set range 6000}
    "6300" {set range 6000}
    "6700" {set range 6000}    
  }
  set ret [JoinTest $tcLayer $stuC $rate $range $delay $ts $ts0 $masterClk $dxcSrcClk $frameSize $pps] 
  puts "$procName ret after jjointest:$ret" ; update
  if {$ret!=0} {return $ret}
  set ret [SystemTestFull $stuC $stuR $tcLayer $range]
  puts "$procName ret after systemTestFull:$ret" ; update
  return $ret
} 
# ***************************************************************************
# JoinTest
# ***************************************************************************
proc JoinTest {tcLayer stuC rate range delay ts ts0 masterClk dxcSrcClk frameSize pps } {
  puts "[MyTime] JoinTest $tcLayer $stuC $rate $range $delay $ts $ts0 $masterClk $dxcSrcClk $frameSize $pps"
	global gaSet gLog gaTest
  MassConnect $::pair
  SwEth disconnect
  
  foreach uut {Uut1 Uut2} {
    set ret [FactDefault $uut]
    if {$ret!=0} {return $ret}
  }
  
  foreach gen {1 2} {
    set id $gaSet(idGen$gen)
    puts "RLEtxGen::PortsConfig $id -updGen all -admStatus down"; update
    RLEtxGen::PortsConfig $id -updGen all -admStatus down
  }
  
  set ret [Wait "Wait for reset" 10 white]
  if {$ret!=0} {return $ret}
  set ret [UUTsUp]
  if {$ret!=0} {return $ret}
  foreach uut {Uut1 Uut2} {
    set ret [DhcpDisable $uut]
    if {$ret!=0} {return $ret}
  } 
  
  foreach {uut} {Uut1 Uut2} {
    if {$gaSet(act)==0} {return -2}
    #set ret [MainMenu $gaSet(com$uut)]
    set ret [UUTup $uut]
    if {$ret != 0} {
   		set gaSet(fail) "$uut - ConfigUutsDsl Fail - Failed to Get Main Menu"
  		return $ret          
    }
  }
  if {$gaSet(perfSet)==0} {
    puts "gaSet(perfSet)==0,  just go to MainMenu"    
    return 0
  }
  if {$gaSet(act)==0} {return -2}
  SwShdsl disconnect 
  # set ret [Wait "Wait for DSL disconnecting" 20 white]
  # if {$ret!=0} {return $ret}

  if {$gaSet(dutFam)=="L" || $gaSet(dutFam)=="54" || $gaSet(dutFam)=="LRT"} {
    set ret [ConfigUutsDsl $stuC $tcLayer $rate tcLayerOnly]
    if {$ret!=0} {return $ret}
    
    if {$tcLayer=="HDLC" && $gaSet(e1)!="NA"} {
      # In order to be able to configure the DSL lines to 192/384Kbps 
      # we have to make sure that the E1/HS lines are configured with very no/low TS 
      # if the E1/HS rates are higher than the DSL , it will not be possible to configure the DSL to the required rate
      if {$rate <= 384} { 
        set ret [ConfigUutsE1 $stuC $ts $ts0 $masterClk]
        if {$ret != 0} {return $ret}
      }    
    }
  } elseif {$gaSet(dutFam)=="f35" && $gaSet(e1)!="NA"} {
    ## do nothing
    set ret [ConfigUutsE1 $stuC 0 $ts0 -]
    if {$ret != 0} {return $ret}
  }
  
  set ret [ConfigUutsDsl $stuC $tcLayer $rate skipTcLayer]
  if {$ret != 0} {return $ret}  
  
  if {($gaSet(dutFam)=="L" || $gaSet(dutFam)=="54" || $gaSet(dutFam)=="LRT") && $tcLayer=="HDLC" && $gaSet(e1)!="NA"} {
    # No need to configure E1/HS rates in case of low rates
    # They were alreasy configured above 
    if {$rate > 384} {
      set ret [ConfigUutsE1 $stuC $ts $ts0 $masterClk]
      if {$ret != 0} {return $ret}
    }  
    
    set ret [MasterClock $stuC $masterClk]
    if {$ret != 0} {return $ret}
  } elseif {$gaSet(dutFam)=="f35" && $gaSet(e1)!="NA"} {
    set ret [ConfigUutsE1 $stuC $ts $ts0 $masterClk]
    if {$ret != 0} {return $ret}
  }
   
  set ret [SetLine $range]
  if {$ret != 0} {
    set gaSet(fail) "Failed to Set DLS range"
    return $ret
  }
  if {$gaSet(act)==0} {return -2}
  
  Status "Connect DSL Lines"
  SwShdsl range    
	
  foreach gen {1 2} {
    set id $gaSet(idGen$gen)
    puts "RLEtxGen::PortsConfig $id -updGen all -admStatus up"; update
    RLEtxGen::PortsConfig $id -updGen all -admStatus up
    set portPps [expr {$pps/4}]
    puts "RLEtxGen::GenConfig $id -updGen all -minLen $frameSize -maxLen $frameSize -packRate $portPps"; update
    RLEtxGen::GenConfig $id -updGen all -minLen $frameSize -maxLen $frameSize -packRate $portPps   
  }
  after 1000 
  SwEth gen
  
  if {($tcLayer=="HDLC" && $gaSet(e1)!="NA") || ($gaSet(dutFam)=="f35" && $gaSet(e1)!="NA")} {
    foreach dxc4 {idDxc4-1 idDxc4-2} srcClk [split $dxcSrcClk _] {
      if {$gaSet(act)==0} {return -2}
      set ret [SetDxc4 $dxc4 $srcClk $ts0 $ts]
      if {$ret !=0} {
        set ret [SetDxc4 $dxc4 $srcClk $ts0 $ts]
        if {$ret !=0} {          
          set gaSet(fail) "$dxc4 Configuration Failed"
          return -1
        }
      }  
    }
  }
  
  return $ret 
}  
# ***************************************************************************
# SystemTestFull
# ***************************************************************************
proc SystemTestFull {stuC stuR tcLayer range} {
  global gaSet
  Status "SystemTestFull $stuC $stuR $tcLayer $range"

  set ret [SetLine $range]
  if {$ret != 0} {
    set gaSet(fail) "Failed to Set DLS range"
    return $ret
  }
  
  foreach uut $stuR {
    if {[WaitForSync $uut $tcLayer] != 0} {
      PowerOffOn
      Wait "Wait for Power up"  30
      set ret [WaitForSync $uut $tcLayer]
      if {$ret != 0} {return $ret}
    }
  }

  #MassConnect $gaSet(massNum) gen    
  Wait "Wait for ETH Connection/Sync"  3
  Etx204Start
  if {($tcLayer=="HDLC" && $gaSet(e1)!="NA") || ($gaSet(dutFam)=="f35" && $gaSet(e1)!="NA")} {
    Dxc4Start
  }
  set ret [Wait "Wait for stabilization" 10 white]
  Etx204Start
  if {($tcLayer=="HDLC" && $gaSet(e1)!="NA") || ($gaSet(dutFam)=="f35" && $gaSet(e1)!="NA")} {
    Dxc4Start
    set ret [Dxc4InjErr]
    if {$ret != 0} {
      Dxc4Start
      set ret [Dxc4InjErr]
      if {$ret != 0} {puts "\nSetLine $range"; return $ret}
    }
  }
  
  set ret [Wait "Check Data Transfer" 30]
  if {$ret != 0} {return $ret} 
  
  set retEth [Etx204Check]
    
  if {($tcLayer=="HDLC" && $gaSet(e1)!="NA") || ($gaSet(dutFam)=="f35" && $gaSet(e1)!="NA")} {
    set retE1 [Dxc4Check]
    puts "[MyTime] 0.1 retE1=$retE1"
      if {$retE1 != 0} {
        Dxc4Start
        set ret [Wait "Check Data Transfer" 30]
        if {$ret != 0} {return $ret}
        set retE1 [Dxc4Check]
        puts "[MyTime] 0.2 retE1=$retE1"
      }
  } else {
    set retE1 0
  }
  puts "[MyTime] 1. retEth=$retEth  retE1=$retE1"
  
  if {$retEth != 0 || $retE1 != 0} {
    puts "\n[MyTime] 1.1 Etx204Check:"
    Etx204Check
    Etx204Refresh
    #Etx204Stop    
    after 1000
    Etx204Start
    puts "\n[MyTime] 1.2 Etx204Check:"
    Etx204Check
    
    set ret [Wait "Wait for stabilization." 30]
    if {$ret != 0} {return $ret}
    
    puts "\n[MyTime] 1.3 Etx204Check:"
    Etx204Check
    Etx204Refresh
    #Etx204Stop
    after 1000
    Etx204Start
    puts "\n[MyTime] 1.4 Etx204Check:"
    Etx204Check
    
    set ret [Wait "Wait for stabilization." 120]
    if {$ret != 0} {return $ret}
    
    #Etx204Stop
    Etx204Refresh
    after 1000
    Etx204Start
    if {($tcLayer=="HDLC" && $gaSet(e1)!="NA") || ($gaSet(dutFam)=="f35" && $gaSet(e1)!="NA")} {
      Dxc4Start
    }
  
    puts "\n[MyTime] 1.5 Etx204Check"
    Etx204Check
    Etx204Refresh

    set ret [Wait "Check Data Transfer" 45]
    if {$ret != 0} {return $ret} 
  
    set retEth [Etx204Check]
    puts "[MyTime] 2. retEth=$retEth  retE1=$retE1"
    if {$retEth != 0} {
      set ret [Wait "Wait for stabilization.." 30]
      if {$ret != 0} {return $ret}
      #Etx204Stop
      after 1000
      Etx204Start      
      puts "\n[MyTime] 2.1 Etx204Check:"
      Etx204Check
      
      #Etx204Stop
      after 1000
      Etx204Start
      set ret [Wait "Check Data Transfer" 45]
      if {$ret != 0} {return $ret} 
      set retEth [Etx204Check]
      puts "[MyTime] 2.2 retEth=$retEth  retE1=$retE1"
      if {$retEth != 0} {
        puts "\nSetLine $range"
        return $retEth
      }
    }
    
    if {($tcLayer=="HDLC" && $gaSet(e1)!="NA") || ($gaSet(dutFam)=="f35" && $gaSet(e1)!="NA")} {
      set retE1 [Dxc4Check]
      puts "[MyTime] 3.1 retE1=$retE1"
      if {$retE1 != 0} {
        Dxc4Start
        set ret [Wait "Check Data Transfer" 30]
        if {$ret != 0} {return $ret}
        set retE1 [Dxc4Check]
        puts "[MyTime] 3.2 retE1=$retE1"
      }
    } else {
      set retE1 0
    }
    puts "[MyTime] 3. retEth=$retEth  retE1=$retE1"
    puts "\nSetLine $range"
    if {$retEth != 0 || $retE1 != 0} {
      if {$retEth != 0} {
        return $retEth
      }
      if {$retE1 != 0} {
        return $retE1
      }  
    }
  } elseif {$retEth == 0 && $retE1 == 0} {
    set ret 0
  }
  
  Etx204Stop
  if {($tcLayer=="HDLC" && $gaSet(e1)!="NA") || ($gaSet(dutFam)=="f35" && $gaSet(e1)!="NA")} {
    Dxc4Stop
  }      
  puts "\nSetLine $range"
  return $ret
}



# ***************************************************************************
# Leds
# ***************************************************************************
proc Leds {pair} {
  global gaSet gRelayState buffer 
  #15/03/2017 15:20:30
  if {$gaSet(TestMode)=="PreloadOnly" || $gaSet(TestMode)=="shortPreLoad" || $gaSet(TestMode)=="short"} {
    return 0
  }
  Status ""
  PairPerfLab $pair yellow
  MassConnect $pair
  SwEth gen
  SwShdsl disconnect
  #Etx204Stop
  update
  set gRelayState red
  IPRelay-LoopRed
  SendEmail "ASMi54" "Manual Test"
  
  #exec c:/rlfiles/tools/btl/beep.exe &
  foreach uut {Uut1 Uut2} {}
    if {$gaSet(act)==0} {return -2}
    
    RLSound::Play beep
    set mes "Please verify on pair $pair:\n"
    append mes "\nSHDSL Leds in both UUTs are Blinking/ON in Red"
    append mes "\nAlarm Led is ON (RED)"
    append mes "\nPower Led in ON"
    append mes "\nTST, all ETH ACT and E1 Leds (if exist) are OFF"
    set res [DialogBox -type "OK Stop" -icon images/question \
        -title "LED Test of pair $pair" -message $mes]
    update
    if {$res=="Stop"}  {
      set gaSet(fail) "LED Test of pair $pair fail"
      return -1
    }     
    
    RLSound::Play beep
    set mes "After pressing OK please verify on pair $pair:"
    append mes "\nSHDSL Leds Blinked in Red and Green"
    append mes "\nTST Led Blinked in Yellow" 
    append mes "\nBoth E1 Leds (if exist) Blinked in Red"     
    append mes "\nAll ETH LINK Leds light in green"   
    append mes "\nAll ETH ACT Leds light in yellow" 
    set res [DialogBox -type "OK Stop" -icon images/question \
        -title "LED Test of pair $pair" -message $mes]
    update
    if {$res=="Stop"}  {
      set gaSet(fail) "LED Test of pair $pair fail"
      return -1
    } 
    while 1 {
      
      foreach uut {Uut1 Uut2} {
        set ret [UUTIsUp $uut]
        if {$ret!=0} {
          set ret [UUTup $uut]
          if {$ret!=0} {return $ret}
        }
        set ret [DebugMainMenu $uut]
        if {$ret!=0} {return $ret}
      }
      set ret [LedTest "LEDs TEST"]
      if {$ret!=0} {return $ret}
      
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
        set gaSet(fail) ""
        break ; # break the while
      } elseif {$res=="Stop"}  {
        return -2
      } elseif {$res=="Repeat"}  {
        ## repeat the test
      }
    }
    
#     RLSound::Play beep
#     set mes "After pressing OK please verify on pair $pair:\n"
#     append mes "\nAll ETH Link Leds light in green\n"
#     set res [DialogBox -type "OK Stop" -icon images/question \
#         -title "LED Test of pair $pair" -message $mes]
#     update
#     if {$res=="Stop"}  {
#       return -2
#     } 
#     while 1 {
# #       set ret [UUTIsUp $uut]
# #       if {$ret!=0} {
# #         set ret [UUTup $uut]
# #         if {$ret!=0} {return $ret}
# #       }
# #       foreach uut {Uut1 Uut2} {
# #         set ret [DebugMainMenu $uut]
# #         if {$ret!=0} {return $ret}
# #       }
#       set ret [LedTest "LED Test Green"]
#       if {$ret!=0} {return $ret}
#       
#       RLSound::Play beep
#       set mes "If leds are working properly?"
#       set res [DialogBox -type "Yes No Repeat Stop" -icon images/question \
#           -title "LED Test of pair $pair" -message $mes]
#       update
#       if {$res=="No"} {
#         set gaSet(fail) "LED Test of pair $pair fail"
#         return -1
#       } elseif {$res=="Yes"}  {
#         set ret 0
#         break ; # break the while
#       } elseif {$res=="Stop"}  {
#         return -2
#       } elseif {$res=="Repeat"}  {
#         ## repeat the test
#       }   
#     } 
#     
#     ## perform the "LED Test Yellow" for stop the green test
#     LedTest "LED Test Yellow" 
#     
  return $ret
  
}

# ***************************************************************************
# FactorySet
# ***************************************************************************
proc FactorySet {run} {
  global gaSet gaGui
  #return 0
  set ret [FactDefault Uut1]
  if {$ret!=0} {return $ret}
  set ret [FactDefault Uut2]
  if {$ret!=0} {return $ret}
  return $ret
}
# ***************************************************************************
# BeeLine_Configuration
# ***************************************************************************
proc BeeLine_Configuration {run} {
  global gaSet gaGui
  #return 0
  set ret [FactDefaultBln Uut1]
  if {$ret!=0} {return $ret}
  set ret [FactDefaultBln Uut2]
  if {$ret!=0} {return $ret}

  return $ret
}

# ***************************************************************************
# DateTime
# ***************************************************************************
proc DateTime {run} {
  global gaSet
  set ret [Date_Time 1 $gaSet(com1)]
  if {$ret!=0} {return $ret}
  set ret [Date_Time 2 $gaSet(com2)]
  if {$ret!=0} {return $ret}
  return $ret
} 
# ***************************************************************************
# Mac_BarCode
# ***************************************************************************
proc Mac_BarCode {run} {
  global gaSet  
  #set pair $::pair  ; ## this line good if the proc is called as normal test
  ## in case of perform after LEDS I use 'run' as number of tested pair:
  set pair $run
  puts "Mac_BarCode \"$pair\" "
  mparray gaSet *mac* ; update
  mparray gaSet *barcode* ; update
  foreach uut {Uut1 Uut2} {
    if {![info exists gaSet($pair.barcode$uut)]} {
      set gaSet(fail)  "Barcode for $uut in pair $pair does not exist"
      return -1
    }  
  }
  set badL [list]
  set ret -1
  foreach uut {Uut1 Uut2} {    
    if ![info exists gaSet($pair.mac$uut)] {
      set ret [UUTup $uut]
      if {$ret!=0} {return $ret}
      set ret [ReadMac $uut]
      if {$ret!=0} {return $ret}
    }  
  } 
  set ret [RegBC $pair]
  return $ret
}

# ***************************************************************************
# UploadAppl
# ***************************************************************************
proc UploadAppl {run} {
  global gaSet
  puts "[MyTime] UploadAppl" ; update
  MassConnect $::pair
  SwEth pc
  set calledBy [lindex [info level -1] 0]
  puts "calledBy:$calledBy"; update
  
  if {$calledBy=="Testing"} {
    if {$gaSet(oneTest)=="1"} {
      ## if oneTest is 1 (on) do not read MACs before UploadAppl
    } else {  
      if {$gaSet(readMacUploadAppl)=="1"} {
        foreach uut {Uut1 Uut2} {
          if ![info exists gaSet($::pair.mac$uut)] {
            set ret [UUTup $uut]
            if {$ret!=0} {return $ret}
            set ret [ReadMac $uut]
            if {$ret!=0} {return $ret}
          }  
        }
      }
    }    
  } elseif {$calledBy=="PreLoadAppl"} {
    ## don't read macs in preload stage
  } 
  
  foreach uut {Uut1 Uut2} {  
    set ret [FormatFlash $uut] 
    if {$ret!=0} {return $ret}
  }
  Wait "Wait for Flash format" 15
  
  if {$calledBy=="Testing"} {
    set applfile $gaSet(uaf)
    set fil uaf
  } elseif {$calledBy=="PreLoadAppl"} {
    set applfile $gaSet(pl)
    set fil pl
  } 
  
  foreach uut {Uut1 Uut2} {
    set res$uut [LoadAppl $uut $applfile $fil]   
    if {[set res$uut]!=0} {
      break
    } 
  } 
  if {$resUut1==0 && $resUut2==0} {
    set ret 0
  } else {
    set ret -1
    if {$gaSet(act)==0} {set ret -2}
  }  
  
  #set ret [DownloadYmodemFile $fil] 
  puts "[MyTime] ret of DownloadYmodemFile:$ret" ; update
  if {$ret==0} {
    Wait "Wait for Loading" 30 white
    set ret [UUTsUp]
  }
  return $ret
}
  
# ***************************************************************************
# SaveUserFile
# ***************************************************************************
proc SaveUserFile {run} {
  global gaSet
  foreach uut {Uut1 Uut2} {      
    set com $gaSet(com$uut)
    set ret [LoadUserConf $uut]
    if {$ret!=0} {return $ret}
  }
   
  set ret [Wait "Wait for reset" 20 white]
  if {$ret!=0} {return $ret} 
  set ret [UUTsUp] 
   
  
  return $ret
}

# ***************************************************************************
# PreLoadAppl
# ***************************************************************************
proc PreLoadAppl {run} {
  global gaSet
  puts "[MyTime] PreLoadAppl" ; update
  set ret [UploadAppl $run]
  return $ret
}

# ***************************************************************************
# License
# ***************************************************************************
proc License {run} {
  global gaSet
  #MassConnect $::pair pc
  foreach uut {Uut1 Uut2} { 
    puts "[MyTime] License in $uut"; update
    if ![info exists gaSet(${::pair}.barcode$uut)] {
      set gaSet(fail) "Barcode of $uut in pair $::pair doesn't exist"
      return -1
    }
    set liccfg c:/license/ate_license.$gaSet(pair).$uut.cfg
    file delete -force $liccfg
  
    if ![info exists gaSet(${::pair}.mac$uut)] {
      set ret [ReadMac $uut]
      if {$ret!=0} {return $ret}
    }
    
    set ret [CreateLicCfg $uut $liccfg]
    if {$ret!=0} {return $ret}
    
    exec c:/license/license.exe $liccfg
    
    set licTxt LIC_$gaSet(${::pair}.mac$uut).txt
    set licPath $gaSet(licDir)/$gaSet(${::pair}.barcode$uut)
    
    if ![file exists $licPath] {
      file mkdir $licPath
      after 1000
    }
    
    puts "licTxt:<$licTxt> licPath:<$licPath>"
    file copy -force $licTxt $licPath
    if [file exists c:/download/$licTxt] {
      file delete -force c:/download/$licTxt      
    }
    
    #file copy -force $licTxt c:/download/
    file delete -force $licTxt 
    
    set ret [LicenseDownload $uut $licPath/$licTxt]
    if {$ret!=0} {return $ret}
#     set ret [VerifyLicense $uut]
#     if {$ret!=0} {return $ret}
  }
  return $ret
}

# ***************************************************************************
# CheckLicense
# ***************************************************************************
proc CheckLicense {run} {
  global gaSet
  #MassConnect $::pair pc
  foreach uut {Uut1 Uut2} { 
    puts "[MyTime] CheckLicense in $uut"; update
    set ret [VerifyLicense $uut]
    if {$ret!=0} {return $ret}
  }
  return $ret
}

# ***************************************************************************
# Pages
# ***************************************************************************
proc Pages {run} {
  MassConnect $::pair
  SwEth pc
  foreach unit {Uut1 Uut2} {
    set ret [PagesInit $unit]
    if {$ret!=0} {return $ret}
  }
  return $ret
}
# ***************************************************************************
# Memory_DyingGasp
# ***************************************************************************
proc Memory_DyingGasp {run} {
  global gaSet
  for {set dgt 1} {$dgt<=3} {incr dgt} {
    set ret [MemoryPerf dg]
    puts "[MyTime] .. ret of DGTest $dgt : <$ret>\r"; update
    if {$gaSet(pair)=="5"} {
      set pa $::pair
    } else {
      set pa $gaSet(pair)
    }
    AddToPairLog $pa "Dying Gasp Test $dgt finish. Result: $ret"
    if {$ret=="-2"} {return $ret}
    if {$ret=="0"} {break}
  }
  return $ret
}
# ***************************************************************************
# Memory
# ***************************************************************************
proc Memory {run} {
  set ret [MemoryPerf mem]
  return $ret
}
# ***************************************************************************
# MemoryPerf
# ***************************************************************************
proc MemoryPerf {type} {
  global gaSet tmsg
  puts "[MyTime] MemoryPerf $type"
  MassConnect $::pair
  SwEth pc
  SwShdsl disconnect

  foreach uut {Uut1 Uut2} {
    if {$gaSet(perfSet)==1} {
      set ret [DhcpDisable $uut]
      if {$ret!=0} {return $ret}
      set ret [IpConfig $uut]
      if {$ret!=0} {return $ret}
    }
  }
  if {$type=="dg"} {
    foreach uut {Uut1 Uut2} {
      set ret [PingTest $uut]
      if {$ret!=0} {return $ret}
    }
    
    set wsDir C:\\Program\ Files\\Wireshark
    set npfL [exec $wsDir\\tshark.exe -D]
    ## 1. \Device\NPF_{3EEEE372-9D9D-4D45-A844-AEA458091064} (ATE net)
    ## 2. \Device\NPF_{6FBA68CE-DA95-496D-83EA-B43C271C7A28} (RAD net)
    set intf ""
    foreach npf [split $npfL "\n\r"] {
      set res [regexp {(\d)\..*ATE} $npf - intf] ; puts "<$res> <$npf> <$intf>"
      if {$res==1} {break}
    }
    if {$res==0} {
      set gaSet(fail) "Get ATE net's Network Interface fail"
      return -1
    }
    
    set trapTime 300
    set ret -1
    set retUut1 -1
    set retUut2 -1
    set secStart [clock seconds]
    for {set i $trapTime} {$i > 0} {incr i -1} {
      if {$gaSet(act)==0} {return -2}	 
      
      set secNow  [clock seconds]
      set runTime [expr $secNow - $secStart]
      $gaSet(runTime) configure -text $runTime
      update	   
#       foreach uut {Uut1 Uut2} {
#         if {[set ret$uut]==0} {continue}
#         if {$gaSet(act)==0} {return -2}	
#         set ret [PingTest $uut]
#         if {$ret!=0} {return $ret}
#       }

      puts "\n[MyTime]. \"ETH Port 1\" trap. runTime:$runTime" ; update
      set resFile c:\\temp\\pi_$gaSet(pair)_[clock format [clock seconds] -format  "%Y.%m.%d_%H.%M.%S"].txt
      set dur 60
      puts "[MyTime].1"; update
      #exec [info nameofexecutable] Lib_tshark.tcl $intf $dur $resFile &
      catch {exec C:\\Program\ Files\\Wireshark\\tshark.exe -i $intf -O snmp -x -S lIsT -a duration:$dur  -A "c:\\temp\\tmp.cap" > [set resFile] &} rr
      puts "[MyTime].2"; update
      foreach uut {Uut1 Uut2} {
        ## 25/10/2017 09:40:52
        ##we should toggle the port to both units,  otherwase traps disappered
        ## on un-toggled unit
        ##if {[set ret$uut]==0} {continue}
        if {$gaSet(act)==0} {return -2}	
        set ret [Eth1Toggle $uut] 
        #set ret [PingTest $uut]
        if {$ret!=0} {return $ret}
      }  
      
      set runTime [expr $secNow - $secStart]
      $gaSet(runTime) configure -text $runTime
      puts "\n[MyTime].. Wait for \"ETH Port 1\" trap. runTime:$runTime" ; update
      if {$gaSet(act)==0} {return -2}	
      #after "[expr {$dur +1}]000" ; ## one sec more then duration
      Wait "Wait for traps" 12
      
      set runTime [expr $secNow - $secStart]
      $gaSet(runTime) configure -text $runTime
      puts "\n[MyTime]...Wait for \"ETH Port 1\" trap. runTime:$runTime" ; update
      
      catch {exec taskkill.exe /f /pid $rr} tsk
      puts "[MyTime]...tsk:<$tsk>" ; update
      after 3000
#       set monData ""
#       set ::md ""
#       set id [open $resFile r]
#         set monData [read $id]
#         set ::md $monData 
#       close $id  
#       puts "\r---resFile:$resFile\nPing monData<$monData>---\r"; update
      set monData ""
      set ::md ""
      set id [open $resFile r]
        set monData [read $id]
        set ::md $monData 
      close $id  
      puts "\r[MyTime]...---resFile:$resFile\nPing monData<$monData>---\r"; update
      foreach uut {Uut1 Uut2} {
        set uutNum [string index $uut end]
        set dutIp 1.1.1.[set gaSet(pair)][set uutNum]
        set res [regexp -all "Src: $dutIp, Dst: 1.1.1.1" $monData]
        puts "uut:$uut res:$res"
        if {$res<1} {
          #set gaSet(fail) "1 Ping traps did not sent"
          set gaSet(fail) "No trap from $uut was detected during $runTime sec"
          set ret$uut -1
          #return -1
        } else {
          set ret$uut 0
        }
#         if [catch {file delete -force $resFile} catRes] {
#           puts "[MyTime] catRes:$catRes"
#           after 2000
#           if [catch {file delete -force $resFile} catRes] {
#             puts "[MyTime] catRes:$catRes"
#             set gaSet(fail) "Delete res file $resFile fail"
#             set ret$uut -1
#           }
#         }  
      } 
      puts "retUut1:$retUut1 retUut2:$retUut2" ; update
#           set ret$uut [TrapCheck $uut $tmsg "ETH Port 1"]
#           puts "ret of TrapCheck $i after $runTime sec: [set ret$uut]"
      #if {[set ret$uut]==0} {break}

      if {$runTime>$trapTime} {
        set ret -1
        break
      }
      if {$retUut1==0 && $retUut2==0} {
        set ret 0
        break
      }
      file delete -force $resFile
      after 2000
    } 
    if {$retUut1!=0} {
      set $gaSet(fail) "No \"ETH Port 1\" trap from Uut1"
      return -1
    }
    if {$retUut2!=0} {
      set $gaSet(fail) "No \"ETH Port 1\" trap from Uut2"
      return -1
    }
  }
  
  if {$type=="dg"} {
    puts "\n[MyTime]. Before DyingGasp trap." ; update
    after 5000
    puts "\n[MyTime]. Try catch DyingGasp trap." ; update
    set resFile c:\\temp\\dg_$gaSet(pair)_[clock format [clock seconds] -format  "%Y.%m.%d_%H.%M.%S"].txt
    set dur 10
    #exec [info nameofexecutable] Lib_tshark.tcl $intf $dur $resFile &
    catch {exec C:\\Program\ Files\\Wireshark\\tshark.exe -i $intf -O snmp -x -S lIsT -a duration:$dur  -A "c:\\temp\\tmp.cap" > [set resFile] &} rr
    puts "\n[MyTime].." ; update
    after 5000
    #ToolsPower all off; after 3000; ToolsPower all on
  }  
  
  PowerOffOn
#   foreach uut {Uut1 Uut2} {
#     Power $uut off 
#   }   
#   after 2000
#   foreach uut {Uut1 Uut2} {
#     Power $uut on
#   } 
  
  if {$type=="dg"} {
    after "[expr {$dur +2}]000" ; ## 2 more sec then duration
    set monData ""
    set ::md ""
    set id [open $resFile r]
      set monData [read $id]
      set ::md $monData 
    close $id
    puts "\rresFile:$resFile\nMonData---<$monData>---\r"; update
    set framsL [wsplit $monData lIsT]
    if {[llength $framsL]==0} {
      set gaSet(fail) "No DyingGasp frame was detected"
      return -1
    }
  } else {
    set ret 0
  }
  
  if {$type=="dg"} {
    set ret 0
    ## 2b0601040181240601 ==  snmp.enterprise
    ## 06 == generic-trap: enterpriseSpecific (6)
    ## 24 == specific-trap: 36
    ## 437269746963616c ==   Critical

    foreach uut {Uut1 Uut2} {
      set ret$uut -1
      set uutNum [string index $uut end]
      set dutIp 1.1.1.[set gaSet(pair)][set uutNum]
      
      set res 0
      foreach fram $framsL {
        puts "\rUUT:$uut FrameA---<$fram>---\r"; update
        
        set m1 [string match "*Src: $dutIp*" $fram]
        #set m2 [string match *2b0601040181240601* $fram]
        set m2 [string match *1.3.6.1.4.1.164.6.1* $fram]
        #set m3 [string match *06* $fram]
        set m3 [string match {*generic-trap: enterpriseSpecific (6)*} $fram]
        #set m4 [string match *24* $fram]
        set m4 [string match {*specific-trap: 36*} $fram]
        set m5 [string match *437269746963616c* $fram]
        set m6 [string match *Critical* $fram]
        puts "$m1 $m2 $m3 $m4 $m5"; update
        if { $m1 && $m2 && $m3 && $m4 && ($m5 || $m6)} {
          set res 1
          #file delete -force $resFile
          break
        }
      } 
      if {$res} {
        puts "\rUUT:$uut FrameB---<$fram>---\r"; update
        set ret$uut 0
      }  
      puts "ret of TrapCheck: [set ret$uut]"
      if {[set ret$uut]!=0} {
        set ret -1
        set gaSet(fail) "No \"Daying Gasp\" trap from $uut"
        break
      }
    }
    
  }  
  
  if {$ret!=0} {return $ret}
  
  if [catch {eval file delete [glob  [file dirname $resFile]/pi*.txt]} res] {
    set gaSet(fail) "Delete ping's res files fail"
    puts "\r[MyTime] $gaSet(fail) res:<$res>\r"    
    return $ret
  }
  
  set ret [Wait "Wait for power on" 30]  
  if {$ret!=0} {return $ret}
  
  foreach uut {Uut1 Uut2} {
    set ret [IpCheck $uut]
    if {$ret!=0} {return $ret}    
  }
  
  return 0
}
proc neMemoryPerf {type} {
  global gaSet tmsg
  puts "[MyTime] MemoryPerf $type"
  MassConnect $::pair
  SwEth pc
  SwShdsl disconnect

  foreach uut {Uut1 Uut2} {
    if {$gaSet(perfSet)==1} {
      set ret [IpConfig $uut]
      if {$ret!=0} {return $ret}
    }
  }
  if {$type=="dg"} {
    foreach uut {Uut1 Uut2} {
      set ret [PingTest $uut]
      if {$ret!=0} {return $ret}
    }
    Status "Wait for Scotty"
    package require RLScotty
    set gaSet(trapId) [RLScotty::SnmpOpenTrap tmsg]
  
    set trapTime 240
    set ret -1
    set retUut1 -1
    set retUut2 -1
    set secStart [clock seconds]
    for {set i $trapTime} {$i > 0} {incr i -1} {
      if {$gaSet(act)==0} {return -2}	 
      
      set secNow  [clock seconds]
      set runTime [expr $secNow - $secStart]
      $gaSet(runTime) configure -text $runTime
      update	   
      foreach uut {Uut1 Uut2} {
        if {[set ret$uut]==0} {continue}
        if {$gaSet(act)==0} {return -2}	
        set tmsg ""
        set ret [Eth1Toggle $uut] 
        if {$ret!=0} {return $ret}
        for {set i 1} {$i<=10} {incr i} {
          if {$gaSet(act)==0} {return -2}	
          after 1000
          set ret [PingTest $uut]
          if {$ret!=0} {return $ret}
          set ret$uut [TrapCheck $uut $tmsg "ETH Port 1"]
          puts "ret of TrapCheck $i after $runTime sec: [set ret$uut]"
          if {[set ret$uut]==0} {break}
        } 
      } 
      if {$runTime>$trapTime} {
        set ret -1
        break
      }
      if {$retUut1==0 && $retUut2==0} {
        set ret 0
        break
      }
      after 2000
    } 
    if {$retUut1!=0} {
      set $gaSet(fail) "No \"ETH Port 1\" trap from Uut1"
      return -1
    }
    if {$retUut2!=0} {
      set $gaSet(fail) "No \"ETH Port 1\" trap from Uut2"
      return -1
    }
  }
  
  foreach uut {Uut1 Uut2} {
    set tmsg ""
    Power $uut off 
    after 2000    
    Power $uut on
    if {$type=="dg"} {
      set ret$uut [TrapCheck $uut $tmsg "DyingGaspTrap"]
      puts "ret of TrapCheck: [set ret$uut]"
      if {[set ret$uut]!=0} {
        set ret -1
        set gaSet(fail) "No \"Daying Gasp\" trap from $uut"
        break
      }
    } else {
      set ret 0
    }
  }  
  
  if {$type=="dg"} {
    RLScotty::SnmpCloseAllTrap
  }
  
  if {$ret!=0} {return $ret}
  
  set ret [Wait "Wait for power on" 30]  
  if {$ret!=0} {return $ret}
  
  foreach uut {Uut1 Uut2} {
    set ret [IpCheck $uut]
    if {$ret!=0} {return $ret}    
  }
  
  return 0
}

# ***************************************************************************
# Relays
# ***************************************************************************
proc Relays {run} {
  global gaSet tmsg
  puts "[MyTime] Relays"
  Power all off
  MassConnect $::pair
  SwEth gen
  SwShdsl relay  
  
  Status "DXC4 Configuration"
  set dxcClk "int"   
  set fram g732n
  set ts0 transparent
  set ts 31  
  foreach dxc4 {idDxc4-1 idDxc4-2} srcClk {int int} {
    if {$gaSet(act)==0} {return -2}
    set ret [SetDxc4 $dxc4 $srcClk $ts0 $ts]
    if {$ret !=0} {
      set ret [SetDxc4 $dxc4 $srcClk $ts0 $ts]
      if {$ret !=0} {          
        set gaSet(fail) "Relay Test - $dxc4 Configuration Failed"
        return -1
      }
    }  
  }
  set ret [BertTestRelay]  
  Power all on
  if {$ret==0} {
    set ret [Wait "Wait for reset" 15 white]
    if {$ret!=0} {return $ret}
    set ret [UUTsUp]
    if {$ret!=0} {return $ret}
  }
  return $ret

}

# ***************************************************************************
# ToggleTestMode
# ***************************************************************************
proc ToggleTestMode {} {
  global gaSet gaGui glTests
  BuildTests
  set gaSet(relDebMode) Release
  Status ""
  if {$gaSet(TestMode)=="long"} {
    ## do nothing
  } elseif {$gaSet(TestMode)=="short" || $gaSet(TestMode)=="shortPreLoad"} {
    #puts $glTests
    set lTestNames [list]
    set glTests [list]
    if {$gaSet(TestMode)=="shortPreLoad" && $gaSet(pl)!=""} {    
      lappend lTestNames PreLoadAppl
    }  
    lappend lTestNames Init ID
    if {$gaSet(dutFam)=="f35" && [string match *4E1* $gaSet(DutInitName)]==1} {
      ## phase 3.5 E1
      lappend lTestNames IntRcv_E1_3840
    } else {
      lappend lTestNames IntRcv_192
    }  
    
    lappend lTestNames FactorySet Mac_BarCode
    puts $lTestNames
    for {set i 0; set k 1} {$i<[llength $lTestNames]} {incr i; incr k} {
      lappend glTests "$k..[lindex $lTestNames $i]"  
    }
  
    set gaSet(startFrom) [lindex $glTests 0]
    $gaGui(startFrom) configure -values $glTests
  
  } elseif {$gaSet(TestMode)=="PreloadOnly"} {
    Status "Preload ONLY!!!" red
    set lTestNames [list]
    set glTests [list]
    lappend lTestNames PreLoadAppl
    puts $lTestNames
    for {set i 0; set k 1} {$i<[llength $lTestNames]} {incr i; incr k} {
      lappend glTests "$k..[lindex $lTestNames $i]"  
    }  
    set gaSet(startFrom) [lindex $glTests 0]
    $gaGui(startFrom) configure -values $glTests
  }
}

