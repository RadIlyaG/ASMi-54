#***************************************************************************
#** DialogBoxEnt
#** 
#** For icon option in [pwd] must be gif file with name like icon.  
#**   error.gif for icon 'error'
#**   stop.gif  for icon 'stop'
#**
#** Input parameters:
#**   -title   Specifies a string to display as the title of the message box. 
#**            The default value is an empty string. 
#**   -text    Specifies the message to display in this message box.  
#**            The default value is an empty string. 
#**   -icon    Specifies an icon to display.
#**            If this option is not specified, then no icon will be displayed. 
#**   -type    Arranges for a predefined set of buttons to be displayed.
#**            The default value is 'ok' button.
#**   -parent  Makes window the logical parent of the message box. 
#**            The message box is displayed on top of its parent window.
#**            The default value is window '.'
#**   -aspect  Specifies a non-negative integer value indicating desired 
#**            aspect ratio for the text.
#**            The aspect ratio is specified as 100*width/height.
#**            100 means the text should be as wide as it is tall, 
#**            200 means the text should be twice as wide as it is tall, 
#**            50 means the text should be twice as tall as it is wide, and so on.
#**            Used to choose line length for text if width option isn't specified. 
#**            Defaults to 150. 
#**   -default Name gives the symbolic name of the default button 
#**            for this message window ('ok', 'cancel', and so on). 
#**            If the message box has just one button it will automatically 
#**            be made the default, otherwise if this option is not specified,
#**            there won't be any default button. 
#**
#** Return value: name of the pressed button
#** Example:
#**   DialogBox
#**   DialogBox -icon error -type "ok yes TCL" -text "Move the Cables"
#***************************************************************************
proc DialogBoxEnt {args} {

  # each option & default value
  foreach {opt def} {title "DialogBoxE" text "" icon "" type ok \
                     parent . aspect 2000 default 0 entVar ""} {
    set var$opt [Opte $args "-$opt" $def]
  }
  wm deiconify $varparent
  set lOptions [list -parent $varparent -modal local -separator 0 \
      -title $vartitle -side bottom -anchor c -default $vardefault -cancel 1]

  if {[catch {Bitmap::get [pwd]\\$varicon.gif} img] == 0} {
    set lOptions [concat $lOptions "-image $img"]
  }

  #create Dialog
  set dlg [eval Dialog .tmpldlg $lOptions]

  #create Buttons
  foreach but $vartype {
    $dlg add -text $but -name $but -command [list Dialog::enddialog $dlg $but]
  }

  #create message
  set msg [message [$dlg getframe].msg -text $vartext -justify center \
     -anchor c -aspect $varaspect]  
  pack $msg -fill both -expand 1 -padx 10 -pady 3

  if {$varentVar!=""} {
    set ent [Entry [$dlg getframe].ent -justify center]
    pack  $ent
	 focus $ent
  }

  set ret [$dlg draw]
  if {$varentVar!=""} {
    set entryString  [$ent cget -text]
	  set ::$varentVar $entryString
  }
  destroy $dlg
  return $ret
}



#***************************************************************************
#** Opte
#***************************************************************************
proc Opte {lOpt opt def} {
  set tit [lsearch $lOpt $opt]
  if {$tit != "-1"} {
    set title [lindex $lOpt [incr tit]]
  } else {
    set title $def
  }
  return $title
} 

