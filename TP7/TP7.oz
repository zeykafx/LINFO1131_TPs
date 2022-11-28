% ----- Q1 -----
% see flexcil for the state diagram
local
    %  Port object with internal state
    fun {NewPortObject Init Fun}
        P
    in
        thread Sin Sout in
            {NewPort Sin P}
            {FoldL Sin Fun Init Sout}
        end
        P
    end
    % Port object without internal state
    fun {NewPortObject2 Proc}
        P
    in
        thread Sin in
            {NewPort Sin P}
            for Msg in Sin do {Proc Msg} end
        end
        P
    end
    %
    proc {Counter X}
        if X > 0 then   
            {Delay 1000}
            {Browse 'Remaining time '#X#',seconds'}
            {Counter X-1}
        end
    end
    fun {Timer}
        {NewPortObject2
            proc {$ Msg}
            case Msg of starttimer(T Dishwasher) then
                thread {Counter T} {Send Dishwasher stoptimer} end
            end
        end}
    end
    %
    fun {Dishwasher}
        Capacity = 10
        Tid = {Timer}
        Did = {NewPortObject count(0)
            fun {$ count(NbrItem) Msg}
                case Msg
                of fill(I) then
                    if (NbrItem+1 < Capacity) then
                        {Browse I#' added into the dishswasher'}
                        count(NbrItem+1)
                    else
                        if (NbrItem+1==Capacity) then {Browse I#' added into the dishwasher'} end
                        {Browse 'dishwasher is Full'}
                        count(Capacity)
                    end
                [] startwashing(Washer) then 
                    if (NbrItem == Capacity) then
                        {Browse 'Diswasher start washing all the things'}
                        {Send Tid starttimer(10 Washer)}
                    end
                    count(NbrItem)
                [] stoptimer() then 
                    {Browse 'Dishwasher has finished its job'}
                    {Browse 'Dishwasher is empty'}
                    count(0)
                end
            end}
        in
            Did
    end
    %
    DW
in
    DW = {Dishwasher}
    for I in 1..10 do 
        {Send DW fill('glass')}
    end
    {Send DW startwashing(DW)}
end

% ----- Q2 -----
% if we associated the same controller to all the lifts in the building, they would all move at the same time

% ----- Q3 -----
% A. we simply call the function instead of sending messages to the port object
% B. some messages may get lost since the messages aren't stored in any way
% C. yes, the controller isn't an actor anymore, the only actors left are the lift, and the floor

% ----- Q4 -----
