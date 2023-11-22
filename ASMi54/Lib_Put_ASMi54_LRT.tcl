proc ConfigBoot4Dwnl {uut} {
  puts "[MyTime] ConfigBoot4Dwnl $uut"
  global gaSet buffer
  set gaSet(fail) "Boot Configuration of $uut fail"
  set com $gaSet(com$uut)
  set unit [string index $uut end]
  set ip 1.1.1.[set gaSet(pair)][set unit]
  
  set ret [Send $com c\r host]
  if {$ret!=0} {return $ret}
  set ret [Send $com \r vxWorks]
  if {$ret!=0} {return $ret}
  set ret [Send $com \r (ip)]
  if {$ret!=0} {return $ret}
  set ret [Send $com $ip\r (dm)]
  if {$ret!=0} {return $ret}
  set ret [Send $com 255.255.255.0\r (sip)]
  if {$ret!=0} {return $ret}
  set ret [Send $com 1.1.1.1\r (g)]
  if {$ret!=0} {return $ret}
  set ret [Send $com 1.1.1.1\r vx]
  if {$ret!=0} {return $ret}
  set ret [Send $com \r :]
  if {$ret!=0} {return $ret}
  set ret [Send $com \r 8313]
  if {$ret!=0} {return $ret}
  set ret [Send $com \r n]
  if {$ret!=0} {return $ret}
  set ret [Send $com \r ftp\]]
  if {$ret!=0} {return $ret}
  set ret [Send $com tftp\r 200\]]
  if {$ret!=0} {return $ret}
  set ret [Send $com \r boot\]]
  return $ret
}