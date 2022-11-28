% ----- Q1 -----
local
    proc {InOrder Tree S E}
        case Tree
        of leaf then S=E
        [] tree(Val L R) then 
            M in
                {InOrder L S Val|M}
                {InOrder R M E}
        end
    end
    %
    Tree = tree(4
        tree(2
            tree(1 leaf leaf)
            tree(3 leaf leaf))
        tree(7
            tree(6
                tree(5 leaf leaf)
                leaf)
            tree(8
                leaf
                tree(9 leaf leaf))))
    %
    List
    %
    fun {Promenade Tree Tail}
        case Tree
        of tree(V L R) then {Promenade L V|{Promenade R Tail}}
        [] leaf then Tail
        end
    end
in
    {InOrder Tree List nil}
    {Browse List}
    {Browse {Promenade Tree nil}}
end


% ----- Q2 -----
local
    fun {NewQueue} 
        q(nil nil)
    end
    %
    fun {Check Q}
        case Q 
        of q(nil R) then 
            q({Reverse R} nil) 
        else 
            Q 
        end
    end
    %
    fun {Insert Q X}
        case Q 
        of q(F R) then 
            {Check q(F X|R)} % add X in the front of R, then check the queue
        end
    end
    %
    fun {Delete Q X}
        case Q 
        of q(F R) then 
            F1 
        in 
            % reminder: equality goes both ways in OZ
            F=X|F1 % Destructuring F into X and F1,
            % e.g. F=1|nil, doing F=X|F1 is equal to 1|nil = X|F1 -> X=1 and F1=nil 
            {Check q(F1 R)} 
        end
    end
    %
    Q Q1 X1
in
    Q={Insert {Insert {Insert {NewQueue} 1} 2} 3}
    {Browse Q}
    %
    Q1={Delete Q X1}
    {Browse Q1}
    {Browse X1}
    % failure if you try to delete more elements than available
end

% ----- Q3 -----

declare
fun {Test NewQueue Insert Delete}
    try
        
        persistent
    catch _ then
        ephemeral
    end
end