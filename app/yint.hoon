::
::  super simple console app
::

/?    314
/-    yint
/+    sole, yint-create, yint-db, yint-look, yint-help, yint-move, yint-set, yint-speech, yint-util
=,  ^clay
=,  ^gall
=,  sole
=,  yint-util
=,  space:userlib
!:
|%
++  move  (pair bone card)                          ::  all actions
++  card
  $%  {$diff $sole-effect sole-effect}              ::  todo: more cards later
      {$info wire @p @tas nori}                     ::  write to fs
  ==
::  A list of all commands
++  command-entry
  $:  name/tape
      c/$-({a/all:yint c/command:yint} a/all:yint)
      full-match/?
  ==
++  commands
  =+  args={a/all:yint c/command:yint}
  ^-  (list command-entry)
  %-  limo  :~
     ["@chown" |=(args (~(do-chown yint-set a) (need player.a) arg1.c arg2.c)) %.n]
     ["@create" |=(args (~(do-create yint-create a) (need player.a) arg1.c arg2.c)) %.n]
     ["@describe" |=(args (~(do-describe yint-set a) (need player.a) arg1.c arg2.c)) %.n]
     ["@dig" |=(args (~(do-dig yint-create a) (need player.a) arg1.c)) %.n]
     ["drop" |=(args (~(do-drop yint-move a) (need player.a) arg1.c)) %.n]
     ["examine" |=(args (~(do-examine yint-look a) (need player.a) arg1.c)) %.n]
     ["@fail" |=(args (~(do-fail yint-set a) (need player.a) arg1.c arg2.c)) %.n]
     ["get" |=(args (~(do-get yint-move a) (need player.a) arg1.c)) %.n]
     ["goto" |=(args (~(do-move yint-move a) (need player.a) arg1.c)) %.n]
     ["help" |=(args (~(do-help yint-help a) (need player.a))) %.n]
     ["inventory" |=(args (~(do-inventory yint-look a) (need player.a))) %.n]
     ["@link" |=(args (~(do-link yint-create a) (need player.a) arg1.c arg2.c)) %.n]
     ["@lock" |=(args (~(do-lock yint-set a) (need player.a) arg1.c arg2.c)) %.n]
     ["look" |=(args (~(do-look-at yint-look a) arg1.c)) %.n]
     ["move" |=(args (~(do-move yint-move a) (need player.a) arg1.c)) %.n]
     ["@name" |=(args (~(do-name yint-set a) (need player.a) arg1.c arg2.c)) %.n]
     ["@ofail" |=(args (~(do-ofail yint-set a) (need player.a) arg1.c arg2.c)) %.n]
     ["@open" |=(args (~(do-open yint-create a) (need player.a) arg1.c arg2.c)) %.n]
     ["@osuccess" |=(args (~(do-osuccess yint-set a) (need player.a) arg1.c arg2.c)) %.n]
     ::  Deviates from TinyMUD: the command there is QUIT.
     ["quit" |=(args (do-quit a)) %.y]
     ["read" |=(args (~(do-look-at yint-look a) arg1.c)) %.n]
     ["say" |=(args (~(do-say yint-speech a) (need player.a) arg1.c arg2.c)) %.n]
     ["score" |=(args (~(do-score yint-look a) (need player.a))) %.n]
     ["@success" |=(args (~(do-success yint-set a) (need player.a) arg1.c arg2.c)) %.n]
     ["take" |=(args (~(do-get yint-move a) (need player.a) arg1.c)) %.n]
     ["throw" |=(args (~(do-drop yint-move a) (need player.a) arg1.c)) %.n]
     ["@unlink" |=(args (~(do-unlink yint-set a) (need player.a) arg1.c)) %.n]
     ["@unlock" |=(args (~(do-unlock yint-set a) (need player.a) arg1.c)) %.n]
  ==
