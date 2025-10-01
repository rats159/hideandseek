package main

DEVTOOLS :: #config(DEVTOOLS, true)

main :: proc()
{
    game: Game

    init_game(&game)
    run_game(&game)
}