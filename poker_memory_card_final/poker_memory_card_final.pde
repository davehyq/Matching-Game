PFont font;
PImage background;
PImage board;
int tn = 22;  // total number of cards
int[] cardN = new int[tn];  // card number
boolean[] fc = new boolean[tn];  // flipcard
boolean[] sc = new boolean[tn];  // show card
float[] rota = new float[tn];    // rotation
int[] dx = new int[tn];  // displacement x
int[] dy = new int[tn];  // displacement y
int completionTime;
boolean ready = false;
int pcard = tn - 1;
int ccard = tn - 2;
String score = " ";
int state = 0; 
int miss = 0;  // mistakes count
boolean gameMode = false;  // toggle between game modes
int anmcounter = 0;  // Animation counter
boolean isGameActive = true;  // This indicates if the game is active or finished.
int timeLimit = 90; // Time limit
int st; // game starts starttime
int tl; // Timeleft
int buttonX, buttonY, buttonW, buttonH;
String buttonText = "Restart Game";
//start button
int startButtonX, startButtonY, startButtonW, startButtonH;
boolean gameStarted = false;
String startButtonText = "Start Game";
//sound import
import processing.sound.*;
SoundFile mouseClick; // Declare the SoundFile object
SoundFile winSound; 
SoundFile matchSound;
SoundFile loseSound;
boolean matchSoundPlayed = false;


void setup() {
  size(1600, 1060);
  background = loadImage("green1.png");
  board = loadImage("board.png");
  font = createFont("ArialMT", 32);
  textFont(font, 32);
  rectMode(CENTER);
  textAlign(CENTER);
  smooth();
  noStroke();
  initCard();
  shuffle();

  // Initialize the restart button at the bottom of the screen
  buttonW = 200;
  buttonH = 50;
  buttonX = 1400;
  buttonY = height - 200; // 100 pixels from the bottom

  // Initialize the start button at the top of the screen
  startButtonW = 200;
  startButtonH = 50;
  startButtonX = 1400;
  startButtonY = height - 300; // Above the restart button

  // Set gameStarted to false initially
  gameStarted = false;
  isGameActive = false; // The game should not be active until "Start" is pressed
  mouseClick = new SoundFile(this, "mouseclick.mp3");
  winSound = new SoundFile(this, "win.wav");
  matchSound = new SoundFile(this, "matchsound.mp3");
  loseSound = new SoundFile(this, "lose.wav");
//wrongSound = new SoundFile(this, "wrong.mp3");
}


