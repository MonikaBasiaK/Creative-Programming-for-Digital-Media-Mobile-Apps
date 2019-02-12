
import org.jbox2d.util.nonconvex.*;
import org.jbox2d.dynamics.contacts.*;
import org.jbox2d.testbed.*;
import org.jbox2d.collision.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.p5.*;
import org.jbox2d.dynamics.*;


Maxim maxim;
AudioPlayer skok;
AudioPlayer przysp;
AudioPlayer podklad;
AudioPlayer punkt;
AudioPlayer lightPointSounds;
AudioPlayer[] heavyPointSounds;
AudioPlayer click;
AudioPlayer sow_bum;

Physics physics; 
Body bomb;
Body[] heavyPoints;
Vec2 startPoint, rabbitStartPoint, sowStartPoint;
PVector[] points;
CollisionDetector detector; 

Slider m1, m2, m3, m4;

int isThereAnyPointOnTheWorld = 0;
int M = 40;
int N = 40;
int P = 44;
float[] isThereAPoint = new float[M];
int[] whichPoint = new int[N];
int bombSize = 30;
int rabbitSize = 80;
int sow_thistleSize= 80;
int pointsSize = 30;
boolean dragging = false;
PFont f;
int losowa;
int scoreForRabbit = 1;
int scoreForSow = 1;
int kx, ky, x, j;
int current = 0;
float blysk = 0;
float nowa;
float slows = 0;
float isThereABird = random(0,4);
float counter = 0;
boolean przelacz = true;
boolean panel_or_game = true;
boolean panel_or_fish = false;
boolean panel_or_slider = false;
boolean[] tintFish = new boolean[20];
boolean sowKaput = false;

float ct_m = 0;
float i = 0;
float[] spec;
PImage [] images;
PImage [] kroliczek;
PImage [] mlecz;
PImage panel;
PImage floor, balustrade;
PImage getyou, ohno, revenge;
PImage[] money;
PImage birds;
PImage crossbow;
PImage bombI;
PImage[] pointsImages = new PImage[P];
PImage[] fishImages = new PImage[20];
PImage backButton;
PImage fishPanelBackgroun;

RadioButtons radioButton;

