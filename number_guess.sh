#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

#WELCOME MESSAGE
echo -e "\n~~~ WELCOME TO NUMBER GUESSING GAME ~~~\n"
RANDOM_NUMBER=$((RANDOM % 1000 +1))

echo -e "\nEnter your username:"
read USERNAME

#get the username 
USER_NAME=$($PSQL "SELECT user_name FROM users WHERE user_name='$USERNAME'")
GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_name='$USER_NAME'")
BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_name='$USER_NAME'")
#if username doesn't exist
if [[ -z $USER_NAME ]]
then
echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
INSERT_USER_RESULT=$($PSQL "INSERT INTO users(user_name) VALUES('$USERNAME')")
else
#if username exists print "Welcome back, <username>! You have played <games_played> games, and your best game took <best_game> guesses."
echo "Welcome back, $USER_NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

#initiation of number of tries
NUMBER=0
#echo "random number: $RANDOM_NUMBER"
echo -e "\nGuess the secret number between 1 and 1000:"

#function for analyzing games
HANDLE_GUESS () {

#read the number that the user guesses
  read GUESSED_NUMBER
#increment the number of tries
  NUMBER=$(( $NUMBER + 1 ))
#if the user didn't guess a number
  if [[ -z $GUESSED_NUMBER ]]
  then
  echo -e "\nPlease $USER_NAME, give it a try. Just enter any number."
  HANDLE_GUESS
#else if the user didn't guess an integer
  elif ! [[ $GUESSED_NUMBER =~ ^[0-9]*$ ]]
  then
  echo -e "\nThat is not an integer, guess again:"
  HANDLE_GUESS
#if guessed number is greater than the random number
  elif (( $GUESSED_NUMBER > $RANDOM_NUMBER ))
  then
  echo -e "\nIt's lower than that, guess again:"
  HANDLE_GUESS
  #if guessed number is less than the random number
  elif (( $GUESSED_NUMBER < $RANDOM_NUMBER ))
  then
  echo -e "\nIt's higher than that, guess again:" 
  HANDLE_GUESS
  #if the guessed number is equal to the random number
  elif (( $GUESSED_NUMBER == $RANDOM_NUMBER ))
  then
  echo -e "\nYou guessed it in $NUMBER tries. The secret number was $RANDOM_NUMBER. Nice job!"
  GAMES_PLAYED=$(( $GAMES_PLAYED + 1 ))
  #update number of games the user has played
  UPDATE_GAMES_RESULT=$($PSQL "UPDATE users SET games_played  = $GAMES_PLAYED WHERE user_name = '$USERNAME'")
  #echo "the result of updating game is: $UPDATE_GAMES_RESULT, games_played = $GAMES_PLAYED"
  # if the user has increased efficiency, update the best game
  if [[ -z $BEST_GAME || $BEST_GAME -gt $NUMBER ]]
  then
  UPDATE_BEST_GAME_RESULT=$($PSQL "UPDATE users SET best_game = $NUMBER WHERE user_name = '$USERNAME'")
  #echo "after updating best game, now it is: $UPDATE_BEST_GAME_RESULT, best_game = $BEST_GAME"
  fi
  fi
}
HANDLE_GUESS

