:: All methods for accessing, modifying and validating against the database.
::
:: This door corresponds to predicates.rb, db.rb, util.rb and parts of player.rb.
::
/-  yint
!:
|_  db/database:yint
::
:: db.rb
::


:: Returns an index to a newly allocated record.
++  add-new-record
  ^-  {@sd database:yint}
  =+  plusone=(sum:si next.db --1)
  :-  next.db
  %=  db
    records  (~(put by records.db) next.db (record:yint ~))
    next  plusone
  ==
++  got
  |=  i/@sd
  ^-  record:yint
  ?:  =(i nothing:yint)  ~|(%nothing !!)
  ?:  =(i ambiguous:yint)  ~|(%ambiguous !!)
  (~(got by records.db) i)
++  put
  |=  {i/@sd r/record:yint}
  ^-  database:yint
  :: Only allow setting already allocated records.
  ?>  (~(has by records.db) i)
  db(records (~(put by records.db) i r))
++  keys  ~(key by records.db)
++  gotname
  |=  i/@sd
  ^-  tape
  =+  r=(~(got by records.db) i)
  name.r
++  gotlocation
  |=  i/@sd
  ^-  @sd
  =+  r=(~(got by records.db) i)
  location.r
::
:: todo: ++length? (from db.rb)
:: todo: ++parse_dbref? (from db.rb)
:: todo: ++clear? (from db.rb)
::

++  next-line-as-tape
  |=  in/(list @t)
  ^-  {tape (list @t)}
  ?~  in  !!
  [(trip i.in) t.in]
++  next-line-as-sd
  |=  in/(list @t)
  ^-  {@sd (list @t)}
  ?~  in  !!
  :: it would be nice to be able to use ++rust for @sd even though the following catches
  :: more errors.
  =+  astxt=(trip i.in)
  ?:  =(astxt "-1")
    [nothing:yint t.in]
  ?:  =(astxt "-2")
    [ambiguous:yint t.in]
  ?:  =(astxt "-3")
    [home:yint t.in]
  :: todo: small.db has the void have pennies=-35. this needs a real implementation.
  [(sun:si (scan astxt dim:ag)) t.in]
++  next-line-as-ud
  |=  in/(list @t)
  ^-  {@ud (list @t)}
  ?~  in  !!
  =+  astxt=(trip i.in)
  [(scan astxt dim:ag) t.in]  
++  restore
  |=  in/(list @t)
  ^-  (unit database:yint)
  =+  maxid=0
  =+  db=(database:yint ~)
  =+  lines=in
  |-
  =^  l  lines  (next-line-as-tape lines)
  ?:  =(l "***END OF DUMP***")
    `db
  =+  newid=(rust l ;~(pfix hax dim:ag))
  ?~  newid
    ~&  [%badid]
    `db
  =^  name  lines  (next-line-as-tape lines)
  =^  description  lines  (next-line-as-tape lines)
  =^  location  lines  (next-line-as-sd lines)
  =^  contents  lines  (next-line-as-sd lines)
  =^  exits  lines  (next-line-as-sd lines)
  =^  next  lines  (next-line-as-sd lines)
  =^  key  lines  (next-line-as-sd lines)
  =^  fail  lines  (next-line-as-tape lines)
  =^  succ  lines  (next-line-as-tape lines)
  =^  ofail  lines  (next-line-as-tape lines)
  =^  osucc  lines  (next-line-as-tape lines)
  =^  owner  lines  (next-line-as-sd lines)
  =^  pennies  lines  (next-line-as-sd lines)
  =^  flags  lines  (next-line-as-ud lines)
  =^  password  lines  (next-line-as-tape lines)
  =+  r=(record:yint name description location contents exits next key fail succ ofail osucc owner pennies flags password)
  %=  $
    maxid  (max maxid (need newid))
    next.db  (sun:si (add 1 (max maxid (need newid))))
    records.db  (~(put by records.db) (sun:si (need newid)) r)
  ==

:::
:: utils.rb
:::

::  note: there's no find-if in the stdlib?
++  find-if
  |=  {a/(list @sd) b/$-(@sd ?)}
  |-
  ^-  (unit @sd)
  ?~  a
    ~
  ?:  (b i.a)
    (some i.a)
  $(a t.a)

::  Remove an item from a database record's next chain.
++  remove-first
  |=  {first/@sd what/@sd}
  ^-  {@sd database:yint}
  ?:  =(first what)
    [next:(got first) db]
  ::  Walk the chain from first until we find the item whose next reference is what.
  =+  before-what=(find-if (enum first) |=(a/@sd =(next:(got a) what)))
  ?~  before-what
    [first db]
  =+  what-next=next:(got what)
  =+  before-what-record=(got (need before-what))
  :-  first
  (put (need before-what) before-what-record(next what-next))