void setup()
{
  //colorMode(RGB);
  size(1000, 1000);
  frameRate(60);
  images = loadImages("l", ".jpg", 21);
  kroliczek = loadImages("kr", ".gif", 6);
  mlecz = loadImages("mlecz", ".gif", 4);
  panel = loadImage("panel.png");
  floor = loadImage("floor.gif");
  balustrade = loadImage("balustrade.gif");
  getyou = loadImage("getyou.png");
  ohno = loadImage("oh.png");
  revenge = loadImage("revenge.png");
  money = loadImages("money", ".png", 5);
  birds = loadImage("birds.gif");
  crossbow = loadImage("crossbow.png");
  bombI = loadImage("bombI.png");
  backButton = loadImage("backButton.png");
  fishPanelBackgroun = loadImage("fishPanelBackgroun.png");
  
  String[] radioNames = {"Play", "Change your fish", "Sound settings", "Quite"};
  radioButton = new RadioButtons(radioNames.length, width/2-150, 30, 300, 35, VERTICAL);
  radioButton.setNames(radioNames);
  //radioButton.setImage(0, panel);
  
  
  for(int i=0; i<pointsImages.length; i++)
  {
    pointsImages[i] = loadImage( i+ ".png");   
  }
  
  for(int i=100; i<100+fishImages.length; i++)
  {
    fishImages[i-100] = loadImage( i+ ".png");   
  }
  
  tintFish[0]=true;
  for(int k=1; k<20; k++)
  {
    tintFish[k] = false;
  }
 
  maxim = new Maxim(this);
  skok = maxim.loadFile("bounce_kroliczek.wav");
  skok.setLooping(false);
  //skok.volume(3);
  przysp = maxim.loadFile("mlecz_bieg.wav");
  przysp.setLooping(false);
  //przysp.volume(2);
  podklad = maxim.loadFile("spring-weather-1.wav");
  punkt = maxim.loadFile("punkt.wav");
  punkt.setLooping(false);
  //podklad.volume(11);
  click = maxim.loadFile("pik.wav");
  click.setLooping(false);
  click.volume(5);
  click.speed(0.5);
  lightPointSounds = maxim.loadFile("he.wav");
  lightPointSounds.setLooping(false);
  //lightPointSounds.volume(3);
  sow_bum = maxim.loadFile("bum.wav");
  sow_bum.setLooping(false);
  sow_bum.volume(3);
  
  
  heavyPointSounds = new AudioPlayer[M];
  for(int i = 0; i<heavyPointSounds.length; i++)
  {
    heavyPointSounds[i] = maxim.loadFile("heav.wav");
    heavyPointSounds[i].setLooping(false);
    //heavyPointSounds[i].volume(3);
  }
 
  f = createFont("Georgia Pogrubiony", 30, true);
  
  physics = new Physics(this, width, (height-panel.height)- 2.15*panel.height-220, 0, -7, width*2, height*2, width, height, 50);
  physics.setCustomRenderingMethod(this, "myCustomRenderer");
  physics.setDensity(6.0);
  
  startPoint = new Vec2(width/2, (height-panel.height)-300);
  startPoint = physics.screenToWorld(startPoint);

  detector = new CollisionDetector(physics, this);
  
  bomb = physics.createCircle(200, (height-panel.height)-330, bombSize/2);
  
  //heavyPoints position
  heavyPoints = new Body[N];
  for (int i = 0; i < heavyPoints.length; i++)
    {
      {
        heavyPoints[i] = physics.createCircle(random(width), random((height-panel.height)- 2.15*panel.height), pointsSize/2);
      }
    }
  
  points = new PVector[M];
  
  if(isThereAnyPointOnTheWorld == 0)
  {
    positionLotteryForPoints();
  }
  
  
  m1 = new Slider("Soundtrack", 40, 0, 40, width/2-300, 310, 600, 40, HORIZONTAL);
  m2 = new Slider("Rabbit bounce", 1.7, 0, 1.7, width/2-300, 350, 600, 40, HORIZONTAL);
  m3 = new Slider("Light point sounds", 10, 0, 10, width/2-300, 390, 600, 40, HORIZONTAL);
  m4 = new Slider("Heavy point sounds", 3.5, 0, 3.5, width/2-300, 430, 600, 40, HORIZONTAL);
 
  
}

