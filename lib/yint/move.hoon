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
  =/  give-penny/?  =(0 (mod rng.a penny-rate:yint))
  ?:  ?&  give-penny
          !(~(controls yint-db db.a) player loc)
          (lte pennies:(~(got yint-db db.a) player) max-pennies:yint)
      ==
    =.  a  (queue-phrase "found-a-penny" a)
    =+  new-count=(sum:si --1 pennies:(~(got yint-db db.a) player))
    (~(pennies-set yint-all a) player new-count)
  a
::
++  send-home
  |=  thing/@sd
  ^-  all:yint
  =+  type=(~(typeof yint-db db.a) thing)
  ?:  =(type type-player:yint)
    =.  a  (send-contents thing home:yint)
    (enter-room thing exits:(~(got yint-db db.a) thing))
  ?:  =(type type-thing:yint)
    (moveto thing exits:(~(got yint-db db.a) thing))
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
    =+  loc=location:(~(got yint-db db.a) player)
    ::   todo: @speech.notify_except...
    =.  a  (queue-phrase "no-place-like-home" a)
    =.  a  (queue-phrase "no-place-like-home" a)
    =.  a  (queue-phrase "no-place-like-home" a)
    =.  a  (queue-phrase "wake-up-home" a)
    (send-home player)
  ::  find the exit
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

::  "Private"

++  send-contents
  |=  {loc/@sd dest/@sd}
  ^-  all:yint
  =+  first=contents:(~(got yint-db db.a) loc)
  =.  a  (~(contents-set yint-all a) loc nothing:yint)
  =+  l=(~(enum yint-db db.a) first)
  ::  remove the location of everything in the list.
  =.  a  %^  left-fold  l  a
    |=  {item/@sd a/all:yint}
    (~(location-set yint-all a) item nothing:yint)
  =.  a  (send-contents-move first loc dest a)
  =+  contents=contents:(~(got yint-db db.a) loc)
  =^  r  a  (~(reverse yint-all a) contents)
  (~(contents-set yint-all a) loc r)

::  Helper gate for send-contents
++  send-contents-move
  |=  {first/@sd loc/@sd dest/@sd a/all:yint}
  ^-  all:yint
  |-
  =+  rest=next:(~(got yint-db db.a) first)
  ?.  (~(is-thing yint-db db.a) first)
    =.  a  (moveto first loc)
    $(first rest)
  =/  i/@sd
    ?:  (~(is-sticky yint-db db.a) first)
      home:yint
    dest
  =.  a  (moveto first i)
  $(first rest)

--
