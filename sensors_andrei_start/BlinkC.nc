//## Solution code for tutorial 2 and start code of tutorial 3, of the wireless sensor network
//## programing module of the pervasive systems course.

#include "Timer.h"
#include "DataMsg.h"


module BlinkC
{
  uses interface Timer<TMilli> as SensorTimer;
  uses interface Leds;
  uses interface Boot;
  uses interface Read<uint16_t> as TempSensor;
  uses interface Read<uint16_t> as LightSensor;

  //Radio Stack
  uses interface SplitControl as AMControl;
  uses interface Packet as DataPacket;
  uses interface AMSend as DataSend;
  uses interface Receive as DataReceive;

}

implementation
{

  enum{
    SAMPLE_PERIOD = 1024,
     };

  uint16_t light_reading;
  ///****Solution 2, implement radio stack.***************************/  
  message_t datapkt;
  bool AMBusy;
  

  event void Boot.booted()
  {
    call AMControl.start();    
    call SensorTimer.startPeriodic(SAMPLE_PERIOD );
    
  }

  event void SensorTimer.fired()
  {

    call LightSensor.read();
   
  }

  
///***** Solution 2. implement radio stack *******************************/

   event void AMControl.stopDone(error_t err) {
        if(err == SUCCESS){
        }
    }
    
    event void AMControl.startDone(error_t err) {
        if (err == SUCCESS) {
            AMBusy    = FALSE;
        }
    } 

    event void DataSend.sendDone(message_t * msg, error_t error) {
        if (&datapkt == msg) {
            AMBusy = FALSE;
        }
    }


    task void blinkGreen() {
    call Leds.led1Toggle();
    }
    event message_t * DataReceive.receive(message_t * msg, void * payload, uint8_t len) {
      
      DataMsg * d_pkt = NULL;  
      if(len == sizeof(DataMsg)) {
        d_pkt = (DataMsg *) payload;      
      }  
  
      call Leds.led1Toggle();
      return msg;   
    }



 
  //==========================================================================================
  event void TempSensor.readDone(error_t result, uint16_t data) {
    // Solution 4. Send data to the basestation.
    DataMsg * pkt = (DataMsg *)(call DataPacket.getPayload(&datapkt, sizeof(DataMsg)));
    
    pkt->srcid          = TOS_NODE_ID;
    pkt->sync_p         = 255;
    pkt->temp           = data;
    pkt->light          = light_reading;
    pkt->avg_temp       = 255;

    if (AMBusy) {}
    else {
        if (call DataSend.send(255, &datapkt, sizeof(DataMsg)) == SUCCESS) {
            AMBusy = TRUE;
        }
    }
	call Leds.led2Toggle();
  }
  //Light Sensor Reading
  //============================================================================================

  event void LightSensor.readDone(error_t result, uint16_t data) {
    light_reading = data;
    call TempSensor.read();
  }
}