void draw()
{
  if(panel_or_game == false && panel_or_fish == false && panel_or_slider == false)
  {
     if (m1.get()>0) 
     {
       podklad.volume((float)m1.get());
      }
    
      if (m2.get()>0) 
      {
        skok.volume((float)m2.get());
      }
      if (m3.get()>0) 
      {
        lightPointSounds.volume((float)m3.get());
      }
        
      if (m4.get()>0) 
      {
        for(int i = 0; i<heavyPointSounds.length; i++)
        {
          heavyPointSounds[i].volume((float)m4.get());
        }
      }
   
   
    kx = (int)kroliczek[0].width/10;
    skok.speed(2);
    //skok.volume(0.5);
    podklad.play();
    //podklad.volume(10);
    
    if(current >= images.length)
    {
      current = 0;
    }
    
    image(images[current], 0, -100, width, height-150);
    if(isThereABird<=1)
    {
      image(birds, (x*1.5 -(isThereABird*150)), sin(x/40)*40, 80, 80);
    }

    if(x > width)
    {
      x = 0;
      current ++;
      isThereABird = random(0,4);
    }
    
    if(przelacz == true )
    {
      image(kroliczek[(int)i], x, height/2-100, 80, 120);
      if(sowKaput==false)
      {
        image(mlecz[3], x-200, height/2-120, 140, 140);
        j = x;
        
        if(x>250 && x< width/2)
        {
          image(getyou, x-250, height/2 - 210, 140, 140);
        }
        if( x > width/2 + 50 && x< width -200)
        {
          image(ohno, x-110, height/2-210, 140, 140);
        }
        counter=0;
      }
      else
      {
        counter+=0.1;
        if(counter <=1)
        {
        image(mlecz[3], j-200, height/2-120, 140, 140);
        }
        if(counter >1)
        {
          if(counter <2)image(mlecz[1], j-200, height/2-120, 140, 140);
          if(counter>=2)
          {
            sow_bum.play();
            //sow_bum.volume(3);
            pushMatrix();
            translate(j-200, height/2-120+height/5);
            rotate(radians(270));
            image(mlecz[1], 0, 0, 140, 140);
            popMatrix();
            
            
            punkt.play();  
            if(counter<7)
            {
              if(counter<3 || (counter>=4 && counter<5) || (counter>6 && counter<7))  
              {
                image(money[0], width/2 - money[0].width/2, height/5, 100, 100);
              }
              else
              {
                image(money[1], width/2 - money[0].width/2, height/5, 100, 100);
              }
            
            f = createFont("Georgia Pogrubiony", 20, true);
            textFont(f);
            fill(255, 0, 0);
            textAlign(CENTER);
            colorMode(RGB);
            text("YOUR SCORE SOW-THISTLE: " + scoreForSow, width/2, 60);
            text("YOUR SCORE RABBIT: " + scoreForRabbit, width/2, 100);
            }
            else
            {
              x = 0;
              blysk = 0;
              przelacz = true;
              sowKaput = false;
              counter=0;
              isThereABird = random(0,4);
            }
          }
        }
        
      }
      
      if(i != 0 && i != 1 && i!= 5)
      {
        x += kx/3;
      }
      if(i == 4) skok.play();
      i += 0.25;
    }
    
    
    else if(przelacz==false && sowKaput==false)
    {
        if(x+ct_m - 200 < x-100)
        {
          image(mlecz[2], x+ct_m-200, height/2-120, 140, 140);
          image(kroliczek[(int)i], x, height/2-100, 80, 120);
          if(i != 0 && i != 1 && i!= 5)
          {
            x += kx/3;
          }
          if(i == 4) skok.play();
          i += 0.25;
          ct_m += 5;
        }
        else if(x+ct_m-200 >= x-100 && blysk<money.length)
        {
          punkt.play();    
          image(money[(int)blysk], width/2 - money[0].width/2, height/5, 100, 100);
          blysk += 0.1;
          
          f = createFont("Georgia Pogrubiony", 20, true);
          textFont(f);
          fill(255, 0, 0);
          textAlign(CENTER);
          colorMode(RGB);
          text("YOUR SCORE SOW-THISTLE: " + scoreForSow, width/2, 60);
          text("YOUR SCORE RABBIT: " + scoreForRabbit, width/2, 100);
        }
        else
        {
          x = 0;
          blysk = 0;
          przelacz = true;
          ct_m = 0;
          i = 0;
          scoreForSow ++;
          scoreForRabbit--;
          isThereABird = random(0,4);
        }
    }
   
    if((int)i >= kroliczek.length) i = 0;

  }
  
  if(panel_or_game == true && panel_or_fish == false&& panel_or_slider == false)
  {
    
    background(0);
    noFill();
    strokeWeight(3);
    podklad.play();
    //podklad.volume(15);
    
    radioButton.display();
    
    pushMatrix();
    colorMode(HSB);
    textFont(f);
    fill(255);
    textAlign(CENTER);    
    //play.display();
    //quite.display();
    //changeTheFish.display();
    
    //text("PLAY",width/2, 60);
    //text("QUITE", width/2, 150);
    popMatrix();
   
    translate(width/2, height/2);
    for(int i=0; i<100; i++)
    {
     colorMode(HSB);
      nowa = map(mouseX, 0, width, 0, 255);
      float l =random(0, 255);
      stroke(l, nowa, l);
      
      rotate(nowa);
      line(losowa, losowa, nowa*losowa*i*10, nowa);
      line(sin(nowa*losowa/10), losowa/20, i, losowa);
      line(-sin(nowa*losowa/10), -losowa/20, -i, -losowa);
      pushMatrix();
      rotate(random(0, 360));
      ellipse(width - width/2, losowa, height-height/2, i*200*sin(losowa*nowa));
      popMatrix();
      
   star(nowa, losowa, 1);
   }
   
  }colorMode(RGB);
  
  if(panel_or_game == false && panel_or_slider == false && panel_or_fish == true)
  {
    background(194, 204, 237);
    image(fishPanelBackgroun, 0, 0, width, height-200);
    
    //draws panel with fish
    for(int i =1; i<5; i++)
    {
      for(int j=1; j<6; j++)
      {
        
        if(i==1)
        {
          if(tintFish[j-1]) 
          {
           tint(140, 140, 140);
           fill(0, 0, 150);
           rect((width/5)*j-(width/5)+10, ((height-300)/5)*i-((height-300)/5)+10, width/5, height/5-60, 17);
           image(fishImages[j-1], (width/5)*j-(width/5)+20, ((height-300)/5)*i-((height-300)/5)+20, (width/5)-20, ((height-300)/5)-20);
           
          pushMatrix(); 
          translate(mouseX- (width/20), mouseY-(height-300)/10);
          for(int k=0; k<25;k++)
          {
            translate((width/7), (height-300)/7);
            rotate((15));
            star(0, 0, 0.25); 
          }
          popMatrix();
         noTint();
           
          }
          else 
          {
            image(fishImages[j-1], (width/5)*j-(width/5)+20, ((height-300)/5)*i-((height-300)/5)+20, (width/5)-20, ((height-300)/5)-20);
          } 
        }
        else
        {
          {
            if(tintFish[(i-1)*5+j-1]) 
            {
              tint(140, 140, 140);
              fill(0, 0, 150);
              //tint(140, 140, 140);
              //tint(0, 196, 5);
              rect((width/5)*j-(width/5)+10, ((height-300)/5)*i-((height-300)/5)+10, width/5, height/5-60, 17);
              
              image(fishImages[(i-1)*5+j-1], (width/5)*j-(width/5)+20, ((height-300)/5)*i-((height-300)/5)+20, (width/5)-20, ((height-300)/5)-20);
              
              pushMatrix(); 
              translate(mouseX- (width/20), mouseY-(height-300)/10);
              for(int k=0; k<25;k++)
              {
               
                translate((width/7), (height-300)/7);
                rotate((15));
                star(0, 0, 0.25); 
              }
              popMatrix();
        
              noTint();
              noFill();
          }
          else
          {
            image(fishImages[(i-1)*5+j-1], (width/5)*j-(width/5)+20, ((height-300)/5)*i-((height-300)/5)+20, (width/5)-20, ((height-300)/5)-20);
          }
        }
      }
    }
  }
  image(backButton, width/2-backButton.width/2, height-370);
 }
 if(panel_or_game == false && panel_or_slider == true && panel_or_fish == false)
 {
   image(fishPanelBackgroun, 0, 0, width, height-200);
   image(backButton, width/2-backButton.width/2, height-370);
    
    m1.display();
    m2.display();
    m3.display();
    m4.display();
 }
  
}

