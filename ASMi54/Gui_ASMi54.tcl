#***************************************************************************
#** GUI
#***************************************************************************
proc GUI {} {
  global gaSet gaGui glTests  
  wm title . "$gaSet(pair) : $gaSet(DutFullName)"
  if {$gaSet(testMode)=="s"} {
    wm title . "$gaSet(pair) : ShortTest ASMi54"
  }
  wm protocol . WM_DELETE_WINDOW {Quit}
  wm geometry . $gaGui(xy)
  wm resizable . 0 0
  set descmenu {
    "&File" all file 0 {	 
      {command "Log File"  {} {} {} -command ShowLog}
	    {separator}     
      {cascad "&Console" {} console 0 {
        {checkbutton "console show" {} "Console Show" {} -command "console show" -variable gConsole}  
        {command "Capture Console" cc "Capture Console" {} -command CaptureConsole}
        {command "Find Console" console "Find Console" {} -command {GuiFindConsole}}          
      }
      }
      {separator}
      {command "Open Pages File" History "" {} \
         -command {
           global gaSet
           if [info  exists gaSet(pageFilePath)] {
             if [file exists $gaSet(pageFilePath)] {
               set cmd [list exec "notepad.exe" $gaSet(pageFilePath) &]
               eval $cmd
             }
           }
         }
      }
      {separator}
      {command "History" History "" {} \
         -command {
           set cmd [list exec "C:\\Program\ Files\\Internet\ Explorer\\iexplore.exe" [pwd]\\history.html &]
           eval $cmd
#            set command [list {*}[auto_execok start] {}]
#            set url file:///[pwd]/history.html
#            exec {*}$command $url &
         }
      }
      {separator}
      {command "Update INIT files on all the Testers" {} "Exit" {} -command {UpdateInitsToTesters}}
      {separator}
      {command "E&xit" exit "Exit" {Alt x} -command {Quit}}
    }
    "&Tools" tools tools 0 {	  
      {command "Inventory" init {} {} -command {GuiInventory}}
      {command "Load Init File" init {} {} -command {GetInitFile}}
      {separator}   
      {cascad "Power" {} pwr 0 {
        {command "Both UUTs ON"  init {} {} -command {ToolsPower all on}}   
        {command "Both UUTs OFF" init {} {} -command {ToolsPower all off}}
        {command "OFF ON"        init {} {} -command {ToolsPower all off; after 1000; ToolsPower all on}}   
                     
      }
      }                
      {separator}    
      {radiobutton "Don't use exist Barcodes" init {} {} -command {} -variable gaSet(useExistBarcode) -value 0}
      {radiobutton "Use exist Barcodes" init {} {} -command {} -variable gaSet(useExistBarcode) -value 1}      
      {separator}
      {radiobutton "One test ON"  init {} {} -value 1 -variable gaSet(oneTest)}
      {radiobutton "One test OFF" init {} {} -value 0 -variable gaSet(oneTest)}
      {separator}      
      {command "Release / Debug mode" {} "" {} -command {GuiReleaseDebugMode}}                 
      {separator}      
      {command "DLS6x00 ports setup" {} "" {} -command {ChooseLS4}}                 
      {separator}
      {cascad "Pairs switch" {} fs 0 {
          {command "Pair 1"  {} "Pair 1"  {} -command {ToolsMassConnect 1}}
          {command "Pair 2"  {} "Pair 2"  {} -command {ToolsMassConnect 2}}
          {command "Pair 3"  {} "Pair 3"  {} -command {ToolsMassConnect 3}}
          {command "Pair 4"  {} "Pair 4"  {} -command {ToolsMassConnect 4}}
          {command "Pair 5"  {} "Pair 5"  {} -command {ToolsMassConnect 5}}
          {command "Pair 6"  {} "Pair 6"  {} -command {ToolsMassConnect 6}}
          {command "Pair 7"  {} "Pair 7"  {} -command {ToolsMassConnect 7}}
          {command "Pair 8"  {} "Pair 8"  {} -command {ToolsMassConnect 8}}
          {command "Pair 9"  {} "Pair 9"  {} -command {ToolsMassConnect 9}}
          {command "Pair 10" {} "Pair 10" {} -command {ToolsMassConnect 10}}
          {command "Pair 11" {} "Pair 11" {} -command {ToolsMassConnect 11}}                   
      }
      }    
      {cascad "DLS Connect mode" {} fs 0 {
          {command "Range"       {} "Range"      {} -command {ToolsDslConnect range}}
          {command "Disconnect"  {} "Disconnect" {} -command {ToolsDslConnect disconnect}}
          {command "Short"       {} "Short"      {} -command {ToolsDslConnect short}}
          {command "Relay"       {} "Relay"      {} -command {ToolsDslConnect relay}}                   
      }
      }    
      {separator}
      {command "Iint ETX204" {} "" {} -command {ToolsEtxGen}} 
      {command "Iint DXC4" {} "" {} -command {ToolsDxc4}}                
      {separator}
      {cascad "Email" {} fs 0 {
        {command "E-mail Setting" gaGui(ToolAdd) {} {} -command {GuiEmail .mail}} 
  		  {command "E-mail Test" gaGui(ToolAdd) {} {} -command {TestEmail}}       
      }
      }
		  {separator}		
      {command "IPRelay IP Address" {} "IPRelay IP Address" {} -command {GuiIPRelay}} 
      {separator}    
      {radiobutton "Next pair will be checked from begin" init {} {} -command {} -variable gaSet(nextPair) -value begin}
      {radiobutton "Next pair will be checked from the same test" init {} {} -command {} -variable gaSet(nextPair) -value same}
      {separator}    
      {radiobutton "Rerun in Tester Multi: within configuration" init {} {} -command {} -variable gaSet(rerunTesterMulti) -value conf}
      {radiobutton "Rerun in Tester Multi: without configuration" init {} {} -command {} -variable gaSet(rerunTesterMulti) -value sync}
      {separator}    
      {radiobutton "System Page" {} {} {} -command {ChoosePageFile} -variable gaSet(pageType) -value System}
      {radiobutton "Local Page"  {} {} {} -command {ChoosePageFile} -variable gaSet(pageType) -value Local}
             
    }
    "&Terminal" terminal tterminal 0  {
      {command "UUT1" "" "" {} -command {OpenTeraTerm gaSet(comUut1)}}
      {command "UUT2" "" "" {} -command {OpenTeraTerm gaSet(comUut2)}} 
      {command "ETX1" "" "" {} -command {OpenTeraTerm gaSet(comGen1)}}
      {command "ETX2" "" "" {} -command {OpenTeraTerm gaSet(comGen2)}}
      {command "DXC1" "" "" {} -command {OpenTeraTerm gaSet(comDxc1)}}
      {command "DXC2" "" "" {} -command {OpenTeraTerm gaSet(comDxc2)}}
      {command "DLS" "" "" {} -command {OpenTeraTerm gaSet(comDls1)}}
    }
    
    "&About" all about 0 {
      {command "&About" about "" {} -command {About} 
      }
    }
  }
  if 0 {
    "&Short Tests" all shortTests 0 {
      {radiobutton "Perform Short Test" {} {} {} -command {UpdStatBarShortTest; BuildTests} -variable gaSet(performShortTest) -value 1}
      {radiobutton "Perform Full Test" {} {} {} -command {UpdStatBarShortTest; BuildTests} -variable gaSet(performShortTest) -value 0}       
    }
  }
   #{command "SW init" init {} {} -command {GuiSwInit}}	
#    {radiobutton "Stop on Failure" {} "" {} -value 1 -variable gaSet(stopFail)}
#       {separator}

  set mainframe [MainFrame .mainframe -menu $descmenu]
  
  set gaSet(sstatus) [$mainframe addindicator]  
  $gaSet(sstatus) configure -width 70 
  
  set gaSet(statBarShortTest) [$mainframe addindicator]
  
  #set gaGui(ls2) [$mainframe addindicator]
  UpdateDlsFields
  
  set gaSet(startTime) [$mainframe addindicator]
  
  set gaSet(runTime) [$mainframe addindicator]
  $gaSet(runTime) configure -width 5
  
  set tb0 [$mainframe addtoolbar]
  pack $tb0 -fill x
  set labstartFrom [Label $tb0.labSoft -text "Start From   "]
  set gaGui(startFrom) [ComboBox $tb0.cbstartFrom  -height 18 -width 25 -textvariable gaSet(startFrom) -justify center  -editable 0]
  $gaGui(startFrom) bind <Button-1> {SaveInit}
  pack $labstartFrom $gaGui(startFrom) -padx 2 -side left
  set sepIntf [Separator $tb0.sepIntf -orient vertical]
  pack $sepIntf -side left -padx 6 -pady 2 -fill y -expand 0
	 
  set bb [ButtonBox $tb0.bbox0 -spacing 1 -padx 5 -pady 5]
    set gaGui(tbrun) [$bb add -image [Bitmap::get images/run1] \
        -takefocus 0 -command ButRun \
        -bd 1 -padx 5 -pady 5 -helptext "Run the Tester"]		 		 
    set gaGui(tbstop) [$bb add -image [Bitmap::get images/stop1] \
        -takefocus 0 -command ButStop \
        -bd 1 -padx 5 -pady 5 -helptext "Stop the Tester"]
    set gaGui(tbpaus) [$bb add -image [Bitmap::get images/pause] \
        -takefocus 0 -command ButPause \
        -bd 1 -padx 5 -pady 1 -helptext "Pause/Continue the Tester"]	    
  pack $bb -side left  -anchor w -padx 7 ;#-pady 3
  set bb [ButtonBox $tb0.bbox1 -spacing 1 -padx 5 -pady 5]
    set gaGui(noSet) [$bb add -image [Bitmap::get images/Set] \
        -takefocus 0 -command {PerfSet swap} \
        -bd 1 -padx 5 -pady 5 -helptext "Run with the UUTs Setup"]    
  pack $bb -side left  -anchor w -padx 7
  set bb [ButtonBox $tb0.bbox12 -spacing 1 -padx 5 -pady 5]
    set gaGui(email) [$bb add -image [image create photo -file  images/email16.ico] \
        -takefocus 0 -command {GuiEmail .mail} \
        -bd 1 -padx 5 -pady 5 -helptext "Email Setup"] 
    set gaGui(ramzor) [$bb add -image [image create photo -file  images/TRFFC09_1.ico] \
        -takefocus 0 -command {GuiIPRelay} \
        -bd 1 -padx 5 -pady 5 -helptext "IP-Relay Setup"]        
  pack $bb -side left  -anchor w -padx 7
  
  set sepIntf [Separator $tb0.sepFL -orient vertical]
  #pack $sepIntf -side left -padx 6 -pady 2 -fill y -expand 0 
  
  set bb [ButtonBox $tb0.bbox2]
    set gaGui(butShowLog) [$bb add -image [image create photo -file images/find1.1.ico] \
        -takefocus 0 -command {ShowLog} -bd 1 -helptext "View Log file"]    
  pack $bb -side left  -anchor w -padx 7
  
    set frCommon [frame $mainframe.frCommon]
      set frUut [frame $frCommon.frUut]   
#         set frDut [TitleFrame $frUut.frDut -bd 2 -relief groove -text "UUT"] 
#           set gaGui(cbUserPort) [Entry [$frDut getframe].frUut -justify center\
#               -textvariable gaSet(uut) -state disabled -width 11]          
#           pack $gaGui(cbUserPort) -anchor w
#         pack $frDut -fill x -expand 1 -anchor n ; # -side left
        
        set frWire [TitleFrame $frUut.frWire -bd 2 -relief groove -text "Wire" ]     
          set gaGui(cbWire) [Entry [$frWire getframe].cdWire -justify center\
              -textvariable gaSet(wire) -state disabled  -width 11]
          pack $gaGui(cbWire) -anchor w
        pack $frWire -fill x -expand 1 -anchor n  
        
        set frEth [TitleFrame $frUut.frEth -bd 2 -relief groove -text "Eth" ]     
          set gaGui(cbEth) [Entry [$frEth getframe].cdEth -justify center\
              -textvariable gaSet(eth) -state disabled  -width 11]
          pack $gaGui(cbEth) -anchor w
        pack $frEth -fill x -expand 1 -anchor n  
        
        set frE1 [TitleFrame $frUut.frE1 -bd 2 -relief groove -text "E1" ]     
          set gaGui(cbE1) [Entry [$frE1 getframe].cdE1 -justify center\
              -textvariable gaSet(e1) -state disabled  -width 11]
          pack $gaGui(cbE1) -anchor w
        pack $frE1 -fill x -expand 1 -anchor n
        
        set frPS [TitleFrame $frUut.frPS -bd 2 -relief groove -text "PS" ]     
          set gaGui(cbPS) [Entry [$frPS getframe].cdPS -justify center\
              -textvariable gaSet(ps) -state disabled  -width 11]
          pack $gaGui(cbPS) -anchor w
        pack $frPS -fill x -expand 1 -anchor n
        
        set frBox [TitleFrame $frUut.frBox -bd 2 -relief groove -text "Box" ]     
          set gaGui(cbBox) [Entry [$frBox getframe].cdBox -justify center\
              -textvariable gaSet(box) -state disabled -width 11 ]
          pack $gaGui(cbBox) -anchor w
        pack $frBox -fill x -expand 1 -anchor n  
      #pack $frUut -fill y -expand 1 -padx 2 -pady 2 -side left ; # -ipadx 10
      set frLic [frame $frCommon.frLic]
#         set frLic0 [TitleFrame $frLic.frLic0 -bd 2 -relief groove ]                
#           set gaGui(enReadTrace) [checkbutton [$frLic0 getframe].enReadTrace -variable  gaSet(readTrace) -command ToggleScanTraceBarcode]
#           set gaGui(labReadTrace) [Label [$frLic0 getframe].labReadTrace -text "Read Traceability"]
#           grid $gaGui(enReadTrace) $gaGui(labReadTrace) -sticky wn
          
        set frLic1 [TitleFrame $frLic.frLic1 -bd 2 -relief groove -text "Files" ]             
          set gaGui(plEn) [checkbutton [$frLic1 getframe].plEn -state disabled -variable gaSet(plEn) ]
          set gaGui(labPlEn) [Label [$frLic1 getframe].labPlEn -text "PreLoad Appl." -helptext $gaSet(pl)]
          
          set gaGui(licEn) [checkbutton [$frLic1 getframe].licEn -state disabled -variable gaSet(licEn)]
          if ![info exists gaSet(licDir)] {set gaSet(licDir) c:/}
          set gaGui(labLicEn) [Label [$frLic1 getframe].labLicEn -text "Create license" -helptext $gaSet(licDir)] 
          
          set gaGui(uafEn) [checkbutton [$frLic1 getframe].uafEn -state disabled -variable gaSet(uafEn)]  
          set gaGui(labUafEn) [Label [$frLic1 getframe].labUafEn -text "User Appl." -helptext $gaSet(uaf)]          
          
          set gaGui(udfEn) [checkbutton [$frLic1 getframe].udfEn -state disabled -variable gaSet(udfEn)]
          set gaGui(labUdfEn) [Label [$frLic1 getframe].labUdfEn -text "User Define" -helptext $gaSet(udf)]          
          
#           grid $gaGui(plEn) $gaGui(labPlEn) -sticky wn
#           grid $gaGui(uafEn) $gaGui(labUafEn) -sticky wn
#           grid $gaGui(licEn) $gaGui(labLicEn) -sticky w
#           grid $gaGui(udfEn) $gaGui(labUdfEn) -sticky wn   
          
        set frLic2 [TitleFrame $frLic.frLic2 -bd 2 -relief groove -text "Test Mode" ] 
          set gaGui(rbTestLong) [radiobutton [$frLic2 getframe].rbTestLong -variable gaSet(TestMode) -value long -command ToggleTestMode]
          set gaGui(labTestLong) [Label [$frLic2 getframe].labTestLong -text "Regular"]
          set gaGui(rbTestShortPreLoad) [radiobutton [$frLic2 getframe].rbTestShortPreLoad -variable gaSet(TestMode) -value shortPreLoad -command ToggleTestMode]
          set gaGui(labTestShortPreLoad) [Label [$frLic2 getframe].labTestShortPreLoad -text "Short with PreLoad"]
          set gaGui(rbTestShort) [radiobutton [$frLic2 getframe].rbTestShort -variable gaSet(TestMode) -value short -command ToggleTestMode]
          set gaGui(labTestShort) [Label [$frLic2 getframe].labTestShort -text "Short"]
          set gaGui(rbTestBeeline) [radiobutton [$frLic2 getframe].rbTestBeeline -variable gaSet(TestMode) -value beeline -command ToggleTestMode]
          set gaGui(labTestBeeline) [Label [$frLic2 getframe].labTestBeeline -text "Beeline"]
          set gaGui(rbTestPreLoad) [radiobutton [$frLic2 getframe].rbTestPreLoad -variable gaSet(TestMode) -value PreloadOnly -command ToggleTestMode]
          set gaGui(labTestPreLoad) [Label [$frLic2 getframe].labTestPreLoad -text "Preload only"]
          set gaGui(rbTestPreLoadMac) [radiobutton [$frLic2 getframe].rbTestPreLoadMac -variable gaSet(TestMode) -value PreloadMac -command ToggleTestMode]
          set gaGui(labTestPreLoadMac) [Label [$frLic2 getframe].labTestPreLoadMac -text "Preload and MacBarcode"]
          
          grid $gaGui(rbTestLong) $gaGui(labTestLong) -sticky wn
          grid $gaGui(rbTestShortPreLoad) $gaGui(labTestShortPreLoad) -sticky wn
          grid $gaGui(rbTestShort) $gaGui(labTestShort) -sticky wn
          #grid $gaGui(rbTestBeeline) $gaGui(labTestBeeline) -sticky wn
          grid $gaGui(rbTestPreLoad) $gaGui(labTestPreLoad) -sticky wn    
            
        #pack $frLic0 -fill both -expand 1 -anchor n -pady 2
        #pack $frLic1 -fill both -expand 1 -anchor n -pady 2
        pack $frLic2 -fill both -expand 1 -anchor n -pady 2
      pack $frLic -fill y -expand 1 -padx 0 -pady 0 -side left ; # -ipadx 10
      pack $frUut -fill y -expand 1 -padx 2 -pady 2 -side left ; # -ipadx 10
    pack $frCommon -fill y -expand 1 -padx 2 -pady 0 -side left 
	 
    set frDUT [frame $mainframe.frDUT -bd 0 -relief groove]
      set frID [TitleFrame $frDUT.frID -bd 2 -relief groove -text "ID number"]
      set fr [$frID getframe]    
      #set labDUT [Label $fr.labDUT -text "UUT's ID number"]
      set gaGui(entDUT) [Entry $fr.entDUT -bd 1 -justify center -width 50\
            -editable 1 -relief groove -textvariable gaSet(entDUT) -command {CmdEntID}\
            -helptext "Scan UUT's ID number here"]
      set gaGui(clrDut) [Button $fr.clrDut -image [image create photo -file  images/clear1.ico] \
            -takefocus 1 \
            -command {
                global gaSet gaGui
                set gaSet(entDUT) ""
                focus -force $gaGui(entDUT)
            }]  
      grid  $gaGui(entDUT) $gaGui(clrDut) -sticky w -padx 2       
      
      set frTrac [TitleFrame $frDUT.frTrac -bd 2 -relief groove -text "Traceability number"] 
        set fr [$frTrac getframe]               
        set gaGui(enReadTrace) [checkbutton $fr.enReadTrace -variable  gaSet(readTrace) -text "Read Traceability" -command ToggleScanTraceBarcode]
#         set gaGui(labReadTrace) [Label $fr.labReadTrace -text "Read Traceability"]
        grid $gaGui(enReadTrace)  -sticky wn
        set labTrace [Label $fr.labTrace -text "UUT's Traceability number"]
        set gaGui(entTrace) [Entry $fr.entTrace -bd 1 -justify center -width 50\
            -editable 1 -relief groove -textvariable gaSet(entTrace) -command {CmdEntTrace}\
            -helptext "Scan UUT's Traceability number here"]
        set gaGui(clrTrace) [Button $fr.clrTrace -image [image create photo -file  images/clear1.ico] \
            -takefocus 1 \
            -command {
                global gaSet gaGui
                set gaSet(entTrace) ""
                focus -force $gaGui(entTrace)
            }] 
         grid $gaGui(entTrace) $gaGui(clrTrace) -sticky w -padx 2     
                   
#       grid $labDUT $gaGui(entDUT) $gaGui(clrDut) -sticky w -padx 2 
      grid $frID  -sticky w -padx 2 -columnspan 2
      grid $frTrac  -sticky w -padx 2 -columnspan 2
#     set frTestPerf [TitleFrame $mainframe.frTestPerf -bd 2 -relief groove \
#         -text "Test Performance"] 
#       set f [$frTestPerf getframe]      17/09/2014 16:26:46
    set frTestPerf [frame $mainframe.frTestPerf -bd 2 -relief groove]     
      set f $frTestPerf
      set frCur [frame $f.frCur]  
        set labCur [Label $frCur.labCur -text "Current Test  " -width 13]
        set gaGui(curTest) [Entry $frCur.curTest -bd 1 \
            -editable 0 -relief groove -textvariable gaSet(curTest) \
	       -justify center -width 50]
        pack $labCur $gaGui(curTest) -padx 7 -pady 1 -side left -fill x;# -expand 1 
      pack $frCur  -anchor w
      #set frStatus [frame $f.frStatus]
      #  set labStatus [Label $frStatus.labStatus -text "Status  " -width 12]
      #  set gaGui(labStatus) [Entry $frStatus.entStatus \
            -bd 1 -editable 0 -relief groove \
	   -textvariable gaSet(status) -justify center -width 58]
      #  pack $labStatus $gaGui(labStatus) -fill x -padx 7 -pady 3 -side left;# -expand 1 	 
      #pack $frStatus -anchor w
      set frFail [frame $f.frFail]
      set gaGui(frFailStatus) $frFail
        set labFail [Label $frFail.labFail -text "Fail Reason  " -width 12]
        set labFailStatus [Entry $frFail.labFailStatus \
            -bd 1 -editable 1 -relief groove \
            -textvariable gaSet(fail) -justify center -width 58]
      pack $labFail $labFailStatus -fill x -padx 7 -pady 3 -side left; # -expand 1	
      #pack $gaGui(frFailStatus) -anchor w
      
