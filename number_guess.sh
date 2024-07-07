#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=game -t --tuples-only --no-align -c"
echo -e "\n ~~~~~ Number Guessing Game ~~~~~\n"

max=1000
NUMBER=$(($RANDOM%($max)+1))
TURN=0

echo -e "\nEnter your username:"
read USERNAME
NAME=$($PSQL "SELECT name FROM users WHERE name = '$USERNAME'")
if [[ -z $NAME ]]
then
  CREATE_USER=$($PSQL "INSERT INTO users(name, games_played, best_game) VALUES('$USERNAME', 0, 0)")
  NAME=$($PSQL "SELECT name FROM users WHERE name = '$USERNAME'")
  echo -e "Welcome, $NAME! It looks like this is your first time here."
else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE name = '$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE name = '$USERNAME'")
  echo -e "Welcome back, $NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  
fi

GAME_FLOW() {
  read GUESS
    if [[ ! $GUESS =~ [0-9]+ ]]
      then 
        echo "\nThat is not an integer, guess again:"
        GAME_FLOW
    elif [[ $GUESS < $NUMBER ]]
      then
        echo -e "\nIt's higher than that, guess again:"
        TURN=$(( $TURN + 1 ))
        GAME_FLOW
    elif [[ $GUESS > $NUMBER ]]
      then
        echo -e "\nIt's lower than that, guess again:"
        TURN=$(( $TURN + 1 ))
        GAME_FLOW
    else
      TURN=$(( $TURN + 1 ))
      UPDATE_GAMES_PLAYED
      UPDATE_BEST_GAME
    fi
}

UPDATE_GAMES_PLAYED() {
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE name = '$NAME'")
  SET_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played = $(( $GAMES_PLAYED + 1 )) WHERE name='$NAME' ")
}

UPDATE_BEST_GAME() {
  CURRENT_BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE name = '$NAME'")
  if [[ $CURRENT_BEST_GAME -gt $TURN || $CURRENT_BEST_GAME = 0 ]]
  then
    SET_BEST_GAME=$($PSQL "UPDATE users SET best_game = $TURN WHERE name='$NAME' ")
  fi
}

echo -e "\nGuess the secret number between 1 and 1000:"
GAME_FLOW

echo -e "You guessed it in $TURN tries. The secret number was $NUMBER. Nice job!"
