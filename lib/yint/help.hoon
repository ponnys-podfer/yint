/-  yint
/+  yint-all, yint-db, yint-match, yint-util
[[. yint-util] match=yint-match]
!:
|_  a/all:yint

:: Quickly putting together a help screen.

++  do-help
  |=  player/@sd
  ^-  all:yint
  =/  nl/tape  (limo `@tD`10 ~)
  =/  h  ;:  weld
    "Basic commands:"  nl
    " move/go <direction>"  nl
    " get/take <thing>; drop/throw <thing>"  nl
    " look; look <thing>; look <direction>"  nl
    " say <message>"  nl
    " inventory"  nl
    " help"  nl
    " @describe me = <description>"  nl
    " home --- go home"  nl
    "You can also say things by starting a line with '\"'"  nl
    "You can pose for other players by starting a line with ':'"  nl
    "Remember, no matter how bad it gets, you can always go home."
  ==
  (queue h a)
--