#       set frPairPerf [frame [$frTestPerf getframe].frPairPerf -bd 0 -relief groove]  17/09/2014 16:26:36
      set frPairPerf [frame $frTestPerf.frPairPerf -bd 0 -relief groove]
      set gaGui(labPairPerf0) [Button $frPairPerf.labPairPerf0 -text "None" -bd 1 -relief raised -command [list TogglePairButAll 0]]
      if {$gaSet(pair)=="5"} {
        pack $gaGui(labPairPerf0) -side left -padx 1 -fill x -expand 1
      }
      for {set i 1} {$i <= $gaSet(maxMultiQty)} {incr i} {
        set gaGui(labPairPerf$i) [Button $frPairPerf.labPairPerf$i -text $i -bd 1 -relief raised -command [list TogglePairBut $i]]
        #set gaGui(labPairPerf$i) [Label $frPairPerf.labPairPerf$i -text $i -bd 1 -relief raised]
        #bind  . <Alt-$i> [list TogglePairBut $i]
        if {$gaSet(pair)=="5"} {
          pack $gaGui(labPairPerf$i) -side left -padx 1 -fill x -expand 1
        } else {
          if {$i=="1"} {
            #pack $gaGui(labPairPerf$i) -side left -padx 1 -fill x -expand 1
          }
        }
      }
      set gaGui(labPairPerfAll) [Button $frPairPerf.labPairPerfAll -text ALL -bd 1 -relief raised -command [list TogglePairButAll All]]
      if {$gaSet(pair)=="5"} {
        pack $gaGui(labPairPerfAll) -side left -padx 1 -fill x -expand 1
      } else {
        TogglePairBut 1
      }
      pack $frPairPerf -fill x -padx 2 -pady 1 -expand 1      
    pack $frDUT $frTestPerf -fill both -expand yes -padx 2 -pady 2 -anchor n	 
  pack $mainframe -fill both -expand yes

  $gaGui(tbrun) configure -relief raised -state normal
  $gaGui(tbstop) configure -relief sunken -state disabled  

  console eval {.console config -height 14 -width 92}
  console eval {set ::tk::console::maxLines 10000}
  console eval {.console config -font {Verdana 8}}
  focus -force .
  bind . <F1> {console show}
  bind . <Alt-i> {GuiInventory}
  bind . <Alt-r> {ButRun}
  bind . <Alt-s> {ButStop}
  bind . <Alt-d> {GuiReleaseDebugMode}

