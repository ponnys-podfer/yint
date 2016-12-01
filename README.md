Yint: A TinyMUD Compatible MUD server
-------------------------------------

While people might assume otherwise from the name, Yint is a derivative of TinyMUD. This is a fairly straight, mechanical translation of the MangledMUD code from Ruby to Hoon. (MangledMUD was a mostly mechanical translation of the original TinyMUD code from C to Ruby.)

The code under app/, gen/, lib/ and sur/ should be copied onto a fresh desk. Copy the data in  You should be able to then start the %yint app, and load phrases and a world.

    > =dir /=yint=
    > |start %yint
    > :yint|load-phrases <path/to/phrases.json>
    > :yint|import <path/to/caves.txt or other database>

License
-------

Yint is licensed under the [original TinyMUD license][1].

[1]: LICENSE.md
