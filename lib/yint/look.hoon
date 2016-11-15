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
      =+  id=(scow %u (abs:si loc))
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
  =.  a  %^  left-fold  items  a
    |=  {item/@sd a/all:yint}
    (notify-name player item)
  (do-score player)

++  look-contents
  |=  {player/@sd loc/@sd contents-name/tape}
  ^-  all:yint
  =/  can-see-loc/?  ?|
    !(~(is-dark yint-db db.a) loc)
    (~(controls yint-db db.a) player loc)
  ==
  =+  c=contents:(~(got yint-db db.a) loc)
  =+  local-things=(~(enum yint-db db.a) c)
  =/  can-see-something/?
    %+  lien
      local-things
      |=(thing/@sd (~(can-see yint-db db.a) player thing can-see-loc))
  ?.  can-see-something
    a
  :: something exists! show them everything
  =.  a  (queue contents-name a)
  %^  left-fold  local-things  a
    |=  {thing/@sd a/all:yint}
    ?:  (~(can-see yint-db db.a) player thing can-see-loc)
      (notify-name player thing)
    a

++  notify-name
  |=  {player/@sd thing/@sd}
  ^-  all:yint
  =+  n=(~(getname yint-db db.a) thing)
  ?:  (~(controls yint-db db.a) player thing)
    =+  id=(scow %u (abs:si thing))
    (queue-styx [[[~ ~ ~] n] [[~ ~ ~] "(#"] [[`%un ~ ~] id] [[~ ~ ~] ")"] ~] a)
  (queue n a)

++  look-simple
  |=  {player/@sd thing/@sd}
  ^-  all:yint
  =+  desc=description:(~(got yint-db db.a) thing)
  ?:  =("" desc)
    (queue-phrase 'see-nothing' a)
  (queue desc a)
--