void draw() {
  image(background, 0, 0, width, height); // This scales the image to fit the screen
  pokertable(); // Draw the poker table
  
  // Draw the borad
  image(board, 430, height - 420, 800, 370);
  fill(#FFFFFF);
  textSize(24);
  text("Welcome to the Memory Card Game!", 800, 770);
  textSize(20);
  text("Click on two cards to flip them. If they match, they disappear.", 810, 830);
  text("Your goal is to match all the cards within the time limit.", 810, 860);
  
  // Draw the "Start Game" button
  if (!gameStarted) {
    drawStartButton();
  }

  // If the game is active, display the time
  if (isGameActive) {
    displayTime();
    gameLogic();
  }

  // Draw cards on the table
  for (int i = 0; i < tn; i++) {
    int x = 50 + (i % 11) * 90 + dx[i] + 300;
    int y = 80 + (int(i / 11)) * 120 + dy[i] + 190;
    pushMatrix();
    translate(x, y);
    rotate(rota[i]);
    card(cardN[i], 0, 0, fc[i], sc[i]);
    popMatrix();
  }

  // draw the "Restart Game" button
  drawButton();
}



void pokertable(){
   // Drawing poker table
  stroke(#360606);
  strokeWeight(40);
  fill(#173901);
  rect(width / 2, 370, 1164, 530, 400);
  noFill();
  strokeWeight(10);
  stroke(0);
  rect(width / 2, 370, 1134, 500, 400);
  
}

void drawStartButton() {
  pushStyle();
  fill(#710505); // Button color
  stroke(#FFFFFF); // Button border color
  strokeWeight(2); // Border weight
  rect(startButtonX, startButtonY, startButtonW, startButtonH, 7); // Rounded corners with radius 7
  fill(#FFFFFF); // Text color
  textSize(20);
  textAlign(CENTER, CENTER);
  text(startButtonText, startButtonX , startButtonY );
  popStyle();
}

void drawButton() {
  pushStyle();
  fill(#710505);
  stroke(#FFFFFF);
  strokeWeight(2);
  rect(buttonX, buttonY, buttonW, buttonH, 7);
  fill(#FFFFFF);
  textSize(20);
  textAlign(CENTER, CENTER);
  text(buttonText, buttonX, buttonY);
  popStyle();
}


void displayTime() {
  if (st == 0) {  // calculate time when the game has started
    
    tl = timeLimit;
  }else {
    // Calculate  time in seconds when the game has started.
    int elapsedTime = (millis() - st) / 1000;
    tl = timeLimit - elapsedTime;

    //game end when time runs out.
    if (tl <= 0) {
      tl = 0; 
      handleGameEnd();
    }
  }

  // show the time left and mistakes
  fill(255);
  textSize(32);
  // Add a shadow for the text
  fill(0, 100);
  text("Time left: " + tl, 152, 52);
  text("Mistakes: " + miss, width - 152, 52); // shadow position
  fill(255);
  text("Time left: " + tl, 150, 50);
  text("Mistakes: " + miss, width - 150, 50); 
}

void mousePressed() {
  
  mouseClick.play();
  // Restart button 
  if (mouseX >= buttonX && mouseX <= buttonX + buttonW && mouseY >= buttonY && mouseY <= buttonY + buttonH) {
    restartGame();
  }
  // Start button 
  else if (mouseX > startButtonX && mouseX < startButtonX + startButtonW &&
           mouseY > startButtonY && mouseY < startButtonY + startButtonH) {
    if (!gameStarted) { // If the game has not started, then start the game
      gameStarted = true;
      st = millis(); // Set the start time to the current time
      isGameActive = true;
    }
  }
  // Card flip logic
  else if (gameStarted && isGameActive) {
    checkCardClick();
  }
}

void keyPressed() {
  if (key == ' ') {
    gameMode = !gameMode;
    initCard();
    shuffle();
  }
}


void initCard() {
  ready = false;
  anmcounter = 0;
  pcard = tn - 1;
  ccard = tn - 2;
  score = " ";
  state = 0;
  miss = 0;
  st = 0;
  for (int i = 0; i < tn; i++) {
    cardN[i] = i % 11;
    rota[i] = random(-0.2, 0.2);
    dx[i] = floor(random(-15, 15));
    dy[i] = floor(random(-15, 15));
    fc[i] = false;
    sc[i] = true;
  }
}

void shuffle() {
  for (int i = 0; i < tn; i++) {
    int r = floor(random(tn));
    int t = cardN[r];
    cardN[r] = cardN[i];
    cardN[i] = t;
  }
}

void card(int n, int x, int y, boolean fc, boolean sc) {
  if (sc) {
    int r = 8;
    int cw = 75;
    int ch = 105;
    fill(255);
    strokeWeight(0);
    ellipse(x - cw / 2 + r, y - ch / 2 + r, r * 2, r * 2);
    ellipse(x + cw / 2 - r - 1, y - ch / 2 + r, r * 2, r * 2);
    ellipse(x - cw / 2 + r, y + ch / 2 - r - 1, r * 2, r * 2);
    ellipse(x + cw / 2 - r - 1, y + ch / 2 - r - 1, r * 2, r * 2);
    rect(x, y, cw - r * 2, ch - 1);
    rect(x, y, cw - 1, ch - r * 2);
    if (fc == false) {
      fill(150, 120, 120);
      rect(x, y, cw - r * 2, ch - r * 2);

      
    } else {
      String pt = toSuit(n);
      String num = toNumber(n);
      if (n < 52) {
        textSize(32);
        if (pt == "♥" || pt == "♦") {
          fill(255, 0, 0);
        } else {
          fill(0);
        }
        text(pt, x + cw / 2 - 12, y - ch / 2 + r * 3);
        text(pt, x - cw / 2 + 12, y + ch / 2 - 4);
        textFont(font, 36);
        text(num, x, y + 13);
      } else { // 
        fill(0);
        textSize(20);
        text(num, x, y + 13);
      }
    }
  }
}

String toNumber(int n) {
  String s;
  int i = n % 13 + 1;
  if (n < 52) {
    if (i == 1) {
      s = "A";
    } else if (i == 11) {
      s = "J";
    } else if (i == 12) {
      s = "Q";
    } else if (i == 13) {
      s = "K";
    } else {
      s = str(i);
    }
  } else {
    s = "JOKER";
  }
  return s;
}

String toSuit(int n) {
  String s;
  int i = int(n / 13);
  if (i == 0) {
    s = "♠";
  } else if (i == 1) {
    s = "♣";
  } else if (i == 2) {
    s = "♥";
  } else if (i == 3) {
    s = "♦";
  } else {
    s = " ";
  }
  return s;
}

boolean allMatched() {
  for (int i = 0; i < tn; i++) {
    if (sc[i]) {
      return false;
    }
  }
  return true;
}

void gameLogic() {
  //game logic based on state
  if (state == 0) {
    score = "CLICK A CARD";
    ready = true;
  } else if (state == 1) {
    score = "CLICK ANOTHER ONE";
  } else if (state == 2) {
    handleCardMatching();
  } else if (state == 3) {
    handleGameEnd();
  }
  if (allMatched() && isGameActive) {
    handleGameEnd();
  }

  fill(#938E8E);
  textSize(28);
  text(score, width / 2, 610);
}

void handleCardMatching() {
    int cp = cardN[pcard];
    int cc = cardN[ccard];

    // Check if the cards match
    if ((cp < 52 && cc < 52 && cp % 13 == cc % 13) || (cc > 51 && cp > 51)) {
        score = "MATCHED";
        if (!matchSoundPlayed && matchSound != null) {
            matchSound.play(); // Play the match sound
            matchSoundPlayed = true; // Set the flag to true after playing the sound
        }

        if (anmcounter > 40) {
            sc[pcard] = false;
            sc[ccard] = false;
            anmcounter = 0;
            state = 0;
            matchSoundPlayed = false; // Reset the flag for the next match

            if (allMatched()) {
                handleGameEnd();
            }
        }
    } else {
        score = "NOT MATCHED";
        if (anmcounter > 40) {
            fc[pcard] = false;
            fc[ccard] = false;
            anmcounter = 0;
            state = 0;
            miss++;
            matchSoundPlayed = false; // Reset the flag for the next match attempt
        }
    }
    ready = false;
    anmcounter++;
}


void handleGameEnd() {
   // Clear the game area  to overlay the end game text
  fill(0, 0, 0, 150);
  rect(width / 2, height / 2, width, height);
  
  textSize(48);
  textAlign(CENTER);
  if (allMatched()) {
if (winSound != null) {
      winSound.play(); // Play the win sound when the player wins
    }
    fill(0, 255, 0); // Green color for winning
    text("Congratulations! You've won!", width / 2, height / 2);
  } else if (tl <= 0) {
    fill(255, 0, 0); // Red color for losing
    text("Time's up! You've lost!", width / 2, height / 2);
    loseSound.play();
  }

  // Stop the game
  noLoop();
}


void checkCardClick() {
   // This function should only allow flipping cards when the game has started
  if (!gameStarted) {
    return; // Exit the function if the game hasn't started
  }
  for (int i = 0; i < tn; i++) {
    int rectW = 75;
    int rectH = 105;
    int xx = 50 + (i % 11) * 90 + dx[i] + 300;
    int yy = 80 + (int(i / 11)) * 120 + dy[i] + 190;
    float x = (mouseX - xx) * cos(-rota[i]) - (mouseY - yy) * sin(-rota[i]);
    float y = (mouseX - xx) * sin(-rota[i]) + (mouseY - yy) * cos(-rota[i]);
    if (fc[i] == false && sc[i] == true) {
      if (x > -rectW / 2 && x < rectW / 2 && y > -rectH / 2 && y < rectH / 2) {
        if (state < 2) {
          fc[i] = true;
          pcard = ccard;
          ccard = i;
          state++;      
        }
      }
    }
  }
}

// Adjust the restartGame function 
void restartGame() {
  // Reset all game states
  initCard();
  shuffle();
  st = 0; // Reset start time
  miss = 0; // Reset mistakes
  gameStarted = false; // Reset game start state
  isGameActive = false; // Deactivate the game until "Start" is pressed again
  loop(); // Ensure the draw loop continues
}
