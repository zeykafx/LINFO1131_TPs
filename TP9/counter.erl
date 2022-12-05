-module(counter).
-compile(export_all).


exec(State) ->
    receive
        inc -> 
            exec(State+1);
        {get_value, Pid} ->
            Pid ! {value, State},
            exec(State)
    end.


inc(Pid, Nbr) when Nbr > 0 ->
    Pid ! inc,
    inc(Pid, Nbr-1);  % add a ; to show that the function inc is still being defined later

inc(_pid, 0) -> 1.

get_value(Pid) ->
    Pid ! {get_value, self()},
    receive {value, V} -> io:format("Value is ~p~n", [V]) end.

start() ->
    spawn(?MODULE, exec, [0]).

main() ->
    C = start(),
    inc(C, 10),
    get_value(C).