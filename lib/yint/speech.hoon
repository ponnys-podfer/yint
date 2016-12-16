:: All methods for movement.
::
:: This door corresponds to move.rb.
::
/-  yint
/+  yint-all, yint-db, yint-util
=,  yint-util
!:
|_  a/all:yint

++  do-say
  |=  {player/@sd arg1/tape arg2/tape}
  ^-  all:yint
  =+  loc=location:(~(got yint-db db.a) player)
  ?:  =(loc nothing:yint)
    a
  =+  msg=(reconstruct-message arg1 arg2)
  =.  a  (queue-phrase-with 'you-say' [msg ~] a)
  %-  notify-except  :*
    contents:(~(got yint-db db.a) loc)
    player
    (phrase-with 'someone-says' [name:(~(got yint-db db.a) player) msg ~] a)
  ==

++  do-pose
  |=  {player/@sd arg1/tape arg2/tape}
  ^-  all:yint
  =+  loc=location:(~(got yint-db db.a) player)
  ?:  =(loc nothing:yint)
    a
  =+  msg=(reconstruct-message arg1 arg2)
  =+  name=name:(~(got yint-db db.a) player)
  (notify-except contents:(~(got yint-db db.a) loc) nothing:yint :(weld name " " msg))

::  todo: ++do-wall
::  todo: ++do-gripe
::  todo: ++do-page

::  Helper function to send a notify everyone in a list with a particular message besides
::  one person.
++  notify-except
  |=  {first/@sd exception/@sd msg/tape}
  ^-  all:yint
  =+  l=(~(enum yint-db db.a) first)
  |-
  ?~  l
    a
  =.  a
    =+  i=i.l
    ?:  ?&  (~(is-player yint-db db.a) i)
            !=(i exception)
        ==
      ::  note: not in original since we separate out current player from others.
      ?:  =(`i player.a)
        (queue msg a)
      (queue-notification i msg a)
    a
  $(l t.l)

++  reconstruct-message
  |=  {arg1/tape arg2/tape}
  ^-  tape
  ?~  arg2
    arg1
  ?:  =(arg2 "")
    arg1
  :(welp arg1 " = " arg2)
--
