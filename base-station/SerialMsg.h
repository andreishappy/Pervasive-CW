#ifndef SERIALMSG_H
#define SERIALMSG_H

enum {
	AM_SERIAL = 11,
	AM_SERIALMSG = 11,
	SERIALMSG_HEADER  = 0x9F,
};

typedef nx_struct SerialMsg {
	nx_uint8_t  header;
	nx_uint8_t srcid;
	nx_uint16_t temperature;
	nx_uint16_t photo;
	nx_uint16_t isFire;
        nx_uint16_t signal_strength;
} SerialMsg;


#endif

