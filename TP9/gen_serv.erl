-module(gen_serv).
-behaviour(gen_server).
-compile(export_all).

% Client

start_link() ->
    gen_server:start_link(?MODULE, [], []).

stop(Pid) -> gen_server:cast(Pid, stop).

inc(Pid, Nbr) when Nbr > 0 ->
    gen_server:cast(Pid, inc),
    inc(Pid, Nbr-1);

inc(_pid, 0) -> 1.

get_value(Pid) -> gen_server:call(Pid, get_value).

% Server

init([]) ->
    {ok, {0, [], []}}.

handle_cast(inc, {CountNbr, Called, Cast}) ->
    {noreply, {CountNbr+1, Called, Cast}}.

handle_call(get_value, _From, {CountNbr, Called, Cast}) ->
    {reply, CountNbr, {CountNbr, Called, Cast}}.



main() ->
    {ok, Counter} = start_link(),
    inc(Counter, 55),
    V = get_value(Counter),
    io:format("Value is ~p~n", [V]).