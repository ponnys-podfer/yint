::
:: This door corresponds to create.rb.
::
/-  yint
/+  yint-all, yint-db, yint-match, yint-util
[[. yint-util] match=yint-match]
!:
|_  a/all:yint

++  parse-linkable-room
  |=  {player/@sd room-name/tape}
  ^-  {@sd all:yint}
  ?:  =((cass room-name) "home")
    [home:yint a]
  =/  room
    ?:  =((cass room-name) "here")
      location:(~(got yint-db db.a) player)
    (parse-dbref room-name)
  ~&  [%checking-room room]
  ?:  =(room nothing:yint)
    [nothing:yint (queue-phrase 'not-a-room' a)]
  ?.  (~(is-room yint-db db.a) room)
    [nothing:yint (queue-phrase 'not-a-room' a)]
  ?.  (~(can-link-to yint-db db.a) player room)
    [nothing:yint (queue-phrase 'bad-link' a)]
  [room a]

::  Opens an exit belonging to the player in the specified direction.
++  do-open
  |=  {player/@sd direction/tape linkto/tape}
  ^-  all:yint
  =+  loc=location:(~(got yint-db db.a) player)
  ?:  =(loc nothing:yint)
    a
  ?~  direction
    (queue-phrase 'no-permission' a)
  =^  can-pay  db.a  (~(payfor yint-db db.a) player exit-cost:yint)
  ?.  can-pay
    (queue-phrase 'sorry-poor-open' a)
  =^  index  db.a  ~(add-new-record yint-db db.a)
  =+  loc-exits=exits:(~(got yint-db db.a) loc)
  =/  r  %-  record:yint  :*
    direction           :: name
    ""                  :: description
    nothing:yint        :: location
    nothing:yint        :: contents
    nothing:yint        :: exits
    loc-exits           :: next
    nothing:yint        :: key
    ""                  :: fail
    ""                  :: succ
    ""                  :: ofail
    ""                  :: osucc
    player              :: owner
    --0                 :: pennies
    type-exit:yint      :: type
    ""                  :: password
  ==
  =.  db.a  (~(put yint-db db.a) index r)
  =.  a  (~(exits-set yint-all a) loc index)
  =.  a  (queue-phrase 'opened' a)
  ?~  linkto
    a
  =.  a  (queue-phrase 'trying-to-link' a)
  =^  loc  a  (parse-linkable-room player linkto)
  ?:  =(loc nothing:yint)
    a
  =^  can-pay  db.a  (~(payfor yint-db db.a) player link-cost:yint)
  ?.  can-pay
    (queue-phrase 'too-poor-to-link' a)
  =.  a  (~(location-set yint-all a) index loc)
  (queue-phrase 'linked' a)

::
++  do-link
  |=  {player/@sd name/tape room-name/tape}
  ^-  all:yint
  =+  loc=location:(~(got yint-db db.a) player)
  ?:  =(nothing:yint loc)
    a
  =^  room  a  (parse-linkable-room player room-name)
  ?:  =(nothing:yint room)
    a
  =+  matcher=(init:yint-match a player name type-exit:yint)
  =.  matcher  ~(match-exit yint-match matcher)
  =.  matcher  ~(match-neighbor yint-match matcher)
  =.  matcher  ~(match-possession yint-match matcher)
  =.  matcher  ~(match-me yint-match matcher)
  =.  matcher  ~(match-here yint-match matcher)
  =.  matcher
    ?.  (~(is-wizard yint-db db.a) player)
      matcher
    =.  matcher  ~(match-absolute yint-match matcher)
    ~(match-player yint-match matcher)
  =^  thing  a  ~(noisy-match-result yint-match matcher)
  ?:  =(thing nothing:yint)
    a
  =+  type=(~(typeof yint-db db.a) thing)
  ?:  =(type type-exit:yint)
    ?.  =(location:(~(got yint-db db.a) thing) nothing:yint)
      ::  all error cases
      ?:  (~(controls yint-db db.a) player thing)
        ?:  (~(is-player yint-db db.a) location:(~(got yint-db db.a) thing))
          (queue-phrase 'exit-being-carried' a)
        (queue-phrase 'exit-already-linked' a)
      (queue-phrase 'no-permission' a)
    ?:  =(player owner:(~(got yint-db db.a) thing))
      =^  can-pay  db.a  (~(payfor yint-db db.a) player link-cost:yint)
      ?.  can-pay
        (queue-phrase 'too-poor-to-link' a)
      (complete-do-link-exit player thing room)
    =^  can-pay  db.a  (~(payfor yint-db db.a) player (add link-cost:yint exit-cost:yint))
    ?.  can-pay
      (queue-phrase 'cost-two-exit' a)
    =+  o=owner:(~(got yint-db db.a) thing)
    =+  old-p=pennies:(~(got yint-db db.a) o)
    =.  a  (~(pennies-set yint-all a) o (add old-p exit-cost:yint))
    (complete-do-link-exit player thing room)

  ?:  =(type type-thing:yint)
    (complete-do-link-thing player thing room)

  ?:  =(type type-player:yint)
    (complete-do-link-thing player thing room)

  ?:  =(type type-room:yint)
    ?.  (~(controls yint-db db.a) player thing)
      (queue-phrase 'no-permission' a)
    =.  a  (~(location-set yint-all a) thing room)
    (queue-phrase 'drop-to-set' a)
  a