void mouseDragged()
{
  if(panel_or_game == false && panel_or_fish ==false &&panel_or_slider==false&& mouseY> height - 400)
  {
    dragging = true;
    bomb.setPosition(physics.screenToWorld(new Vec2(mouseX, mouseY)));
  }
  else mouseReleased();
}

void mouseReleased() 
{
  if(panel_or_game == false && panel_or_fish ==false &&panel_or_slider==true)
  {
    if(mouseX>(width/2)-backButton.width/2 && mouseX<(width/2)+backButton.width/2 && mouseY> height-370 && mouseY<height-370+backButton.height)
    {
    panel_or_slider = false;
    panel_or_game = true;
    }
    
    m1.mouseReleased();
    m2.mouseReleased();
    m3.mouseReleased();
    m4.mouseReleased();
    }
    if(panel_or_game == false && panel_or_fish ==false &&panel_or_slider==false)
    {
      dragging = false;
      Vec2 impulse = new Vec2();
      impulse.set(startPoint);   
      impulse = impulse.sub(bomb.getWorldCenter()); 
      impulse = impulse.mul(50);
      bomb.applyImpulse(impulse, bomb.getWorldCenter());
    }
  else if(panel_or_game == true && panel_or_fish == false && panel_or_slider==false)
  {
    if(radioButton.mouseReleased())
    {
      panel_or_game = false;
      click.play();
      if(radioButton.get() == 1)
      {
        panel_or_fish = true;
      }
      if(radioButton.get() == 2)
      {
        panel_or_slider = true;
      }
      if(radioButton.get() == 3)
      {
        exit();
      }
    }
    //set all buttons to false
    for(Toggle b : radioButton.buttons) b.set(false);
  }
  
 
}

