import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

Minim minim;

AudioOutput output;

float timeLineX; //x position of time line

PVector[] soundPos = new PVector[3];

float speedVar; //variable that changes the speed of the timer
 
float[] values; 

float[] SampleRate = {0.0, 0.0, 0.0};

Sampler[] samplers = new Sampler[3];
 
void setup()
{
  size(500, 500);
  
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
  
  for(int i = 0; i < SampleRate.length; i++){
    SampleRate[i] = samplers[i].sampleRate();
  }
}
 
void draw()
{
  background(0);
  fill(80);
  
  //allowing user/us to test changes to ball positions and time line speed
  if (keyPressed) {
    if (key == 'a' || key == 'A') { //speeds the timer up
      if(speedVar > 1){ //stops if from going too fast or dividing by 0
        speedVar = speedVar - 0.1;
        
      }
    }
    if (key == 'd' || key == 'D') { //slows the timer line down
      if(speedVar < 13){ //stops if from going too slow
        speedVar = speedVar + 0.1;
      }
    }
    if (key == 's' || key == 'S') { //randomizes the position of the sound circles
      for(int i = 0; i < soundPos.length; i++){
        soundPos[i] = new PVector(random(5,width-5), random(5,height-5));
      }
    }
    if(key == '+')
    {
      
    }
  }
  //print(speedVar, ", ");
  //draws the sound circles
  for(int i = 0; i < soundPos.length; i++){
    ellipse(soundPos[i].x,soundPos[i].y,5,5);
  }
  
  //pitch
  for(int i = 0; i < soundPos.length; i++){
    if(soundPos[i].y <= 50){
      samplers[i].setSampleRate(SampleRate[i]/1.5); 
    }
    else if(soundPos[i].y  <= 100){
      samplers[i].setSampleRate(SampleRate[i]/1.4);      
    }
    else if(soundPos[i].y  <= 150){
      samplers[i].setSampleRate(SampleRate[i]/1.3);      
    }
    else if(soundPos[i].y  <= 200){
      samplers[i].setSampleRate(SampleRate[i]/1.2);      
    }
    else if(soundPos[i].y  <= 250){
      samplers[i].setSampleRate(SampleRate[i]/1.1);      
    }
    else if(soundPos[i].y  <= 300){
      samplers[i].setSampleRate(SampleRate[i]*1);
    }
    else if(soundPos[i].y  <= 350){
      samplers[i].setSampleRate(SampleRate[i]*1.1);      
    }
    else if(soundPos[i].y  <= 400){
      samplers[i].setSampleRate(SampleRate[i]*1.2);      
    }
    else if(soundPos[i].y  <= 450){
      samplers[i].setSampleRate(SampleRate[i]*1.3);      
    }
    else if(soundPos[i].y  > 450){
      samplers[i].setSampleRate(SampleRate[i]*1.4);      
    }
  }
  
  
  //time line
  stroke(255);
  strokeWeight(1);
  
  if(timeLineX < width){ //check if time line is at the end of the screen
    line(timeLineX, 0, timeLineX, width); //draws the time line
    timeLineX = timeLineX + (minute()/speedVar); //changes the speed the time line goes accross the screen 
    for(int i = 0; i < soundPos.length; i++){
      if(timeLineX > soundPos[i].x - 5 && timeLineX < soundPos[i].x + 5){ //checking if the time line is over the sound 1 circle
        float[] nums = samplers[i].getLastValues();
  
        if(nums[0] == 0.0 && nums[1] == 0.0)
        {
          samplers[i].trigger();
        }
  
      }
    }
  }
  else { //resets line to the beginning of the screen when it reaches the edge of the screen 
    timeLineX = 0;
  }
}