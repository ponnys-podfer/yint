::
:: This door corresponds to create.rb.
::
/-  yint
/+  yint-all, yint-db, yint-match, yint-util
=,  yint-util
!:
|_  a/all:yint

++  do-name
  |=  {player/@sd name/tape newname/tape}
  ^-  all:yint
  =^  thing  a  (match-controlled player name)
  ?:  =(thing nothing:yint)
    a
  ?~  newname
    (queue-phrase 'what-name' a)
  ?:  =(newname "")
    (queue-phrase 'what-name' a)
  ?:  (~(is-player yint-db db.a) thing)
    (impl-name-player thing player newname)
  (impl-name-thing thing player name newname)

++  impl-name-player
  |=  {thing/@sd player/@sd unparsed/tape}
  ^-  all:yint
  =+  f=(find " " unparsed)
  ?~  f
    =.  a  (queue-phrase 'specify-a-password' a)
    (queue-phrase 'help-player-password' a)
  ::  note: the original allowed multiple spaces.
  =+  newname=p:(trim (need f) unparsed)
  =+  password=q:(trim (add 1 (need f)) unparsed)
  ?.  =(password password:(~(got yint-db db.a) thing))
    (queue-phrase 'bad-password' a)
  ?.  (~(ok-name yint-db db.a) newname)
    (queue-phrase 'bad-player-name' a)
  =^  can-pay  db.a  (~(payfor yint-db db.a) player lookup-cost:yint)
  ?.  can-pay
    (queue-phrase 'bad-player-name' a)
  =.  a  (~(name-set yint-all a) thing newname)
  (queue-phrase 'name-set' a)

++  impl-name-thing
  |=  {thing/@sd player/@sd name/tape newname/tape}
  ^-  all:yint
  ?.  (~(ok-name yint-db db.a) newname)
    (queue-phrase 'not-a-reasonable-name' a)
  =.  a  (~(name-set yint-all a) thing newname)
  (queue-phrase 'name-set' a)

++  do-describe
  |=  {player/@sd name/tape description/tape}
  ^-  all:yint
  =^  thing  a  (match-controlled player name)
  ?:  =(thing nothing:yint)
    a
  =.  a  (~(description-set yint-all a) thing description)
  (queue-phrase 'desc-set' a)

++  do-fail
  |=  {player/@sd name/tape msg/tape}
  ^-  all:yint
  =^  thing  a  (match-controlled player name)
  ?:  =(thing nothing:yint)
    a
  =.  a  (~(fail-set yint-all a) thing msg)
  (queue-phrase 'message-set' a)

++  do-success
  |=  {player/@sd name/tape msg/tape}
  ^-  all:yint
  =^  thing  a  (match-controlled player name)
  ?:  =(thing nothing:yint)
    a
  =.  a  (~(success-set yint-all a) thing msg)
  (queue-phrase 'message-set' a)

++  do-osuccess
  |=  {player/@sd name/tape msg/tape}
  ^-  all:yint
  =^  thing  a  (match-controlled player name)
  ?:  =(thing nothing:yint)
    a
  =.  a  (~(osuccess-set yint-all a) thing msg)
  (queue-phrase 'message-set' a)

++  do-ofail
  |=  {player/@sd name/tape msg/tape}
  ^-  all:yint
  =^  thing  a  (match-controlled player name)
  ?:  =(thing nothing:yint)
    a
  =.  a  (~(ofail-set yint-all a) thing msg)
  (queue-phrase 'message-set' a)

::  todo: ++do-lock

