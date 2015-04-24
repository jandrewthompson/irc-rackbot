# Rackbot
An IRC Bot Framework written in Racket.

## Design Goals
All functionality is provided via the plugin system.
The core should be simple and easily modifiable while running in the REPL.  AKA: Shouldn't have to disconnect from chan/restart to 
add new features or bugfixes.

## Purpose
I built this primarily as an excuse for me to learn Racket, but I also notice this sort of thing (an extensible
plugin-based bot framework written in racket doesn't seem to exist).
