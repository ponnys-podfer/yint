::  common utilities used everywhere
/-  yint
!:
|%
:: Add an entry to the system log.
++  log
  |=  {msg/tape a/all:yint}
  ^-  all:yint
  a(syslog [i=msg t=syslog.a])
:: Queue a message to the player.
++  queue
  |=  {msg/tape a/all:yint}
  ^-  all:yint
  a(messages [i=[%txt msg] t=messages.a])
--
