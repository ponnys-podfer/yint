/-  sole
!:
|%
:::
:: constants for match.hoon
:::
++  match-types
  $?  $match-player
      $match-absolute
      $match-me
      $match-here
      $match-possession
      $match-neighbor
      $match-exit
  ==
:::
:: constants.rb
:::
++  type-room  0x0
++  type-thing  0x1
++  type-exit  0x2
++  type-player  0x3
++  notype  0x7
++  type-mask  0x7
++  antilock  0x8
++  wizard  0x10
++  link-ok  0x20
++  dark  0x40
++  temple  0x80
++  sticky  0x100
++  nothing  -1
++  ambiguous  -2
++  home  -3
++  player-start  --0
++  object-cost  10
++  exit-cost  1
++  link-cost  1
++  room-cost  10
++  max-pennies  --10.000
++  lookup-cost  1
++  not-token  `@tas`'!'
++  lookup-token  `@tas`'*'
++  number-token  `@tas`'#'
++  say-token  `@tas`'"'
++  pose-token  `@tas`':'
++  exit-delimeter  `@tas`';'
++  kill-base-cost  100
++  kill-min-cost  10
++  kill-bonus  50
++  penny-rate  10
++  max-object-endowment  100
++  endowment-calculator  5

:: An individual object in a TinyMUD data dump. Note that most numbers below are
:: signed integers, as TinyMUD's data dumps use:
::   * -1 as a special value for NOTHING
::   * -2 as a special value for AMBIGUOUS
::   * -3 as a special value for HOME
++  record
  $:  name/tape
      description/tape
      location/@sd
      contents/@sd
      exits/@sd
      next/@sd
      key/@sd
      fail/tape
      succ/tape
      ofail/tape
      osucc/tape
      owner/@sd
      pennies/@sd
      flags/@ud
      password/tape
  ==
:: A TinyMUD database is a map of integers to records.
++  database
  $:  next/@sd
      records/(map @sd record)
  ==
:: State which persists across procesing multiple lines of input.
++  world
  $:  :: Maps terminal connections to player ids in the database. When this is
      :: ~, the terminal hasn't logged in yet.
      logged-in/(map bone (unit @sd)) 
      :: Maps logged in players to bones for output.
      player-out/(map @sd bone)
      :: The current world database.
      db/database
  ==
:: State which is local to a single line being processed.
++  io
  $:  :: [in] The ship which caused this message
      src/ship
      :: [in/out] The current player of the user. ~ means the user hasn't
      :: logged into a player. Change this to log the user in or out of a
      :: player.
      player/(unit @sd)
      :: [out] Queued messages for the current connection. We separate this out
      :: from |quque| because the user may not have a player number yet. This
      :: queue should be reversed for printing.
      messages/(list sole-effect:sole)
      :: [out] Queued messages for other players. Each of these sole-effects
      :: will be sent to the player ids in turn. Each queue should be reversed
      :: for printing.
      notifications/(map @sd (list sole-effect:sole))
      :: [out] A list of system messages to be printed to the event log. This
      :: queue should be reversed for printing.
      syslog/(list tape)
  ==
:: A combination of both of the above done for a 
++  all  {world io}

:: A parsed line of input.
++  command  {command/tape arg1/tape arg2/tape}
--
