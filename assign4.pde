PImage title, gameover, startNormal, startHovered, restartNormal, restartHovered;
PImage groundhogIdle, groundhogLeft, groundhogRight, groundhogDown;
PImage bg, life, cabbage, stone1, stone2, soilEmpty;
PImage soldier;
PImage soil0, soil1, soil2, soil3, soil4, soil5;
PImage[][] soils, stones;
PImage heartImg;

final int GAME_START = 0, GAME_RUN = 1, GAME_OVER = 2;
int gameState = 0;

final int GRASS_HEIGHT = 15;
final int SOIL_COL_COUNT = 8;
final int SOIL_ROW_COUNT = 24;
final int SOIL_SIZE = 80;

int[][] soilHealth;

final int START_BUTTON_WIDTH = 144;
final int START_BUTTON_HEIGHT = 60;
final int START_BUTTON_X = 248;
final int START_BUTTON_Y = 360;

float[] cabbageX = new float[7], cabbageY= new float[7], soldierX = new float[7], soldierY= new float[7];
float soldierSpeed = 2f;

float playerX, playerY;
int playerCol, playerRow;
final float PLAYER_INIT_X = 4 * SOIL_SIZE;
final float PLAYER_INIT_Y = - SOIL_SIZE;
boolean leftState = false;
boolean rightState = false;
boolean downState = false;
int playerHealth = 2;
final int PLAYER_MAX_HEALTH = 5;
int playerMoveDirection = 0;
int playerMoveTimer = 0;
int playerMoveDuration = 15;

boolean demoMode = false;

float playerXb, playerXs, playerYb, playerYs;
float soldxb[] = new float[7], soldxs[]= new float[7], soldyb[]= new float[7], soldys[]= new float[7];
float foodxb[] = new float[7], foodxs[]= new float[7], foodyb[]= new float[7], foodys[]= new float[7];
void setup() {
  size(640, 480, P2D);
  bg = loadImage("img/bg.jpg");
  title = loadImage("img/title.jpg");
  gameover = loadImage("img/gameover.jpg");
  startNormal = loadImage("img/startNormal.png");
  startHovered = loadImage("img/startHovered.png");
  restartNormal = loadImage("img/restartNormal.png");
  restartHovered = loadImage("img/restartHovered.png");
  groundhogIdle = loadImage("img/groundhogIdle.png");
  groundhogLeft = loadImage("img/groundhogLeft.png");
  groundhogRight = loadImage("img/groundhogRight.png");
  groundhogDown = loadImage("img/groundhogDown.png");
  life = loadImage("img/life.png");
  soldier = loadImage("img/soldier.png");
  cabbage = loadImage("img/cabbage.png");
  heartImg =loadImage("img/life.png");
  soilEmpty = loadImage("img/soils/soilEmpty.png");

  // Load soil images used in assign3 if you don't plan to finish requirement #6
  soil0 = loadImage("img/soil0.png");
  soil1 = loadImage("img/soil1.png");
  soil2 = loadImage("img/soil2.png");
  soil3 = loadImage("img/soil3.png");
  soil4 = loadImage("img/soil4.png");
  soil5 = loadImage("img/soil5.png");

  // Load PImage[][] soils
  soils = new PImage[6][5];
  for (int i = 0; i < soils.length; i++) {
    for (int j = 0; j < soils[i].length; j++) {
      soils[i][j] = loadImage("img/soils/soil" + i + "/soil" + i + "_" + j + ".png");
    }
  }

  // Load PImage[][] stones
  stones = new PImage[2][5];
  for (int i = 0; i < stones.length; i++) {
    for (int j = 0; j < stones[i].length; j++) {
      stones[i][j] = loadImage("img/stones/stone" + i + "/stone" + i + "_" + j + ".png");
    }
  }

  // Initialize player
  playerX = PLAYER_INIT_X;
  playerY = PLAYER_INIT_Y;
  playerCol = (int) (playerX / SOIL_SIZE);
  playerRow = (int) (playerY / SOIL_SIZE);
  playerMoveTimer = 0;
  playerHealth = 2;

  // Initialize soilHealth
  soilHealth = new int[SOIL_COL_COUNT][SOIL_ROW_COUNT];
  for (int i = 0; i < soilHealth.length; i++) {
    for (int j = 0; j < soilHealth[i].length; j++) {
      // 0: no soil, 15: soil only, 30: 1 stone, 45: 2 stones
      soilHealth[i][j] = 15;
    }
  }

  // Initialize soidiers and their position
  for (int i =0; i<6; i++) {
    soldierX[i] = 0;
  }
  for (int i =0; i<6; i++) {
    soldierY[i] =80*(int)random(i*4, i*4+4);
  }

  // Initialize cabbages and their position
  for (int i =0; i<6; i++) {
    cabbageX[i] = (int)random(0, 7)*80;
  }
  for (int i =0; i<6; i++) {
    cabbageY[i] =80*(int)random(i*4, i*4+4);
  }
}




