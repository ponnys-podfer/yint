:: A fairly mechanical translation of the matcher in MangledMUD/TinyMUD. While
:: other code in yint is content to differ from the original source in tiny
:: ways, the matcher is really subtle, and as such this is a fairly literal
:: translation of the code; I suspect this is even worse hoon than I usually
:: write.
::
:: I really feel like I'm fighting the language here. Hypothesis: I'm trying to
:: literally translate data structures that were optimized for raw C (embeded
:: index based linked lists) to a functional language with no arrays (so all
:: indexed lookup is O(log n) instead of O(1)).
::
/-  yint
/+  yint-db, yint-util
[. yint-util]
!:
|%
++  matcher-instance
  $:  a/all:yint
      exact-match/@sd
      last-match/@sd
      match-count/@ud
      match-who/@sd
      match-name/tape
      check-keys/?
      preferred-type/@u
  ==
::  ++roll is confusing. I don't see how I'm supposed to pass the initial
::  value of the accumulator, so I can't do (roll list m gate). And what's
::  a ' _|= '?
++  m-left-fold
  |*  $:  a/(list)
          state/matcher-instance
          b/$-({* matcher-instance} matcher-instance)
      ==
  ?~  a
    state
  $(a t.a, state (b i.a state))
::  "Constructor" for the matcher.
++  init
  |=  {a/all:yint player/@sd name/tape type/@u}
  ^-  matcher-instance
  [a nothing:yint nothing:yint 0 player name %.n type]
--
|_  m/matcher-instance
++  match-player
  ^-  matcher-instance
  ?~  match-name.m
    m
  ?.  =(i.match-name.m lookup-token:yint)
    m
  =^  can-afford  db.a.m  (~(payfor yint-db db.a.m) match-who.m lookup-cost:yint)
  ?.  can-afford
    m
  =+  player-id=(~(lookup-player yint-db db.a.m) q:(trim 1 match-name.m))
  ?:  =(player-id nothing:yint)
    m
  m(exact-match player-id)
::  Match by absolute name; ie by a numeric database identifier.
++  match-absolute
  ^-  matcher-instance
  =+  match=absolute-name
  ?:  =(match nothing:yint)
    m
  m(exact-match match)
++  match-me
  ^-  matcher-instance
  ?~  match-name.m
    m
  ?.  =(match-name.m "me")
    m
  m(exact-match match-who.m)

++  match-here
  ^-  matcher-instance
  ?~  match-name.m
    m
  ?.  =(match-name.m "here")
    m
  ~&  [%considering match-name.m]
  =+  loc=location:(~(got yint-db db.a.m) match-who.m)
  ?:  =(loc nothing:yint)
    m
  m(exact-match loc)

++  match-possession
  ^-  matcher-instance
  (match-list contents:(~(got yint-db db.a.m) match-who.m))  

++  match-neighbor
  ^-  matcher-instance
  =+  loc=(~(gotlocation yint-db db.a.m) match-who.m)
  ?:  =(loc nothing:yint)
    m
  (match-list contents:(~(got yint-db db.a.m) loc))

::
++  match-exit
  ^-  matcher-instance
  =+  loc=(~(gotlocation yint-db db.a.m) match-who.m)
  ?:  =(loc nothing:yint)
    m
  =+  a-n=absolute-name
  =/  absolute/@sd
    ?:  (~(controls yint-db db.a.m) match-who.m a-n)
      a-n
    nothing:yint
  =+  loc-record=(~(got yint-db db.a.m) loc)
  =+  l=(~(enum yint-db db.a.m) exits.loc-record)
  %^  m-left-fold  l  m
    |=  {exit/@sd m/matcher-instance}
    ^-  matcher-instance
    ?:  =(exit absolute)
      m(exact-match exit)
    ?:  =(match-name.m "")
      m
    =+  exit-tape=name:(~(got yint-db db.a.m) exit)
    =+  tokens=(tokenize:yint-util exit-delimeter:yint exit-tape)
    %^  m-left-fold  tokens  m
      |=  {token/tape m/matcher-instance}
      ^-  matcher-instance
      ::  todo: strip.
      ?.  (lower-starts-with:yint-util match-name.m token)
        m
      =.  match-count.m
        ?:  check-keys.m
          ?:  (~(could-doit yint-db db.a.m) match-who.m exit)
            (add 1 match-count.m)
          match-count.m
        (add 1 match-count.m)
      ?:  =(match-name.m token)
        m(exact-match (choose-thing exact-match.m exit))
      m

