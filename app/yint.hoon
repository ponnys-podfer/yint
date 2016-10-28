::
::  super simple console app
::

/?    314
/-    yint
/+    sole, yint-db, yint-look, yint-util
[. sole yint-util]
!:
|%
++  move  (pair bone card)                          ::  all actions
++  card
  $%  {$diff $sole-effect sole-effect}              ::  todo: more cards later
  ==
::  A list of all commands
++  command-entry  {name/tape c/$-({a/all:yint c/command:yint} a/all:yint) full-match/?}
++  commands
  =+  args={a/all:yint c/command:yint}
  ^-  (list command-entry)
  %-  limo  :~
::     ["examine" |=(args (~(do-look-at yint-look a) arg1.c)) %.n]
     ["look" |=(args (~(do-look-at yint-look a) arg1.c)) %.n]
  ==
:: A door which takes a
++  user-state
  |_  a/all:yint
  :: Parses a command into a 3-tuple. The command goes in command/ and usually
  :: the rest is placed into arg1/. For commands which take an x=y argument, x
  :: is set to arg1/ and y to arg2/.
  ::
  :: todo: double check for extra spaces. i may be a moron like in login.
  ++  parse-command
    :: TODO: Strip leading and trailing whitespace.
    |=  in/tape
    ^-  command:yint
    =+  f=(find " " in)
    ?~  f
      [in "" ""]
    =+  s=(trim (need f) in)
    =+  command=p.s
    =+  equals=(find "=" q.s)
    ?~  equals
      [command q.s ""]
    =+  arg1=(trim (need equals) q.s)
    =+  arg2=(trim (add 1 (need equals)) q.s)
    [command p.arg1 q.arg2]
  ::  cass for some reason also crips the tape.
  ++  tolower
    |=  vib/tape
    ^-  tape
    (turn vib |=(a/@ ?.(&((gte a 'A') (lte a 'Z')) a (add 32 a))))
  ++  process-line
    |=  in/tape
    ^-  all:yint
    =.  a  (queue-styx [[[`%br ~ ~] "> "] [[~ ~ ~] in] ~] a)
    :: TODO: eat leading/trailing whitespace on |in|.
    ?~  in
      (queue "huh? (null)" a)
    ?:  =(0 (lent in))
      (queue "huh? (empty" a)
    ?:  =('"' i.in)
      (queue "do_say: {<in>}" a)    :: todo: write say.
    ?:  =(':' i.in)
      (queue "do_pose: {<in>}" a)   :: todo: write pose.
    :: TODO: Check movement.
    =+  parsed=(parse-command in)
    ::  Make a list of candidates that start with the types command (case insensitive)
    =+  lower-command=(tolower command.parsed)
    =+  matcher=|=(e/command-entry =([~ 0] (find lower-command name.e)))
    =/  candidates/(list command-entry)  (skim commands matcher)
    ?~  candidates
      (queue "huh" a)
    ::  We should only have one candidate; otherwise the player input is ambigious.
    ?.  =(1 (lent candidates))
      (queue "huh" a)
    ::  Some commands are so dangerous that they require the whole thing typed exactly.
    ?.  ?|(!full-match.i.candidates =(name.i.candidates lower-command))
      (queue "huh" a)
    (c.i.candidates a parsed)
  --
:: A door which takes a 
++  login-state
  |_  a/all:yint

  :: Parses a line into a triple.
  :: todo: this can be replaced by split when there's a string library.
  ++  parse-line
    |=  in/tape
    ^-  command:yint
    =+  f=(find " " in)
    ?~  f
      :: one word commands are fine at the login prompt
      [in "" ""]
    =+  lhs=(trim (need f) in)
    =+  command=p.lhs
    =+  rhs=(trim (add 1 (need f)) in)
    =+  equals=(find " " q.rhs)
    ?~  equals
      :: only a single argument is a syntax error
      ["" "" ""]
    =+  arg1=(trim (need equals) q.rhs)
    =+  arg2=(trim (add 1 (need equals)) q.rhs)
    [command p.arg1 q.arg2]
  :: Returns a player id if name/password valid.
  ++  connect-player
    |=  {name/tape password/tape}
    ^-  @sd
    =+  player-id=(~(lookup-player yint-db db.a) name)
    ?:  =(player-id nothing:yint)
      nothing:yint
    =+  player-record=(~(got yint-db db.a) player-id)
    ?:  =(password password.player-record)
      player-id
    nothing:yint
  :: Main entrypoint for processing lines when the user is not logged in.
  ++  process-line
    |=  in/tape
    ^-  all:yint
    =+  parsed=(parse-line in)
    ?:  =("create" command.parsed)
      =^  id  db.a  (~(create-player yint-db db.a) arg1.parsed arg2.parsed)
      ?:  =(id nothing:yint)
        =.  a  (queue "create-fail" a)
        =.  a  (log "FAILED CREATE {<arg1.parsed>} from {<src.a>}" a)
        a
      =.  a  (log "CREATED {<arg1.parsed>}({<id>}) from {<src.a>}" a)
      (~(process-line user-state a(player `id)) "look")
    ?:  =("connect" command.parsed)
      =+  id=(connect-player arg1.parsed arg2.parsed)
      ?:  =(id nothing:yint)
        =.  a  (queue "connect-fail" a)
        =.  a  (log "FAILED CONNECT {<arg1.parsed>} from {<src.a>}" a)
        a
      =.  a  (log "CONNECTED {<arg1.parsed>}({<id>}) from {<src.a>}" a)
      (~(process-line user-state a(player `id)) "look")
    (queue "phrase: welcome-message" a)
  --
--
|_  $:  bow/bowl
        :: terminal information for |link
        sos/(map bone sole-share)
        w/world:yint
    ==
++  prompt-for
  |=  p/bone
  ^-  sole-effect
  =+  x=(~(get by logged-in.w) p)
  ?~  x
    :: first run through the main loop.
    [%pro [& %test "(login)> "]]
  =+  id=(need x)
  ?~  id
    :: not logged in
    [%pro [& %test "(login)> "]]
  =+  player-record=(~(got yint-db db.w) (need id))
  [%pro [& %test [[[~ ~ ~] "("] [[`%un ~ ~] name.player-record] [[~ ~ ~] ")> "] ~]]]
