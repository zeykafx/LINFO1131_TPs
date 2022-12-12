% ----- Q1 -----
local
    proc {NewPort S P}
        P = {NewCell S}
    end
    %
    proc {Send P Msg}
            NewTail
    in
        {Exchange P Msg|NewTail NewTail}
        % or we could use a lock: lock L then ...
        % @P = Msg|NewTail
        % P := NewTail
    end    
    Port Stream
in
    {Browse Stream}
    {NewPort Stream Port}
    for I in 0..100 do
        thread {Send Port I} end
    end
end

% ----- Q2 -----

local 
    X
    C = {NewCell 0}
in 
    % X = C := X+1 % this doesn't work because X is unbound
    % {Exchange C X thread X+1 end}
    % we put the X+1 in a thread to avoid being blocked on the unbound variable
    for I in 0..10 do
        thread 
            {Exchange C I thread I+1 end}   
            {Browse @C}
        end
    end
end

% ----- Q3 -----
local
    class BankAccount
        attr value l
        meth init()
            value := 0
            l := {NewLock}
        end
        %
        meth deposit(Amount)
            lock @l then
                value := @value + Amount
            end
        end
        %
        meth withdraw(Amount)
            lock @l then
                value := @value - Amount
            end
        end
        %
        meth getBalance($)
            lock @l then
                @value
            end
        end
        %
        % ----- Q4 -----
        meth transfer(To Amount) 
            lock @l then
                if @value-Amount > 0 then
                    value := @value - Amount
                    {To deposit(Amount)}
                else
                    {Browse 'not enough funds'}
                end
            end
        end
    end
    BankAcc1 BankAcc2
in
    % BankAcc1 = {New BankAccount init()}
    % for I in 1..10 do
    %     thread
    %         {BankAcc1 deposit(I)}
    %     end
    %     % {BankAcc1 withdraw(10)}
    % end
    % {Delay 100} % make sure all the thtreads finish
    % {BankAcc1 getBalance(X)}
    % {Browse X}
    %
    % ----- Q4 -----
    BankAcc1 = {New BankAccount init()}
    BankAcc2 = {New BankAccount init()}
    {BankAcc1 deposit(50)}
    {BankAcc2 deposit(50)}
    {BankAcc1 transfer(BankAcc2 25)}
    {Browse {BankAcc1 getBalance($)}}
    {Browse {BankAcc2 getBalance($)}}
end

% ----- Q5 -----
