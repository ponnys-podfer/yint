:: All methods for movement.
::
:: This door corresponds to move.rb.
::
/-  yint
/+  yint-all, yint-util
=,  yint-util
!:
|_  a/all:yint
::
:: move.rb
::
::
++  moveto
  |=  {what/@sd where/@sd}
  ^-  all:yint
  =+  loc=location:(~(got yint-db db.a) what)
  ::  remove what from old location
  =?  a  !=(loc nothing:yint)
    =+  loc-record=(~(got yint-db db.a) loc)
    =+  contents-loc=contents:loc-record
    =^  new  db.a  (~(remove-first yint-db db.a) contents-loc what)
    (~(contents-set yint-all a) loc new)
  :: test for special case
  ?:  =(where nothing:yint)
    (~(location-set yint-all a) loc nothing:yint)
  =?  where  =(where home:yint)
    exits:(~(got yint-db db.a) what)
  =+  where-contents=contents:(~(got yint-db db.a) where)
  =.  a  (~(next-set yint-all a) what where-contents)
  =.  a  (~(contents-set yint-all a) where what)
  (~(location-set yint-all a) what where)
::
++  enter-room
  |=  {player/@sd loc/@sd}
  ^-  all:yint
  =?  loc  =(loc home:yint)
    exits:(~(got yint-db db.a) loc)
  =+  old=location:(~(got yint-db db.a) player)
  =?  a  !=(loc old)
    =.  a
      ?.  ?&  !=(old nothing:yint)
              !(~(is-dark yint-db db.a) old)
              !(~(is-dark yint-db db.a) player)
          ==
        a
      %-  ~(notify-except yint-speech a)  :*
        contents:(~(got yint-db db.a) old)
        player
        (phrase-with 'player-left' [name:(~(got yint-db db.a) player) ~] a)
      ==
    =.  a  (moveto player loc)
    ::  todo: maybe_dropto
    =.  a
      ?.  ?&(!(~(is-dark yint-db db.a) loc) !(~(is-dark yint-db db.a) player))
        a
      %-  ~(notify-except yint-speech a)  :*
        contents:(~(got yint-db db.a) loc)
        player
        (phrase-with 'player-arrived' [name:(~(got yint-db db.a) player) ~] a)
      ==
    a
  =.  a  (~(look-room yint-look a) player loc)
  =/  give-penny/?  =(0 (mod rng.a penny-rate:yint))
  ?:  ?&  give-penny
          !(~(controls yint-db db.a) player loc)
          (lte pennies:(~(got yint-db db.a) player) max-pennies:yint)
      ==
    =.  a  (queue-phrase 'found-a-penny' a)
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
::  Determines if a player is making a legal move. Legal move is one of the
::  exits in the room or "home" keyword.
++  can-move
  |=  {player/@sd direction/tape}
  ^-  ?
  ?:  =((cass direction) "home")
    %.y
  =+  matcher=(init:yint-match a player direction type-exit:yint)
  =.  matcher  ~(match-exit yint-match matcher)
  !=(~(last-match-result yint-match matcher) nothing:yint)
::  Moves a player through a given exit, or keyword "home". Notifies player
::  and room of consequence.
++  do-move
  |=  {player/@sd direction/tape}
  ^-  all:yint
  ?:  =(direction "home")
    =+  loc=location:(~(got yint-db db.a) player)
    =?  a  !=(loc nothing:yint)
      %-  ~(notify-except yint-speech a)  :*
        contents:(~(got yint-db db.a) loc)
        player
        (weld name:(~(got yint-db db.a) player) " goes home.")
      ==
    =.  a  (queue-phrase 'no-place-like-home' a)
    =.  a  (queue-phrase 'no-place-like-home' a)
    =.  a  (queue-phrase 'no-place-like-home' a)
    =.  a  (queue-phrase 'wake-up-home' a)
    (send-home player)
  ::  find the exit
  =+  matcher=(init:yint-match a player direction type-exit:yint)
  =.  matcher  ~(match-exit yint-match matcher)
  =+  exit=~(match-result yint-match matcher)
  ?:  =(exit nothing:yint)
    (queue-phrase 'bad-direction' a)
  ?:  =(exit ambiguous:yint)
    (queue-phrase 'which-way' a)
  =^  can  a  (~(can-doit yint-all a) player exit "You can't go that way.")
  ?:  can
    (enter-room player location:(~(got yint-db db.a) exit))
  a
