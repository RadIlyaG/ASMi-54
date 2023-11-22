
#============================================================================
#  Installation:
#   Need to install the following Aplication "Procom" Terminal before use.
#   1. package require twapi ;# 1.0
#   2. Manual Procom Terminal setup:
#	     File>Connection Directory>New Entry>Data:
#	     - Name: tst1 
#	     - OTHER INFO:  VT-100 , Ymodem , Com 4 , 115200, N-8-1  
#      
#===========================================================================


proc CreateYmodemFile {file logFile uut} {
  # ***************************************************************************
  #  CreateYmodemFile   
  # ***************************************************************************    
#   set file "C:\\download\\$file"
puts fffffffff=$file
  set fileId [open "C:\\Program\ Files\\Symantec\\Procomm\ Plus\\Aspect\\Ymodem[set uut].WAS" w]
  puts $fileId "proc main"
  puts $fileId " integer iStatus"
  puts $fileId " transmit \"^M\""
  puts $fileId " Waitfor \"Prompt\" 4"
  puts $fileId " transmit \"dl x^M\""
  puts $fileId " Waitfor \"at 115200 bps...\" 10"
  puts $fileId " pause 2"
  puts $fileId " sendfile YMODEM \"$file\""
  puts $fileId " iStatus = \$XFERSTATUS"
  puts $fileId " while iStatus"
  puts $fileId "    yield"
  puts $fileId "    iStatus = \$XFERSTATUS"  
  puts $fileId " endwhile"
  puts $fileId " Waitfor \"Boot Prompt\" 60"
  puts $fileId " pause 3"  
  puts $fileId " snapshot FILE \"$logFile\""  
  puts $fileId " pwexit"  
  puts $fileId "endproc"    
  close $fileId   
  return 0
}


# ***************************************************************************
# DownloadYmodemFile
# DownloadYmodemFile Uut1 C:\\download\\asmi53_1.4.0_0.7_.bin
# DownloadYmodemFile Uut2 C:\\download\\asmi53_1.4.0_0.7_.bin
# DownloadYmodemFile  $gaSet(pl)

# ***************************************************************************
proc DownloadYmodemFile {file {cycles 90}} {
  global gaSet
  regsub -all {/} $file {\\} fil
  
  ## logFile and ymodem script
  foreach uut {Uut1 Uut2} {
    puts "[MyTime] DownloadYmodemFile $uut $fil $cycles"
    set logFile c:\\download\\YmodemLog$uut.txt
    set lf$uut $logFile
  
    # Create file: Ymodem.ssr
    set ret [CreateYmodemFile $fil $logFile $uut]
    if {$ret!=0} {return $ret}
  
    # Del Log:  
    if {[file exist $logFile]==1} {
      file delete -force $logFile
    }
  } 
  
  ## format flash and start loading 
  foreach uut {Uut1 Uut2} {
    set ret [FormatFlash $uut]
    set gaSet(fail) "Format flash of $uut fail"
    if {$ret!=0} {return $ret}
    RLCom::Close $gaSet(com$uut)
    after 200

    # Download:
    puts "[MyTime] start loading"; update
    set id$uut [lindex [twapi::create_process {} \
        -cmdline "C:\\Program\ Files\\Symantec\\Procomm\ Plus\\PROGRAMS\\pw5.exe CONNECT $uut Ymodem[set uut].WAS" &] 0]
    puts "[MyTime] finish loading"; update
  }

  set i 0
  while {$i<$cycles} {
    incr i 
    if {[file exist $lfUut1] && [file exist $lfUut2]} {
      puts "[MyTime] Both logs exist"; update
      break
    }
    
    ## if there is not pw5 in tasklist, break the while loop
    catch {exec tasklist.exe} task_list
    if {[regexp {pw5.exe} $task_list]==0} {
      puts "[MyTime] task list does not contain pw5" ; update
      break
    }
    
    Wait "Wait for download (passed [expr {$i * 10}] sec)." 10
  }
  catch {twapi::end_process $idUut1 -force}
  catch {twapi::end_process $idUut2 -force}
  
  Wait "$uut. Wait for close PW5" 3 
  if {$i==$cycles} {
      set gaSet(fail) "Ymodem Download fail: Download proccess took too much time: [expr $i * 10] sec"
      return -1
  }
  
  # Get Result:
  foreach uut {Uut1 Uut2} {
    set id [open [set lf$uut] r+]
    set buffer [read $id]
    close $id
  
    puts "[MyTime] [set lf$uut] : \n$buffer"
  
    set str "Verifying checksum ... OK"
  
    if {[string match -nocase "*$str*" $buffer]==0} {
      set gaSet(fail) "Ymodem Download of $uut fail !"
      return -1
    }
    puts "[MyTime] Ymodem Download of $uut pass"
    RLCom::Open $gaSet(com$uut) 115200 8 NONE 1    
    set ret [Send $gaSet(com$uut) "\r" "Boot Prompt"]
    if {$ret!=0} {
      Wait "Wait for finishing" 10
      set ret [Send $gaSet(com$uut) "\r" "Boot Prompt"]
      if {$ret!=0} {
        Wait "Wait for finishing" 10
        set ret [Send $gaSet(com$uut) "\r" "Boot Prompt"]
      }
    } 
    set ret [Send $gaSet(com$uut) "@\r" "retry"] 
  }
  return 0    
}

proc InstallSwPack1 {com} {
  # ***************************************************************************
  # InstallSwPack1
  # ***************************************************************************
  Send $com "a" "Boot Menu" 1
  if {[Send $com "3" "Done" 70]!=0} {
    UpdateAllOutputs "Fail: Can't install sw pack 1" tag(fail)
    return "abort"
  }
  if {[Send $com "5" "SW-PACK 1 Status: Exist" 3]!=0} {
    UpdateAllOutputs "Fail: SW-PACK 1 Status not Exist" tag(fail)
    return "abort"
  }
  UpdateAllOutputs "SW-PACK 1 Install check Pass."
  return "ok"     
}
