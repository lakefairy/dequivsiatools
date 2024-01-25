- Dequivsia tools -
English translation and increased max scaling factor mod

Place the original game in the dequivsia directory and build using make.

Technical notes follow.

- Encryption -
Encryption algo: c[x] = ((p[x]-p[x-1])^k1)+k2
Decryption algo: p[x] = ((c[x]-k2)^k1)+p[x-1]
p[-1] is assumed to be 0

Because adding/subtracting 128 is the same as xoring 128, we can assume one of
the keys is less than 128. Therefore, there are 32768 possible encryption keys.

Thankfully the ax files have a magic number "HSP3", and it so happens that the
encryption algo produces a distinct result for every key when used on that
string. We also know that k2 = c[0]-('H'^k1), which narrows it down to 128
keys.

- Increased scaling factor mod -
There's this bit of code in the source:
gameWindowSize = (gameWindowSize + 1) \ 3

Which gets turned into the following byte code:
0x2001, 0x0000 (EXFLG_1|TYPE_VAR, 0)
0x0000, 0x0008 (TYPE_MARK, CALCCODE_EQ)
0x0001, 0x0000 (TYPE_VAR, 0)
0x0004, 0x0001 (TYPE_INUM, 1)
0x0000, 0x0000 (TYPE_MARK, CALCCODE_ADD)
0x0004, 0x0003 (TYPE_INUM, 3)
0x0000, 0x0004 (TYPE_MARK, CALCCODE_MOD)
(Note: gameWindowSize happens to be variable 0)

To patch this we simply search and replace.
It has to be patched in two places: main menu and pause menu.

- References -
https://github.com/onitama/OpenHSP
https://github.com/gocha/spihsp
https://github.com/patapancakes/dequivsia
