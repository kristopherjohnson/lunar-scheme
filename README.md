LUNAR for Scheme
================

This is an implementation of a classic text-based ["lunar lander" game][lunarlander] in [Scheme][scheme].

The first time I saw a computer was when my father took me to an open-house at the IBM headquarters in Atlanta in the late 1970's, when I was around ten years old.  I wasn't impressed with the big sterile glass rooms filled with big orange computers, but there was a room in the basement where a couple of bearded guys asked me to sit down at a terminal and play a game.

It was this lunar landing game.  For each ten seconds of game time, it asks how much thrust you want to use, and then it tells you your new altitude, velocity, and remaining fuel.  I crashed, and then I had to get up to let the next kid take a turn.

It was simple, primitive even, but I was immediately fascinated with computers.  I saw that a computer would let me create little simulated universes that followed whatever rules I could imagine.

So after that I kept bugging my dad to buy me books about programming.  A couple of years later, my parents bought me a computer.  Thanks Mom and Dad!

I did some research, and I found the [original Lunar Lander program by Jim Storer][storerlunarlander], written in the [FOCAL programming language][wpfocal] in 1969.  This Scheme implementation is translated from a [C version][lunar-c] which faithfully recreates the original physics and gameplay.

This code is based upon these sources:

* [Jim Storer's original lunar landing simulation code in FOCAL][storer]
* [FOCAL Programming Manual][focal]  
* [David Ahl's port to BASIC in _BASIC Computer Games_ (1978)][ahl]
* [C translation][lunar-c]

## Running with Chez Scheme

If you have [Chez Scheme][chez] installed:

```
chez --script lunar.scm
```

## Running with Chicken Scheme

If you have [Chicken Scheme][chicken] installed:

```
csi -script lunar.scm
```

## Running with Gambit Scheme

If you have [Gambit Scheme][gambit] installed:

```
gsi lunar.scm
```

## Running with Racket

Racket requires a special implementation due to its different output buffering behavior. If you have [Racket][racket] installed, you can run the game using either version:

```
# Portable version (may have display timing issues in interactive mode)
racket -f lunar.scm

# Racket-optimized version (recommended for interactive play)
racket -f lunar-racket.scm
```

## Implementation Notes

This Scheme implementation uses only standard Scheme constructs and should work with any R5RS-compliant Scheme implementation.

**Two Versions Available**:
- `lunar.scm`: Portable version compatible with all Scheme implementations (Racket, Chez, Chicken, Gambit)
- `lunar-racket.scm`: Racket-optimized version with proper output flushing for better interactive display

The implementation produces output identical to the original C implementation, including:
- Exact physics calculations using the same algorithms
- Identical number formatting and spacing
- Same input validation and error handling
- Matching game flow and termination logic

## Example of Play

Here is an example play session:

```
CONTROL CALLING LUNAR MODULE. MANUAL CONTROL IS NECESSARY
YOU MAY RESET FUEL RATE K EACH 10 SECS TO 0 OR ANY VALUE
BETWEEN 8 & 200 LBS/SEC. YOU'VE 16000 LBS FUEL. ESTIMATED
FREE FALL IMPACT TIME-120 SECS. CAPSULE WEIGHT-32500 LBS


FIRST RADAR CHECK COMING UP


COMMENCE LANDING PROCEDURE
TIME,SECS   ALTITUDE,MILES+FEET   VELOCITY,MPH   FUEL,LBS   FUEL RATE
      0             120      0        3600.00     16000.0      K=:0
     10             109   5016        3636.00     16000.0      K=:0
     20              99   4224        3672.00     16000.0      K=:0
     30              89   2904        3708.00     16000.0      K=:0
     40              79   1056        3744.00     16000.0      K=:0
     50              68   3960        3780.00     16000.0      K=:0
     60              58   1056        3816.00     16000.0      K=:170
     70              48    154        3503.86     14300.0      K=:200
     80              38   4455        3104.80     12300.0      K=:200
     90              30   4273        2674.41     10300.0      K=:200
    100              24    102        2207.83      8300.0      K=:200
    110              18   3077        1698.97      6300.0      K=:200
    120              14   3310        1140.06      4300.0      K=:200
    130              12   1608         520.96      2300.0      K=:170
    140              11   3416         -57.20       600.0      K=:0
    150              11   3991         -21.20       600.0      K=:0
    160              11   4038          14.80       600.0      K=:30
    170              11   4396         -63.90       300.0      K=:0
    180              11   5069         -27.90       300.0      K=:8
    190              12    161         -22.83       220.0      K=:10
    200              12    517         -25.70       120.0      K=:9
    210              12    887         -24.89        30.0      K=:100
FUEL OUT AT   210.30 SECS
ON THE MOON AT   376.51 SECS
IMPACT VELOCITY OF   562.79 M.P.H.
FUEL LEFT:     0.00 LBS
SORRY,BUT THERE WERE NO SURVIVORS-YOU BLEW IT!
IN FACT YOU BLASTED A NEW LUNAR CRATER   156.33 FT. DEEP



TRY AGAIN?
(ANS. YES OR NO):NO
CONTROL OUT


```

## Game Rules

- You start 120 miles above the lunar surface with 16,000 lbs of fuel
- Every 10 seconds, you set your fuel burn rate (K) between 0 and 200 lbs/sec  
- Rates between 1-7 lbs/sec are not allowed (minimum thrust threshold)
- Your goal is to land with the lowest possible impact velocity
- Landing outcomes:
  - ≤ 1 MPH: Perfect landing!
  - ≤ 10 MPH: Good landing
  - ≤ 22 MPH: Poor landing  
  - ≤ 40 MPH: Craft damage
  - ≤ 60 MPH: Crash landing
  - \> 60 MPH: No survivors

[ahl]: https://www.atariarchives.org/basicgames/showpage.php?page=106
[chicken]: https://call-cc.org
[chez]: https://cisco.github.io/ChezScheme/
[focal]: http://www.bitsavers.org/www.computer.museum.uq.edu.au/pdf/DEC-08-AJAB-D%20PDP-8-I%20FOCAL%20Programming%20Manual.pdf
[gambit]: https://gambitscheme.org
[lunar-c]: https://github.com/kristopherjohnson/lunar-c
[lunarlander]: https://en.wikipedia.org/wiki/Lunar_Lander_(video_game_genre)#Text_games
[racket]: https://racket-lang.org
[scheme]: https://en.wikipedia.org/wiki/Scheme_(programming_language)
[storer]: http://www.cs.brandeis.edu/~storer/LunarLander/LunarLander/LunarLanderListing.jpg
[storerlunarlander]: https://www.cs.brandeis.edu/~storer/LunarLander/LunarLander.html
[wpfocal]: https://en.wikipedia.org/wiki/FOCAL_(programming_language)