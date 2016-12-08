Yint: A TinyMUD Compatible MUD server
-------------------------------------

Yint is a fairly straight, mechanical translation of the [MangledMUD][mm] code from Ruby to Hoon. (MangledMUD was a mechanical translation of the original TinyMUD code from C to Ruby.) Unlike MangledMUD, on top of the mechanical porting, we further do some minor cleanup to make Yint more idiomatic Hoon code.

The code under `app/`, `gen/`, `lib/` and `sur/` should be copied onto a fresh desk, we'll use `/=yint=` in these instructions. Copy the data in `data/` somewhere accessible. You should be able to then start the `%yint` app, and load phrases and a world.

    > =dir /=yint=
    > |start %yint
    > :yint|load-phrases <path/to/phrases.json>
    > :yint|import <path/to/caves.txt or other database>

License
-------

`%yint` started as a mechanical translation of [MangledMUD][mm], which
itself was a rewrite of the original [TinyMUD][tm] codebase. I've obtained permission from both the authors of MangledMUD and TinyMUD to release this code under the [BSD-3 license][bsd]

[mm]: https://github.com/mangled/MangledMud/
[tm]: https://en.wikipedia.org/wiki/TinyMUD
[bsd]: LICENSE
