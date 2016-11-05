:: All methods for movement.
::
:: This door corresponds to move.rb.
::
/-  yint
/+  yint-all, yint-util
[. yint-util]
!:
|_  a/all:yint
::
:: move.rb
::

++  moveto
  |=  {what/@sd where/@sd}
  ^-  all:yint
  =+  loc=location:(~(got yint-db db.a) what)
  ::  remove what from old location
  =.  a
    ?:  =(loc nothing:yint)
      a
    =+  loc-record=(~(got yint-db db.a) loc)      
    =+  contents-loc=contents:loc-record
    =^  new  db.a  (~(remove-first yint-db db.a) contents-loc what)
    (~(contents-set yint-all a) loc new)
  :: test for special case
  ?:  =(where nothing:yint)
    (~(location-set yint-all a) loc nothing:yint)
  =.  where
    ?.  =(where home:yint)
      where
    exits:(~(got yint-db db.a) what)
  =+  where-contents=contents:(~(got yint-db db.a) where)
  =.  a  (~(next-set yint-all a) what where-contents)
  =.  a  (~(contents-set yint-all a) where what)
  (~(location-set yint-all a) what where)

::  todo: continue here.
++  enter-room
  |=  {player/@sd loc/@sd}
  ^-  all:yint
  =.  loc
    ?:  =(loc home:yint)
      exits:(~(got yint-db db.a) loc)
    loc
  =+  old=location:(~(got yint-db db.a) player)
  =.  a
    ?:  =(loc old)
      a
    ::  todo: Speech.notify_except player-left message. (starts old != NOTHING)
    =.  a  (moveto player loc)
    ::  todo: maybe_dropto
    ::  todo: Speech.notify_except player-arrived...
    a
  =.  a  (~(look-room yint-look a) player loc)
  :: todo: check for pennies
  a

:: 
++  can-move
  |=  {player/@sd direction/tape}
  ^-  ?
  ?:  =((cass direction) "home")
    %.y
  =+  matcher=(init:yint-match a player direction type-exit:yint)
  =.  matcher  ~(match-exit yint-match matcher)
  !=(~(last-match-result yint-match matcher) nothing:yint)
::
++  do-move
  |=  {player/@sd direction/tape}
  ^-  all:yint
  ?:  =(direction "home")
    :: todo: we don't support home yet
    (queue "todo: we don't support home yet" a)
  =+  matcher=(init:yint-match a player direction type-exit:yint)
  =.  matcher  ~(match-exit yint-match matcher)
  =+  exit=~(match-result yint-match matcher)
  ?:  =(exit nothing:yint)
    (queue-phrase "bad-direction" a)
  ?:  =(exit ambiguous:yint)
    (queue-phrase "which-way" a)
  =^  can  a  (~(can-doit yint-all a) player exit "You can't go that way.")
  ?:  can
    (enter-room player location:(~(got yint-db db.a) exit))
  a
--
