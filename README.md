# minimicro-asteroids
## an Asteroids clone for Mini Micro

This is the code from a live-coding session on Twitch on March 20, 2022.  I set myself a goal of recreating the classic arcade game _Asteroids_ in an hour using [MiniScript](https://miniscript.org/) and [Mini Micro](https://miniscript.org/MiniMicro) (with the art assets prepared ahead of time).

![](pics/Asteroids-Demo.png)

I didn't quite make it!  You can fly your ship around and shoot the asteroids, which break into smaller chunks until gone.  So I'd say the _core_ of the game is functional, but a whole lot of details are still missing:

- no pew pew sound when firing
- one bullet can hit multiple rocks (including the freshly-spawn sub-rocks) on the same frame
- no score
- only one life (game ends after your ship is destroyed)
- heartbeat sound does not reflect the number of rocks left
- no UFO
- no reset if you manage to clear the board (not that I ever managed to do so in my testing today)
- no maximum speed for the ship
- turn rate, acceleration, and deceleration probably need a bit more tweaking

If there is interest, I will tackle these issues and try to finish things up in a future stream.


