-module(test).
-export([start/0, hello_world/0]).


println(Msg) -> io:format("~p\n", [Msg]).

start() -> 
    Pid = spawn(?MODULE, hello_world, []),
    % link(Pid), % throws an the done exception when we send stop
    Pid ! print,
    Pid ! stop.

hello_world() ->
    receive
        print -> 
            println("Hello world"),
            hello_world();
        stop -> 
            % exit(self(), done)
            ok
        % Other -> % we may not want to do this, it could be useful to keep messages for later
        %     println(Other)
    end.