void draw() {

  switch (gameState) {

  case GAME_START: // Start Screen
    image(title, 0, 0);
    if (START_BUTTON_X + START_BUTTON_WIDTH > mouseX
      && START_BUTTON_X < mouseX
      && START_BUTTON_Y + START_BUTTON_HEIGHT > mouseY
      && START_BUTTON_Y < mouseY) {

      image(startHovered, START_BUTTON_X, START_BUTTON_Y);
      if (mousePressed) {
        gameState = GAME_RUN;
        mousePressed = false;
      }
    } else {

      image(startNormal, START_BUTTON_X, START_BUTTON_Y);
    }

    break;

  case GAME_RUN: // In-Game
    // Background
    image(bg, 0, 0);

    // Sun
    stroke(255, 255, 0);
    strokeWeight(5);
    fill(253, 184, 19);
    ellipse(590, 50, 120, 120);

    // CAREFUL!
    // Because of how this translate value is calculated, the Y value of the ground level is actually 0
    pushMatrix();
    translate(0, max(SOIL_SIZE * -18, SOIL_SIZE * 1 - playerY));

    // Ground

    fill(124, 204, 25);
    noStroke();
    rect(0, -GRASS_HEIGHT, width, GRASS_HEIGHT);
    boom();
    // Soil

    for (int i = 0; i < soilHealth.length; i++) {
      for (int j = 0; j < soilHealth[i].length; j++) {

        // Change this part to show soil and stone images based on soilHealth value
        // NOTE: To avoid errors on webpage, you can either use floor(j / 4) or (int)(j / 4) to make sure it's an integer.
        int areaIndex = floor(j / 4);
        image(soils[areaIndex][4], i * SOIL_SIZE, j * SOIL_SIZE);
      }
    }

    //stone
    for (int i=0; i<8; i++) {//layer1 to 8
      image(stones[0][4], i*80, i*80);
    }
    for (int i=0; i<8; i++) {//layer9-16
      for (int j=8; j<16; j++) {
        if (j==8 || j==11||j==12||j==15) {
          if (i==1 || i==2||i==5||i==6) {
            image(stones[0][4], i*80, j*80);
          }
        } else {
          if (i==0 || i==3||i==4||i==7) {
            image(stones[0][4], i*80, j*80);
          }
        }
      }
    }

    for (int i=0; i<8; i++) {//layer17-24
      for (int j=16; j<24; j++) {
        if (i+j==17||i+j==18||i+j==20||i+j==21||i+j==23||i+j==24||i+j==26||i+j==27||i+j==29||i+j==30) {
          image(stones[0][4], i*80, j*80);
          if (i+j==18||i+j==21||i+j==24||i+j==27||i+j==30) {
            image(stones[1][4], i*80, j*80);
          }
        }
      }
    }

    // Cabbages
    // > Remember to check if playerHealth is smaller than PLAYER_MAX_HEALTH!

    // Groundhog

    PImage groundhogDisplay = groundhogIdle;

    // If player is not moving, we have to decide what player has to do next
    if (playerMoveTimer == 0) {

      // HINT:
      // You can use playerCol and playerRow to get which soil player is currently on

      // Check if "player is NOT at the bottom AND the soil under the player is empty"
      // > If so, then force moving down by setting playerMoveDirection and playerMoveTimer (see downState part below for example)
      // > Else then determine player's action based on input state

      if (leftState) {

        groundhogDisplay = groundhogLeft;

        // Check left boundary
        if (playerCol > 0) {

          // HINT:
          // Check if "player is NOT above the ground AND there's soil on the left"
          // > If so, dig it and decrease its health
          // > Else then start moving (set playerMoveDirection and playerMoveTimer)

          playerMoveDirection = LEFT;
          playerMoveTimer = playerMoveDuration;
        }
      } else if (rightState) {

        groundhogDisplay = groundhogRight;

        // Check right boundary
        if (playerCol < SOIL_COL_COUNT - 1) {

          // HINT:
          // Check if "player is NOT above the ground AND there's soil on the right"
          // > If so, dig it and decrease its health
          // > Else then start moving (set playerMoveDirection and playerMoveTimer)

          playerMoveDirection = RIGHT;
          playerMoveTimer = playerMoveDuration;
        }
      } else if (downState) {

        groundhogDisplay = groundhogDown;

        // Check bottom boundary

        // HINT:
        // We have already checked "player is NOT at the bottom AND the soil under the player is empty",
        // and since we can only get here when the above statement is false,
        // we only have to check again if "player is NOT at the bottom" to make sure there won't be out-of-bound exception
        if (playerRow < SOIL_ROW_COUNT - 1) {

          // > If so, dig it and decrease its health

          // For requirement #3:
          // Note that player never needs to move down as it will always fall automatically,
          // so the following 2 lines can be removed once you finish requirement #3

          playerMoveDirection = DOWN;
          playerMoveTimer = playerMoveDuration;
        }
      }
    }

    // If player is now moving?
    // (Separated if-else so player can actually move as soon as an action starts)
    // (I don't think you have to change any of these)

    if (playerMoveTimer > 0) {

      playerMoveTimer --;
      switch(playerMoveDirection) {

      case LEFT:
        groundhogDisplay = groundhogLeft;
        if (playerMoveTimer == 0) {
          playerCol--;
          playerX = SOIL_SIZE * playerCol;
        } else {
          playerX = (float(playerMoveTimer) / playerMoveDuration + playerCol - 1) * SOIL_SIZE;
        }
        break;

      case RIGHT:
        groundhogDisplay = groundhogRight;
        if (playerMoveTimer == 0) {
          playerCol++;
          playerX = SOIL_SIZE * playerCol;
        } else {
          playerX = (1f - float(playerMoveTimer) / playerMoveDuration + playerCol) * SOIL_SIZE;
        }
        break;

      case DOWN:
        groundhogDisplay = groundhogDown;
        if (playerMoveTimer == 0) {
          playerRow++;
          playerY = SOIL_SIZE * playerRow;
        } else {
          playerY = (1f - float(playerMoveTimer) / playerMoveDuration + playerRow) * SOIL_SIZE;
        }
        break;
      }
    }

    image(groundhogDisplay, playerX, playerY);

    // Soldiers
    for (int i =0; i<6; i++) {
      for (int x =0; x<4; x++) {
        for (int j =0; j<6; j++) {
          image(soldier, soldierX[i], soldierY[j]);

          if (soldierX[i]>=640) {
            soldierX[i]=0;
            soldierY[i] =80*(int)random(i*4, i*4+4);
          }
        }
      }
      soldierX[i]+=soldierSpeed;
    }

    for (int i =0; i<6; i++) {
      image(cabbage, cabbageX[i], cabbageY[i]);
    }
    // > Remember to stop player's moving! (reset playerMoveTimer)
    // > Remember to recalculate playerCol/playerRow when you reset playerX/playerY!
    // > Remember to reset the soil under player's original position!

    // Demo mode: Show the value of soilHealth on each soil
    // (DO NOT CHANGE THE CODE HERE!)

    if (demoMode) {	

      fill(255);
      textSize(26);
      textAlign(LEFT, TOP);

      for (int i = 0; i < soilHealth.length; i++) {
        for (int j = 0; j < soilHealth[i].length; j++) {
          text(soilHealth[i][j], i * SOIL_SIZE, j * SOIL_SIZE);
        }
      }
    }

    popMatrix();

    // Health UI
      if(playerHealth==0){gameState =GAME_OVER;}
    else if(playerHealth<=5){
    for (int i=0; i<playerHealth; i++)
    {
      image(heartImg, 10+i*70, 10);
    }
    } 

    break;

  case GAME_OVER: // Gameover Screen
    image(gameover, 0, 0);

    if (START_BUTTON_X + START_BUTTON_WIDTH > mouseX
      && START_BUTTON_X < mouseX
      && START_BUTTON_Y + START_BUTTON_HEIGHT > mouseY
      && START_BUTTON_Y < mouseY) {

      image(restartHovered, START_BUTTON_X, START_BUTTON_Y);
      if (mousePressed) {
        gameState = GAME_RUN;
        mousePressed = false;

        // Initialize player
        playerX = PLAYER_INIT_X;
        playerY = PLAYER_INIT_Y;
        playerCol = (int) (playerX / SOIL_SIZE);
        playerRow = (int) (playerY / SOIL_SIZE);
        playerMoveTimer = 0;
        playerHealth = 2;

        // Initialize soilHealth
        soilHealth = new int[SOIL_COL_COUNT][SOIL_ROW_COUNT];
        for (int i = 0; i < soilHealth.length; i++) {
          for (int j = 0; j < soilHealth[i].length; j++) {
            // 0: no soil, 15: soil only, 30: 1 stone, 45: 2 stones
            soilHealth[i][j] = 15;
          }
        }

        // Initialize soidiers and their position

        // Initialize cabbages and their position
      }
    } else {

      image(restartNormal, START_BUTTON_X, START_BUTTON_Y);
    }
    break;
  }
}

