% ----- Higher order programming -----
local
    fun {Filter L F}
        case L
        of nil then nil
        [] H|T then
            if {F H} then
                H|{Filter T F}
            else
                {Filter T F}
            end
        end
    end
    % Q2
    fun {IsEven Item}
        if Item mod 2 == 0 then
            true
        else
            false
        end
    end    
in
   {Browse {Filter [1 2 3 4] IsEven}}
end

% ----- Threads and declarative concurrency -----
% X=1, Y=2, Z=2

local X Y Z in
    thread if X==1 then Y=2 else Z=2 end end
    thread if Y==1 then X=1 else Z=2 end end
    X=1
    {Browse res(x:X)} % 1
    {Browse res(y:Y)} % 2
    {Browse res(z:Z)} % 2
end

% 
local X Y Z in
    thread if X==1 then Y=2 else Z=2 end end
    thread if Y==1 then X=1 else Z=2 end end
    X=2
    {Browse res(x:X)} % 2
    {Browse res(y:Y)} % jamais bound
    {Browse res(z:Z)} % 2
end

% Q2

local
    fun {Prod N}
        if N == 10 then
            nil
        else
            N|{Prod N+1}
        end
    end
    %
    fun {Filter L F}
        case L
        of nil then nil
        [] H|T then
            if {F H} then
                H|{Filter T F}
            else
                {Filter T F}
            end
        end
    end
    %
    fun {IsEven Item}
        if Item mod 2 == 1 then
            true
        else
            false
        end
    end   
    %
    fun {Cons L U}
        case L
        of nil then U
        [] H|T then
            {Cons T U+H}
        end
    end
    %
    Stream
    Stream2
    Stream3
in
    thread Stream = {Prod 0} end
    thread Stream2 = {Filter Stream IsEven} end
    thread Stream3 = {Cons Stream2 0} end
    {Browse Stream3}
end

% Q3 -> pas fait
local
    proc {Ping L}
        case L of H|T then T2 in
            {Delay 500} {Browse ping}
            T=_|T2
            {Ping T2}
        end
    end
    %
    proc {Pong L}
        case L of H|T then T2 in
            {Browse pong}
            T=_|T2
            {Pong T2}
        end
    end
    % vars
    L
in
    thread {Ping L} end
    thread {Pong L} end
    L=_|_
end

% ----- Message passing -----

% Q1


