wm iconify . ; update

## delete barcode files TO3001483079.txt
foreach fi [glob -nocomplain -type f *.txt] {
  if [regexp {\w{2}\d{9,}} $fi] {
    file delete -force $fi
  }
}
if [file exists c:/TEMP_FOLDER] {
  file delete -force c:/TEMP_FOLDER 
}
after 1000
set ::RadAppsPath c:/RadApps

if 1 {
  set gaSet(radNet) 0
  foreach {jj ip} [regexp -all -inline {v4 Address[\.\s\:]+([\d\.]+)} [exec ipconfig]] {
    if {[string match {*192.115.243.*} $ip] || [string match {*172.18.*} $ip]} {
      set gaSet(radNet) 1
    }  
  }
  if {$gaSet(radNet)} {
    set mTimeTds [file mtime //prod-svm1/tds/install/ateinstall/jate_team/autosyncapp/rlautosync.tcl]
    set mTimeRL  [file mtime c:/tcl/lib/rl/rlautosync.tcl]
    puts "mTimeTds:$mTimeTds mTimeRL:$mTimeRL"
    if {$mTimeTds>$mTimeRL} {
      puts "$mTimeTds>$mTimeRL"
      file copy -force //prod-svm1/tds/install/ateinstall/jate_team/autosyncapp/rlautosync.tcl c:/tcl/lib/rl
      after 2000
    }
    set mTimeTds [file mtime //prod-svm1/tds/install/ateinstall/jate_team/autoupdate/rlautoupdate.tcl]
    set mTimeRL  [file mtime c:/tcl/lib/rl/rlautoupdate.tcl]
    puts "mTimeTds:$mTimeTds mTimeRL:$mTimeRL"
    if {$mTimeTds>$mTimeRL} {
      puts "$mTimeTds>$mTimeRL"
      file copy -force //prod-svm1/tds/install/ateinstall/jate_team/autoupdate/rlautoupdate.tcl c:/tcl/lib/rl
      after 2000
    }
    update
  }
  
  package require RLAutoSync
  
  #set s1 [file normalize //prod-svm1/tds/Temp/ilya/shared/ETX-2i/AT-ETX-2i/AT-ETX-2i_v1]
  set s1 [file normalize //prod-svm1/tds/AT-Testers/JER_AT/ilya/TCL/ASMi-54/AT-ASMi54/ASMi54]
  set d1 [file normalize  C:/ASMi54]
  set s2 [file normalize //prod-svm1/tds/AT-Testers/JER_AT/ilya/TCL/ASMi-54/AT-ASMi54/download]
  set d2 [file normalize  C:/download]
  
  if {$gaSet(radNet)} {
    set emailL {{meir_ka@rad.com} {} {}}
  } else {
    set emailL [list]
  }
  
  set ret [RLAutoSync::AutoSync "$s1 $d1 $s2 $d2" -noCheckFiles {init*.tcl *.db} -noCheckDirs {tmpFiles temp} \
      -jarLocation $::RadAppsPath -javaLocation $gaSet(javaLocation) -emailL $emailL -putsCmd 1 -radNet $gaSet(radNet)]
  #console show
  puts "ret:<$ret>"
  set gsm $gMessage
  foreach gmess $gMessage {
    puts "$gmess"
  }
  update
  if {$ret=="-1"} {
    set res [tk_messageBox -icon error -type yesno -title "AutoSync"\
    -message "The AutoSync process did not perform successfully.\n\n\
    Do you want to continue? "]
    if {$res=="no"} {
      exit
    }
  }
  
  if {$gaSet(radNet)} {
    package require RLAutoUpdate
    set s2 [file normalize W:/winprog/ATE]
    set d2 [file normalize $::RadAppsPath]
    set ret [RLAutoUpdate::AutoUpdate "$s2 $d2" \
        -noCopyGlobL {Get_Li* Macreg.2* Macreg-i* DP* *.prd}]
    #console show
    puts "ret:<$ret>"
    set gsm $gMessage
    foreach gmess $gMessage {
      puts "$gmess"
    }
    update
    if {$ret=="-1"} {
      set res [tk_messageBox -icon error -type yesno -title "AutoSync"\
      -message "The AutoSync process did not perform successfully.\n\n\
      Do you want to continue? "]
      if {$res=="no"} {
        #SQliteClose
        exit
      }
    }
  }
}

package require BWidget
package require img::ico
package require tile
package require RLSerial; #RLCom
package require RLEH
package require RLTime
package require RLStatus
package require RLExMmux
#package require RLGen2002
package require RLEtxGen
package require RLDxc4
package require ezsmtp
package require http
package require RLSound
package require RLCom
## the package will be requireed inside the MemoryPerf ##package require RLScotty
RLSound::Open [list failbeep fail.wav passbeep pass.wav beep warning.wav]
package require twapi
package require sqlite3
package require RLAutoUpdate

package require registry
set gaSet(hostDescription) [registry get "HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Services\\LanmanServer\\Parameters" srvcomment ]


source Gui_ASMi54.tcl
source Main_ASMi54.tcl
source Lib_Put_ASMi54.tcl ; ## this file contains all produts' procs
## source of a specific lib performed from Main_ASMi54.tcl, proc BuildTests
source Lib_Gen_ASMi54.tcl
source [info host]/init$gaSet(pair).tcl
source Lib_Dls.tcl
source lib_bc.tcl
source Lib_DialogBox.tcl
source Lib_Dxc4.tcl
source Lib_FindConsole.tcl
source LibEmail.tcl
source LibIPRelay.tcl
source LibYmodem.tcl
source Lib_Ds280e01_ASMi54.tcl
source Lib_Etx204.tcl
source lib_SQlite.tcl
if [file exists uutInits/$gaSet(DutInitName)] {
  source uutInits/$gaSet(DutInitName)
} else {
  source [lindex [glob uutInits/ASMi-54*.tcl] 0]
}
source LibUrl.tcl
source Lib_GetOperator.tcl

set gaSet(maxMultiQty) 11
set gaSet(act) 1
set gaSet(initUut) 1
set gaSet(oneTest)    0
set gaSet(puts) 1
set gaSet(perfSet) 1

set gaSet(resetTime) 50
set gaSet(bertRunTime) 30
set gaSet(syncCycles) 50

set gaSet(toTestClr)    #aad5ff
set gaSet(toNotTestClr) SystemButtonFace
set gaSet(halfPassClr)  #a8f4ad

set gaSet(useExistBarcode) 0
set gaSet(nextPair) begin
set gaSet(rerunTesterMulti) conf

set gaSet(readMacUploadAppl) 1
set gaSet(saveScript) 0

set gaSet(TestMode) long
set gaSet(relDebMode) Release

if {(![info exists gaSet(performShortTest)]) || ($gaSet(performShortTest)=="")} {
  set gaSet(performShortTest) 0
}
set gaSet(pageType) System
set gaSet(localPageFile) ""

set ::glIntf [list "Asmi 54N" "ASMi-54" "ASMi-54L" "ASMi-54LRT"]

GUI      
BuildTests
ToggleScanTraceBarcode
ID_Trace
UpdStatBarShortTest
update

ToolsMassConnect 1
##DialogBox -text "Enable ToolsMassConnect 1"
after 50

wm deiconify .
wm geometry . $gaGui(xy)
update

Status "Ready"
#set ret [SQliteOpen]