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
  =+  record=(~(got yint-db db.a) loc)
  =.  a
    ?:  (~(can-link-to yint-db db.a) player loc)
      =+  id=(print-ref loc)
      (queue-styx [[[`%br ~ ~] name.record] [[~ ~ ~] "(#"] [[`%un ~ ~] id] [[~ ~ ~] ")"] ~] a)
    (queue-styx [[[`%br ~ ~] name.record] ~] a)
  ::  If there's a description, queue it.
  =.  a
    ?:  =("" description.record)
      a
    (queue description.record a)
  =^  ret  a  (~(can-doit yint-all a) player loc ~)
  (look-contents player loc "Contents:")

++  do-look-at
  |=  name/tape
  ^-  all:yint
  =+  player=(need player.a)
  ?:  =("" name)
    =+  location=(~(gotlocation yint-db db.a) player)
    ?.  =(location nothing:yint)
      (look-room player location)
    a
  =+  matcher=(init:yint-match a player name notype:yint)
  =.  matcher  ~(match-exit yint-match matcher)
  =.  matcher  ~(match-neighbor yint-match matcher)
  =.  matcher  ~(match-possession yint-match matcher)
  ::  todo: implement is-wizard matching here.
  =.  matcher  ~(match-here yint-match matcher)
  =.  matcher  ~(match-me yint-match matcher)
  =^  thing  a  ~(noisy-match-result yint-match matcher)
  ?:  =(thing nothing:yint)
    a
  =+  type=(~(typeof yint-db db.a) thing)
  ?:  =(type type-room:yint)
    (look-room player thing)
  ?:  =(type type-player:yint)
    =.  a  (look-simple player thing)
    (look-contents player thing (phrase 'carrying-list' a))
  (look-simple player thing)

++  get-thing-to-examine
  |=  {player/@sd name/tape}
  =+  thing=location:(~(got yint-db db.a) player)
  ?~  name
    [thing a]
  ?:  =("" name)
    [thing a]  
  =+  matcher=(init:yint-match a player name notype:yint)
  =.  matcher  ~(match-exit yint-match matcher)
  =.  matcher  ~(match-neighbor yint-match matcher)
  =.  matcher  ~(match-possession yint-match matcher)
  =.  matcher  ~(match-absolute yint-match matcher)
  ::  todo: implement is-wizard matching for match_player.
  =.  matcher  ~(match-here yint-match matcher)
  =.  matcher  ~(match-me yint-match matcher)
  ~(noisy-match-result yint-match matcher)

++  do-examine
  |=  {player/@sd name/tape}
  ^-  all:yint
  =^  thing  a  (get-thing-to-examine player name)
  ?:  =(thing nothing:yint)
    a
  ?.  (~(can-link yint-db db.a) player thing)
    (queue-phrase 'can-only-examine-owned' a)
  =+  r=(~(got yint-db db.a) thing)
  =/  antilock
    ?:  (~(is-antilock yint-db db.a) thing)
      "!"
    " "
  =/  line  ;:
    weld
    (getname thing a)
    "(#"  (print-ref thing)  ") ["
    (getname owner:r a)
    "] "
    (phrase 'key' a)  " "  antilock
    (getname key:r a)
    "(#"  (print-ref key:r)  ") "
    (phrase 'pennies' a)  " "
    (print-ref pennies:r)  " "
    (flag-description thing)
  ==
  =.  a  (queue line a)
  =.  a
    ?:  =(description:r "")  a
    (queue description:r a)
  =.  a
    ?:  =(fail:r "")  a
    (queue-phrase-with 'fail' [fail:r ~] a)
  =.  a
    ?:  =(succ:r "")  a
    (queue-phrase-with 'success' [succ:r ~] a)
  =.  a
    ?:  =(ofail:r "")  a
    (queue-phrase-with 'ofail' [ofail:r ~] a)
  =.  a
    ?:  =(osucc:r "")  a
    (queue-phrase-with 'osucc' [osucc:r ~] a)
  =+  type=(~(typeof yint-db db.a) thing)
  ?:  =(type type-room:yint)
    (examine-room player r)
  ?:  =(type type-thing:yint)
    (examine-thing player r)
  ?:  =(type type-player:yint)
    (examine-thing player r)
  ?:  =(type type-exit:yint)
    (examine-exit player r)
  ~&  [%weird-thing-examined name thing]
  a

++  examine-room
  |=  {player/@sd r/record:yint}
  ^-  all:yint
  =.  a
    ?:  =(exits:r nothing:yint)
      (queue-phrase 'no-exits' a)
    =.  a  (queue-phrase 'exits' a)
    =+  exits=(~(enum yint-db db.a) exits:r)
    |-
    ?~  exits
      a
    =.  a  (notify-name player i.exits)
    $(exits t.exits)      
  ?.  =(location:r nothing:yint)
    =+  n=(getname location:r a)
    =+  loc=(print-ref location:r)
    (queue-phrase-with 'dropped-go-to' [n loc ~] a)
  a

++  examine-thing
  |=  {player/@sd r/record:yint}
  ^-  all:yint
  =+  home=(getname exits:r a)
  =+  home-num=(print-ref exits:r)
  =.  a  (queue-phrase-with 'home' [home home-num ~] a)
  =+  loc=location:r
  ?:  ?&  !=(loc nothing:yint)
          ?|  (~(controls yint-db db.a) player loc)
              (~(can-link-to yint-db db.a) player loc)
          ==
      ==
    =+  n=(getname location:r a)
    =+  ref=(print-ref location:r)
    (queue-phrase-with 'location' [n ref ~] a)
  a

++  examine-exit
  |=  {player/@sd r/record:yint}
  ^-  all:yint
  ?:  =(location:r nothing:yint)
    (queue-phrase 'dest-home' a)
  ?:  =(location:r home:yint)
    (queue-phrase 'dest-home' a)
  =+  n=(getname location:r a)
  =+  ref=(print-ref location:r)
  ?:  (~(is-room yint-db db.a) location:r)
    (queue-phrase-with 'dest' [n ref ~] a)
  (queue-phrase-with 'carried-by' [n ref ~] a)  

++  do-score
  |=  player/@sd
  ^-  all:yint
  =+  count=pennies:(~(got yint-db db.a) player)
  ?:  =(--1 count)
    (queue-phrase 'you-have-a-penny' a)
  (queue-phrase-with 'you-have-pennies' [(scow %ud (abs:si count)) ~] a)

++  do-inventory
  |=  player/@sd
  ^-  all:yint
  =+  thing=contents:(~(got yint-db db.a) player)
  ?:  =(thing nothing:yint)
    =.  a  (queue-phrase 'carrying-nothing' a)
    (do-score player)
  =.  a  (queue-phrase 'carrying' a)
  =+  items=(~(enum yint-db db.a) thing)
  |-
  ?~  items
    (do-score player)
  =.  a  (notify-name player i.items)
  $(items t.items)

::  todo: do-find

++  look-contents
  |=  {player/@sd loc/@sd contents-name/tape}
  ^-  all:yint
  =/  can-see-loc/?  ?|
    !(~(is-dark yint-db db.a) loc)
    (~(controls yint-db db.a) player loc)
  ==
  =+  c=contents:(~(got yint-db db.a) loc)
  =/  things/(list @sd)  (~(enum yint-db db.a) c)
  =/  can-see-something/?
    %+  lien
      things
      |=(thing/@sd (~(can-see yint-db db.a) player thing can-see-loc))
  ?.  can-see-something
    a
  :: something exists! show them everything
  =.  a  (queue contents-name a)
  |-
  ?~  things
    a
  =.  a
    ?:  (~(can-see yint-db db.a) player i.things can-see-loc)
      (notify-name player i.things)
    a
  $(things t.things)

++  notify-name
  |=  {player/@sd thing/@sd}
  ^-  all:yint
  =+  n=(getname thing a)
  ~&  [%notify-name n]
  ?:  (~(controls yint-db db.a) player thing)
    =+  id=(print-ref thing)
    (queue-styx [[[~ ~ ~] n] [[~ ~ ~] "(#"] [[`%un ~ ~] id] [[~ ~ ~] ")"] ~] a)
  (queue n a)

++  look-simple
  |=  {player/@sd thing/@sd}
  ^-  all:yint
  =+  desc=description:(~(got yint-db db.a) thing)
  ?:  =("" desc)
    (queue-phrase 'see-nothing' a)
  (queue desc a)

++  flag-description
  |=  thing/@sd
  ^-  tape
  =+  type=(~(typeof yint-db db.a) thing)
  =/  type-tape
    ?:  =(type-room:yint type)
      (phrase 'type-room' a)
    ?:  =(type-exit:yint type)
      (phrase 'type-exit' a)
    ?:  =(type-thing:yint type)
      (phrase 'type-thing' a)
    ?:  =(type-player:yint type)
      (phrase 'type-player' a)
    (phrase 'type-unknown' a)
  =/  description  :(weld (phrase 'type' a) " " type-tape)
  ::  todo: all the type flags.
  description
--