::  (Helper detail of do-link.)
++  complete-do-link-exit
  |=  {player/@sd thing/@sd room/@sd}
  ^-  all:yint
  =.  a  (~(owner-set yint-all a) thing player)
  =.  a  (~(location-set yint-all a) thing room)
  (queue-phrase 'linked' a)

::  (Helper detail of do-link.)
++  complete-do-link-thing
  |=  {player/@sd thing/@sd room/@sd}
  ^-  all:yint
  ?.  (~(controls yint-db db.a) player thing)
    (queue-phrase 'no-permission' a)
  ?:  =(room home:yint)
    (queue-phrase 'no-set-home' a)
  =.  a  (~(exits-set yint-all a) thing room)
  (queue-phrase 'home-set' a)

::  Creates an object with a particular name under the ownership of a player.
++  do-create
  |=  {player/@sd name/tape in-cost/tape}
  ?:  =(name "")
    (queue-phrase 'create-what' a)
  ?.  (~(ok-name yint-db db.a) name)
    (queue-phrase 'silly-thing-name' a)
  =+  parsed-cost=(rust in-cost dim:ag)
  ?~  parsed-cost
    (queue-phrase 'objects-must-have-a-value' a)
  =/  cost/@ud
    ?:  (lth (need parsed-cost) object-cost:yint)
      object-cost:yint
    (need parsed-cost)
  =^  can-pay  db.a  (~(payfor yint-db db.a) player cost)
  ?.  can-pay
    (queue-phrase 'sorry-poor' a)
  =^  index  db.a  ~(add-new-record yint-db db.a)
  =+  player-r=(~(got yint-db db.a) player)
  =/  pennies/@sd
    =+  base=(endow cost)
    ?:  (gth base max-object-endowment:yint)
      (sun:si max-object-endowment:yint)
    (sun:si base)
  =/  exits/@sd
    ?:  ?&  !=(location:player-r nothing:yint)
            (~(can-link-to yint-db db.a) player location:player-r)
        ==
      location:player-r
    exits:player-r
  =/  r  %-  record:yint  :*
    name                :: name
    ""                  :: description
    player              :: location
    nothing:yint        :: contents
    exits               :: exits
    contents:player-r   :: next
    nothing:yint        :: key
    ""                  :: fail
    ""                  :: succ
    ""                  :: ofail
    ""                  :: osucc
    player              :: owner
    pennies             :: pennies
    type-thing:yint     :: type
    ""                  :: password
  ==
  ::  todo: if I could reliably set some of those default values to NOTHING, I could
  ::  use the following and cut down duplicates.
  :: =.  r  %=  r
  ::   name      name
  ::   location  player
  ::   contents  nothing:yint
  ::   exits     exits
  ::   next      contents:player-r
  ::   key       nothing:yint
  ::   owner     player
  ::   pennies   pennies
  ::   flags     type-thing:yint
  :: ==
  =.  db.a  (~(put yint-db db.a) index r)
  =.  a  (~(contents-set yint-all a) player index)
  (queue-phrase 'created' a)

::  Endow is a helper function to calculate the autmatic endowment for an object.
++  endow
  |=  cost/@ud
  ^-  @ud
  %+  div
    (sub cost endowment-calculator:yint)
    endowment-calculator:yint

::  Digs into an area, creating a new room. Notifies the player of outcome.
++  do-dig
  |=  {player/@sd name/tape}
  ^-  all:yint
  ?:  =(name "")
    (queue-phrase 'dig-what' a)
  ?.  (~(ok-name yint-db db.a) name)
    (queue-phrase 'silly-room-name' a)
  =^  can-pay  db.a  (~(payfor yint-db db.a) player room-cost:yint)
  ?.  can-pay
    (queue-phrase 'sorry-poor-dig' a)
  =^  index  db.a  ~(add-new-record yint-db db.a)
  =/  r  %-  record:yint  :*
    name                :: name
    ""                  :: description
    nothing:yint        :: location
    nothing:yint        :: contents
    nothing:yint        :: exits
    nothing:yint        :: next
    nothing:yint        :: key
    ""                  :: fail
    ""                  :: succ
    ""                  :: ofail
    ""                  :: osucc
    player              :: owner
    --0                 :: pennies
    type-room:yint      :: type
    ""                  :: password
  ==
  =.  db.a  (~(put yint-db db.a) index r)
  (queue-phrase-with 'created-room' [name (print-ref index) ~] a)
--