void mouseClicked()
{
  
  if(panel_or_game ==  false && panel_or_fish == true &&panel_or_slider==false)
  {
     //click.speed(1);
     click.play();
    for(int i =1; i<5; i++)
    {
      for(int j=1; j<6; j++)
      {
        if(mouseX>(width/5)*j-(width/5)+20 && mouseX<(width/5)*j && mouseY>((height-300)/5)*i-((height-300)/5)+20 && mouseY<((height-300)/5)*i)
        {
          for(int k=0; k<20; k++)
          {
            tintFish[k] = false;
          }
          
          if(i==1) tintFish[j-1] = true;
          else 
          {
            tintFish[(i-1)*5+j-1] = true;
          }
        }
      }
    }
    
    if(mouseX>(width/2)-backButton.width/2 && mouseX<(width/2)+backButton.width/2 && mouseY> height-370 && mouseY<height-370+backButton.height)
    {
    panel_or_fish = false;
    panel_or_game = true;
    }
  }
}
 
void mousePressed()
{
  for(Toggle t : radioButton.buttons) {
    if(t.mousePressed()) t.bgColor = t.activeColor;
  }
}
 
void keyPressed()
{
   if (keyCode == ' ' && panel_or_game == false)
   {
      panel_or_game = !panel_or_game;
   }
}


void myCustomRenderer(World world) 
{
  if(panel_or_game == false && panel_or_fish ==false &&panel_or_slider==false)
  {
    Vec2 screenStartPoint = physics.worldToScreen(startPoint);
    
    //load start position with crossbow
    stroke(240);
    //strokeWeight(8);
    //tint(100);
    image(balustrade, 0, height-360, width, 50);
    image(floor, 0, height-350, width, 110);
    //noTint();
    image(balustrade, 65, height-400, width-130, 50);
    //line(30, height-400, width -30, height -400 );
    strokeWeight(4);
    line(screenStartPoint.x, screenStartPoint.y, mouseX, height-300);
    
    //heavyPoints position
    for (int i = 0; i < heavyPoints.length; i++)
    {
      Vec2 heavyPointsCenter = heavyPoints[i].getWorldCenter();//ponownie- bierzemy poszczegolne pozycje cratesów jakie ustalilismy wczesniej
      Vec2 heavyPointsPos = physics.worldToScreen(heavyPointsCenter);// i zapisujemy jako cratesPos, aplikujemy do fizyki naszego swiata
      float heavyPointsAngle = physics.getAngle(heavyPoints[i]);
      pushMatrix();
      translate(heavyPointsPos.x, heavyPointsPos.y);
      rotate(radians(-heavyPointsAngle));
      //rect(0,0, pointsSize/2, pointsSize/2);
      image(pointsImages[whichPoint[i]], 0, 0, pointsSize, pointsSize);
      popMatrix();

    }
  
    //points position
    for (int i = 0; i < points.length; i++)
    {
      if(isThereAnyPointOnTheWorld >0 )
      {
        if(isThereAPoint[i]<=1)
        {
          pushMatrix();
          translate(points[i].x, points[i].y);
          //rect(0,0, pointsSize/2, pointsSize/2);
          image(pointsImages[whichPoint[i]], 0, 0, pointsSize, pointsSize);
          popMatrix();
        }
      }
      else positionLotteryForPoints();
      
    }
   
    //bomb on position
    Vec2 screenBombPos = physics.worldToScreen(bomb.getWorldCenter());//to jest wziecie pozycji droida z tej biblioteki fizyka tego swiata
    float bombAngle = physics.getAngle(bomb);//a tu jest wziecie kata tego samego droida z gotowej biblioteki i to bedziemy do obrazka aplikować
    pushMatrix();
    translate(screenBombPos.x, screenBombPos.y);
    rotate(-radians(bombAngle));
    
    for(int i=0; i<20; i++)
    {  if(tintFish[i]== true)
      image(fishImages[i], -20, 0, bombSize+20, bombSize);
    }
    popMatrix();
  
    //when fish hit rabbit
    if((przelacz == true) && sowKaput==false && (abs( (screenBombPos.x +bombSize/2) - (x+40) )<(bombSize+80)/4 ) && (abs( (screenBombPos.y + bombSize/2) - (height/2-100+80) )<(bombSize+160)/4) ) 
    {
      przelacz = false; 
      przysp.play();
    }
    
    //when fish hit sow-thistle
    if((przelacz == true) && (abs( (screenBombPos.x +bombSize/2) - (x- 200+ 60) )<(bombSize+120)/3 ) && (abs( (screenBombPos.y + bombSize/2) - (height/2-120+60) )<(bombSize+120)/3) ) 
    {
      sowKaput=true;
      scoreForRabbit++;
      scoreForSow--;
    }
    
    //when fish hit any point
    for (int i = 0; i < points.length; i++)
    {
      if( isThereAPoint[i]<=1 && (abs( (screenBombPos.x +bombSize/2) - (points[i].x + pointsSize/2) )<(bombSize+pointsSize)/2 ) && (abs( (screenBombPos.y +bombSize/2) - (points[i].y + pointsSize/2) )<(bombSize+pointsSize)/2 ) ) 
      {
        lightPointSounds.play();
        scoreForRabbit++;
        scoreForSow++;
        isThereAnyPointOnTheWorld--;
        isThereAPoint[i] = 2;
      }
    }
 
  
    if (dragging)
    {
      strokeWeight(2);
      line(screenBombPos.x, screenBombPos.y, screenStartPoint.x, screenStartPoint.y);
    }
  }
}

