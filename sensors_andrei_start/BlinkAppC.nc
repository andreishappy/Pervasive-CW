//## Solution sheet for tutorial 2 and start code for tutorial 3 of the wireless sensor network
//## programing module of the pervasive systems course.

#include <message.h>

configuration BlinkAppC
{
}
implementation
{
  components MainC, BlinkC, LedsC;
  components new TimerMilliC() as SensorTimer;
  components new TempC() as TempSensor;
  components new PhotoC() as LightSensor;
  
  //Setting up Radio Stack
  components ActiveMessageC;
  components new AMSenderC(AM_DATAMSG) as DataSender;
  components new AMReceiverC(AM_DATAMSG) as DataReceiver;

  BlinkC -> MainC.Boot;

  BlinkC.SensorTimer -> SensorTimer;
  BlinkC.Leds -> LedsC;
  BlinkC.TempSensor -> TempSensor;
  BlinkC.LightSensor -> LightSensor;

  ///*********Solution 2. Wiring in Radio stack components*********************/
  BlinkC.AMControl -> ActiveMessageC;
  BlinkC.DataPacket -> DataSender;
  BlinkC.DataSend -> DataSender;
  BlinkC.DataReceive -> DataReceiver;

}

