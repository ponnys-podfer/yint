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
  =+  cost=(rust in-cost dim:ag)
  ?~  cost
    (queue-phrase 'objects-must-have-a-value' a)
  =^  can-pay  db.a  (~(payfor yint-db db.a) player (need cost))
  ?.  can-pay
    (queue-phrase 'sorry-poor' a)
  a

--
