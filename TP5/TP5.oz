% ----- Q1 -----

local
    fun {Ints N}
        fun {DoInts I}
            if I > N then nil
            else 
                I | {DoInts I+1}
            end
        end
    in
        {DoInts 0}
    end
    %
    fun lazy {LAppRev F R B}
        case pair(F R)
        of pair(X|F1 Y|R2) then
            {Browse "Lazy suspension"}
            X|{LAppRev F1 R2 Y|B}
        [] pair(nil [Y]) then
            Y|B
        end
    end
    %
    fun {NewQueue} q(0 nil 0 nil) end
    %
    fun {Check Q}
        case Q of q(LenF F LenR R) then
            if LenF<LenR then % Here: |F|+1 = |R| (F and R about the same)
                q(LenF+LenR {LAppRev F R nil} 0 nil)
            else 
                Q 
            end
        end
    end
    %
    fun {Insert Q X}
        case Q of q(LenF F LenR R) then 
            {Check q(LenF F LenR+1 X|R)} 
        end
    end
    %
    fun {Delete Q X}
        case Q of q(LenF F LenR R) then F1 in
            F=X|F1 
            {Check q(LenF-1 F1 LenR R)} 
        end
    end
    % VARS
    Q0 Q1 Q2 X
in
    Q0={NewQueue}
    Q1={FoldL {Ints 32} Insert Q0}
    {Browse Q1}
    Q2={Delete Q1 X}
end

% 1 C
local
    fun lazy {LAppRev F R B}
        case pair(F R)
        of pair(X|F2 Y|R2) then
            X|{LAppRev F2 R2 Y|B}
        [] pair(nil [Y]) then 
            Y|B
        end
    end
    fun {NewQueue}
        q(
            nil % F
            nil % R
            nil % S (schedule), things we want to force
        )
    end
    %
    fun {ForceOne Q}
        case Q of q(F R nil) then
            X in
                X = {LAppRev F R nil}
                q(X 0 X)
        [] q(F R S) then
            q(F R S.2) % call for an element
        end
    end
    %
    fun {Insert q(F R S) X} 
        {ForceOne q(F X|R S)}
    end
    %
    fun {Delete q(X|Fr R S) Y} 
        Y=X
        {ForceOne q(Fr R S)}
    end
in
    %
end

% ----- Q2 Binomial Heap -----
local
    fun {NewHeap} nil end
    %
    fun {Link N1 N2} % make a bigger tree from two trees with the same rank
        node(R E1 T1) = N1
        node(_ E2 T2) = N2
    in
        if E1 < E2
        then node(R+1 E1 N2|T1)
        else node(R+1 E2 N1|T2)
        end
    end
    %
    fun {InsTree T Ls} % Insert one tree in the list of trees.
        {Browse insTree(T Ls)}
        case Ls of nil then [T]
        [] L|Lr then
            if T.1 < L.1 then T|Ls
            elseif L.1 < T.1 then L|{InsTree T Lr}
            else {InsTree {Link T L} Lr}
            end
        end
    end
    %
    fun {Insert X Ts} % Insert one element in the Heap
        {Browse insert(X Ts)}
        {InsTree node(0 X nil) Ts}
    end
    %
    fun {Merge Ts Us} % Merge two heaps
        case Ts#Us
        of nil#_ then Us
        [] _#nil then Ts
        [] (T|Tr)#(U|Ur) then
            if T.1 < U.1 then T|{Merge Tr Us}
            elseif T.1 > U.1 then U|{Merge Ts Ur}
            else {InsTree {Link T U} {Merge Tr Ur}}
            end
        end
    end
    %
    fun {RemoveMinTree Ts} % Get the tree with the minimal root in the list, and the remaining ones altogether.
        case Ts
        of [T] then pair(T nil)
        [] T|Tr then
            pair(L Lr) = {RemoveMinTree Tr}
        in
            if T.2 < L.2 then pair(T Tr)
            else pair(L T|Lr)
            end
        end
    end
    %
    fun {FindMin Ts} % Get the minimal value in the heap
        {RemoveMinTree Ts}.1.2
    end
    %
    fun {DeleteMin Ts} % Get the heap minus the minimum element.
        pair(T Tr) = {RemoveMinTree Ts}
    in
        {Merge {Reverse T.3} Tr}
    end
    %
    fun {Ints N}
        0|{Arity {Tuple.make i N}}
    end
in
    {Browse {Insert 5 nil}}
    % {Browse {Ints 9}}
    % {Browse {FoldR {Ints 9} Insert {NewHeap}}}
end