void keyPressed() {
  if (key==CODED) {
    switch(keyCode) {
    case LEFT:
      leftState = true;
      break;
    case RIGHT:
      rightState = true;
      break;
    case DOWN:
      downState = true;
      break;
    }
  } else {
    if (key=='b') {
      // Press B to toggle demo mode
      demoMode = !demoMode;
    }
  }
}

void keyReleased() {
  if (key==CODED) {
    switch(keyCode) {
    case LEFT:
      leftState = false;
      break;
    case RIGHT:
      rightState = false;
      break;
    case DOWN:
      downState = false;
      break;
    }
  }
}

void boom() {
  for (int i = 0; i<6; i++) {
    playerXs = playerX - 80 / 2;
    playerXb = playerX + 80 / 2;
    playerYs = playerY - 80 / 2;
    playerYb = playerY + 80 / 2;

    soldxs[i] = soldierX[i] - 80 / 2;
    soldxb[i] = soldierX[i] + 80 / 2;
    soldys[i] = soldierY[i] - 80 / 2;
    soldyb[i] = soldierY[i] + 80 / 2;

    foodxs[i] = cabbageX[i] - 80 / 2;
    foodxb[i] = cabbageX[i] + 80 / 2;
    foodys[i]= cabbageY[i] - 80 / 2;
    foodyb[i] = cabbageY[i] + 80 / 2;

    if (playerXb >soldxs[i] && soldxb[i] > playerXs &&
      playerYb > soldys[i] && soldyb[i] > playerYs) {
      playerHealth--;

      playerX = 320;
      playerY = 80;
image(soils[0][0], 0 * SOIL_SIZE, 3 * SOIL_SIZE);
    }

    if (playerXb >foodxs[i] && foodxb[i] > playerXs &&
      playerYb > foodys[i] && foodyb[i] > playerYs) {
      playerHealth++;
      cabbageX[i]=-80;
      cabbageY[i] =0;
      
    }
  }
}