:::
:: player.rb
:::
++  find-impl
  |=  {a/(map @sd record:yint) p/$-(record:yint ?)}
  |-
  ^-  (unit @sd)
  ?~  a  ~
  ?:  (p q.n.a)  `p.n.a
  =+  lhs=$(a l.a)
  ?~  lhs
    =+  rhs=$(a r.a)
    ?~  rhs
      ~
    rhs
  lhs
:: Performs a depth first walk of the tree returning the first index to match
:: the passed in predicate. Returns ++nothing:yint if nothing matches.  
++  find-record
  |=  p/$-(record:yint ?)
  ^-  @sd
  =+  x=(find-impl records.db p)
  ?~  x  nothing:yint
  (need x)
++  lookup-player
  |=  name/tape
  ^-  @sd
  %-  find-record
    |=  a/record:yint
    ?&
      =((dis flags.a type-mask:yint) `@u`type-player:yint)
      =((cuss name.a) (cuss name))
    ==
++  create-player
  |=  {name/tape password/tape}
  ^-  {@sd database:yint}
  ?.  (ok-player-name name)
    [nothing:yint db]
  =^  index  db  add-new-record
  =+  player-start-record=(~(got by records.db) player-start:yint)
  =+  cur-start-contents=contents.player-start-record
  =/  r  %-  record:yint  :*
    name                :: name
    ""                  :: description
    player-start:yint   :: location
    nothing:yint        :: contents
    player-start:yint   :: exits
    cur-start-contents  :: next
    nothing:yint        :: key
    ""                  :: fail
    ""                  :: succ
    ""                  :: ofail
    ""                  :: osucc
    index               :: owner
    0                   :: pennies
    type-player:yint    :: type
    password            :: password
  ==
  =.  records.db  (~(put by records.db) index r)
  =+  new-player-start=player-start-record(contents index)
  =.  records.db  (~(put by records.db) player-start:yint new-player-start)
  [index db]
::
:: Helpers.rb
::

:: Enumerates a chain of records linked by next. in db.
++  enum
  |=  next/@sd
  ^-  (list @sd)
  =|  out/(list @sd)
  |-
  ?:  =(next -1)
    (flop out)
  =+  obj=(~(got by records.db) next)
  $(next next.obj, out [i=next t=out])

++  list-contains
  |=  {a/(list @sd) b/@sd}
  ^-  ?
  !=(~ (find (limo b ~) a))

:: todo: I was here yesterday. needed for could_doit, which is needed for can_doit,
:: needed for look.
::
++  member
  |=  {thing/@sd start/@sd}
  ^-  ?
  (list-contains (enum start) start)

:: Get the location name for a thing
++  getname
  |=  loc/@sd
  ^-  tape
  ::  todo: manual phrasebook looup below.
  ?:  =(loc nothing:yint)
    "loc-nothing"
  ?:  =(loc home:yint)
    "loc-home"
  name:(got loc)

++  masked-type
  |=  type/@u
  |=  i/@sd
  ^-  ?
  =+  a=(~(got by records.db) i)
  =((dis flags.a type-mask:yint) type)
++  has-bit
  |=  mask/@u
  |=  i/@sd
  ^-  ?
  =+  a=(~(got by records.db) i)
  !=((dis flags.a mask) 0)

++  is-antilock  (has-bit antilock:yint)
++  is-dark      (has-bit dark:yint)
++  is-link-ok   (has-bit link-ok:yint)
++  is-sticky    (has-bit sticky:yint)
++  is-temple    (has-bit temple:yint)
++  is-wizard    (has-bit wizard:yint)

++  is-exit      (masked-type type-exit:yint)
++  is-player    (masked-type type-player:yint)
++  is-room      (masked-type type-room:yint)
++  is-thing     (masked-type type-thing:yint)

++  typeof
  |=  i/@sd
  ^-  @u
  =+  a=(~(got by records.db) i)
  (dis flags.a type-mask:yint)

::
:: Predicates.rb
::

++  can-link-to
  |=  {who/@sd where/@sd}
  ^-  ?
  ?&
    (gte:si where 0)
    (lth:si where next.db)
    (is-room where)
    ?|((controls who where) (is-link-ok where))
  ==
++  could-doit
  |=  {who/@sd what/@sd}
  ^-  ?
  =+  what-record=(~(got by records.db) what)
  ?:  ?&(!(is-room what) =(location.what-record nothing:yint))
    %.n
  ?:  =(key.what-record nothing:yint)
    %.y
  =+  player-record=(~(got by records.db) who)
  =/  status/?  ?|(=(who key.what-record) (member key.what-record contents.player-record))
  ?:  (is-antilock what)
    !status
  status
++  can-see
  |=  {player/@sd thing/@sd can-see-loc/?}
  ^-  ?
  ?:  ?|(=(player thing) (is-exit thing))
    %.n
  ?:  can-see-loc
    ?|(!(is-dark thing) (controls player thing))
  (controls player thing)                           ::  can't see loc

++  controls
  |=  {who/@sd what/@sd}
  ^-  ?
  ?&
    (gte:si 0 what)
    (lth:si what next.db)
    ?|((is-wizard who) =(who owner:(~(got by records.db) what)))
  ==
++  payfor
  |=  {who/@sd cost/@ud}
  ^-  {? database:yint}
  ?:  (is-wizard who)
    [%.y db]
  =+  who-record=(got who)
  =+  pennies=pennies.who-record
  ?:  (gte pennies cost)
    =.  db  (put who who-record(pennies (sub pennies cost)))
    [%.y db]
  [%.n db]
++  ok-name
  |=  name/tape
  ^-  ?
  ?~  name  %.n
  ?:  =((lent name) 0)  %.n
  :: todo: null check for first character?
  :: todo: next checks are wrong, should be first char instead of equals
  ?:  =(i.name lookup-token:yint)  %.n
  ?:  =(i.name number-token:yint)  %.n
  ?:  =(name "me")  %.n
  ?:  =(name "home")  %.n
  ?:  =(name "here")  %.n
  %.y
++  ok-player-name
  |=  name/tape
  ^-  ?
  ?.  (ok-name name)  %.n
  :: todo: Ensure name only contains visible chracters.
  =((lookup-player name) nothing:yint)
--
