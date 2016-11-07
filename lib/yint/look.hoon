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
  ?:  =("" name)
    =+  p=(need player.a)
    =+  location=(~(gotlocation yint-db db.a) p)
    ?.  =(location nothing:yint)
      (look-room p location)
    a
  :: todo: this is mostly unimplemented. this core is going to be huge.
  a

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
--