# ***************************************************************************
# RegBC
# ***************************************************************************
proc RegBC {lPassPair} {
  global gaSet gaDBox
  Status "BarCode Registration"
  puts "RegBC \"$lPassPair\"" ;  update
  set ret  -1
  set res1 -1
  set res2 -1
#   while {$ret != "0" } {
#     set ret [CheckBcOk $lPassPair]
#     puts "CheckBcOk res:$ret"
#     if { $ret == "-2" } {
#       set logFileID [open logFile-$gaSet(pair).txt a+]
#       puts $logFileID "User stop..[MyTime].."
#       close $logFileID
#       return $ret
#     }
# 	}	 	
  
#   set pairIndx -1
  foreach {ent1 ent2} [lsort -dict [array names gaDBox entVal*]] { }
  
  set needReadBarcode 0
  foreach pair $lPassPair {       
    foreach uut {Uut1 Uut2} {
      set mac $gaSet($pair.mac$uut)
      if {![info exists gaSet($pair.barcode$uut)]} {
        set needReadBarcode 1
        break
      }
    }
  }
  if {$needReadBarcode==1} {
    set ret [ReadBarcode $lPassPair]
    if {$ret!=0} {return $ret}
  } 
  
  foreach pair $lPassPair {
    #incr pairIndx
    #set pair [lindex $lPassPair $pairIndx]
    foreach uut {Uut1 Uut2} {
      set mac $gaSet($pair.mac$uut)
      if {![info exists gaSet($pair.barcode$uut)]} {
        set gaSet(fail)  "Barcode for $uut in pair $pair does not exist"
	      return -1
      }
      set barcode $gaSet($pair.barcode$uut)
      set barcode$uut $barcode   
      #puts "pairIndx:$pairIndx pair:$pair"
      Status "Registration the ${uut}'s MAC. Pair $pair"
      
      set mr [file mtime $::RadAppsPath/MACReg.exe]
      set prevMr [clock scan "Wed Jan 22 23:20:40 2020"] ; # last working version, with 1 MAC
      if {$mr>$prevMr} {
        ## the newest MacReg
        set str "$::RadAppsPath/MACReg.exe /$mac / /$barcode /DISABLE /DISABLE /DISABLE /DISABLE /DISABLE /DISABLE /DISABLE /DISABLE"
      } else {
        set str "$::RadAppsPath/MACReg.exe /$mac /$barcode /DISABLE /DISABLE /DISABLE /DISABLE /DISABLE /DISABLE /DISABLE /DISABLE"
      }
      puts "mr:<[clock format $mr]> prevMr:<[clock format $prevMr]> \n str<$str>"
      set res$uut [string trim [catch {eval exec $str} retVal$uut]]
      #set res$uut [catch {exec c://RADapps/MACReg.exe /$mac /$barcode /DISABLE /DISABLE /DISABLE /DISABLE /DISABLE /DISABLE /DISABLE /DISABLE} retVal$uut]
      puts "Pair:$pair $uut mac:$mac barcode:$barcode res$uut:[set res$uut] retVal$uut:[set retVal$uut] res$uut:[set res$uut]"
      update
      after 500
      if {[set res$uut]!=0} {
        set ret -1
        break
      } else {
        #AddToLog "Pair:$pair $uut MAC:$mac Barcode:$barcode"
        if {$gaSet(pair)=="5"} {
          AddToLog "Pair:$pair $uut MAC:$mac Barcode:$barcode"
          AddToPairLog $pair "Pair:$pair $uut MAC:$mac Barcode:$barcode"
        } else {
          AddToLog "Pair:$gaSet(pair) $uut MAC:$mac Barcode:$barcode" 
          AddToPairLog $gaSet(pair) "Pair:$gaSet(pair) $uut MAC:$mac Barcode:$barcode"         
        }
      }
    } 
#     if {$res1==0 && $res2==0} {
#       PairPerfLab $pair green
#       set txt "Pair $pair Pass Barcode (MAC:$gaSet($pair.mac1) barcode:$barcode1) (MAC:$gaSet($pair.mac2) barcode:$barcode2)"
#     } else {
#       PairPerfLab $pair red
#       set txt "Pair $pair Fail Barcode (MAC:$gaSet($pair.mac1) barcode:$barcode1) (MAC:$gaSet($pair.mac2) barcode:$barcode2)"
#     }
#     set logFileID [open logFile-$gaSet(pair).txt a+]
#     puts $logFileID "$txt..[MyTime].."
#     close $logFileID

    if {$ret!=0} {
      #break
    }
    #AddToLog "Barcode-1 - $barcode1 \nBarcode-2 - $barcode2"
    
    if ![file exists c://logs//macHistory.txt] {
      set id [open c://logs//macHistory.txt w]
      after 100
      close $id
    }
    set id [open c://logs//macHistory.txt a+]
    foreach uut {Uut1 Uut2} {
      puts $id "[MyTime] Tester:$gaSet(pair) Pair:$pair $uut MAC:$gaSet($pair.mac$uut) BarCode:[set barcode$uut] res:[set res$uut]"
    }      
    close $id
  
    if {$ret!=0} {
      break
    } 
  }  
  Status ""	  

  if {$resUut1 != 0 || $resUut2 != 0} {
	  set gaSet(fail)  "Fail to update Data-Base"
	  return -1 
	} else {
 		return 0 
  }
} 

# ***************************************************************************
# CheckBcOk
# ***************************************************************************
proc CheckBcOk {lPassPair} {
	global  gaDBox  gaSet
  puts "CheckBcOk \"$lPassPair\"" ;  update
  puts "gaSet(useExistBarcode):$gaSet(useExistBarcode)"
  if {$gaSet(useExistBarcode)==0} {
    if {$gaSet(pair)=="5"} {
      foreach pair $lPassPair {
        lappend entLabL "Pair-$pair Uut1 " "Pair-$pair Uut2 "
#         if {$gaSet(readTrace)=="0"} { 
#           lappend entLabL "Pair-$pair Uut1 " "Pair-$pair Uut2 "
#         } elseif {$gaSet(readTrace)=="1"} { 
#           lappend entLabL "Pair-$pair Uut1 " "Traceability Uut1 " "Pair-$pair Uut2 "  "Traceability Uut2 "
#         } 
      }
    } else {
      foreach pair $lPassPair {
        lappend entLabL "Pair-$gaSet(pair) Uut1 " "Pair-$gaSet(pair) Uut2 "
#         if {$gaSet(readTrace)=="0"} {
#           lappend entLabL "Pair-$gaSet(pair) Uut1 " "Pair-$gaSet(pair) Uut2 " 
#         } elseif {$gaSet(readTrace)=="1"} { 
#           lappend entLabL "Pair-$gaSet(pair) Uut1 " "Traceability Uut1 " "Pair-$gaSet(pair) Uut2 "  "Traceability Uut2 "
#         }  
      }
    }   
    RLSound::Play beep
    SendEmail "ASMi54" "Read Barcodes"
    
    set entQty [expr {[llength $lPassPair]*2}]
    set entPerRow 2
    set entL "ent1 ent2"
#     if {$gaSet(readTrace)=="0"} {
#       set entQty [expr {[llength $lPassPair]*2}]
#       set entPerRow 2
#       set entL "ent1 ent2"
#     } elseif {$gaSet(readTrace)=="1"} {
#       set entQty [expr {[llength $lPassPair]*4}]
#       set entPerRow 4
#       set entL "ent1 ent3 ent2 ent4"
#     }
    set entLab $entLabL
    set txt "Enter the UUTs' BarCodes"
    set ret [DialogBox -title "BarCode" -text $txt -ent1focus 1\
        -type "Ok Cancel" -entQty $entQty -entPerRow $entPerRow -entLab $entLab] 
    #-type "Ok Cancel Skip" 12/10/2020 09:29:54   
  	if {$ret == "Cancel"} {
  	  return -2 
  	} elseif {$ret == "Ok"} {
      foreach $entL [lsort -dict [array names gaDBox entVal*]] {        
        set barcode1 [string toupper $gaDBox($ent1)]  
        set barcode2 [string toupper $gaDBox($ent2)]  
        puts "barcode1 == $barcode1 barcode2 == $barcode2"
  	    if {$barcode1 == $barcode2} {
  		    return -1 
  		  }
        if {[string length $barcode1]!=11 && [string length $barcode1]!=12} {
          set gaSet(fail) "The barcode ($barcode1) should be 11 or 12 HEX digits"
          return -1
        }
        if {[string length $barcode2]!=11 && [string length $barcode2]!=12} {
          set gaSet(fail) "The barcode ($barcode2) should be 11 or 12 HEX digits"
          return -1
        }
      }
      if {[llength [lsort -unique [array get gaDBox entVal*]]] != [expr {2 *$entQty}]} {
        return -1 
      }
      return 0  	
  	} elseif {$ret == "Skip"} {
      return 0
    }
  } elseif {$gaSet(useExistBarcode)==1} {
    foreach pair [PairsToTest] {
      foreach uut {Uut1 Uut2} {
        if ![info exists gaSet($pair.barcode$uut)] {
          set gaSet(useExistBarcode) 0
          return -1
        }
      }
    }
    set gaSet(useExistBarcode) 0
    return 0
  }
}
# ***************************************************************************
# ReadBarcode
# ***************************************************************************
proc ReadBarcode {lPassPair} {
  global gaSet gaDBox
  puts "ReadBarcode \"$lPassPair\"" ;  update
  set ret -1
  catch {array unset gaDBox}
  while {$ret != "0" } {
    set ret [CheckBcOk $lPassPair]
    puts "CheckBcOk ret:$ret"
    if { $ret == "-2" } {
      foreach pair $lPassPair {
        PairPerfLab $pair red
      }
      #set logFileID [open c://logs//logFile-$gaSet(pair).txt a+]
      AddToLog "User stop..."
      #close $logFileID
      return $ret
    }
	}	
  set pairIndx -1
  puts "array names gaDBox entVal*: <[lsort -dict [array names gaDBox entVal*]]>"
  if {[llength [array names gaDBox entVal*]]==0} {
    if {$gaSet(pair)=="5"} {
      foreach pair [PairsToTest] {
        set pa $pair
        set barc1 $gaSet($pa.barcodeUut1)
        set barc2 $gaSet($pa.barcodeUut2)
        set gaSet(log.$pa) c:/logs/${gaSet(logTime)}-$barc1-$barc2.txt
        AddToLog "Pair $pa , Uut1 - $barc1"
        AddToLog "Pair $pa , Uut2 - $barc2"
        AddToPairLog $pa "$gaSet(DutFullName)"
        AddToPairLog $pa "UUT1 - $barc1"
        AddToPairLog $pa "UUT2 - $barc2"
      }
    } else {
      set pa $gaSet(pair) 
      set barc1 $gaSet($pa.barcodeUut1)
      set barc2 $gaSet($pa.barcodeUut2)
      set gaSet(log.$pa) c:/logs/${gaSet(logTime)}-$barc1-$barc2.txt
      AddToLog "Pair $pa , Uut1 - $barc1"
      AddToLog "Pair $pa , Uut2 - $barc2"
      AddToPairLog $pa "$gaSet(DutFullName)"
      AddToPairLog $pa "UUT1 - $barc1"
      AddToPairLog $pa "UUT2 - $barc2"
    } 
  }
  foreach {ent1 ent2} [lsort -dict [array names gaDBox entVal*]] {
    incr pairIndx
    set pair [lindex $lPassPair $pairIndx]
    foreach uut {Uut1 Uut2} ent {1 2} {
      set barcode [string toupper $gaDBox([set ent$ent])] 
      set barc$ent $barcode 
      set gaSet($pair.barcode$uut) $barcode
      #AddToLog "Pair $pair , $uut - $barcode"
      puts "pair:$pair uut:$uut ent:$ent barcode:$barcode"
      if {$gaSet(pair)=="5"} {
        AddToLog "Pair $pair , $uut - $barcode"
      } else {
        AddToLog "Pair $gaSet(pair) , $uut - $barcode"
      }      
    }
    mparray gaSet *log*
    if {$gaSet(pair)=="5"} {
      set gaSet(log.$pair) c:/logs/${gaSet(logTime)}-$barc1-$barc2.txt
      set pa $pair 
      set par $pair     
    } else {
      set gaSet(log.$gaSet(pair)) c:/logs/${gaSet(logTime)}-$barc1-$barc2.txt
      set pa $gaSet(pair) 
      set par 1  
    }
    mparray gaSet *log*
    
    AddToPairLog $pa "$gaSet(DutFullName)"
    AddToPairLog $pa "UUT1 - $barc1"
    AddToPairLog $pa "UUT2 - $barc2"
    CheckMac $barc1 $par Uut1
    CheckMac $barc2 $par Uut2
  }

  return $ret
}

# ***************************************************************************
# UnregIdBarcode
# UnregIdBarcode $gaSet(1.barcode1)
# UnregIdBarcode EA100463652
# ***************************************************************************
proc UnregIdBarcode {pa barcode {mac {}}} {
  global gaSet
  Status "Unreg ID Barcode $barcode"
  set res [UnregIdMac $barcode $mac]
    
  puts "\nUnreg ID Barcode $barcode res:<$res>\n"
  if {$res=="OK" || [string match "*No records to Delete by ID-Number*" $res]} {
    set ret 0
  } else {
    set ret $res
  }
  AddToPairLog $pa "Unreg ID Barcode $barcode mac:<$mac> res:<$res> ret:<$ret>"
  return $ret
}

# ***************************************************************************
# UnregIdMac
# ***************************************************************************
proc UnregIdMac {barcode {mac {}}} {
  set ret 0
  set res ""
  set url "http://ws-proxy01.rad.com:10211/ATE_WS/ws/rest/"
  #set url "https://ws-proxy01.rad.com:8445/ATE_WS/ws/rest/"
  set param "DisconnectBarcode\?mac=[set mac]\&idNumber=[set barcode]"
  append url $param
  puts "url:<$url>"
  if [catch {set tok [::http::geturl $url -headers [list Authorization "Basic [base64::encode webservices:radexternal]"]]} res] {
    return $res
  } 
  update
  set st [::http::status $tok]
  set nc [::http::ncode $tok]
  if {$st=="ok" && $nc=="200"} {
    #puts "Get $command from $barc done successfully"
  } else {
    set res "http::status: <$st> http::ncode: <$nc>"
    set ret -1
  }
  upvar #0 $tok state
  #parray state
  #puts "body:<$state(body)>"
  set ret $state(body)
  ::http::cleanup $tok
  
  return $ret
}

