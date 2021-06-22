# blackjack
# Small plsql program demonstrating a game of Blackjack using a deck provided as a json array.
# Took the oportunity to use oracle's native json capabilities and ended up going with json_table to transform the array into a recordset.
# Turns out I could probably have got away with using 12.2
# sys_ref_cursor as I like to be able to pass the cursor around.
