This project implements a reaction-based LED chase game on the Basys3 FPGA. 

A target LED is randomly selected and a moving LED cycles across the board. The player must press the center button when the cycling LED
is in the same position as the target LED. Upon success, the player's score will increment until 5 successful rounds have been played in 
a row, at which point the game is won. The player can initiate a reset at any time with the top button. 

The game begins in an idle state where all LEDs flash continuously. Pressing the center button starts the game. 