// This method gets called automatically when there is a collision
void collision(Body b1, Body b2, float impulse)
{
  if ((b1 == bomb && b2.getMass() > 0)
    || (b2 == bomb && b1.getMass() > 0))
  {
    if (impulse > 1.0)
    {
      scoreForRabbit += 1;
      scoreForSow++;
    }
  }
  
  if ((b1 == bomb || b2 == bomb)&& panel_or_game==false && panel_or_fish==false &&panel_or_slider==false) { // b1 or b2 are the sprat
  sow_bum.play();
  //sow_bum.volume(7);
  }
  
  for (int i=0;i<heavyPoints.length;i++)
  {
   if ((b1 == heavyPoints[i] || b2 == heavyPoints[i])&& panel_or_fish==false && panel_or_game==false &&panel_or_slider==false)
   {
     heavyPointSounds[i].cue(0);
     //heavyPointSounds[i].speed(1);
     heavyPointSounds[i].play();
   }
 }
}

void positionLotteryForPoints()
{
   //points new position
   for(int j=0; j<N; j++)
   {
     whichPoint[j] = int(random(P));
   }
    
  for (int i = 0; i < points.length; i++)
  {  
    points[i] = new PVector(random(width), random(0, (height-panel.height)- 2.15*panel.height - 100 ) );
    //points[i] = physics.screenToWorld(points[i]);
    isThereAPoint[i] = random(0, 2);
    if(isThereAPoint[i]>= 0 && isThereAPoint[i]<=1) isThereAnyPointOnTheWorld++;
  }
  
  //heavyPoints new position
  for (int i = 0; i < heavyPoints.length; i++)
    {
      {
        heavyPoints[i] = physics.createCircle(random(width), random((height-panel.height)- 2.15*panel.height), pointsSize/2);
      }
    }
}
  
void star(float x, float y, float ratio)
{
    pushMatrix();
    translate(x, y);
    fill(102);
    colorMode(RGB);
    stroke(255);
    strokeWeight(2);
    beginShape();
    vertex(0, -50*ratio);
    vertex(14*ratio, -20*ratio);
    vertex(47*ratio, -15*ratio);
    vertex(23*ratio, 7*ratio);
    vertex(29*ratio, 40*ratio);
    vertex(0, 25*ratio);
    vertex(-29*ratio, 40*ratio);
    vertex(-23*ratio, 7*ratio);
    vertex(-47*ratio, -15*ratio);
    vertex(-14*ratio, -20*ratio);
    endShape(CLOSE);
    popMatrix();
 }
