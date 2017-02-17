import org.openkinect.processing.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

Minim minim;
AudioOutput output;
 
float[] sampleRates = {0.0, 0.0, 0.0};
Sampler[] samplers = new Sampler[3];

// Kinect Library object
Kinect2 kinect2;

float timeLineX;
float speedVar;
PVector[] soundPos = new PVector[3];
float minThresh = 600;
float maxThresh = 1050;
PImage img;
float legoSize = 10;
boolean yellow;
boolean red;
boolean white;
  
void setup() {
  //size of Kinect
  size(512, 424);
  
  //Kinect set-up
  kinect2 = new Kinect2(this);
  kinect2.initDepth();
  kinect2.initRegistered();
  kinect2.initDevice();
  img = createImage(kinect2.depthWidth, kinect2.depthHeight, RGB);
    
  //Minim set-up
  minim = new Minim(this);
  output = minim.getLineOut();
  
  samplers[0] = new Sampler( "beep.wav", 1, minim );
  samplers[1] = new Sampler( "beep.wav", 1, minim );
  samplers[2] = new Sampler( "beep.wav", 1, minim );
  
  samplers[0].patch(output);
  samplers[1].patch(output);
  samplers[2].patch(output);
      
  speedVar = 10; //initialising speedVar
  timeLineX = 0; //start position of time line
  
  for(int i = 0; i < soundPos.length; i++){
    soundPos[i] = new PVector(random(5,width-5), random(5,height-5));
  }
  for(int i = 0; i < sampleRates.length; i++){
    sampleRates[i] = samplers[i].sampleRate();
  }
}


void draw() {
  background(0);

  img.loadPixels();
  
  // Easy way to test depth values on execution!
  //minThresh = map(mouseX, 0, width, 0, 4500);
  //maxThresh = map(mouseY, 0, height, 0, 4500);
  //println(minThresh + " " + maxThresh);   

  PImage img = kinect2.getRegisteredImage();
  
  // Get the raw depth as array of integers  
  int[] depth = kinect2.getRawDepth();
       
  float sumX = 0;
  float sumY = 0;
  float totalPixels = 0;
  
  for (int x = 0; x < kinect2.depthWidth; x++) {
    for (int y = 0; y < kinect2.depthHeight; y++) {
      int offset = x + y * kinect2.depthWidth;
      int d = depth[offset];

      if (d > minThresh && d < maxThresh && x < 360 && x > 240 && y < 260 && y > 140) {
        
        color c = img.pixels[offset];
        
        float r = red(c);
        float b = blue(c);
        float g = green(c);
        
        if( (245 <= r == r <= 255) && (250 <= g == g <= 255) && (65 <= b == b <= 90) )
        {        
          soundPos[0].x = x;
          soundPos[0].y = y;
          
          yellow = true;
        } 
        if( (190 <= r == r <= 200) && (30 <= g == g <= 50) && (50 <= b == b <= 70) )
        {        
          soundPos[1].x = x;
          soundPos[1].y = y;
          
          red = true;
        }
        if( (250 <= r == r <= 255) && (250 <= g == g <= 255) && (250 <= b == b <= 255) )
        {        
          soundPos[2].x = x;
          soundPos[2].y = y;
          
          white = true;
        }
        
        
        sumX += x;
        sumY += y;
        totalPixels++;
        
      } else {
        img.pixels[offset] = color(0);
      }  
    }
  }
  
   if(((soundPos[0].x - legoSize) <= mouseX == mouseX <= (soundPos[0].x + legoSize)) && ((soundPos[0].y - legoSize) <= mouseY == mouseY <= (soundPos[0].y + legoSize)))
   {
     println("On yellow!"); 
   }
   else if(((soundPos[1].x - legoSize) <= mouseX == mouseX <= (soundPos[1].x + legoSize)) && ((soundPos[1].y - legoSize) <= mouseY == mouseY <= (soundPos[1].y + legoSize)))
   {
     println("On red!"); 
   }
   else if(((soundPos[2].x - legoSize) <= mouseX == mouseX <= (soundPos[2].x + legoSize)) && ((soundPos[2].y - legoSize) <= mouseY == mouseY <= (soundPos[2].y + legoSize)))
   {
     println("On white!"); 
   }
   else
   {
     println("On nothing..."); 
   }
  //if(yellow)
  //{
  //  ellipse(xPos, yPos, 30, 30); 
  //}

  img.updatePixels();
  image(img, 0, 0);
  
}

// check the colour of where we click
void mouseClicked() {
  loadPixels();
    print("Red: "+red(pixels[mouseX + mouseY * width]) + " ");
    print("Green: "+green(pixels[mouseX + mouseY * width]) + " ");
    print("Blue: "+blue(pixels[mouseX + mouseY * width]) + " ");
    println();
}