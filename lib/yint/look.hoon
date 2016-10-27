:: All methods for looking.
::
:: This door corresponds to look.rb.
::
/-  yint
/+  yint-db, yint-util
[. yint-util]
!:
|_  a/all:yint
++  look-room
  |=  {player/@sd loc/@sd}
  ^-  all:yint
  =+  record=(~(got yint-db db.a) loc)
  =.  a
    ?:  (~(can-link-to yint-db db.a) player loc)
        (queue "{<name.record>} ({<loc>})" a)
      (queue "{<name.record>}" a)
  =.  a
    ?:  =("" description.record)
      a
    (queue description.record a)
  :: todo: need to deal with can_doit.
  a

++  do-look-at
  |=  name/tape
  :: todo: this is mostly unimplemented. this core is going to be huge.
  (look-room (need player.a) (~(gotlocation yint-db db.a) (need player.a)))
--
