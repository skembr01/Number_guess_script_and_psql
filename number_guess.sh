#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
RAND_NUM=$[RANDOM % 1000 + 1]

#getting username inputted
echo Enter your username:
read USERNAME_INPUT

#username in database
USERNAME_DATA=$($PSQL "SELECT username FROM number_guess WHERE username='$USERNAME_INPUT'")
if [[ -z $USERNAME_DATA ]]
then
  echo -e "Welcome, $USERNAME_INPUT! It looks like this is your first time here."
  INSERT_NEW_USER=$($PSQL "INSERT INTO number_guess(username, games_played, best_game) VALUES('$USERNAME_INPUT', 1, 0)")
else
  BEST_GAME=$($PSQL "SELECT best_game FROM number_guess WHERE username='$USERNAME_INPUT'")
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM number_guess WHERE username='$USERNAME_INPUT'")
  echo -e "Welcome back, $USERNAME_INPUT! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  ((GAMES_PLAYED=GAMES_PLAYED+1))
  INSERT_GAMES_PLAYED=$($PSQL "UPDATE number_guess SET games_played = $GAMES_PLAYED where username='$USERNAME_INPUT'")
fi
#getting guesses
echo Guess the secret number between 1 and 1000:
read GUESS



NUM_GUESSES=0
#while loop to continue until correct guess
while [[ $GUESS > $RAND_NUM || $GUESS < $RAND_NUM ]]
do
  while [ $((GUESS)) != $GUESS ]
  do
    echo That is not an integer, guess again:
  read GUESS
  done
  if [[ $GUESS -gt $RAND_NUM ]] 
  then 
    echo -e "It's lower than that, guess again:"
  elif [[ $GUESS -lt $RAND_NUM ]] 
  then
    echo -e "It's higher than that, guess again:"
  fi
  read GUESS
  ((NUM_GUESSES=NUM_GUESSES+1))
done

#output when guessed correctly
((NUM_GUESSES=NUM_GUESSES+1))

BEST_GUESS_PRIOR=$($PSQL "SELECT best_game FROM number_guess WHERE username='$USERNAME_INPUT'")
if [[ $BEST_GUESS_PRIOR -lt $NUM_GUESSES ]]
then
  INSERT_BEST=$($PSQL "UPDATE number_guess SET best_game=$NUM_GUESSES WHERE username='$USERNAME_INPUT'")
fi
echo -e "You guessed it in $NUM_GUESSES tries. The secret number was $RAND_NUM. Nice job!"
