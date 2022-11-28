local
    fun lazy {Prod L H}
        {Delay 200}
        if L>H then nil
        else
            L|{Prod L+1 H}
        end
    end
    %
    fun lazy {Cons S Acc}
        case S of H|T then
            Acc+H|{Cons T Acc+H}
        [] nil then nil
        end
    end
    %
    proc {Touch L N}
        if N > 0 then
            {Touch L.2 N-1}
        else 
            skip 
        end
    end
    % BOUNDED BUFFER ----
    proc {BoundedBuffer S1 S2 N}
        fun lazy {Loop S1 End}
            case S1 of H1|T1 then
                H1|{Loop T1 thread End.2 end} % asking for more elem from prod in another thread to avoid blocking
            end
        end
        End
    in
        thread End = {List.drop S1 N} end % asks for N elements at the beginning
        S2 = {Loop S1 End}
    end
    %
    S1 S2 S3
in
    {Browse S1}
    {Browse S2}
    {Browse S3}
    S1={Prod 1 100}
    {BoundedBuffer S1 S2 5}
    S3={Cons S2 0}
    {Touch S3 10}
end


% lazy quicksort

local
    proc {Partition L Pivot L1 L2}
        case L
        of H|T then
            if H<Pivot then
                M1 in
                    L1=H|M1
                    {Partition T Pivot M1 L2}
            else
                M2 in
                    L2=H|M2
                    {Partition T Pivot L1 M2}
            end
        [] nil then L1 = nil L2 = nil
        end
    end
    %
    fun lazy {LAppend L1 L2}
        case L1
        of nil then L2
        [] H|T then
            H|{LAppend T L2}
        end
    end
    %
    fun lazy {LQuicksort L}
        case L of Pivot|T then
            L1 L2 S1 S2 in
                {Partition T Pivot L1 L2}
                S1 ={LQuicksort L1}
                S2 = {LQuicksort L2}
                {LAppend S1 Pivot|S2}
        [] nil then nil
        end
    end
    %
    proc {Touch L N}
        if N > 0 then
            {Touch L.2 N-1}
        else 
            skip
        end
    end
    %
    L = [4 6 2 7] % sorted version: [2 4 6 7]
    Sorted
in
    {Browse Sorted}
    Sorted = {LQuicksort L} 
    {Touch Sorted 2}
end
