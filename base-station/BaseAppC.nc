//## Solution sheet for tutorial 2 and start code for tutorial 3 of the wireless sensor network
//## programing module of the pervasive systems course.

#include <message.h>

configuration BaseAppC
{
}
implementation
{
  components MainC, BaseC, LedsC;
  ///****** Solution 2. Adding Radio stack components***********/
  //components ActiveMessageC;
  components CC2420ActiveMessageC;
  

///******** Solution 2. Message type parameters.Note: These parameters are enumerated values defined in the message type header file DataMsg.h********/
  components new AMReceiverC(AM_DATAMSG) as DataReceiver;

  ///*******Solution 3. Adding Serial stack components********************/
  components SerialActiveMessageC;
  ///********* Solution 3. Message type parameters************************/
  ///****Note: These parameters are enumerated values defined in the message type header file SerialMsg.h*********/
  components new SerialAMSenderC(AM_SERIALMSG) as SerialSender;
  components new SerialAMReceiverC(AM_SERIALMSG) as SerialReceiver; 

  BaseC -> MainC.Boot;
  BaseC.Leds -> LedsC;

  ///*********Solution 2. Wiring in Radio stack components*********************/
  BaseC.SplitControl -> CC2420ActiveMessageC.SplitControl;
  //ADDED THE NEXT LINE
  BaseC.CC2420Packet -> CC2420ActiveMessageC.CC2420Packet;

  BaseC.DataReceive -> DataReceiver;

  ///********* Solution 3. Wiring in Serial stack components**********************/
  BaseC.SerialAMControl -> SerialActiveMessageC;
  BaseC.SerialPacket -> SerialSender;
  BaseC.SerialSend -> SerialSender;
}

