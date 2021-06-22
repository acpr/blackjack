create or replace package body blackjack
AS

    type a_card IS record (
        suit varchar2(10),
        value varchar2(10),
        points integer,
        total integer
        );
    this_card  a_card;
    type cards is table of a_card index by binary_integer;


    procedure shuffle_deck (rc  out sys_refcursor) is
    begin
        open rc for 
        with json as  
        ( select utl_http.request ( 'http://nav-deckofcards.herokuapp.com/shuffle') doc from dual 
        )  
        select  substr(suit,1,1) suit 
               ,value
               ,case value
                    when 'A' then 11
                    when 'J' then 10
                    when 'Q' then 10
                    when 'K' then 10
                    else to_number(value)
                    end points,
                    null total
          from  json_table( (select doc from json) , '$[*]'  
                        COLUMNS ( suit PATH '$.suit'  
                                , value PATH '$.value'  
                                )  
                       );
    end;

    procedure draw (deck in out sys_refcursor, a_hand in out cards)
    IS
        hand_idx integer:=a_hand.count+1;
    begin
        fetch deck into this_card;
        a_hand(hand_idx).suit:=this_card.suit;
        a_hand(hand_idx).value:=this_card.value;
        a_hand(hand_idx).points:=this_card.points;
        if hand_idx=1 then
          a_hand(hand_idx).total:=this_card.points;
        else
          a_hand(hand_idx).total:=this_card.points+a_hand(hand_idx-1).total;
        end if;  
    end;
    
    function get_winner(my_score in integer,marits_score in integer)  return varchar2 is
    begin
        if my_score>21 then
            return 'Marit';
        elsif marits_score>21 then
            return 'Anthony';
        elsif marits_score>my_score then
            return 'Marit';
        elsif marits_score<my_score then
            return 'Anthony';
        else
            return 'Unknown '||my_score||' / '||marits_score;
        end if;
    end;

    procedure show_hand (owner_label in varchar2, hand in cards) is
        winning_hand varchar2(255):=owner_label||' | '||hand(hand.count).total||' | ';
    begin
        for i in hand.first..hand.last loop
            winning_hand:=winning_hand||hand(i).suit||hand(i).value||', '; 
        end loop;
        winning_hand:=rtrim(winning_hand,', ');
        dbms_output.put_line(winning_hand);
    end;
    
    procedure spool_result(my_hand in cards,marits_hand in cards) is
    begin
        dbms_output.put_line('Winner: '||get_winner(my_hand(my_hand.count).total,marits_hand(marits_hand.count).total));
        dbms_output.put_line ('');
        show_hand(owner_label=>rpad('Anthony''s hand',15,' '), hand=>my_hand);
        show_hand(owner_label=>rpad('Marit''s hand',15,' '), hand=>marits_hand);
    end;    
    
    procedure deal(deck in out sys_refcursor,my_hand out cards,marits_hand out cards) is
    begin
        draw(deck=>deck, a_hand =>my_hand);
        draw(deck=>deck, a_hand =>my_hand);
        draw(deck=>deck, a_hand =>marits_hand);
        draw(deck=>deck, a_hand =>marits_hand);
        while my_hand(my_hand.count).total <18 loop
            draw(deck=>deck, a_hand =>my_hand);
            exit when my_hand(my_hand.count).total>21;
        end loop;
        while my_hand(my_hand.count).total<22 and marits_hand(marits_hand.count).total<=my_hand(my_hand.count).total and marits_hand(marits_hand.count).total<22 loop
            draw(deck=>deck, a_hand =>marits_hand);
        end loop;        
    end;
    
    PROCEDURE play
    IS
        rc sys_refcursor;
        my_hand cards;
        marits_hand cards;
    BEGIN
        dbms_output.enable;
        shuffle_deck(rc=>rc);
        deal(deck=>rc,my_hand=>my_hand,marits_hand=>marits_hand);
        spool_result(my_hand=>my_hand,marits_hand=>marits_hand);
    END;
END;