% ----- Q1 -----
local
    % --- 1
    fun lazy {Gen I}
        I|{Gen I+1}
    end
    %
    proc {Touch L N}
        if N==0 then
            skip
        else
            % {Delay 100}
            {Touch L.2 N-1}
        end
    end
    % --- 2
    fun {GiveMeNth N L}
        if N==0 then nil
        else 
            L.1|{GiveMeNth N-1 L.2}
        end
    end
    %
    L1 L2
in
    L1 = {Gen 5}
    {Browse L1}
    L2 = {GiveMeNth 20 L1}
    {Browse L2}
end

% ----- Q2 -----
local
    fun lazy {Gen I}
        I|{Gen I+1}
    end
    %
    fun lazy {Prime}
        {Sieve {Gen 2}}
    end
    %
    fun lazy {Filter Xs P}
        case Xs
        of nil then nil
        [] X|Xr then
            if {P X} then
                X|{Filter Xr P}
            else
                {Filter Xr P}
            end
        end
    end
    %
    fun lazy {Sieve Xs}
        case Xs
        of nil then nil
        [] H|T then
            H|{Sieve {Filter T fun {$ Y} Y mod H \= 0 end}}
        end
    end
    %
    proc {Touch L N}
        if N==0 then
            skip
        else
            {Touch L.2 N-1}
        end
    end
    % ----- Q3 -----
    proc {ShowPrimes N}
        L = {Prime}
        {Touch L N}
        {Browse L}
    end
    %
    L
in
    {ShowPrimes 10}
end

% ----- Q4 -----
local
    fun lazy {Gen I N}
        {Delay 500}
        if I == N then [I] else I|{Gen I+1 N} end
    end
    %
    fun lazy {Filter L F}
        case L
        of nil then nil
        [] H|T then
            if {F H} then H|{Filter T F} else {Filter T F} end
        end
    end
    %
    fun lazy {Map L F}
        case L
        of nil then nil
        [] H|T then
            {F H}|{Map T F}
        end
    end
    %
    proc {Touch L N}
        if N==0 then
            skip
        else
            {Touch L.2 N-1}
        end
    end
    %
    Xs Ys Zs
in
    % sub question a: surround all calls with thread end
    % sub questio b: make all functions lazy and then use touch at the end to show Zs progressing
    {Browse Zs}
    Xs = {Gen 1 100}
    Ys = {Filter Xs fun {$ X} (X mod 2)==0 end}
    Zs = {Map Ys fun {$ X} X*X end}
    {Touch Zs 100}
end

% ----- Q5 -----
local
    fun {Insert X Ys}
        case Ys
        of nil then [X]
        [] Y|Yr then
            if X < Y then
                X|Ys
            else
                Y|{Insert X Yr}
            end
        end
    end
    %
    fun {InSort Xs} %% sorts list Xs
        case Xs
        of nil then nil
        [] X|Xr then
            {Insert X {InSort Xr}}
        end
    end
    %
    fun {Minimum Xs}
        {InSort Xs}.1
    end
in
    % A) O(N^2)
    {Browse {Minimum [1 2 3 4]}}
    % B) O(N) car au pire on parcours tout le tableau
end

% ----- Q6 -----
local
    fun {Last Xs}
        case Xs of [X] then X
        [] X|Xr then {Last Xr}
        end
    end
    %
    fun {Maximum Xs}
        {Last {InSort Xs}}
    end
    %
    fun {InSort Xs} %% sorts list Xs
        case Xs
        of nil then nil
        [] X|Xr then
            {Insert X {InSort Xr}}
        end
    end
in
    % non, il faut tout de même tout parcourir pour obtenir le maximum
end

% ----- Q7 -----
% damn Canada

% ----- Q8 -----
local
    fun {Buffer In N} 
        End = thread {List.drop In N} end
        fun lazy {Loop In End}
            case In
            of I|In2 then
                I|{Loop In2 thread End.2 end}
            end
        end
    in
        {Loop In End}
    end
in
    
end