#    RLStatus::Show -msg atp
#   RLStatus::Show -msg fti
  
  .menubar.tterminal entryconfigure 0 -label "UUT1: COM $gaSet(comUut1)"
  .menubar.tterminal entryconfigure 1 -label "UUT2: COM $gaSet(comUut2)"
  .menubar.tterminal entryconfigure 2 -label "ETX1: COM $gaSet(comGen1)"
  .menubar.tterminal entryconfigure 3 -label "ETX2: COM $gaSet(comGen2)"
  .menubar.tterminal entryconfigure 4 -label "DXC1: COM $gaSet(comDxc1)"
  .menubar.tterminal entryconfigure 5 -label "DXC2: COM $gaSet(comDxc2)"
  .menubar.tterminal entryconfigure 6 -label "DLS: COM $gaSet(comDls1)"
  
  set gaSet(entDUT) ""
  focus -force $gaGui(entDUT)
  
  if ![info exists ::RadAppsPath] {
    set ::RadAppsPath c:/RadApps
  }
}
proc About {} {
  if [file exists history.html] {
    set id [open history.html r]
    set hist [read $id]
    close $id
#     regsub -all -- {[<>]} $hist " " a
#     regexp {div ([\d\.]+) \/div} $a m date
    regsub -all -- {<[\w\=\#\d\s\"\/]+>} $hist "" a
    regexp {<!---->\s(.+)\s<!---->} $a m date
  } else {
    set date 14.06.2015 
  }
  DialogBox -title About -icon info -type ok -font {{Lucida Console} 9} -message "The software upgrated at $date"

  #DialogBox -title "About the Tester" -icon info -type ok\
          -message "The software upgrated at 14.06.2015"
}
#***************************************************************************
#** ButRun
#***************************************************************************
proc ButRun {} {
  global gaSet gaGui glTests gRelayState
  
  pack forget $gaGui(frFailStatus)
  Status ""
  set gaSet(runStatus) ""
  if {$gaSet(pair)=="5"} {
    for {set pa 1} {$pa <= 27} {incr pa} {
      set gaSet($pa.barcodeUut1.IdMacLink) ""
      set gaSet($pa.barcodeUut2.IdMacLink) ""
    }
  } else {
    set pa $gaSet(pair) 
    set gaSet($pa.barcodeUut1.IdMacLink) ""
    set gaSet($pa.barcodeUut2.IdMacLink) ""
  }
  set ::wastedSecs 0
  set gaSet(ButRunTime) [clock seconds]
  
  set gaSet(act) 1
  console eval {.console delete 1.0 end}
  console eval {set ::tk::console::maxLines 100000}
  if {$gaSet(pair)!="5"} {
    $gaGui(labPairPerf1) configure -bg $gaSet(toTestClr)
  }
  set ret 0
  
  if ![file exists c:/logs] {
    file mkdir c:/logs
  }
  if {[catch {glob *logFile.txt} lTxt]==0} {
    ## if there is no logFile, the [glob] rises error. therefor i use catch]
    foreach fil [glob *logFile.txt] {
      file copy -force $fil c:/logs/$fil
    } 
    foreach fil [glob *logFile.txt] {
      file delete -force $fil
    }
  }
  
  set ti [clock format [clock seconds] -format  "%Y.%m.%d_%H.%M.%S"]
  set gaSet(logFile.$gaSet(pair)) c:/logs/$ti.$gaSet(pair).logFile.txt
  set gaSet(logTime) [clock format [clock seconds] -format  "%Y.%m.%d-%H.%M.%S"]
  AddToLog "$gaSet(DutFullName)"
  AddToLog "$gaSet(relDebMode) mode"
  
  if {$ret==0} {
    if {$gaSet(pageType)=="Local"} {
      set res [DialogBox -icon images/warning.ico -type "Continue Abort" \
          -text "Warning!!!\rYou are sure you want to use a local page?" \
          -default 1 -aspect 2000 -title "Local Page use"]
      if {$res=="Abort"} {
        set ret -2
        set gaSet(fail) "Local Page abort"
        Status "Local Page abort"
        AddToLog $gaSet(fail)
      } else {
        AddToLog "Local Page: $gaSet(localPageFile)"
        set ret 0
      }
    }
  }
  
  if {$ret==0} {
    if {$gaSet(relDebMode)=="Debug"} {
      set res [DialogBox -icon images/info -type "Continue Abort" \
          -text "You are attemping to run the Tester in the Debug Mode.\nAre you sure?" \
          -default 1 -aspect 2000 -title "Debug Mode"]
      if {$res=="Abort"} {
        set ret -2
        set gaSet(fail) "Debug Mode abort"
        Status "Debug Mode abort"
        AddToLog $gaSet(fail)
      } else {
        set ret 0
      }
    }
  }
  
  if {![file exists uutInits/$gaSet(DutInitName)]} {
    set txt "Init file for \'$gaSet(DutFullName)\' is absent"
    Status  $txt
    set gaSet(fail) $txt
    set gaSet(curTest) $gaSet(startFrom)
    set ret -1
    AddToLog $gaSet(fail)
  }
  
  
  if {$gaSet(performShortTest)=="1"} {
    RLSound::Play beep
    RLSound::Play failbeep
    set txt "Be aware!\r\rYou are about to perform the short test.\r\r\
    If you are not sure, click the GUI's \'Short Tests\'->\'Perform Full Test\'"
    set res [DialogBox -icon images/info -type "Continue Abort" -text $txt -default 1 -aspect 2000 -title ASMi53]
    if {$res=="Abort"} {
      set ret -1
      set gaSet(fail) "Short test abort"
      Status "Short test abort"
      AddToLog $gaSet(fail)
    } else {
      set ret 0
    }
  }
  foreach v {sw hw bootVer wire box ps e1 eth} {
    if {$gaSet($v)=="??"} {
      puts "ButRun v:$v gaSet($v):$gaSet($v)"
      set txt "Init file for \'$gaSet(DutFullName)\' is wrong"
      Status  $txt
      set gaSet(fail) $txt
      set gaSet(curTest) $gaSet(startFrom)
      set ret -1
      AddToLog $gaSet(fail)
      break
    }
  }
  
  puts "[MyTime] source Lib_Put_ASMi54.tcl" ; update
  source Lib_Put_ASMi54.tcl
  puts "[MyTime] source Lib_Put_ASMi54_$gaSet(dutFam).tcl" ; update
  source Lib_Put_ASMi54_$gaSet(dutFam).tcl
  
  if [info exists gaSet(TraceID)] {
    puts "gaSet(TraceID) <$gaSet(TraceID)>"
  }
  if [info exists gaSet(DutID)] {
    puts "gaSet(DutID) <$gaSet(DutID)>"
  }
  update
  
  if {$ret==0} {
    set ret [GuiReadOperator]
    parray gaSet *rato*
  }
  
  if {$ret==0} {
    if {[llength [PairsToTest]]==0} {
      PairPerfLab 1 $gaSet(toTestClr)
#       Status  "Choose at least one pair"
#       set gaSet(fail) "Choose at least one pair"
#       set gaSet(curTest) $gaSet(startFrom)
#       set ret -1
      #return -1
    }
    foreach pToTest [PairsToTest] {
      PairPerfLab $pToTest $gaSet(toTestClr)
    } 
    IPRelay-Green
    Status ""
    set gaSet(curTest) [$gaGui(startFrom) cget -text]
    console eval {.console delete 1.0 "end-1001 lines"}
    pack forget $gaGui(frFailStatus)
    $gaSet(startTime) configure -text " Start: [MyTime] "
    $gaGui(tbrun) configure -relief sunken -state disabled
    $gaGui(tbstop) configure -relief raised -state normal
    $gaGui(tbpaus) configure -relief raised -state normal
    set gaSet(fail) ""
    foreach wid {startFrom} {
      $gaGui($wid) configure -state disabled
    }
    #.mainframe setmenustate tools disabled
    update
    catch {exec taskkill.exe /im hypertrm.exe /f /t}
    catch {exec taskkill.exe /im mb.exe /f /t}
    RLTime::Delay 1
    
    for {set pair 1} {$pair<=$gaSet(maxMultiQty)} {incr pair} {
      #PairPerfLab $pair gray
      foreach uut {Uut1 Uut2} {
        catch {unset gaSet($pair.mac$uut)}
        if {$gaSet(useExistBarcode)==0} {
          catch {unset gaSet($pair.barcode$uut)}
          catch {unset gaSet($pair.trace$uut)}
        }
      }
    }
    $gaGui(labPairPerf0) configure -state disable
    $gaGui(labPairPerfAll) configure -state disable
    if {$gaSet(pair)!="5"} {
      $gaGui(labPairPerf1) configure -bg $gaSet(toTestClr) -activebackground $gaSet(toTestClr)
    }
    
    set gaSet(bootScreenUut1) ""
    set gaSet(bootScreenUut2) ""
    set ret 0
    ToolsPower all on ; ## power ON before scan barcodes and OpenRL
    
    if {$ret==0} {
      if 1 {
        set gRelayState red
        IPRelay-LoopRed
        set ret [ReadBarcode [PairsToTest]]
        puts "1. ret:<$ret>"; update
      } else {
        set ret 0
        ## 15/03/2017 15:21:04
        foreach pair [PairsToTest] {
          if {$gaSet(pair)=="5"} {
            set gaSet(log.$pair) c:/logs/${gaSet(logTime)}-${pair}.txt
            set pa $pair
          } else {
            set gaSet(log.$gaSet(pair)) c:/logs/${gaSet(logTime)}-${gaSet(pair)}.txt
            set pa $gaSet(pair) 
          }
          AddToPairLog $pa "$gaSet(DutFullName)"
          puts "2. gaSet(log.$gaSet(pair)):<$gaSet(log.$gaSet(pair))>"; update
        }
      }
      
      if {$gaSet(pageType)=="Local"} {
        foreach pair [PairsToTest] {
          if {$gaSet(pair)=="5"} {
            set pa $pair
          } else {
            set pa $gaSet(pair) 
          }
          AddToPairLog $pa "Local Page: $gaSet(localPageFile)"
        }        
      }
      
      if {$ret==0} {
        IPRelay-Green
        set ret [OpenRL]
#         Power all off
#         after 500
#         Power all on
        MassConnect 1
        if {$ret==0} {
          set ret [Testing]
        }
      }
    }
    puts "ret of Testing: $ret"  ; update
    foreach wid {startFrom } {
      $gaGui($wid) configure -state normal
    }
    $gaGui(labPairPerf0) configure -state normal
    $gaGui(labPairPerfAll) configure -state normal
    .mainframe setmenustate tools normal
    puts "end of normal widgets"  ; update
    update
    set retC [CloseRL]
    puts "ret of CloseRL: $retC"  ; update
    
    set gaSet(oneTest) 0
    set gaSet(rerunTesterMulti) conf
    set gaSet(nextPair) begin
    set gaSet(readMacUploadAppl) 1
    
    set gRelayState red
    IPRelay-LoopRed
  }
  
  Finish $ret
  
  $gaGui(tbrun) configure -relief raised -state normal
  $gaGui(tbstop) configure -relief sunken -state disabled
  $gaGui(tbpaus) configure -relief sunken -state disabled
  update
}
# ***************************************************************************
# Finish
# ***************************************************************************
proc Finish {ret} { 
  global gaSet gaGui glTests  
  if {$ret==0} {
    RLSound::Play passbeep
    Status "Done"  green
	  set gaSet(curTest) ""
	  set gaSet(startFrom) [lindex $glTests 0]
  } elseif {$ret==1} {
    RLSound::Play beep
    Status "The test has been perform"  yellow
  } else {    
    if {$ret=="-2"} {
	    set gaSet(fail) "User stop"
	  }
	  pack $gaGui(frFailStatus)  -anchor w
	  $gaSet(runTime) configure -text ""
    RLSound::Play failbeep
	  Status "Test FAIL"  red
    set gaSet(startFrom) $gaSet(curTest)
    update
  }
  SendEmail "ASMi54" [$gaSet(sstatus) cget -text]
}

#***************************************************************************
#** ButStop
#***************************************************************************
proc ButStop {} {
  global gaGui gaSet
  set gaSet(act) 0
  $gaGui(tbrun) configure -relief raised -state normal
  $gaGui(tbstop) configure -relief sunken -state disabled
  $gaGui(tbpaus) configure -relief sunken -state disabled
  foreach wid {startFrom } {
    $gaGui($wid) configure -state normal
  }
  .mainframe setmenustate tools normal
  CloseRL
  update
}
# ***************************************************************************
# ButPause
# ***************************************************************************
proc ButPause {} {
  global gaGui gaSet
  if { [$gaGui(tbpaus) cget -relief] == "raised" } {
    $gaGui(tbpaus) configure -relief "sunken"     
    #CloseRL
  } else {
    $gaGui(tbpaus) configure -relief "raised" 
    #OpenRL   
  }
        
  while { [$gaGui(tbpaus) cget -relief] != "raised" } {
    RLTime::Delay 1
  }  
}

#***************************************************************************
#** GuiSwInit
#***************************************************************************
proc GuiSwInit {} {  
  global gaSet tmpSw tmpCsl
  set tmpSw  $gaSet(soft)
  set base .topHwInit
  toplevel $base -class Toplevel
  wm focusmodel $base passive
  wm geometry $base +200+200
  wm resizable $base 1 1 
  wm title $base "SW init"
  pack [LabelEntry $base.entHW -label "UUT's SW:  " \
      -justify center -textvariable tmpSw] -pady 1 -padx 3  
  pack [Separator $base.sep1 -orient horizontal] -fill x -padx 2 -pady 3
  pack [frame $base.frBut ] -pady 4 -anchor e
    pack [Button $base.frBut.butCanc -text Cancel -command ButCanc -width 7] -side right -padx 6
    pack [Button $base.frBut.butOk -text Ok -command ButOk -width 7]  -side right -padx 6
  
  focus -force $base
  grab $base
  return {}  
}


#***************************************************************************
#** ButOk
#***************************************************************************
proc ButOk {} {
  global gaSet lp
  #set lp [PasswdDlg .topHwInit.passwd -parent .topHwInit]
  set login 1 ; #[lindex $lp 0]
  set pw    1 ; #[lindex $lp 1]
  if {$login!="1" || $pw!="1"} {
    #exec c:\\rlfiles\\Tools\\btl\\beep.exe &
    RLSound::Play beep
    tk_messageBox -icon error -title "Access denied" -message "The Login or Password isn't correct" \
       -type ok
  } else {
    set sw  [.topHwInit.entHW cget -text]
    puts "$sw"
    set gaSet(soft) $sw
    SaveInit
  }
  ButCanc
}


#***************************************************************************
#** ButCanc -- 
#***************************************************************************
proc ButCanc {} {
  grab release .topHwInit
  focus .
  destroy .topHwInit
}

#***************************************************************************
#** ChooseDslamPort
#***************************************************************************
proc ChooseDslamPort {} {
  global gaSet gaGui
  toplevel .dp
  wm geometry .dp $gaGui(xy) 
  wm title .dp " DSUUTM ports Setup" 

  set ::DSh $gaSet(dsh)
  label .dp.labShNum -text "Type number of DSLAM Shelf"
  SpinBox .dp.entShNum -textvariable ::DSh -justify c -values {1 2}
  pack .dp.labShNum .dp.entShNum -pady 3

  set ::DS $gaSet(ds)
  label .dp.labSlNum -text "Type number of DSLAM Slot"
  SpinBox .dp.entSlNum -textvariable ::DS -justify c -values {6 8 10}
  pack .dp.labSlNum .dp.entSlNum -pady 3

  foreach {p pNum} {First 1 Last 2} {
    set ::DP$pNum $gaSet(dp$pNum)
    label .dp.lab$pNum -text "Type number of $p DSLAM Port"
    entry .dp.ent$pNum -textvariable ::DP$pNum -justify c
    pack .dp.lab$pNum .dp.ent$pNum -pady 3
  }
  button .dp.butDPok -text OK -command "ButDPok"
  pack .dp.butDPok -pady 3
}


#***************************************************************************
#** ButDPok
#***************************************************************************
proc ButDPok {} {
  global gaSet gaGui
  set gaSet(dp1) $::DP1
  set gaSet(dp2) $::DP2
  set gaSet(ds)  $::DS
  set gaSet(dsh) $::DSh
  $gaGui(dp) configure \
      -text "DSLAM ports : $gaSet(dp1) &- $gaSet(dp2) at slot $gaSet(ds)"
  destroy .dp
  SaveInit
}

# ***************************************************************************
# ChooseLS4
# ***************************************************************************
proc ChooseLS4 {} {
  global gaSet gaGui
  if [winfo exists .ls4] {
    focus -force .ls4
    return {}
  }
  toplevel .ls4
  wm geometry .ls4 $gaGui(xy) 
  wm title .ls4 " DLS6x00 ports Setup" 
  focus -force .ls4
  set ::LS4_DLS6x $gaSet(ls4_DLS6x)
  set ::LS4_APD   $gaSet(ls4_APD)
  set frDLS6x [frame .ls4.frDLS6x -bd 2 -relief groove] 
    label $frDLS6x.labDLS6x -text "Choose DLS6x00 type"  -width 23
    ComboBox $frDLS6x.cbDLS6x -values {6100 6300 6700} -width 8 -textvariable ::LS4_DLS6x -justify c
    ComboBox $frDLS6x.cbAPD -values {RSD10} -width 8 -textvariable ::LS4_APD -justify c 
    pack $frDLS6x.labDLS6x $frDLS6x.cbDLS6x $frDLS6x.cbAPD -side left -padx 2 -pady 1
  pack $frDLS6x -padx 2 -pady 2 -fill x -expand 1
  
  set frPorts [frame .ls4.frPorts -bd 2 -relief groove]
    foreach {p pNum} {1st 1 2nd 2 3rd 3 4th 4} {
      set fr [frame $frPorts.fr$pNum]
        set ::LS4_$pNum $gaSet(ls4_$pNum)
        label $fr.lab$pNum -text "$p port" -width 23
        set spPort$pNum [ComboBox $fr.ent$pNum -textvariable ::LS4_$pNum -justify c \
            -width 5 \
            -values {1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24}]
        pack $fr.lab$pNum $fr.ent$pNum -side left -padx 2 -pady 1 -anchor w
      pack $fr -padx 2 -pady 1 
    }
  pack $frPorts -padx 2 -pady 2 -fill x -expand 1   
  button .ls4.butDPok -text OK -command "ButLSok4"
  pack .ls4.butDPok -pady 3
#   if {$gaSet(wire)==2} {
#     $spPort2 configure -state disabled
#   }
  #set txt "DSLAM ports : $gaSet(dp1) &- $gaSet(dp2) at slot $gaSet(ds)"
  #$gaGui(dp) configure -text "$txt"
}



# ***************************************************************************
# ButLSok4
# ***************************************************************************
proc ButLSok4 {} {
  global gaSet gaGui
  set gaSet(ls4_1) $::LS4_1
  set gaSet(ls4_2) $::LS4_2  
  set gaSet(ls4_3) $::LS4_3
  set gaSet(ls4_4) $::LS4_4  
  
  
  set gaSet(ls4_DLS6x) $::LS4_DLS6x 
  set gaSet(ls4_APD) $::LS4_APD 
  if {$::LS4_DLS6x=="6100"} {
    set gaSet(ls4_1) "6100" ; set gaSet(ls4_2) "6100" 
  }
  UpdateDlsFields
  destroy .ls4
  SaveInit
}
# ***************************************************************************
# UpdateDlsFields
# ***************************************************************************
proc UpdateDlsFields {} {
  global gaSet gaGui
  if {$gaSet(ls4_DLS6x)=="6100"} {
    set txt "${gaSet(wire)}w  \"$gaSet(ls4_DLS6x)\""
  } else {
    if {$gaSet(wire)==2} {
      set txt "2w  \"$gaSet(ls4_DLS6x)\" port : $gaSet(ls4_1)"
    } elseif {$gaSet(wire)==4} {
      set txt "4w  \"$gaSet(ls4_DLS6x)\" ports : $gaSet(ls4_1),$gaSet(ls4_2)"
    } elseif {$gaSet(wire)==8} {
      set txt "8w  \"$gaSet(ls4_DLS6x)\" ports : $gaSet(ls4_1),$gaSet(ls4_2),$gaSet(ls4_4),$gaSet(ls4_4)"
    } elseif {$gaSet(wire)=="???"} {
      set txt "???"
    }
  }
  #$gaGui(ls2) configure -text $txt
  if [info exists gaGui(cbWire)] {
    $gaGui(cbWire) configure  -helptext $txt
  }
  update
}
#***************************************************************************
#** GuiInventory
#***************************************************************************
proc GuiInventory {} {  
  global gaSet gaTmpSet gaGui
  
  if {![info exists gaSet(DutFullName)] || $gaSet(DutFullName)==""} {
    RLSound::Play failbeep    
    set txt "Define the UUT first"
    DialogBox -title "Wrong UUT" -message $txt -type OK -icon images/error
    focus -force $gaGui(entDUT)
    return -1
  }
  
  array unset gaTmpSet
  
  set parL [list plEn licEn uafEn udfEn udfEn uut wire hw sw bootVer bootMngr box ps eth e1 sfp udf uaf pl licDir]
  foreach par $parL {
    if ![info exists gaSet($par)] {set gaSet($par) ??}
    set gaTmpSet($par) $gaSet($par)
  }
  
#   don't change the hw according to page
#   if {[string match *HWRev* $gaSet(DutInitName)]} {
#     regexp {HWRev(\d+\.\d+)\.tcl} $gaSet(DutInitName) ma val
#     set gaTmpSet(hw) $val
#   }
  
  set base .topHwInit
  toplevel $base -class Toplevel
  wm focusmodel $base passive
  wm geometry $base $gaGui(xy)
  wm resizable $base 1 1 
  #wm title $base "Inventory of $gaSet(DutFullName) ([file rootname $gaSet(DutInitName)])"
  wm title $base "Inventory of [file rootname $gaSet(DutInitName)]"
  
  set inx 0
  set fr [frame $base.fr[incr inx] -bd 0 -relief groove]
    pack [Label $fr.labInterface  -text "Device" -width 15 -justify left] -pady 1 -padx 2 -anchor w -side left
    pack [ComboBox $fr.cbInterface -justify center -editable 0 -textvariable gaTmpSet(uut) -values $::glIntf] -pady 1 -padx 2 -anchor w -side left
  pack $fr -anchor w
  set fr [frame $base.fr[incr inx] -bd 0 -relief groove]
    pack [Label $fr.labWire  -text "Wire" -width 15] -pady 1 -padx 2 -anchor w -side left
    pack [ComboBox $fr.cbWire -justify center -editable 0 -textvariable gaTmpSet(wire) -values [list 2 4 8]] -pady 1 -padx 2 -anchor w -side left
  pack $fr  -anchor w
  set fr [frame $base.fr[incr inx] -bd 0 -relief groove]
    pack [Label $fr.labEth  -text "Eth" -width 15] -pady 1 -padx 2 -anchor w -side left
    pack [ComboBox $fr.cbEth -justify center -editable 0 -textvariable gaTmpSet(eth) -values [list 1 4 1NULL3UTP 2NULL2UTP ]] -pady 1 -padx 2 -anchor w -side left
  pack $fr  -anchor w
  set fr [frame $base.fr[incr inx] -bd 0 -relief groove]
    pack [Label $fr.labE1  -text "E1" -width 15] -pady 1 -padx 2 -anchor w -side left
    pack [ComboBox $fr.cbE1 -justify center -editable 0 -textvariable gaTmpSet(e1) -values [list NA 1 4]] -pady 1 -padx 2 -anchor w -side left
  pack $fr  -anchor w
  set fr [frame $base.fr[incr inx] -bd 0 -relief groove]
    pack [Label $fr.labPS  -text "PS" -width 15] -pady 1 -padx 2 -anchor w -side left
    pack [ComboBox $fr.cbPS -justify center -editable 0 -textvariable gaTmpSet(ps) -values [list WR PS24V 24VDC PS15NG]] -pady 1 -padx 2 -anchor w -side left
  pack $fr  -anchor w
  set fr [frame $base.fr[incr inx] -bd 0 -relief groove]
    pack [Label $fr.labBox  -text "Box" -width 15] -pady 1 -padx 2 -anchor w -side left
    pack [ComboBox $fr.cbBox -justify center -editable 0 -textvariable gaTmpSet(box) -values [list METAL PLASTIC MOUNT]] -pady 1 -padx 2 -anchor w -side left
  pack $fr  -anchor w
  
  set fr [frame $base.fr[incr inx] -bd 0 -relief groove]
    pack [Label $fr.labHW  -text "HW Rev" -width 15] -pady 1 -padx 2 -anchor w -side left
    pack [Entry $fr.cbHW -justify center -editable 1 -textvariable gaTmpSet(hw)] -pady 1 -padx 2 -anchor w -side left
    #pack [Button $fr.butHW  -text "Refresh" -command {RefreshHRev}] -pady 1 -padx 2 -anchor w -side left
  pack $fr  -anchor w 
  set fr [frame $base.fr[incr inx] -bd 0 -relief groove]
    pack [Label $fr.labSW  -text "SW Ver" -width 15] -pady 1 -padx 2 -anchor w -side left
    pack [Entry $fr.cbSW -justify center -editable 1 -textvariable gaTmpSet(sw)] -pady 1 -padx 2 -anchor w -side left
  pack $fr  -anchor w
  set fr [frame $base.fr[incr inx] -bd 0 -relief groove]
    pack [Label $fr.labBootVerr  -text "Boot Ver" -width 15] -pady 1 -padx 2 -anchor w -side left
    pack [Entry $fr.cbBootVer -justify center -editable 1 -textvariable gaTmpSet(bootVer)] -pady 1 -padx 2 -anchor w -side left
  pack $fr  -anchor w
  set fr [frame $base.fr[incr inx] -bd 0 -relief groove]
    pack [Label $fr.labBootMngr  -text "Boot Manager " -width 15] -pady 1 -padx 2 -anchor w -side left
    pack [Entry $fr.cbBootMngr -justify center -editable 1 -textvariable gaTmpSet(bootMngr)] -pady 1 -padx 2 -anchor w -side left
  pack $fr  -anchor w
   
#   set fr [frame $base.fr[incr inx] -bd 0 -relief groove]
#     pack [Label $fr.labHW  -text "FPGA" -width 15] -pady 1 -padx 2 -anchor w -side left
#     pack [Entry $fr.cbHW -justify center -editable 1 -textvariable gaTmpSet(fpga)] -pady 1 -padx 2 -anchor w -side left
#   pack $fr  -anchor w 
 
  
  pack [Separator $base.sep[incr inx] -orient horizontal] -fill x -padx 2 -pady 3
  
  set fr [frame $base.fr[incr inx] -bd 2 -relief groove]
    pack [checkbutton $fr.chbUaf  -variable gaTmpSet(plEn)] -pady 1 -padx 3 -anchor w  -side left
    pack [Button $fr.brwUaf -text "Browse Preload Application File..." -command "BrowsePL" -width 30] -side left -pady 1 -padx 3 -anchor w
    pack [Button $fr.cl  -image [image create photo -file images/clear1.ico] -command [list ClearInvLabel pl]]  -side left -pady 1 -padx 3 -anchor w    
    pack [Label $fr.labUaf  -textvariable gaTmpSet(pl)] -pady 1 -padx 3 -anchor w
   pack $fr  -fill x 
  
  set fr [frame $base.fr[incr inx] -bd 2 -relief groove]
    pack [checkbutton $fr.chbUaf  -variable gaTmpSet(uafEn)] -pady 1 -padx 3 -anchor w  -side left
    pack [Button $fr.brwUaf -text "Browse User Application File..." -command "BrowseUaf" -width 30] -side left -pady 1 -padx 3 -anchor w
    pack [Button $fr.cl  -image [image create photo -file images/clear1.ico] -command [list ClearInvLabel uaf]]  -side left -pady 1 -padx 3 -anchor w
    pack [Label $fr.labUaf  -textvariable gaTmpSet(uaf)] -pady 1 -padx 3 -anchor w
  pack $fr  -fill x   
  
  set fr [frame $base.fr[incr inx] -bd 2 -relief groove]
    pack [checkbutton $fr.chbLic  -variable gaTmpSet(licEn)] -pady 1 -padx 3 -anchor w  -side left
    pack [Button $fr.brwLic -text "Choose LIC File location..." -command "BrowseLic" -width 30] -side left -pady 1 -padx 3 -anchor w
    pack [Button $fr.cl  -image [image create photo -file images/clear1.ico] -command [list ClearInvLabel licDir]]  -side left -pady 1 -padx 3 -anchor w
    pack [Label $fr.labUdf  -textvariable gaTmpSet(licDir)] -pady 1 -padx 3 -anchor w  
  pack $fr -fill x
  
  set fr [frame $base.fr[incr inx] -bd 2 -relief groove]
    pack [checkbutton $fr.chbUdf  -variable gaTmpSet(udfEn)] -pady 1 -padx 3 -anchor w  -side left
    pack [Button $fr.brwUdf -text "Browse User Define File..." -command "BrowseUdf" -width 30] -side left -pady 1 -padx 3 -anchor w
    pack [Button $fr.cl  -image [image create photo -file images/clear1.ico] -command [list ClearInvLabel udf]]  -side left -pady 1 -padx 3 -anchor w          
    pack [Label $fr.labUdf  -textvariable gaTmpSet(udf)] -pady 1 -padx 3 -anchor w  
  pack $fr -fill x
  
  #pack [Separator $base.sep3 -orient horizontal] -fill x -padx 2 -pady 3
  
  pack [frame $base.frBut ] -pady 4 -anchor e
    pack [Button $base.frBut.butImp -text Import -command ButImportInventory -width 7] -side right -padx 6
    pack [Button $base.frBut.butCanc -text Cancel -command ButCancInventory -width 7] -side right -padx 6
    pack [Button $base.frBut.butOk -text Ok -command ButOkInventory -width 7]  -side right -padx 6
  
  focus -force $base
  grab $base
  return {}  
}
# ***************************************************************************
# BrowseUdf
# ***************************************************************************
proc BrowseUdf {} {
  global gaTmpSet
  set fil [tk_getOpenFile -title "Choose user configuration file for upload" -initialdir "c:\\Download"]
  if {$fil!=""} {
    set gaTmpSet(udf) $fil
  }
  focus -force .topHwInit
}
# ***************************************************************************
# BrowseUaf
# ***************************************************************************
proc BrowseUaf {} {
  global gaTmpSet
  set fil [tk_getOpenFile -title "Choose application file for upload" -initialdir "c:\\Download"]
  if {$fil!=""} {
    set gaTmpSet(uaf) $fil
  }
  focus -force .topHwInit
}
# ***************************************************************************
# BrowsePL
# ***************************************************************************
proc BrowsePL {} {
  global gaTmpSet
  set fil [tk_getOpenFile -title "Choose application file for preload" -initialdir "c:\\Download"]
  if {$fil!=""} {
    set gaTmpSet(pl) $fil
  }
  focus -force .topHwInit
}
# ***************************************************************************
# BrowseLic
# ***************************************************************************
proc BrowseLic {} {
  global gaTmpSet
  set fil [tk_chooseDirectory -title "Choose Licence file location" -initialdir "c:\\Download"]
  if {$fil!=""} {
    set gaTmpSet(licDir) $fil
  }
  focus -force .topHwInit
}
# ***************************************************************************
# ButImportInventory
# ***************************************************************************
proc ButImportInventory {} {
  global gaSet gaTmpSet
  set fil [tk_getOpenFile -initialdir [pwd]/uutInits  -filetypes {{{TCL Scripts} {.tcl}}} -defaultextension tcl ]
  if {$fil!=""} {  
    set gaTmpSet(DutFullName) $gaSet(DutFullName)
    set gaTmpSet(DutInitName) $gaSet(DutInitName)
    set parL [lsort [list plEn licEn uafEn udfEn udfEn uut wire hw sw bootVer bootMngr box ps eth e1 sfp udf uaf pl licDir]]
    foreach par $parL {
      puts "$par:<$gaSet($par)>"
    }
    puts ""
    update
    source $fil
    foreach par $parL {
      puts "$par:<$gaSet($par)>"
    }
    puts ""
    update
    foreach par $parL {
      set gaTmpSet($par) $gaSet($par)
    }
    set gaSet(DutFullName) $gaTmpSet(DutFullName)
    set gaSet(DutInitName) $gaTmpSet(DutInitName)    
  } 
  
  focus -force .topHwInit   
}
#***************************************************************************
#** ButOk
#***************************************************************************
proc ButOkInventory {} {
  global gaSet gaTmpSet
  
  set saveInitFile 0
  foreach nam [array names gaTmpSet] {
    if {$gaTmpSet($nam)!=$gaSet($nam)} {
      puts "ButOkInventory1 $nam tmp:$gaTmpSet($nam) set:$gaSet($nam)"
      #set gaSet($nam) $gaTmpSet($nam)      
      set saveInitFile 1 
      break
    }  
  }
  
  if {$saveInitFile=="1"} {
    set res Save
    if {[file exists uutInits/$gaSet(DutInitName)]} {
      set txt "Init file for \'$gaSet(DutFullName)\' exists.\n\nAre you sure you want overwright the file?"
      set res [DialogBox -title "Save init file" -message  $txt -icon images/question \
          -type [list Save "Save As" Cancel] -default 2]
      if {$res=="Cancel"} {array unset gaTmpSet ; return -1}
    }
    if ![file exists uutInits] {
      file mkdir uutInits
    }
    if {$res=="Save"} {
      #SaveUutInit uutInits/$gaSet(DutInitName)
      set fil "uutInits/$gaSet(DutInitName)"
    } elseif {$res=="Save As"} {
      set fil [tk_getSaveFile -initialdir [pwd]/uutInits  -filetypes {{{TCL Scripts} {.tcl}}} -defaultextension tcl ]
      if {$fil!=""} {        
        set fil1 [file tail [file rootname $fil]]
        puts fil1:$fil1
        set gaSet(DutInitName) $fil1.tcl
        set gaSet(DutFullName) $fil1
        #set gaSet(entDUT) $fil1
        wm title . "$gaSet(pair) : $gaSet(DutFullName)"
        #SaveUutInit $fil
        update
      }
    } 
    puts "ButOkInventory fil:<$fil>"
    if {$fil!=""} {
      foreach nam [array names gaTmpSet] {
        if {$gaTmpSet($nam)!=$gaSet($nam)} {
          puts "ButOkInventory2 $nam tmp:$gaTmpSet($nam) set:$gaSet($nam)"
          set gaSet($nam) $gaTmpSet($nam)      
        }  
      }
      SaveUutInit $fil
    } 
  }
  array unset gaTmpSet
  SaveInit
  BuildTests
  ButCancInventory
}


#***************************************************************************
#** ButCancInventory
#***************************************************************************
proc ButCancInventory {} {
  grab release .topHwInit
  focus .
  destroy .topHwInit
}


#***************************************************************************
#** Quit
#***************************************************************************
proc Quit {} {
  global gaSet
  SaveInit
  RLSound::Play beep
  set ret [DialogBox -title "Confirm exit"\
      -type "yes no" -icon images/question -aspect 2000\
      -text "Are you sure you want to close the application?"]
  if {$ret=="yes"} {CloseRL; IPRelay-Green; exit}
}

#***************************************************************************
#** CaptureConsole
#***************************************************************************
proc CaptureConsole {} {
  console eval { 
    set ti [clock format [clock seconds] -format  "%Y.%m.%d_%H.%M"]
    set fi c:\\tmpDir\\ConsoleCapt_[set ti].txt
    if [file exists $fi] {
      set res [tk_messageBox -title "Save Console Content" \
        -icon info -type yesno \
        -message "File $fi already exist.\n\
               Do you want overwrite it?"]      
      if {$res=="no"} {
         set types { {{Text Files} {.txt}} }
         set new [tk_getSaveFile -defaultextension txt \
                 -initialdir c:\\tmpDir\\ -initialfile [file rootname $fi]  \
                 -filetypes $types]
         if {$new==""} {return {}}
      }
    }
    set aa [.console get 1.0 end]
    set id [open $fi w]
    puts $id $aa
    close $id
  }
}
#***************************************************************************
#** PairPerfLab
#***************************************************************************
proc PairPerfLab {lab bg} {
  global gaGui gaSet
  $gaGui(labPairPerf$lab) configure -bg $bg
}

# ***************************************************************************
# AllPairPerfLab
# ***************************************************************************
proc AllPairPerfLab {bg} {
  global gaSet
  for {set i 1} {$i <= $gaSet(maxMultiQty)} {incr i} {
    PairPerfLab $i $bg
  }
}
# ***************************************************************************
# TogglePairBut
# ***************************************************************************
proc TogglePairBut {pair} {
  global gaGui gaSet
  set _toTestClr $gaSet(toTestClr)
  set _toNotTestClr $gaSet(toNotTestClr)
  set bg  [$gaGui(labPairPerf$pair) cget -bg]
  set _bg $bg
  #puts "pair:$pair bg1:$bg"
  if {$bg=="gray" || $bg==$_toNotTestClr} {
    ## initial state, for change to _toTest change it to blue
    set _bg $_toTestClr
  } elseif {$bg==$_toTestClr || $bg=="green" || $bg=="red" || \
      $bg==$gaSet(halfPassClr) || $bg=="yellow" || $bg=="#ddffdd"} {
    ## for under Test, pass or fail - for change to _toNoTest change it to gray
    set _bg $_toNotTestClr
    IPRelay-Green
  } 
  $gaGui(labPairPerf$pair) configure -bg $_bg
}
# ***************************************************************************
# TogglePairButAll
# ***************************************************************************
proc TogglePairButAll {mode} {
  global gaGui   gaSet
  set _toNotTestClr $gaSet(toNotTestClr)
  set _toTestClr $gaSet(toTestClr)
  if {$mode=="0"} {
    set _bg $_toNotTestClr
  } elseif {$mode=="All"} {
    set _bg $_toTestClr
  }
  for {set pair 1} {$pair <= $gaSet(maxMultiQty)} {incr pair} {
    $gaGui(labPairPerf$pair) configure -bg $_bg
  }
}
# ***************************************************************************
# PairsToTest
# ***************************************************************************
proc PairsToTest {} {
  global gaGui gaSet
  set _toTestClr $gaSet(toTestClr)
  set l [list]
  for {set i 1} {$i <= $gaSet(maxMultiQty)} {incr i} {
    set bg  [$gaGui(labPairPerf$i) cget -bg]
    if {$bg==$_toTestClr || $bg=="red" || $bg=="green"} {
      lappend l $i
    }
  }
  return $l
}

# ***************************************************************************
# CheckPairsToTest
# ***************************************************************************
proc CheckPairsToTest {} {
  global gaGui gaSet
  set l [list]
  for {set i 1} {$i <= $gaSet(maxMultiQty)} {incr i} {
    set bg  [$gaGui(labPairPerf$i) cget -bg]
    if {$bg!=$gaSet(toNotTestClr)} {
      lappend l $i
    }
  }
  return $l
}

# ***************************************************************************
# UpdStatBarShortTest
# ***************************************************************************
proc UpdStatBarShortTest {} {
  global gaSet
  
  if {$gaSet(performShortTest)==1} {
    set txt " SHORT TEST! " 
    set bg red
    set fg SystemButtonText  
  } else {
    set txt ""
    set bg SystemButtonFace
    set fg SystemButtonText
  }
  $gaSet(statBarShortTest) configure -text $txt -bg $bg -fg $fg
}




# ***************************************************************************
# ShowComs
# ***************************************************************************
proc ShowComs {} {                                                                        
  global gaSet gaGui
  DialogBox -title "COMs definitions" -type OK \
    -message "Uut1: COM $gaSet(comUut1), Uut2: COM $gaSet(comUut2)\n
ETX1: COM $gaSet(comGen1), ETX2: COM $gaSet(comGen2)\n
DXC1: COM $gaSet(comDxc1), DXC2: COM $gaSet(comDxc2)\n
DLS: COM $gaSet(comDls1)"
  return {}
}

# ***************************************************************************
# GuiReleaseDebugMode
# ***************************************************************************
proc GuiReleaseDebugMode {} {
  global gaSet gaGui gaTmpSet glTests 
  
  set base .topReleaseDebugMode
  if [winfo exists $base] {
    wm deiconify $base
    return {}
  }
    
  toplevel $base -class Toplevel
  wm focusmodel $base passive
  wm geometry $base $gaGui(xy)
  wm resizable $base 1 1 
  wm title $base "Release/Debug Mode"
  
   array unset gaTmpSet
   
  if ![info exists gaSet(relDebMode)] {
    set gaSet(relDebMode) Release  
  }
  foreach par {relDebMode} {
    set gaTmpSet($par) $gaSet($par) 
  }
    
  set fr1 [ttk::frame $base.fr1 -relief groove]
    set fr11 [ttk::frame $fr1.fr11]
      set gaGui(rbRelMode) [ttk::radiobutton $fr11.rbRelMode -text "Release Mode" -variable gaTmpSet(relDebMode) -value Release -command ToggleRelDeb]
      set gaGui(rbDebMode) [ttk::radiobutton $fr11.rbDebMode -text "Debug Mode" -variable gaTmpSet(relDebMode) -value Debug -command ToggleRelDeb]
      pack $gaGui(rbRelMode) $gaGui(rbDebMode) -anchor nw
      
    set fr12 [ttk::frame $fr1.fr12]
      set fr121 [ttk::frame $fr12.fr121]
        set l2 [ttk::label $fr121.l2 -text "Available Tests"]
        pack $l2 -anchor w
        scrollbar $fr121.yscroll -command {$gaGui(lbAllTests) yview} -orient vertical
        pack $fr121.yscroll -side right -fill y
        set gaGui(lbAllTests) [ListBox $fr121.lb1  -selectmode multiple \
            -yscrollcommand "$fr121.yscroll set" -height 25 -width 33 \
            -dragenabled 1 -dragevent 1 -dropenabled 1 -dropcmd DropRemTest]
        pack $gaGui(lbAllTests) -side left -fill both -expand 1
        
      set fr122 [frame $fr12.fr122 -bd 0 -relief groove]
        grid [button $fr122.b0 -text ""   -command {} -state disabled -relief flat] -sticky ew
        $fr122.b0 configure -background [ttk::style lookup . -background disabled]
        grid [set gaGui(addOne) [ttk::button $fr122.b3 -text ">"  -command {AddTest sel}]] -sticky ew
        grid [set gaGui(addAll) [ttk::button $fr122.b4 -text ">>" -command {AddTest all}]] -sticky ew
        grid [set gaGui(remOne) [ttk::button $fr122.b5 -text "<"  -command {RemTest sel}]] -sticky ew
        grid [set gaGui(remAll) [ttk::button $fr122.b6 -text "<<" -command {RemTest all}]] -sticky ew
            
      set fr123 [frame $fr12.fr123 -bd 0 -relief groove]  
        set l3 [Label $fr123.l3 -text "Tests to run"]
        pack $l3 -anchor w  
        scrollbar $fr123.yscroll -command {$gaGui(lbTests) yview} -orient vertical  
        pack $fr123.yscroll -side right -fill y
        set gaGui(lbTests) [ListBox $fr123.lb2  -selectmode multiple \
            -yscrollcommand "$fr123.yscroll set" -height 25 -width 33 \
            -dragenabled 1 -dragevent 1 -dropenabled 1 -dropcmd DropAddTest] 
        pack $gaGui(lbTests) -side left -fill both -expand 1  
      
      grid $fr121 $fr122 $fr123 -sticky news  
          
    pack $fr11 -side left -padx 14 -anchor n -pady 2
    pack $fr12 -side left -padx 2 -anchor n -pady 2
  pack $fr1  -padx 2 -pady 2
  pack [ttk::frame $base.frBut] -pady 4 -anchor e    -padx 2 
    #pack [Button $base.frBut.butImp -text Import -command ButImportInventory -width 7] -side right -padx 6
    pack [ttk::button $base.frBut.butCanc -text Cancel -command ButCancReleaseDebugMode -width 7] -side right -padx 6
    pack [ttk::button $base.frBut.butOk -text Ok -command ButOkReleaseDebugMode -width 7]  -side right -padx 6
  
  #BuildTests
  ToggleTestMode
  foreach te $glTests {
    $gaGui(lbAllTests) insert end $te -text $te
  }
  
  ToggleRelDeb
  
  focus -force $base
  grab $base
  return {}  
}
# ***************************************************************************
# ButCancReleaseDebugMode
# ***************************************************************************
proc ButCancReleaseDebugMode {} {
  grab release .topReleaseDebugMode
  focus .
  destroy .topReleaseDebugMode
}
# ***************************************************************************
# ButOkReleaseDebugMode
# ***************************************************************************
proc ButOkReleaseDebugMode {} {
  global gaGui gaSet gaTmpSet glTests
  
  if {[llength [$gaGui(lbTests) items]]==0} {
    return 0
  }
  
  set gaSet(relDebMode) $gaTmpSet(relDebMode) 
  
  set glTests [$gaGui(lbTests) items]
  set gaSet(startFrom) [lindex $glTests 0]
  
  $gaGui(startFrom) configure -values $glTests
  if {$gaSet(relDebMode)=="Debug"} {
    set gaSet(debugTests) $glTests
  }
  
  if {[llength [$gaGui(lbAllTests) items]] != [llength [$gaGui(lbTests) items]]} {
    Status "Debug Mode" red
  }
  array unset gaTmpSet
  #SaveInit
  #BuildTests
  ButCancReleaseDebugMode
}  
# ***************************************************************************
# AddTest
# ***************************************************************************
proc AddTest {mode} {
   global gaSet gaGui
   if {$mode=="sel"} {
     set ftL [$gaGui(lbAllTests) selection get]
   } elseif {$mode=="all"} {
     set ftL [$gaGui(lbAllTests) items]
   }
   foreach ft $ftL {
     if {[lsearch [$gaGui(lbTests) items] $ft]=="-1"} {
       $gaGui(lbTests) insert end $ft -text $ft
     }
   }
   $gaGui(lbAllTests) selection clear
   $gaGui(lbTests) reorder [lsort -dict [$gaGui(lbTests) items]]
}
# ***************************************************************************
# RemTest
# ***************************************************************************
proc RemTest {mode} {
   global gaSet gaGui
   if {$mode=="sel"} {
     set ftL [$gaGui(lbTests) selection get]
   } elseif {$mode=="all"} {
     set ftL [$gaGui(lbTests) items]
     eval $gaGui(lbTests) selection set $ftL
#      RLSound::Play beep
#      set res [DialogBox -title "Remove all tests" -type [list Cancel Yes] \
#        -text "Are you sure you want to remove ALL the tests?" -icon images/info]
#      if {$res=="Cancel"} {
#        $gaGui(lbTests) selection clear
#        return {}
#      }
   }
   foreach ft $ftL {
     $gaGui(lbTests) delete $ftL
   }
}
# ***************************************************************************
# DropAddTest
# ***************************************************************************
proc DropAddTest {listbox dragsource itemList operation datatype data} {
  puts [list $listbox $dragsource $itemList $operation $datatype $data]
  global gaSet gaGui
  if {$dragsource=="$gaGui(lbAllTests).c"} {
    set ft $data
    if {[lsearch [$gaGui(lbTests) items] $ft]=="-1"} {
      $gaGui(lbTests) insert end $ft -text $ft
    }
    $gaGui(lbTests) reorder [lsort -dict [$gaGui(lbTests) items]]
  } elseif {$dragsource=="$gaGui(lbTests).c"} {
    set destIndx [$gaGui(lbTests) index [lindex $itemList 1]]
    $gaGui(lbTests) move $data $destIndx
    $gaGui(lbTests) selection clear
    
  }
}
# ***************************************************************************
# DropRemTest
# ***************************************************************************
proc DropRemTest {listbox dragsource itemList operation datatype data} {
  puts [list $listbox $dragsource $itemList $operation $datatype $data]
  global gaSet gaGui gaTmpSet
  if {$gaTmpSet(relDebMode)=="Debug"} {
    if {$dragsource=="$gaGui(lbTests).c"} {
      set ft $data
      $gaGui(lbTests) delete $ft
    }
  }
}
# ***************************************************************************
# ToggleRelDeb
# ***************************************************************************
proc ToggleRelDeb {} {
  global gaGui gaTmpSet
  if {$gaTmpSet(relDebMode)=="Release"} {
    puts "ToggleRelDeb Release"
    #BuildTests
    after 100
    AddTest all
    set state disabled
  } elseif {$gaTmpSet(relDebMode)=="Debug"} {
    puts "ToggleRelDeb Debug"
    RemTest all
    after 100 ; update
    set state normal
    if {[info exists gaSet(debugTests)] && [llength $gaSet(debugTests)]>0} {
      foreach ft $gaSet(debugTests) {
        if {[lsearch [$gaGui(lbTests) items] $ft]=="-1"} {
          $gaGui(lbTests) insert end $ft -text $ft
        }
      }
    }
  }
  foreach b [list $gaGui(addOne) $gaGui(addAll) $gaGui(remOne) $gaGui(remAll)] {
    $b configure -state $state
  }
}
# ***************************************************************************
# RefreshHRev
# ***************************************************************************
proc RefreshHRev {} {
  global gaSet gaGui
}
# ***************************************************************************
# ToggleScanTraceBarcode
# ***************************************************************************
proc ToggleScanTraceBarcode {} {
  global gaSet gaGui 
  if {$gaSet(readTrace)==1} {
    set state normal  
  } else {
    set state disabled
  }
  $gaGui(entTrace) configure -state $state
} 
# ***************************************************************************
# CmdEntID
# ***************************************************************************
proc CmdEntID {} {
  global gaSet gaGui
#   if {$gaSet(entDUT)!=""} {
#     if {$gaSet(readTrace)==0} {
#       GetDbrName
#     } elseif {$gaSet(readTrace)==1} { 
#       if {$gaSet(entTrace)==""} {
#         focus -force $gaGui(entTrace)
#       } elseif {$gaSet(entTrace)!=""} {
#         GetDbrName
#       } 
#     }
#   }
  GetDbrName
  RetriveDutFam
  if {$gaSet(dutFam)=="L"} {
    if {$gaSet(readTrace)==1} {
      Status "Scan the Traceability number"
      focus -force $gaGui(entTrace)
    } else {
      GetHWrevFromPage
      focus -force $gaGui(tbrun)
    } 
  } else {
    set gaSet(readTrace) 0
    ToggleScanTraceBarcode
    set gaSet(entDUT) ""
    SourceInitFile
    focus -force $gaGui(tbrun)
  }
}
# ***************************************************************************
# CmdEntTrace
# ***************************************************************************
proc CmdEntTrace {} {
  global gaSet gaGui
#   if {$gaSet(entDUT)!=""} {
#     if {$gaSet(readTrace)==0} {
#       GetDbrName
#     } elseif {$gaSet(readTrace)==1} { 
#       if {$gaSet(entTrace)==""} {
#         focus -force $gaGui(entDUT)
#       } elseif {$gaSet(entTrace)!=""} {
#         GetDbrName
#       } 
#     }
#   }
  GetHWrevFromPage 
  focus -force $gaGui(tbrun)
}
# ***************************************************************************
# ClearInvLabel
# ***************************************************************************
proc ClearInvLabel {f} {
  global gaSet gaGui  gaTmpSet
  set gaTmpSet($f) ""
}

# ***************************************************************************
# ID_Trace
# ***************************************************************************
proc ID_Trace {} {
  global gaSet gaGui
  if {[info exist gaSet(DutID)] && [info exist gaSet(TraceID)] } {
    set gaSet(entDUT) $gaSet(DutID)
    set gaSet(entTrace) $gaSet(TraceID)
    
    GetDbrName
    if {$gaSet(dutFam)=="L"} {
      GetHWrevFromPage
    }
  }
}
# ***************************************************************************
# GuiReadOperator
# ***************************************************************************
proc GuiReadOperator {} {
  global gaSet gaGui gaDBox gaGetOpDBox
  catch {array unset gaDBox} 
  catch {array unset gaGetOpDBox} 
  #set ret [GetOperator -i pause.gif -ti "title Get Operator" -te "text Operator's Name "]
  set sn [clock seconds]
  set ret [GetOperator -i images/oper32.ico -gn $::RadAppsPath]
  incr ::wastedSecs [expr {[clock seconds]-$sn}]
  if {$ret=="-1"} {
    set gaSet(fail) "No Operator Name"
    return $ret
  } else {
    set gaSet(operator) $ret
    return 0
  }
}   
