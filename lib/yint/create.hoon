::
:: This door corresponds to create.rb.
::
/-  yint
/+  yint-all, yint-db, yint-match, yint-util
[[. yint-util] match=yint-match]
!:
|_  a/all:yint

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
  =.  db.a  (~(put yint-db db.a) index r)
  =.  a  (~(contents-set yint-all a) player index)
  (queue-phrase 'created' a)

++  endow
  |=  cost/@ud
  ^-  @ud
  %+  div
    (sub cost endowment-calculator:yint)
    endowment-calculator:yint
--