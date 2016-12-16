::  The TinyMUD/MangledMUD code often mixes contexts where we have to output and cause
::  side effects as a single method in what's otherwise a pure function or a database only
::  mutating function. This is a catchall door which takes care of that.
/-  yint
/+  yint-db, yint-util
=,  yint-util
!:
|_  a/all:yint
++  can-doit
  |=  {player/@sd thing/@sd default-fail-msg/tape}
  ^-  {? all:yint}
  =+  player-record=(~(got yint-db db.a) player)
  =+  loc=location:player-record
  =+  thing-record=(~(got yint-db db.a) thing)
  ?:  =(loc nothing:yint)
    [%.n a]
  =+  con-loc=contents:(~(got yint-db db.a) loc)
  ?.  (~(could-doit yint-db db.a) player thing)     :: can't do it
    =.  a
      ?.  =("" fail.thing-record)
        (queue fail.thing-record a)
      ?.  =("" default-fail-msg)
        (queue default-fail-msg a)
      a
    =+  ofail=ofail:thing-record
    =?  a  !=("" ofail)
      =/  msg  :(weld name:player-record " " ofail)
      (~(notify-except yint-speech a) con-loc player msg)
    [%.n a]
  =?  a  !=("" succ.thing-record)
    (queue succ.thing-record a)
  =+  osucc=osucc:thing-record
  =?  a  !=("" osucc)
    =/  msg  :(weld name:player-record " " osucc)
    (~(notify-except yint-speech a) con-loc player msg)
  [%.y a]

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
++  name-set
  |=  {what/@sd c/tape}
  =+  old=(~(got yint-db db.a) what)
  a(db (~(put yint-db db.a) what old(name c)))
++  description-set
  |=  {what/@sd c/tape}
  =+  old=(~(got yint-db db.a) what)
  a(db (~(put yint-db db.a) what old(description c)))
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
++  key-set
  |=  {what/@sd c/@sd}
  =+  old=(~(got yint-db db.a) what)
  a(db (~(put yint-db db.a) what old(key c)))
++  fail-set
  |=  {what/@sd c/tape}
  =+  old=(~(got yint-db db.a) what)
  a(db (~(put yint-db db.a) what old(fail c)))
++  success-set
  |=  {what/@sd c/tape}
  =+  old=(~(got yint-db db.a) what)
  a(db (~(put yint-db db.a) what old(succ c)))
++  osuccess-set
  |=  {what/@sd c/tape}
  =+  old=(~(got yint-db db.a) what)
  a(db (~(put yint-db db.a) what old(osucc c)))
++  ofail-set
  |=  {what/@sd c/tape}
  =+  old=(~(got yint-db db.a) what)
  a(db (~(put yint-db db.a) what old(ofail c)))
++  owner-set
  |=  {what/@sd c/@sd}
  =+  old=(~(got yint-db db.a) what)
  a(db (~(put yint-db db.a) what old(owner c)))
++  pennies-set
  |=  {what/@sd c/@sd}
  =+  old=(~(got yint-db db.a) what)
  a(db (~(put yint-db db.a) what old(pennies c)))

++  flag-set
  |=  {what/@sd f/@u}
  =+  old=(~(got yint-db db.a) what)
  =+  new=(con flags:old f)
  a(db (~(put yint-db db.a) what old(flags new)))

::  not a general &= ~ function. Only goes up to 0x100, which is what is used
::  in our bitfield.
++  flag-unset
  |=  {what/@sd f/@u}
  =+  old=(~(got yint-db db.a) what)
  =+  new=(dis flags:old (not 0 9 f))
  a(db (~(put yint-db db.a) what old(flags new)))

--
