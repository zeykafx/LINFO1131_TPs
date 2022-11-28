-module(rps).
-export([start/0, init_game/0, exec_game/0, init_player/1, exec_player/1]).


-define(MOVES, [pierre, papier, ciseaux]).


random_move() ->
    lists:nth(rand:uniform(length(?MOVES)), ?MOVES).

play(pierre, pierre) -> tie;
play(pierre, papier) -> lost;
play(pierre, ciseaux) -> won;
play(papier, pierre) -> won;
play(papier, papier) -> tie;
play(papier, ciseaux) -> lost;
play(ciseaux, pierre) -> lost;
play(ciseaux, papier) -> won;
play(ciseaux, ciseaux) -> tie.

start() ->
    Game = init_game(),
    P1 = init_player("Player 1"),
    P2 = init_player("Player 1"),
    Game ! {play, P1, pierre},
    Game ! {play, P2, papier}.

init_game() -> 
    spawn(?MODULE, exec_game, []).

exec_game() -> 
    receive
        {play, Pid, Move} -> 
            receive {play, Pid2, Move2} when Pid =/= Pid2 ->
                Pid ! {you, play(Move, Move2)},
                Pid2 ! {you, play(Move2, Move)}
            end
    end,
    exec_game().


init_player(Name) ->
    spawn(?MODULE, exec_player, [Name]).

exec_player(Name) ->
    receive
        {you, Move} -> io:format("~p received ~p.\n", [Name, Move])
    end,
    exec_player(Name).
