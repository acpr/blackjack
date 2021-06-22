create or replace PACKAGE           blackjack as 
               

    TYPE a_card IS RECORD (
        suit varchar2(10),
        value varchar2(10),
        points integer,
        total integer
        );
    this_card  a_card;
    TYPE cards IS TABLE OF a_card INDEX BY BINARY_INTEGER;

    PROCEDURE init;


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