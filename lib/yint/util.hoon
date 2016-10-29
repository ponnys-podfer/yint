::  common utilities used everywhere
/-  yint
/+  yint-db
!:
|%
::  Add an entry to the system log.
++  log
  |=  {msg/tape a/all:yint}
  ^-  all:yint
  a(syslog [i=msg t=syslog.a])
::  Queue raw text to the player.
++  queue
  |=  {msg/tape a/all:yint}
  ^-  all:yint
  a(messages [i=[%txt msg] t=messages.a])
::  Looks up a response phrase and queues it to the active player.
++  queue-phrase
  |=  {msg/tape a/all:yint}
  ^-  all:yint
  ::  todo: actually look up message in a 
  (queue msg a)
++  queue-styx
  |=  {msg/styx a/all:yint}
  ^-  all:yint
  a(messages [i=[%klr msg] t=messages.a])
::  Misc function that starts quiting a player's session.
++  do-quit
  |=  {a/all:yint}
  ^-  all:yint
  =+  id=(need player.a)
  =+  record=(~(got yint-db db.a) id)
  =.  a  (log "DISCONNECTED {<name.record>}({<id>}) from {<src.a>}" a)
  a(player ~)
--