:: A door which takes a
++  user-state
  |_  a/all:yint
  :: Parses a command into a 3-tuple. The command goes in command/ and usually
  :: the rest is placed into arg1/. For commands which take an x=y argument, x
  :: is set to arg1/ and y to arg2/.
  ++  parse-command
    :: TODO: Strip leading and trailing whitespace.
    |=  in/tape
    ^-  command:yint
    =+  f=(find " " in)
    ?~  f
      [in "" ""]
    =+  lhs=(trim (need f) in)
    =+  command=p.lhs
    =+  rhs=(trim (add 1 (need f)) in)
    =+  equals=(find "=" q.rhs)
    ?~  equals
      [command q.rhs ""]
    =+  arg1=(trim (need equals) q.rhs)
    =+  arg2=(trim (add 1 (need equals)) q.rhs)
    [command p.arg1 q.arg2]
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
      (~(do-say yint-speech a) (need player.a) t.in ~)
    ?:  =(':' i.in)
      (~(do-pose yint-speech a) (need player.a) t.in ~)    
    ?:  (~(can-move yint-move a) (need player.a) in)
      (~(do-move yint-move a) (need player.a) in)
    =+  parsed=(parse-command in)
    ::  Make a list of candidates that start with the types command (case insensitive)
    =+  lower-command=(cass command.parsed)
    =+  matcher=|=(e/command-entry =([~ 0] (find lower-command name.e)))
    =/  candidates/(list command-entry)  (skim commands matcher)
    ?~  candidates
      (queue-phrase 'huh' a)
    ::  We should only have one candidate; otherwise the player input is ambigious.
    ?.  =(1 (lent candidates))
      (queue-phrase 'huh' a)
    ::  Some commands are so dangerous that they require the whole thing typed exactly.
    ?.  ?|(!full-match.i.candidates =(name.i.candidates lower-command))
      (queue-phrase 'huh' a)
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
        =.  a  (queue-phrase 'create-fail' a)
        =.  a  (log "FAILED CREATE {<arg1.parsed>} from {<src.a>}" a)
        a
      =.  a  (log "CREATED {<arg1.parsed>}({<id>}) from {<src.a>}" a)
      (~(process-line user-state a(player `id)) "look")
    ?:  =("connect" command.parsed)
      =+  id=(connect-player arg1.parsed arg2.parsed)
      ?:  =(id nothing:yint)
        =.  a  (queue-phrase 'connect-fail' a)
        =.  a  (log "FAILED CONNECT {<arg1.parsed>} from {<src.a>}" a)
        a
      =.  a  (log "CONNECTED {<arg1.parsed>}({<id>}) from {<src.a>}" a)
      (~(process-line user-state a(player `id)) "look")
    (queue-phrase 'welcome-message' a)
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
++  build-notification
  |=  {p/@sd q/(list sole-effect:sole)}
  ^-  (list move)
  =+  b=(~(get by player-out.w) p)                  ::  ensure player logged in
  ?~  b
    ~
  [i=[(need b) %diff %sole-effect mor+q] t=~]
++  make-notification-list
  |=  a/(map @sd (list sole-effect:sole))
  ^-  (list move)
  =|  out/(list move)
  ?~  a
    ~
  :(welp (build-notification p.n.a q.n.a) (make-notification-list l.a) (make-notification-list r.a))
  
::
::  Part X: The low level urbit interface stuff. This is mostly based off of
::  ~master-morzod's minimal sole app skeleton, with enough modifications to
::  get saving a buffer hacked in by me. Any stupidity below is entirely my
::  fault.
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
      =+  num=(~(raw og eny.bow) 0xff)
      =+  all=(all:yint w [src.bow player-id num ~])
      =.  all
        ?~  player-id
          (~(process-line login-state all) command)
        (~(process-line user-state all) command)
      :: Update world state
      =.  w  (update-world player-id all)
      =+  msgs=[i=(prompt-for ost.bow) t=(flop messages.all)]
      =+  notifications=(make-notification-list notifications.all)
      :: todo: syslog should go to a local talk channel?
      =+  todo-syslog=(turn (flop syslog.all) |=(m/tape ~&([%log m] 0)))
      ::  Maintain the typing state.
      =/  som  (~(got by sos) ost.bow)
      =^  det  som  (~(transmit sole som) set+~)
      =.  sos  (~(put by sos) ost.bow som)
      :_  +>.$
      [i=[ost.bow %diff %sole-effect mor+[det+det msgs]] t=notifications]
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
::  Load 
++  poke-yint-load-phrases
  |=  arg/path
  ^-  {(list move) _+>.$}
  =,  dejs:format
  =/  j  .^(json %cx arg)
  =+  parsed=((om sa) j)
  :: todo: write something to the syslog instead of the console.
  ~&  [%loaded-phrases]
  [~ +>.$(phrases.w parsed)]
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
++  poke-yint-export
  |=  man/knot
  ^-  {(list move) _+>.$}
  =/  paf/path  /(scot %p our.bow)/home/(scot %da now.bow)/yint/[man]/txt
  =/  data/wall  ~(serialize yint-db db.w)
  =+  to=(foal paf [%txt !>((turn data crip))])
  [[ost.bow %info /jamfile our.bow to]~ +>.$]
--
