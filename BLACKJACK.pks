create or replace package blackjack as 
               
    procedure play;

    -- Prerequisites
    /*
    BEGIN
      DBMS_NETWORK_ACL_ADMIN.append_host_ace (
        host       => 'nav-deckofcards.herokuapp.com', 
        lower_port => 80,
        upper_port => 80,
        ace        => xs$ace_type(privilege_list => xs$name_list('http'),
                                  principal_name => 'BLACKJACK',
                                  principal_type => xs_acl.ptype_db)); 
    END;
    /
    commit
    */
end;