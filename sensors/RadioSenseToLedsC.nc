// $Id: RadioSenseToLedsC.nc,v 1.7 2010-06-29 22:07:17 scipio Exp $

/*									tab:4
 * Copyright (c) 2000-2005 The Regents of the University  of California.  
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 * - Neither the name of the University of California nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * Copyright (c) 2002-2003 Intel Corporation
 * All rights reserved.
 *
 * This file is distributed under the terms in the attached INTEL-LICENSE     
 * file. If you do not find these files, copies can be found by writing to
 * Intel Research Berkeley, 2150 Shattuck Avenue, Suite 1300, Berkeley, CA, 
 * 94704.  Attention:  Intel License Inquiry.
 */
 
#include "Timer.h"
#include "DataMsg.h"
#include <message.h>
#include "Timer.h"


/**
 * Implementation of the RadioSenseToLeds application.  RadioSenseToLeds samples 
 * a platform's default sensor at 4Hz and broadcasts this value in an AM packet. 
 * A RadioSenseToLeds node that hears a broadcast displays the bottom three bits 
 * of the value it has received. This application is a useful test to show that 
 * basic AM communication, timers, and the default sensor work.
 * 
 * @author Philip Levis
 * @date   June 6 2005
 */

module RadioSenseToLedsC @safe(){
  uses {
    interface Leds;
    interface Boot;
    interface Read<uint16_t> as TempSensor;
    interface Read<uint16_t> as LightSensor;
    interface Receive;
    interface AMSend;
    interface Timer<TMilli> as SensorTimer;
    interface Timer<TMilli> as GreenTimer;
    interface Timer<TMilli> as RedTimer;
    interface Timer<TMilli> as YellowTimer;

    interface Packet;


     
    interface SplitControl as RadioControl;
  }
}
implementation {

  uint16_t temperatures[30];
  uint8_t temp_index = 100;
  nx_uint8_t neighbours[2];
  nx_uint8_t is_dark[2];
  uint8_t synced;
  uint8_t sync_count = 0;  
  message_t packet;
  bool locked = FALSE;
  uint16_t light_reading; 
  
  event void Boot.booted() {
    call RadioControl.start();
  }

  event void RadioControl.startDone(error_t err) {
    if (err == SUCCESS) {
        uint8_t i;
        for (i=0; i<2; i++) {
            neighbours[i] = 0;
        }
      call SensorTimer.startPeriodic(SAMPLE_PERIOD);
      synced = 0;
    }
  }
  event void RadioControl.stopDone(error_t err) {}
  
  event void SensorTimer.fired() {
    call LightSensor.read();
  }

  void blink_yellow() {
    call Leds.led2Toggle();
    call YellowTimer.startOneShot(20);
  }

  void blink_red() {
    call Leds.led0Toggle();
    call RedTimer.startOneShot(20);
  }

  void blink_green() {
    call Leds.led1Toggle();
    call GreenTimer.startOneShot(20);
  }
 
  event void YellowTimer.fired() {
    call Leds.led2Toggle();
  }

  event void RedTimer.fired() {
    call Leds.led0Toggle();
  }

  event void GreenTimer.fired() {
    call Leds.led1Toggle();
  }

  void add_temperature(uint16_t temp) {
      uint8_t i;
      
      //Do initial insert
      if (temp_index == 100) {
          for (i=0; i<30; i++) {
              temperatures[i] = temp;
          }
          temp_index = 0;
      }
      
      temperatures[temp_index] = temp;
      //Increment the index
      if (temp_index < 29) temp_index++;
      else temp_index = 0;
  }
  
   bool raised_temperature() {
       uint16_t min = temperatures[0];
       uint16_t max = temperatures[0];
       uint16_t current;
       uint8_t i;
       
      for (i=1; i<30; i++) {
          current = temperatures[i];
          if (current < min) {
              min = current;
          }
          if (current > max) {
              max = current;
          }
      }
       return max - min > 20;
  }
   
   uint8_t neighbours_dark() {
       uint8_t i;
       uint8_t result = 0;
       
       for (i=0; i<2; i++) {
           if (is_dark[i]) result++;
       }
       return result;
   }
   
  event void TempSensor.readDone(error_t result, uint16_t data) {
    blink_yellow();  
    if(result != SUCCESS) data = 100000;
    
    if (locked) {
      return;
    }
    else {
      DataMsg* msg;

      msg = (DataMsg*)call Packet.getPayload(&packet, sizeof(DataMsg));
      if (msg == NULL) {
	return;
      }
      
      msg -> temp = data;
      msg -> photo = light_reading;
      add_temperature(data);
      
      if (neighbours_dark() > 0) blink_green();
      if (raised_temperature() && neighbours_dark() == 2) {
          blink_red();
          msg -> isFire = 1;
      }
      else msg -> isFire = 0;
      msg->srcid = TOS_NODE_ID;
      if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(DataMsg)) == SUCCESS) {
	locked = TRUE;
        
      }      
    }
  }

  event void LightSensor.readDone(error_t result, uint16_t data) {
      light_reading = data;
      call TempSensor.read();
  }

  void log_dark_for(nx_uint8_t srcid, uint8_t dark) {
      uint8_t current = 10;
      uint8_t i;
      for (i=0; i<2; i++) {
          if (neighbours[i] == 0) {
              //blink_red();
              break;
          }
          
          if (neighbours[i] == srcid) {
              //blink_green();
              current = i;
              break;
          }     
      }
      
      if (current == 10) {
          //blink_green();
          neighbours[i] = srcid;
          is_dark[i] = dark;
      } else {
          //blink_red();
          is_dark[current] = dark;
      }
  }
  event message_t* Receive.receive(message_t* bufPtr, 
				   void* payload, uint8_t len) {
    
    if (len == sizeof(SyncMsg)) {            
      if (sync_count == 0) { call SensorTimer.startPeriodic(SAMPLE_PERIOD);
                             }
      sync_count = (sync_count + 1) % 5;
      
    }
    else if(len == sizeof(DataMsg)){
      
      DataMsg* msg = (DataMsg*)payload;
      
      
      
      if (msg -> photo < 100) {
          log_dark_for(msg->srcid,1);
          //blink_green();
      }//read in the values
      else {
          log_dark_for(msg->srcid,0);
      }
      
    }
    
    return bufPtr;
  }

  event void AMSend.sendDone(message_t* bufPtr, error_t error) {
    if (&packet == bufPtr) {
      locked = FALSE;
    }
  }

}
