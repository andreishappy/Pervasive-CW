//## Solution code for tutorial 2 and start code of tutorial 3, of the wireless sensor network
//## programing module of the pervasive systems course.

#include "Timer.h"
#include "DataMsg.h"

{
  uses interface Timer<TMilli> as SensorTimer;
  uses interface Leds;
  uses interface Boot;
  uses interface Read<uint16_t> as Temp_Sensor;
  uses interface Read<uint16_t> as Light_Sensor;
  ///* Solution 2, implement the Radio stack*********/.
  uses interface SplitControl as AMControl;
  uses interface Packet as DataPacket;
  uses interface AMSend as DataSend;
  uses interface Receive as DataReceive;

  ///* Solution 3, implement the Serial stack.*************/
  //uses interface SplitControl as SerialAMControl;
  //uses interface Packet as SerialPacket;
  //uses interface AMSend as SerialSend;
  //uses interface Receive as SerialReceive;
}
implementation
{
   message_t datapkt;
   DataMsg * pkt;
  

  enum{
    SAMPLE_PERIOD = 1024, //there are 1024 ticks per second when template is <TMilli>
     };

  uint16_t temperature_value;
  uint16_t light_value;
  ///****Solution 2, implement radio stack.***************************/  
  //Probably needs to change here, but fuck it for now

  bool AMBusy;
  
  ///************ Solution 3, implement serial stack.*****************/
  message_t serialpkt;
  bool SerialAMBusy;

  event void Boot.booted()
  {
    temperature_value = 0;

    pkt = (DataMsg *)(call DataPacket.getPayload(&datapkt, sizeof(DataMsg)));
      pkt->srcid          = TOS_NODE_ID;
      //pkt->sync_p       = 255;
      pkt->temp           = -1;
     //pkt->avg_temp       = 255;
   
    call SensorTimer.startPeriodic(SAMPLE_PERIOD);
    ///************** Solution 2. start radio stack******************/
    call AMControl.start();
    // Solution 3. start serial stack
  }

  event void SensorTimer.fired()
  {
    //MAKE THIS TURN ON YELLOW
    call Leds.led0Toggle();
    call Temp_Sensor.read();
    call Light_Sensor.read();
   
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
        /*if (&datapkt == msg) {
            AMBusy = FALSE;
	    pkt = (DataMsg *)(call DataPacket.getPayload(&datapkt, sizeof(DataMsg)));
             pkt->srcid          = TOS_NODE_ID;
   	     //pkt->sync_p       = 255;
             pkt->temp           = -1;
             pkt->light          = -1;
             //pkt->avg_temp       = 255;
        }*/
    }

    event message_t * DataReceive.receive(message_t * msg, void * payload, uint8_t len) {
      /*
      SerialMsg * s_pkt = NULL;
      DataMsg * d_pkt = NULL;  

      if(len == sizeof(DataMsg)) {
        d_pkt = (DataMsg *) payload;      
      } 
        
       Solution 3. implement serial stack
      s_pkt = (SerialMsg *)(call SerialPacket.getPayload(&serialpkt, sizeof(SerialMsg)));
        
      s_pkt->header      = SERIALMSG_HEADER;
      s_pkt->srcid       = TOS_NODE_ID;
      s_pkt->temperature    = d_pkt->temp;
 
      if(SerialAMBusy) {      
      }
      else {
        if (call SerialSend.send(AM_BROADCAST_ADDR, &serialpkt, sizeof(SerialMsg)) == SUCCESS) {
            SerialAMBusy = TRUE;
        }
      } 
        
      return msg;
      */
      return NULL;
    }

    
  ///*** END Solution 3. **********************************/


  event void Light_Sensor.readDone(error_t result, uint16_t data) {
    // Solution 4. Send data to the basestation.
    /*pkt = (DataMsg *)(call DataPacket.getPayload(&datapkt, sizeof(DataMsg)));
     pkt->srcid          = TOS_NODE_ID;
     //pkt->sync_p       = 255;
     pkt->light           = data;
     //pkt->avg_temp       = 255;


    if (pkt->temp != -1)
    {
    //If the light reading has already been received
        if (AMBusy) 
	{         }
        else {
        	if (call DataSend.send(31, &datapkt, sizeof(DataMsg)) == SUCCESS) 
                {
                AMBusy = TRUE;
	        call Leds.led1Toggle();
                }
             }
     } */
  }

  ///******** Sensor Reading code *******************/
  event void Temp_Sensor.readDone(error_t result, uint16_t data) {
    /*// Solution 4. Send data to the basestation.
    pkt = (DataMsg *)(call DataPacket.getPayload(&datapkt, sizeof(DataMsg)));
     pkt->srcid          = TOS_NODE_ID;
     //pkt->sync_p       = 255;
     pkt->temp           = data;
     //pkt->avg_temp       = 255;


    if (pkt->light != -1 )
    {
    //If the light reading has already been received
        if (AMBusy) 
	{         }
        else {
             if (call DataSend.send(31, &datapkt, sizeof(DataMsg)) == SUCCESS) 
                {
                AMBusy = TRUE;
	        call Leds.led1Toggle();
                }
             }
    } */
  }
}