::
++  do-get
  |=  {player/@sd what/tape}
  ^-  all:yint
  =+  matcher=(init:yint-match a player what type-thing:yint)
  =.  matcher  ~(match-neighbor yint-match matcher)
  =.  matcher  ~(match-exit yint-match matcher)
  =?  matcher  (~(is-wizard yint-db db.a) player)
    ~(match-absolute yint-match matcher)
  =^  thing  a  ~(noisy-match-result yint-match matcher)
  ?:  =(thing nothing:yint)
    a
  ?:  =(player location:(~(got yint-db db.a) thing))
    (queue-phrase 'already-have-it' a)
  =+  type=(~(typeof yint-db db.a) thing)
  ?:  =(type type-thing:yint)
    =^  can  a  (~(can-doit yint-all a) player thing "You can't pick that up.")
    ?:  can
      =.  a  (moveto thing player)
      (queue-phrase 'taken' a)
    a
  ?:  =(type type-exit:yint)
    ?.  (~(controls yint-db db.a) player thing)
      (queue-phrase 'bad-pickup' a)
    ?.  =(location:(~(got yint-db db.a) thing) nothing:yint)
      (queue-phrase 'no-get-linked-exit' a)
    =+  loc=location:(~(got yint-db db.a) player)
    ?:  =(loc nothing:yint)
      a
    =+  loc-record=(~(got yint-db db.a) loc)
    ?.  (~(member yint-db db.a) thing exits:loc-record)
      (queue-phrase 'no-get-exit-elsewhere' a)
    =^  new  db.a  (~(remove-first yint-db db.a) exits:loc-record thing)
    =.  a  (~(exits-set yint-all a) loc new)
    =.  a  (~(next-set yint-all a) thing contents:(~(got yint-db db.a) player))
    =.  a  (~(contents-set yint-all a) player thing)
    =.  a  (~(location-set yint-all a) thing player)
    (queue-phrase 'exit-taken' a)
  (queue-phrase 'cant-take' a)
::
++  do-drop
  |=  {player/@sd name/tape}
  ^-  all:yint
  =+  loc=location:(~(got yint-db db.a) player)
  ?:  =(loc nothing:yint)
    a
  =+  matcher=(init:yint-match a player name type-thing:yint)
  =.  matcher  ~(match-possession yint-match matcher)
  =+  thing=~(match-result yint-match matcher)
  ?:  =(thing nothing:yint)
    (queue-phrase 'dont-have-it' a)
  ?:  =(thing ambiguous:yint)
    (queue-phrase 'which' a)
  ?.  =(player location:(~(got yint-db db.a) thing))
    ::  Should never happen.
    (queue-phrase 'cant-drop-that' a)
  ?:  (~(is-exit yint-db db.a) thing)
    ?.  (~(controls yint-db db.a) player loc)       ::  special case for exits
      (queue-phrase 'no-drop-exit-here' a)
    =.  a  (moveto thing nothing:yint)              ::  take it out of the pack
    =.  a  (~(next-set yint-all a) thing exits:(~(got yint-db db.a) loc))
    =.  a  (~(exits-set yint-all a) loc thing)
    (queue-phrase 'exit-dropped' a)
  ?:  (~(is-temple yint-db db.a) loc)
    ::  todo: is temple case.
    (queue "todo: is-temple case" a)
  ?:  (~(is-sticky yint-db db.a) thing)
    =.  a  (send-home thing)
    (queue-phrase 'dropped' a)
  ?:  ?&  !=(location:(~(got yint-db db.a) loc) nothing:yint)
          !(~(is-sticky yint-db db.a) loc)
      ==
    =.  a  (moveto thing location:(~(got yint-db db.a) loc))
    (queue-phrase 'dropped' a)
  =.  a  (moveto thing loc)
  =.  a  (queue-phrase 'dropped' a)
  %-  ~(notify-except yint-speech a)  :*
    contents:(~(got yint-db db.a) loc)
    player
    %^  phrase-with
      'dropped-thing'
      :~
        name:(~(got yint-db db.a) player)
        name:(~(got yint-db db.a) thing)
      ==
      a
  ==

::  "Private"

::
++  send-contents
  |=  {loc/@sd dest/@sd}
  ^-  all:yint
  =+  first=contents:(~(got yint-db db.a) loc)
  =.  a  (~(contents-set yint-all a) loc nothing:yint)
  =.  a  (set-all-contents-nothing first)
  =.  a  (send-contents-move first loc dest a)
  =+  contents=contents:(~(got yint-db db.a) loc)
  =^  r  a  (~(reverse yint-all a) contents)
  (~(contents-set yint-all a) loc r)
::
++  set-all-contents-nothing
  |=  first/@sd
  ::  remove the location of everything in the list.
  =/  l/(list @sd)  (~(enum yint-db db.a) first)
  |-
  ?~  l
    a
  =+  x=i.l
  =.  a  (~(location-set yint-all a) x nothing:yint)
  $(l t.l)
::  Helper gate for send-contents
++  send-contents-move
  |=  {first/@sd loc/@sd dest/@sd a/all:yint}
  =+  x=~(keys yint-db db.a)
  ^-  all:yint
  |-
  ?:  =(first nothing:yint)
    a
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
