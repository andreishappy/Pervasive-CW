
#include <message.h>

configuration SensorAppC
{
}
implementation
{
  components MainC, SensorC, LedsC;
  components new TimerMilliC() as SensorTimer;


  //*****  Sensors
  components new TempC() as Temp_Sensor;
  components new PhotoC() as Light_Sensor;

  ///****** Solution 2. Adding Radio stack components***********/
  components ActiveMessageC;

  ///******** Solution 2. Message type parameters.Note: These parameters are enumerated values defined in the message type header file DataMsg.h********/
  components new AMSenderC(AM_DATAMSG) as DataSender;
  components new AMReceiverC(AM_DATAMSG) as DataReceiver;

  ///*******Solution 3. Adding Serial stack components********************/
  components SerialActiveMessageC;
  ///********* Solution 3. Message type parameters************************/
  ///****Note: These parameters are enumerated values defined in the message type header file SerialMsg.h*********/
  //components new SerialAMSenderC(AM_SERIALMSG) as SerialSender;


  //components new SerialAMReceiverC(AM_SERIALMSG) as SerialReceiver; 

  SensorC -> MainC.Boot;

  SensorC.SensorTimer -> SensorTimer;
  SensorC.Leds -> LedsC;
  SensorC.Temp_Sensor -> Temp_Sensor;
  SensorC.Light_Sensor -> Light_Sensor;
  

  ///*********Solution 2. Wiring in Radio stack components*********************/
  SensorC.AMControl -> ActiveMessageC;
  SensorC.DataPacket -> DataSender;
  SensorC.DataSend -> DataSender;
  SensorC.DataReceive -> DataReceiver;

  ///********* Solution 3. Wiring in Serial stack components**********************/
  //DON'T NEED  
  //SensorC.SerialAMControl -> SerialActiveMessageC;
  //SensorC.SerialPacket -> SerialSender;
  //SensorC.SerialSend -> SerialSender;
  //SensorC.SerialReceive -> SerialReceiver;
}

