#include <message.h>

configuration BaseAppC
{
}
implementation
{
  components MainC, BaseC, LedsC;
  components CC2420ActiveMessageC;
  
  components new AMReceiverC(AM_DATAMSG) as DataReceiver;

  components SerialActiveMessageC;

  components new SerialAMSenderC(AM_SERIALMSG) as SerialSender;
  components new SerialAMReceiverC(AM_SERIALMSG) as SerialReceiver; 

  components new AMSenderC(AM_DATAMSG) as DataSend;
  components new TimerMilliC() as SensorTimer;
  
  BaseC -> MainC.Boot;
  BaseC.Leds -> LedsC;

  BaseC.SplitControl -> CC2420ActiveMessageC.SplitControl;
  BaseC.CC2420Packet -> CC2420ActiveMessageC.CC2420Packet;

  BaseC.DataReceive -> DataReceiver;

  BaseC.SerialAMControl -> SerialActiveMessageC;
  BaseC.SerialPacket -> SerialSender;
  BaseC.SerialSend -> SerialSender;
  BaseC.DataSend -> DataSend;
  BaseC.SensorTimer -> SensorTimer;
  BaseC.Packet -> DataSend;
}

