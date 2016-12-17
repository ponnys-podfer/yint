::  common utilities used everywhere
/-  yint
/+  yint-db
=,  zuse
!:
|%
::  Add an entry to the system log.
++  log
  |=  {msg/tape a/all:yint}
  ^-  all:yint
  a(syslog [i=msg t=syslog.a])
::
++  phrase
  |=  {p/@t a/all:yint}
  ^-  tape
  (~(got by phrases.a) p)
::
++  phrase-with
  |=  {p/@t args/(list tape) a/all:yint}
  ^-  tape
  =+  txt=(phrase p a)
  |-
  ?~  args
    txt
  :: Find the next '%s' in the
  =+  pos=(find "%s" txt)
  ?~  pos
    ~&  [%bad-format-string txt args]
    txt
  =+  lhs=p:(trim (need pos) txt)
  =+  rhs=q:(trim (add 2 (need pos)) txt)
  $(args t.args, txt :(weld lhs i.args rhs))
::  Queue raw text to the player.
++  queue
  |=  {msg/tape a/all:yint}
  ^-  all:yint
  =+  lines=(tokenize `@`10 msg)
  |-
  ?~  lines
    a
  $(messages.a [i=[%txt i.lines] t=messages.a], lines t.lines)
::  Looks up a response phrase and queues it to the active player.
++  queue-phrase
  |=  {p/@t a/all:yint}
  ^-  all:yint
  (queue (phrase p a) a)
::
++  queue-phrase-with
  |=  {p/@t args/(list tape) a/all:yint}
  ^-  all:yint
  (queue (phrase-with p args a) a)
::
++  queue-styx
  |=  {msg/styx:^dill a/all:yint}
  ^-  all:yint
  a(messages [i=[%klr msg] t=messages.a])
::
++  queue-notification
  |=  {player/@sd msg/styx:^dill a/all:yint}
  ^-  all:yint
  =+  old=(~(get by notifications.a) player)
  ?~  old
    a(notifications (~(put by notifications.a) player [i=[%klr msg] t=~]))
  a(notifications (~(put by notifications.a) player [i=[%klr msg] t=(need old)]))
::
++  parse-dbref
  |=  s/tape
  ^-  @sd
  ?~  s
    nothing:yint
  =+  id=(rust s dim:ag)
  ?~  id
    nothing:yint
  (sun:si (need id))
::
++  print-ref
  |=  r/@sd
  ^-  tape
  ?:  (syn:si r)                                    ::  if positive
    (scow %ud (abs:si r))
  (scow %sd r)
::
::  "one;two;three" -> <<"one" "two" "three">>
++  tokenize
  |=  {b/@tD t/tape}
  =|  out/(list tape)
  %-  flop
  |-
  ^-  (list tape)
  ?~  t
    out
  ?:  =(t "")
    out
  =+  pos=(find ~[b] t)
  ?~  pos
    [i=t t=out]
  =+  s=(trim (need pos) t)
  ?~  q.s
    $(t "", out [i=p.s t=out])
  $(t t.q.s, out [i=p.s t=out])
::
++  lower-starts-with
  |=  {nedl/tape hstk/tape}
  ^-  ?
  =.  nedl  (cass nedl)
  =.  hstk  (cass hstk)
  =([~ 0] (find nedl hstk))
:: Get the location name for a thing
++  getname
  |=  {loc/@sd a/all:yint}
  ^-  tape
  ?:  =(loc nothing:yint)
    (phrase 'loc-nothing' a)
  ?:  =(loc home:yint)
    (phrase 'loc-home' a)
  name:(~(got yint-db db.a) loc)
::  Misc function that starts quiting a player's session.
++  do-quit
  |=  {a/all:yint}
  ^-  all:yint
  =+  id=(need player.a)
  =+  record=(~(got yint-db db.a) id)
  =.  a  (log "DISCONNECTED {<name.record>}({<id>}) from {<src.a>}" a)
  a(player ~)
--
