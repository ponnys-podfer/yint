::  The TinyMUD/MangledMUD code often mixes contexts where we have to output and cause
::  side effects as a single method in what's otherwise a pure function or a database only
::  mutating function. This is a catchall door which takes care of that.
/-  yint
/+  yint-db, yint-util
[. yint-util]
!:
|_  a/all:yint
++  can-doit
  |=  {player/@sd thing/@sd default-fail-msg/tape}
  ^-  {? all:yint}
  =+  player-record=(~(got yint-db db.a) player)
  =+  thing-record=(~(got yint-db db.a) thing)
  ?:  =(location.player-record nothing:yint)
    [%.n a]
  ?.  (~(could-doit yint-db db.a) player thing)     :: can't do it
    =.  a
      ?.  =("" fail.thing-record)
        (queue fail.thing-record a)
      ?.  =("" default-fail-msg)
        (queue default-fail-msg a)
      a
    ::  todo: Speech.new().notify_except().
    [%.n a]
  =.  a
    ?.  =("" succ.thing-record)
      (queue succ.thing-record a)
    a
  :: todo: Spech.new.notify_except()...
  [%.y a]


:: todo: continue here tomorrow.
::
++  reverse
  |=  list/@sd
  ^-  {@sd all:yint}
  =+  newlist=nothing:yint
  |-
  ?:  =(list nothing:yint)
    [newlist a]
  =+  rest=next:(~(got yint-db db.a) list)
  =.  a  (next-set list newlist)
  $(newlist list, list rest)


::  Helper for mutating db records concisely.
++  location-set
  |=  {what/@sd c/@sd}
  =+  old=(~(got yint-db db.a) what)
  a(db (~(put yint-db db.a) what old(location c)))
++  contents-set
  |=  {what/@sd c/@sd}
  =+  old=(~(got yint-db db.a) what)
  a(db (~(put yint-db db.a) what old(contents c)))
++  exits-set
  |=  {what/@sd c/@sd}
  =+  old=(~(got yint-db db.a) what)
  a(db (~(put yint-db db.a) what old(exits c)))
++  next-set
  |=  {what/@sd c/@sd}
  =+  old=(~(got yint-db db.a) what)
  a(db (~(put yint-db db.a) what old(next c)))
++  pennies-set
  |=  {what/@sd c/@sd}
  =+  old=(~(got yint-db db.a) what)
  a(db (~(put yint-db db.a) what old(pennies c)))
--