:: Called after a process line to change the login state.
++  update-world
  |=  {old-id/(unit @sd) a/all:yint}
  ^-  world:yint
  ?~  old-id
    ?~  player.a
      -.a                  :: no change
    %=  -.a                :: player logged in
      logged-in  (~(put by logged-in.-.a) ost.bow player.a)
      player-out  (~(put by player-out.-.a) (need player.a) ost.bow)
    ==
  ?~  player.a
    %=  -.a                :: player logged out
      logged-in  (~(put by logged-in.-.a) ost.bow ~)
      player-out  (~(del by player-out.-.a) (need old-id))
    ==
  :: todo: assert that we didn't change player ids.
  -.a      :: no change
::
::  Part X: The low level urbit interface stuff. This is mostly based off of
::  ~master-morzod's minimal sole app skeleton, with enough modifications to
::  get saving a buffer hacked in by me. Any stupidity below is entirely my
::  fault.
::
++  poke
  |=  *
  ^-  {(list move) _+>.$}
  =+  ost=p.,:(head (prey /sole bow))
  [[ost %diff %sole-effect %txt "foo"]~ +>.$]
::
++  poke-sole-action
  |=  act/sole-action
  ^-  {(list move) _+>.$}
  =/  som  (~(got by sos) ost.bow)
  ?-  act
    {$det *}
      :: Minimal parsing to get a command in the buffer.
      =^  inv  som  (~(transceive sole som) +.act)
      =.  sos  (~(put by sos) ost.bow som)
      [[~] +>.$]
    {$ret *}
      =+  command=(tufa buf.som)
      =+  player-id=(~(got by logged-in.w) ost.bow)
      =+  all=(all:yint w [src.bow player-id ~])
      =.  all
        ?~  player-id
          (~(process-line login-state all) command)
        (~(process-line user-state all) command)
      :: Update world state
      =.  w  (update-world player-id all)
      :: todo: should echo the types command.
      =+  msgs=[i=(prompt-for ost.bow) t=(flop messages.all)]
      :: todo: syslog should go to a local talk channel?
      =+  todo-syslog=(turn (flop syslog.all) |=(m/tape ~&([%log m] 0)))
      (transmit set+~ msgs)
    {$clr *}
      [[[ost.bow %diff %sole-effect [%mor ~]] ~] +>.$]
  ==
++  coup
  |=  {way/wire saw/(unit tang)}
  ^-  {(list move) _+>.$}
  [~ +>.$]
::
++  peer
  |=  *
  ^-  {(list move) _+>.$}
  =+  wel=[%txt "Welcome to Yint MUD"]
  =+  toconnect=[%txt "To connect to your existing character, enter \"connect name password\""]
  =+  tocreate=[%txt "To create a new character, enter \"create name password\""]
  :_
    %=  +>.$
      sos  (~(put by sos) ost.bow *sole-share)
      logged-in.w  (~(put by logged-in.w) ost.bow ~)
    ==
  [ost.bow %diff %sole-effect %mor ~[(prompt-for ost.bow) wel toconnect tocreate]]~
++  pull
  |=  *
  ^-  {(list move) _+>.$}
  :: todo: add syslog messages for logout. (see player_quit() in session.rb)
  =+  player-id=(~(got by logged-in.w) ost.bow)
  :-  ~
  %=  +>.$
    sos  (~(del by sos) ost.bow)
    logged-in.w  (~(del by logged-in.w) ost.bow)
    player-out.w  ?~  player-id
      player-out.w
      (~(del by player-out.w) (need player-id))
  ==
++  poke-yint-import
  |=  arg/path
  ^-  {(list move) _+>.$}
  =/  lines  .^(wain %cx arg)
  =+  mydb=(~(restore yint-db db.w) lines)
  ?~  mydb
    ~&  [%failed-to-load]
    [~ +>.$]
  ::  null out the character id of all logged-in users.
  =.  logged-in.w  (~(run by logged-in.w) |=(* ~))
  ::  grab all the active bones and reset it in the world state.
  =+  bones=(~(tap by player-out.w))
  =.  player-out.w  ~
  :: todo: write something to the syslog instead of the console.
  ~&  [%reboot-world]
  :_  +>.$(db.w (need mydb))
  ::  turn our list of logged in players into a set of log out messages to
  ::  those players.
  %+  turn
    bones
    |=  {a/* b/bone}
    :*
      b
      %diff
      %sole-effect
      %mor
      :~
        (prompt-for b)
        [%klr [[[`%br ~ `%r] "World being imported. Logging off..."] ~]]
      ==
    ==
++  effect  |=(fec/sole-effect [ost.bow %diff %sole-effect fec])
++  transmit
  |=  {inv/sole-edit mor/(list sole-effect)}
  =/  som  (~(got by sos) ost.bow)
  =^  det  som  (~(transmit sole som) inv)
  =.  sos  (~(put by sos) ost.bow som)
  [[(effect mor+[det+det mor])]~ +>.$]
--
