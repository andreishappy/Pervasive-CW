//#ifndef DATAMSG_H
#define DATAMSG_H

enum {
	AM_DATAMSG = 9,
	DATAMSG_HEADER = 0x99,
};

typedef nx_struct DataMsg {
	nx_uint8_t srcid;
	nx_uint16_t sync_p;
	nx_uint16_t temp; //NULL if no temp
	nx_uint16_t photo; //NULL if no photo
	nx_uint16_t isFire; //0 means no fire and 1 means fire
} DataMsg;

typedef nx_struct SyncMsg {
	nx_uint16_t sync_p;
} SyncMsg;