++  do-lock
  |=  {player/@sd name/tape keyname/tape}
  ^-  all:yint
  =+  matcher=(init:yint-match a player name notype:yint)
  =.  matcher  ~(match-everything yint-match matcher)
  =+  thing=~(match-result yint-match matcher)
  ?:  =(thing nothing:yint)
    (queue-phrase 'dont-see-lock' a)
  ?:  =(thing ambiguous:yint)
    (queue-phrase 'which-one-lock' a)
  ?.  (~(controls yint-db db.a) player thing)
    (queue-phrase 'bad-lock' a)
  ::  this slighly deviates from MangledMUD; we're doing an extra check here to
  ::  simplify an if block.
  ?~  keyname
    (queue-phrase 'no-key' a)
  ?:  =(keyname "")
    (queue-phrase 'no-key' a)
  =/  antilock/?  =(i.keyname not-token:yint)
  ::  todo: why do we have to shadow this for the type system ehre?
  =/  keyname/tape
    ?.  antilock
      keyname
    q:(trim 1 keyname)

  =+  key-match=(init:yint-match a player keyname type-thing:yint)
  =.  key-match  ~(match-neighbor yint-match key-match)
  =.  key-match  ~(match-possession yint-match key-match)
  =.  key-match  ~(match-me yint-match key-match)
  =.  key-match  ~(match-player yint-match key-match)
  =.  key-match
    ?.  (~(is-wizard yint-db db.a) player)
      key-match
    ~(match-absolute yint-match key-match)
  =+  key=~(match-result yint-match key-match)

  ?:  =(key nothing:yint)
    (queue-phrase 'no-key' a)
  ?:  =(key ambiguous:yint)
    (queue-phrase 'which-key' a)
  ?:  ?&  !(~(is-player yint-db db.a) key)
          !(~(is-thing yint-db db.a) key)
      ==
    (queue-phrase 'bad-key-link' a)

  ::  everything ok, do it
  =.  a  (~(key-set yint-all a) thing key)
  ?:  antilock
    =.  a  (~(flag-set yint-all a) thing antilock:yint)
    (queue-phrase 'anti-locked' a)
  =.  a  (~(flag-unset yint-all a) thing antilock:yint)
  (queue-phrase 'locked' a)

++  do-unlock
  |=  {player/@sd name/tape}
  ^-  all:yint
  =^  thing  a  (match-controlled player name)
  ?:  =(thing nothing:yint)
    a
  =.  a  (~(key-set yint-all a) thing nothing:yint)
  =.  a  (~(flag-unset yint-all a) thing antilock:yint)
  (queue-phrase 'unlocked' a)

::  todo: ++do-unlink

++  do-unlink
  |=  {player/@sd name/tape}
  ^-  all:yint
  =+  matcher=(init:yint-match a player name type-thing:yint)
  =.  matcher  ~(match-exit yint-match matcher)
  =.  matcher  ~(match-here yint-match matcher)
  =?  matcher  (~(is-wizard yint-db db.a) player)
    ~(match-absolute yint-match matcher)
  =+  exit=~(match-result yint-match matcher)

  ?:  =(exit nothing:yint)
    (queue-phrase 'unlink-what' a)
  ?:  =(exit ambiguous:yint)
    (queue-phrase 'which-one' a)
  ?.  (~(controls yint-db db.a) player exit)
    (queue-phrase 'no-permission' a)

  =+  type=(~(typeof yint-db db.a) exit)
  ?:  =(type type-exit:yint)
    =.  a  (~(location-set yint-all a) exit nothing:yint)
    (queue-phrase 'unlinked' a)
  ?:  =(type type-room:yint)
    =.  a  (~(location-set yint-all a) exit nothing:yint)
    (queue-phrase 'drop-to-removed' a)
  (queue-phrase 'cant-unlink-that' a)

++  do-chown
  |=  {player/@sd name/tape new-owner/tape}
  ^-  all:yint
  ~&  [%do-chown name new-owner]
  ?.  (~(is-wizard yint-db db.a) player)
    (queue-phrase 'no-permission' a)
  =+  matcher=(init:yint-match a player name notype:yint)
  =.  matcher  ~(match-everything yint-match matcher)
  =^  thing  a  ~(noisy-match-result yint-match matcher)
  ?:  =(thing nothing:yint)
    a
  =+  owner=(~(lookup-player yint-db db.a) new-owner)
  ?:  =(owner nothing:yint)
    (queue-phrase 'no-player' a)
  ?:  (~(is-player yint-db db.a) thing)
    (queue-phrase 'own-self' a)
  =.  a  (~(owner-set yint-all a) thing owner)
  (queue-phrase 'owner-changed' a)

::  todo: ++do-set

++  match-controlled
  |=  {player/@sd name/tape}
  ^-  {@sd all:yint}
  =+  matcher=(init:yint-match a player name type-exit:yint)
  =.  matcher  ~(match-everything yint-match matcher)
  =^  match  a  ~(noisy-match-result yint-match matcher)
  ?:  ?&  !=(match nothing:yint)
          !(~(controls yint-db db.a) player match)
      ==
    =.  a  (queue-phrase 'no-permission' a)
    [nothing:yint a]
  [match a]
--
