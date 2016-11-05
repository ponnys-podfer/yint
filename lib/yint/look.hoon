:: All methods for looking.
::
:: This door corresponds to look.rb.
::
/-  yint
/+  yint-all, yint-db, yint-match, yint-util
[[. yint-util] match=yint-match]
!:
|_  a/all:yint
++  look-room
  |=  {player/@sd loc/@sd}
  ^-  all:yint
::  =+  matcher=(init:match db.a player ")
  =+  record=(~(got yint-db db.a) loc)
  =.  a
    ?:  (~(can-link-to yint-db db.a) player loc)
      =+  id=(scow %u (abs:si loc))
      (queue-styx [[[`%br ~ ~] name.record] [[~ ~ ~] "("] [[`%un ~ ~] id] [[~ ~ ~] ")"] ~] a)
    (queue-styx [[[`%br ~ ~] name.record] ~] a)
  ::  If there's a description, queue it.
  =.  a
    ?:  =("" description.record)
      a
    (queue description.record a)
  =^  ret  a  (~(can-doit yint-all a) player loc ~)
  ::  todo: look_contents
  a

++  do-look-at
  |=  name/tape
  ^-  all:yint
  ?:  =("" name)
    =+  p=(need player.a)
    =+  location=(~(gotlocation yint-db db.a) p)
    ?.  =(location nothing:yint)
      (look-room p location)
    a
  :: todo: this is mostly unimplemented. this core is going to be huge.
  a
--
