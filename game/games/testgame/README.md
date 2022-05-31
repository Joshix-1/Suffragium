# How to add you own Minigame
## A Step by step Guide

### 1. Chose a folder
All files related only to your game go into a folder inside res://games/. You shouldn't rename it after the game is first merged. 
There are no rules what to call it but a good Idea is to use your name and the games name (ex. "asecondguy_assimilator") to avoid any accidental collisions.

### 2. Make a game.cfg
The game.cfg file resides in your Minigame's folder. It defines how your game is displayed. 
If you are unsure copy the game.cfg from the testgame and change the values.
It will always contain all required and optional settings clearly marked.

### 3. Make your game work
* GameManager is always available in every script and has useful functions. (like `end_game` and `get_high_score()`)
* To save things that aren't scores while running the game, use `GameManager.save_game_data("some_key", {"data": 2})` and `GameManager.load_game_data("some_key")`
* Don't add Autoload scripts. They are loaded on startup and run all the time so it is bad practice to use one in a minigame.
* The scene you defined in game.cfg will be loaded with get_tree().change_scene(). So It'll work like it is the mainscene.
* To return to the game selection use `GameManager.end_game("This is the end message", score)`, where score is a number that represents the score of the player.

