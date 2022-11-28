% ----- Q1 -----
local
    fun lazy {Ints N} 
        N|{Ints N+1} 
    end
    %
    fun lazy {Sum2 Xs Ys}
        case Xs#Ys 
        of (X|Xr)#(Y|Yr) then 
            (X+Y)|{Sum2 Xr Yr}  % sum the heads and do the same on the rest of the list
        end
    end
    %
    proc {Touch L N}
        if N >= 0 then
            {Touch L.2 N-1}
        else
            skip
        end
    end
    % 2 ---
    fun {GetI S I}
        if I==0 then
            S.1
        else
            {GetI S.2 I-1}
        end
    end
    % 3 -- kernel version
    IntsLazy Sum2Kernel GetIKernel
    IntsLazy = proc {$ N ?R}
        NInc R1 R2 One
    in
        thread 
            {WaitNeeded R}
            One = 1
            NInc=N+One
            {IntsLazy NInc R1}
            R2=N|R1
            R=R2
        end
    end
    %
    Sum2Kernel = proc {$ Xs Ys ?R}
        thread 
            {WaitNeeded R}
            case Xs#Ys
            of (X|Xr)#(Y|Yr) then
                Head R1 Res 
            in
                Head=X+Y
                {Sum2Kernel Xr Yr R1}
                Res = Head|R1
                R = Res
            end
        end
    end
    %
    GetIKernel = proc {$ S I ?R}
        Bool Zero
    in
        Zero=0
        Bool = I==Zero
        if Bool then
            R = S.1
        else
            Tail IDec One
        in
            One = 1
            Tail = S.2
            IDec = I-One
            {GetIKernel Tail IDec R}
        end
    end
    %
    S S2
in
    {Browse "Normal version:"}
    S=0|{Sum2 S {Ints 1}} % 0+0, 0+1, 1+2, 3+3, 6+4, 10+5, ...
    % {Touch S 10}
    {Browse S}
    {Browse {GetI S 4}} % 6 + 4 
    % Kernel version ----
    {Browse "Kernel version:"}
    S2=0|{Sum2Kernel S2{IntsLazy 1}}
    {Browse S2}
    {Browse {GetIKernel S2 4}}
end

% ----- Q2 -----
local
    fun lazy {Prod N}
        N|{Prod N+1}
    end
    %
    fun lazy {Cons Xs}
        case Xs
        of X|Xr then
            X*X|{Cons Xr}  
        end
    end
    % 
    fun lazy {Filter Xs D}
        case Xs
        of H|T then
            {Delay D}
            H|{Filter T D}
        end
    end
    %
    proc {Dup L R1 R2} % proc version of a lazy function since we want to return two values
        thread 
            {WaitNeeded R1}
            {WaitNeeded R2}
            T1 T2
        in
            R1 = L.1|T1
            R2 = L.1|T2
            {Dup L.2 T1 T2}
        end
    end
    %
    proc {Touch L N}
        if N >= 0 then
            {Touch L.2 N-1}
        else
            skip
        end
    end
    %
    L1 L2 L3 Cons1 Cons2
in
    L1 = {Prod 1}
    {Dup L1 L2 L3}
    % main branch
    Cons1 = {Cons {Filter L2 500}}
    % second branch
    Cons2 = {Cons {Filter L3 200}}
    {Browse Cons1}
    {Browse Cons2}
    thread {Touch Cons1 10} end
    thread {Touch Cons2 10} end %% this is faster than the first one
end

% ----- Q3 -----
local
    fun {Counter L}
        {CounterAux L nil}
    end
    %
    fun lazy {CounterAux L Acc}
        case L
        of H|T then
            L1 in 
                L1 = {Insert H Acc}
                L1|{CounterAux T L1}
        end
    end
    %
    fun {Insert Elem AccList}
        case AccList
        of nil then [Elem#1]
        [] H|T then
            if (Elem == H.1) then
                (Elem#H.2+1)|T
            else
                H|{Insert Elem T}
            end
        end
    end
    %
    proc {Touch L N}
        if N >= 0 then
            {Touch L.2 N-1}
        else 
            skip
        end
    end
    %
    InS Stream
in
    % one pipe
    InS = e|m|e|c|_
    Stream = {Counter InS}
    {Browse stream(stream: Stream)}
    {Touch Stream 10}
    % need to merge the streams to work with more than one pipe
end