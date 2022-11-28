% ----- Q1 -----
declare
A={NewCell 0}
B={NewCell 0}
T1=@A
T2=@B
{Show A==B} % a: What will be printed here
            % true, false, A, B or 0? -> false, identities are !=
{Show T1==T2} % b: What will be printed here
              % true, false, A, B or 0? -> true, the values are the same
{Show T1=T2} % c: What will be printed here
             % true, false, A, B or 0? -> 0
A:=@B
{Show A==B} % d: What will be printed here
            % true, false, A, B or 0? -> false, the identities are different, but the values are the same thanks to the last statement


% ----- Q2 -----
local
    % foldl
    fun {FoldL L F U}
        case L
        of nil then U
        [] H|T then {FoldL T F {F U H}}
        end
    end
    % NewCell
    fun {NewCell F Init}
        P Out
    in
        thread S 
        in 
            P = {NewPort S}
            Out = {FoldL S F Init}
        end
        proc {$ M}
            {Send P M}
        end
    end
    %
    fun {CellProcess S M}
        case M
        of assign(New) then
            New
        [] access(Old) then
            Old = S
            nil % or S since it's nil anyways
        end
    end
    %
    proc {Access Cell Value}
        {Cell access(Value)}
    end
    proc {Assign Cell Value}
        {Cell assign(Value)}
    end
    Cell
in
    Cell = {NewCell CellProcess 0}
    % {Cell assign(1)} % without the procedure
    {Assign Cell 2}
    local
        X
    in
        {Cell access(X)}
        {Browse X}
    end    
end

% ----- Q3 -----
local
    fun {NewPort Stream}
        {NewCell Stream}
    end
    %
    proc {Send Port Value}
        NewS
    in
        % taken from the port semantics
        @Port = Value|NewS
        Port := NewS
    end
    %
    Port Stream
    % ----- Q4 -----
    proc {Close Port}
        @Port = nil
    end
in
    {Browse Stream}
    Port = {NewPort Stream}
    {Send Port 1}
    {Send Port 2}
    {Send Port 2}
    {Send Port 2}
    {Send Port 2}
    {Close Port}
end

% ----- Q5 -----
local
    fun {Q A B}
        Cell
    in
        Cell = {NewCell A}
        for Value in A..B do
            Cell := @Cell + Value
        end
        @Cell
    end
in
    {Browse {Q 0 10}} % = 55, which is correct
end

% ----- Q6 -----
% A)
local
    class Counter
        attr count % attributes have to start with a lowercase otherwise we cant see them when we inherit the class
        meth init(Val)
            count := Val
        end
        meth add(N)
            count := @count + N
        end
        meth read(N)
            N = @count
        end
    end
    %
    fun {Q A B}
        Ctr Val
    in
        Ctr = {New Counter init(A)}
        for Value in A..B do
            {Ctr add(Value)}
        end
        {Ctr read(Val)}
        Val
    end
in
    {Browse {Q 0 10}} % = 55, which is correct
end
% B)
local
    class Port
        attr portVal
        meth init(InitStream)
            portVal := InitStream
        end
        meth send(Value)
            NewS
        in
            @portVal = Value|NewS
            portVal := NewS
        end
    end
    fun {NewPort Stream}
        {New Port init(Stream)}
    end
    proc {Send PortObj Value}
        {PortObj send(Value)}
    end
    % C)
    class PortClose from Port
        meth close()
            @portVal = nil % we have the attribute here too
        end
    end
    %
    fun {NewPortClose Stream}
        {New PortClose init(Stream)}
    end
    % send stays the same
    proc {Close PortObj}
        {PortObj close()}
    end
    % vars
    P PClose S SClose
in
    {Browse S}
    P = {NewPort S}
    {Send P 1}
    {Send P 2}
    {Send P 2}
    {Send P 2}
    {Send P 2}
    % Port close
    {Browse SClose}
    PClose = {NewPortClose SClose}
    {Send PClose 1}
    {Send PClose 2}
    {Close PClose}
end

% ----- Q7 -----
