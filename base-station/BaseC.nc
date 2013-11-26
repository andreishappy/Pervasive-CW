#include "Timer.h"
#include "DataMsg.h"
#include "SerialMsg.h"

module BaseC
{
    uses interface Timer<TMilli> as SensorTimer;
    uses interface Leds;
    uses interface Boot;

    uses interface SplitControl;
    uses interface CC2420Packet;
    uses interface Receive as DataReceive;

    uses interface SplitControl as SerialAMControl;
    uses interface Packet as SerialPacket;
    uses interface AMSend as SerialSend;
    uses interface AMSend as DataSend;
    uses interface Packet;
}

implementation{

    enum {
        SAMPLE_PERIOD = 1024,
    };

    uint16_t temperature_value;
    message_t packet;
    bool locked = FALSE;

    message_t serialpkt;
    bool SerialAMBusy;
    bool AMBusy;

    event void Boot.booted() {
        temperature_value = 0;
        call SensorTimer.startPeriodic(SAMPLE_PERIOD );
        call SplitControl.start();
        call SerialAMControl.start();
    }

    event void SensorTimer.fired() {
        
        SyncMsg* msg = (SyncMsg*)call Packet.getPayload(&packet, sizeof(SyncMsg));
        if (call DataSend.send(AM_BROADCAST_ADDR, &packet, sizeof(SyncMsg)) == SUCCESS) 
        {
	locked = TRUE;
        call Leds.led2Toggle();
        }  
        
    }

    event void DataSend.sendDone(message_t* bufPtr, error_t error) {
        if (&packet == bufPtr) 
        {
                locked = FALSE;
        }
    }

    event void SplitControl.stopDone(error_t err) {
        if (err == SUCCESS) {
        }
    }

    event void SplitControl.startDone(error_t err) {
        if (err == SUCCESS) {
            AMBusy = FALSE;
        }
    }

    event message_t * DataReceive.receive(message_t * msg, void * payload, uint8_t len) {

        SerialMsg * s_pkt = NULL;
        DataMsg * d_pkt = NULL;


        if (len == sizeof (DataMsg)) {
            d_pkt = (DataMsg *) payload;
            if (d_pkt->srcid == 29) {
                call Leds.led1Toggle();

            }

            s_pkt = (SerialMsg *) (call SerialPacket.getPayload(&serialpkt, sizeof (SerialMsg)));

            s_pkt->header = SERIALMSG_HEADER;
            s_pkt->srcid = d_pkt->srcid;
            s_pkt->temperature = d_pkt->temp;
            s_pkt->photo = d_pkt->photo;
            s_pkt->isFire = d_pkt->isFire;
            s_pkt->signal_strength = call CC2420Packet.getRssi(msg) - 45;

            if (SerialAMBusy) {
            } else {
                if (call SerialSend.send(AM_BROADCAST_ADDR, &serialpkt, sizeof (SerialMsg)) == SUCCESS) {
                    SerialAMBusy = TRUE;
                }
            }
            call Leds.led0Toggle();
        }
        return msg;
    }

    event void SerialAMControl.stopDone(error_t err) {
        if (err == SUCCESS) {
        }
    }

    event void SerialAMControl.startDone(error_t err) {
        if (err == SUCCESS) {
            SerialAMBusy = FALSE;
        }
    }

    event void SerialSend.sendDone(message_t *msg, error_t error) {
        SerialAMBusy = FALSE;

    }
}