++  match-result
  ^-  @sd
  ?.  =(exact-match.m nothing:yint)
    exact-match.m
  ?:  =(match-count.m 0)
    nothing:yint
  ?:  =(match-count.m 1)
    last-match.m
  ambiguous:yint

++  last-match-result
  ^-  @sd
  ?.  =(exact-match.m nothing:yint)
    exact-match.m
  last-match.m

++  noisy-match-result
  ^-  {@sd all:yint}
  ::  get grass fails?
  ~&  :*  %noisy-result
          exact-match.m
          last-match.m 
          match-count.m
          match-who.m
          match-name.m
          check-keys.m
          preferred-type.m
      ==
  =+  r=match-result
  ?:  =(r nothing:yint)
    :-  nothing:yint
    (queue-phrase 'dont-see-that' a.m)
  ?:  =(r ambiguous:yint)
    :-  nothing:yint
    (queue-phrase 'which-one' a.m)  
  [r a.m]

::::::::::::: "Private"

++  absolute-name
  ^-  @sd
  ?~  match-name.m
    nothing:yint
  ?.  =(i.match-name.m number-token:yint)
    nothing:yint
  (parse-dbref:yint-util t.match-name.m)


++  match-list
  |=  first/@sd
  =+  a-n=absolute-name
  =/  absolute/@sd
    ?:  (~(controls yint-db db.a.m) match-who.m a-n)
      a-n
    nothing:yint
  =+  l=(~(enum yint-db db.a.m) first)
  %^  m-left-fold  l  m
    |=  {i/@sd m/matcher-instance}
    ^-  matcher-instance
    ?:  =(i absolute)
      m(exact-match i)
    ?~  match-name.m
      m
::    ~&  [%checking name:(~(got yint-db db.a.m) i)]
    ?:  =(name:(~(got yint-db db.a.m) i) match-name.m)
      m(exact-match (choose-thing exact-match.m i))
    :: todo: final else case is hard; need regexps or a custom space chomper.
    m

:: Given a choice of two things, pick one of them (one or both things may be
:: nothing:yint)
++  choose-thing
  |=  {thing1/@sd thing2/@sd}
  ^-  @sd
  ?:  =(thing1 nothing:yint)
    thing2
  ?:  =(thing2 nothing:yint)
    thing1
  ::  note: this construct seems really bad; is there a much easier way to handle
  ::  ratsnests of nested ifs in hoon?
  ?:  !=(preferred-type.m notype:yint)
    ?:  =((~(typeof yint-db db.a.m) thing1) preferred-type.m)
      ?:  =((~(typeof yint-db db.a.m) thing2) preferred-type.m)
        (choose-thing-part-2 thing1 thing2)
      thing1
    ?:  =((~(typeof yint-db db.a.m) thing2) preferred-type.m)
      thing2
    (choose-thing-part-2 thing1 thing2)
  (choose-thing-part-2 thing1 thing2)

++  choose-thing-part-2
  |=  {thing1/@sd thing2/@sd}
  ^-  @sd
  ?:  check-keys.m
    =+  has1=(~(could-doit yint-db db.a.m) match-who.m thing1)
    =+  has2=(~(could-doit yint-db db.a.m) match-who.m thing2)
    ?:  ?&(has1 !has2)
      thing1
    ?:  ?&(has2 !has1)
      thing2
    (choose-thing-part-3 thing1 thing2)
  (choose-thing-part-3 thing1 thing2)

++  choose-thing-part-3
  |=  {thing1/@sd thing2/@sd}
  ^-  @sd
  ?:  =(0 (mod rng.a.m 2))
    thing1
  thing2
--
