% ----- Wrapper -----
local
    proc {NewWrapper Wrap Unwrap}
        Key = {NewName}
    in
        fun {Wrap W}
            {Chunk.new w(Key: W)}
        end

        fun {Unwrap W}
            try
                W.Key
            catch _ then
                raise valueError(W) end
            end
        end
    end
in
    %
end

% ----- SimpleLock -----
local
    fun {SimpleLock}
        Token = {NewCell unit}

        proc {Lock Stmt}
            Old New
        in
            {Exchange Token Old New}
            {Wait Old}
            try
                {Stmt}
            finally
                New = unit % forward the token
            end
        end

    in
        'lock'('lock': Lock)
    end
in
  %  
end

% ----- Simple Reentrant lock -----
fun {ReLock}
    Token = {NewCell unit}
    CurThr = {NewCell unit}

    proc {Lock Stmt}
        if @CurThr == {Thread.this} then
            {Stmt} % the calling thread already has the lock
        else Old New in
            {Exchange Token Old New}
            {Wait Old}
            try
                {Stmt} % we got the lock, run the protected procedure
            finally 
                New = unit
                CurThr := unit
            end
        end
    end
in 
    relock('lock': Lock)
end

% ----- Get Release Lock -----
fun {GRLock}
    Token = {NewCell unit}
    CurToken = {NewCell unit}
    CurThr = {NewCell unit}

    fun {Get}
        if @CurThr \= {Thread.this} then
            Old New
        in
            {Exchange Token Old New}
            {Wait Old}
            CurToken := New
            true % this thread now has the lock
        else
            false % this thread already had the lock
        end
    end

    fun {Release}
        if @CurThr == {Thread.this} then
            @CurToken = unit
            CurThr := unit
            true
        else
            false % we didn't release the lock since this thread didn't have it
        end
    end
in
    grlock(get:Get release:Release)
end


% ----- Stack ADT -----
local Wrap Unwrap in
    {NewWrapper Wrap Unwrap}

    fun {NewStack}
        {Wrap nil}
    end

    fun {Push WS X}
        {Wrap 
            X|{Unwrap WS} 
        }
    end

    fun {Pop WS ?X}
        Stack = {Unwrap WS}
    in
        X = Stack.1
        {Wrap S.2}
    end
end

% ----- StackObj -----
fun {NewStackObj}
    Cell = {NewCell nil}

    proc {Push X}
        Cell := X|@Cell
    end

    proc {Pop ?X}
        S = @Cell
    in
        X = S.1
        Cell := S.2
    end

    proc {IsEmpty ?B}
        B = @Cell == nil
    end

in
    proc {$ Msg}
        case Msg
        of push(X) then {Push X}
        [] pop(X) then {Pop X}
        [] IsEmpty(B) then {IsEmpty B}
        end
    end
end

% ----- Concurrent Queue with lock -----
fun {Queue}
    X
    Q = {NewCell q(0 X X)} % diff list
    Lock = {NewLock} % use a normal Oz lock

    proc {Insert X}
        N F B2
    in
        lock Lock then
            q(N F X|B2) = @Q
            Q := q(N+1 F B2) 
        end
    end

    proc {Remove ?X}
        N F2 B
    in
        lock Lock then
            q(N X|F2 B) = @Q
            Q := q(N-1 F2 B)
        end
    end
in
    queue(insert:Insert remove:Remove)
end


% ----- Concurrent Queue with TupleSpace -----
fun {Queue}
    TS = {New TupleSpace init}
    X

    proc {Insert X}
        N F B2
    in
        {TS read(q q(N F X|B2))}
        {TS write(q(N+1 F B2))}
    end

    proc {Remove ?X}
        N F2 B
    in
        {TS read(q q(N X|F2 B))}
        {TS write(q(N-1 F2 B))}
    end
in
    {TS write(q(0 X X))}
    queue(insert:Insert remove:Remove)
end

% ----- Port Object -----
fun {NewPortObject Fun Init}
    Out Port
in
    thread S in 
        P = {NewPort S} 
        Out = {FoldL S Fun Init}
    end
    P
end

% FoldL definition for good measure
fun {FoldL L F U}
    case L
    of nil then U
    [] H|T then {FoldL T F {F U H}} end
end

% ----- Port Obj without FoldL -----
fun {NewPortObj Fun Init}
    proc {Loop Stream Acc}
        case Stream
        of Msg|T then
            {Loop T {Fun U Msg}} % fun handles all new messages
        end
    end

    Port
in
    thread Stream in
        Port = {NewPort Stream}
        {Loop Stream Init}
    end
end


% ----- Active Object -----
fun {NewActive Class Init}
    Obj = {New Class Init}
    Port
in
    thread Stream in
        Port = {NewPort Stream}
        for Msg in Stream do
            {Obj Msg}
        end
    end

    % make it look like a normal object
    proc {$ Msg}
        {Send Port Msg}
    end
end