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
  
  samplers[0] = new Sampler( "yellow.wav", 1, minim );
  samplers[1] = new Sampler( "red.wav", 1, minim );
  samplers[2] = new Sampler( "white.wav", 1, minim );
  
  samplers[0].patch(output);
  samplers[1].patch(output);
  samplers[2].patch(output);
      
  speedVar = 0.5; //initialising speedVar
  timeLineX = 240; //start position of time line
  
  for(int i = 0; i < soundPos.length; i++){
    soundPos[i] = new PVector(0.0, 0.0);
  }
  for(int i = 0; i < sampleRates.length; i++){
    sampleRates[i] = samplers[i].sampleRate();
  }
}


void draw() 
{
  background(0);

  img.loadPixels();
  
  // Easy way to test depth values on execution!
  //minThresh = map(mouseX, 0, width, 0, 4500);
  //maxThresh = map(mouseY, 0, height, 0, 4500);
  //println(minThresh + " " + maxThresh);   

  PImage img = kinect2.getRegisteredImage();
  
  // Get the raw depth as array of integers  
  int[] depth = kinect2.getRawDepth();
  
  for (int x = 0; x < kinect2.depthWidth; x++) 
  {
    for (int y = 0; y < kinect2.depthHeight; y++) 
    {
      int offset = x + y * kinect2.depthWidth;
      int d = depth[offset];

      if (d > minThresh && d < maxThresh && x < 360 && x > 240 && y < 260 && y > 140) 
      {
        
        color c = img.pixels[offset];
        
        float r = red(c);
        float b = blue(c);
        float g = green(c);
        
        if( (235 <= r == r <= 245) && (235 <= g == g <= 245) && (40 <= b == b <= 70) )
        {        
          soundPos[0].x = x;
          soundPos[0].y = y;
          
          yellow = true;
        } 
        if( (100 <= r == r <= 110) && (10 <= g == g <= 20) && (25 <= b == b <= 35) )
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
        
      } 
      else 
      {
        img.pixels[offset] = color(0);
      }  
    }
  }
   
  //FOR DEBUG PURPOSES - Print out colour and play sound
  //if(((soundPos[0].x - legoSize) <= mouseX == mouseX <= (soundPos[0].x + legoSize)) && ((soundPos[0].y - legoSize) <= mouseY == mouseY <= (soundPos[0].y + legoSize)))
  //{
  //  println("On yellow!"); 
  //  float[] nums = samplers[0].getLastValues();

  //  if(nums[0] == 0.0 && nums[1] == 0.0)
  //  {
  //    samplers[0].trigger();
  //  }
  //}
  //if(((soundPos[1].x - legoSize) <= mouseX == mouseX <= (soundPos[1].x + legoSize)) && ((soundPos[1].y - legoSize) <= mouseY == mouseY <= (soundPos[1].y + legoSize)))
  //{
  //  println("On red!"); 
  //  float[] nums = samplers[1].getLastValues();

  //  if(nums[0] == 0.0 && nums[1] == 0.0)
  //  {
  //    samplers[1].trigger();
  //  }
  //}
  //if(((soundPos[2].x - legoSize) <= mouseX == mouseX <= (soundPos[2].x + legoSize)) && ((soundPos[2].y - legoSize) <= mouseY == mouseY <= (soundPos[2].y + legoSize)))
  //{
  //  println("On white!"); 
  //  float[] nums = samplers[2].getLastValues();

  //  if(nums[0] == 0.0 && nums[1] == 0.0)
  //  {
  //    samplers[2].trigger();
  //  }
  //}
  img.updatePixels();
  image(img, 0, 0);
  
  //time line
  stroke(255);
  strokeWeight(1);
    
  if(timeLineX < 360){ //check if time line is at the end of the screen
    line(timeLineX, 0, timeLineX, height); //draws the time line
    timeLineX = timeLineX + speedVar; //changes the speed the time line goes accross the screen 
    for(int i = 0; i < soundPos.length; i++)
    {
      if(timeLineX > soundPos[i].x - 5 && timeLineX < soundPos[i].x + 5)
      { //checking if the time line is over the sound 1 circle
        updatePitch();
        
        float[] nums = samplers[i].getLastValues();
  
        if(nums[0] == 0.0 && nums[1] == 0.0)
        {
          samplers[i].trigger();
        }
  
      }
    }
  }
  else 
  { //resets line to the beginning of the screen when it reaches the edge of the screen 
    timeLineX = 240;
    
    for(int i = 0; i < soundPos.length; i++)
    {
      soundPos[i] = new PVector(0.0, 0.0);
      samplers[i].setSampleRate(sampleRates[i]);
    }
  } 
}

void updatePitch()
{  
  for(int i = 0; i < soundPos.length; i++)
  {
    float position = map(soundPos[i].y, 140, 260, 0.0, 1.0); 
    
    if(position <= 0.1)
    {
      samplers[i].setSampleRate(sampleRates[i]/1.5); 
    }
    else if(position <= 0.2)
    {
      samplers[i].setSampleRate(sampleRates[i]/1.4);      
    }
    else if(position <= 0.3)
    {
      samplers[i].setSampleRate(sampleRates[i]/1.3);      
    }
    else if(position <= 0.4)
    {
      samplers[i].setSampleRate(sampleRates[i]/1.2);      
    }
    else if(position <= 0.5)
    {
      samplers[i].setSampleRate(sampleRates[i]/1.1);      
    }
    else if(position <= 0.6)
    {
      samplers[i].setSampleRate(sampleRates[i]*1);
    }
    else if(position <= 0.7)
    {
      samplers[i].setSampleRate(sampleRates[i]*1.1);      
    }
    else if(position <= 0.8)
    {
      samplers[i].setSampleRate(sampleRates[i]*1.2);      
    }
    else if(position <= 0.9)
    {
      samplers[i].setSampleRate(sampleRates[i]*1.3);      
    }
    else if(position <= 1.0)
    {
      samplers[i].setSampleRate(sampleRates[i]*1.4);      
    }
  } 
}

void keyPressed()
{
  if(key == '+')
  {
    if(speedVar < 1.5)
    {
      speedVar += 0.1;
    }
  }
  if(key == '-')
  {
    if(speedVar > 0.2)
    {
      speedVar -= 0.1; 
    }
  }
}

// check the colour of where we click
void mouseClicked() {
  loadPixels();
    print("Red: "+red(pixels[mouseX + mouseY * width]) + " ");
    print("Green: "+green(pixels[mouseX + mouseY * width]) + " ");
    print("Blue: "+blue(pixels[mouseX + mouseY * width]) + " ");
    println();
}