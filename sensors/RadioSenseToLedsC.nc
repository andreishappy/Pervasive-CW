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
#include "RadioSenseToLeds.h"
#include "DataMsg.h"

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
    interface Receive;
    interface AMSend;
    interface Timer<TMilli> as SensorTimer;
    interface Timer<TMilli> as GreenTimer;
    interface Timer<TMilli> as RedTimer;
    interface Timer<TMilli> as YellowTimer;

    

    interface Packet;
    interface Read<uint16_t> as TempSensor;
    interface Read<uint16_t> as LightSensor;

     
    interface SplitControl as RadioControl;
  }
}
implementation {

  message_t packet;
  bool locked = FALSE;
   
  event void Boot.booted() {
    call RadioControl.start();
  }

  event void RadioControl.startDone(error_t err) {
    if (err == SUCCESS) {
      call SensorTimer.startPeriodic(250);
    }
  }
  event void RadioControl.stopDone(error_t err) {}
  
  event void SensorTimer.fired() {
    call Read.read();
  }

  void blink_yellow() {
    call Leds.led2Toggle();
    call YellowTimer.startOneShot(100);
  }

  void blink_red() {
    call Leds.led0Toggle();
    call RedTimer.startOneShot(100);
  }

  void blink_green() {
    call Leds.led1Toggle();
    call GreenTimer.startOneShot(100);
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


  event void TempSensor.readDone(error_t result, uint16_t data) {
    call Leds.led0Toggle();
    if (locked) {
      return;
    }
    else {
      radio_sense_msg_t* rsm;

      rsm = (radio_sense_msg_t*)call Packet.getPayload(&packet, sizeof(radio_sense_msg_t));
      if (rsm == NULL) {
	return;
      }
      rsm->error = result;
      rsm->data = data;
      if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(radio_sense_msg_t)) == SUCCESS) {
	locked = TRUE;
      }
    }
  }

  event void LightSensor.readDone(error_t result, uint16_t data) {
    
  }


  event message_t* Receive.receive(message_t* bufPtr, 
				   void* payload, uint8_t len) {
    call Leds.led1Toggle();
    if (len != sizeof(radio_sense_msg_t)) {return bufPtr;}
    else {
      radio_sense_msg_t* rsm = (radio_sense_msg_t*)payload;
      uint16_t val = rsm->data;
      blink_yellow();
      return bufPtr;
    }
  }

  event void AMSend.sendDone(message_t* bufPtr, error_t error) {
    if (&packet == bufPtr) {
      locked = FALSE;
    }
  }

}
