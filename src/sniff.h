
#ifndef _SNIFF_H_
#define _SNIFF_H_

#define UNUSED(x) (void)(x)
#define MIN(a,b) (((a)<(b))?(a):(b))
#define MAXPATH 255

#ifdef _WIN32
#include <windows.h>
#define COUNT DWORD
#define PADSIZE 4 // //./
#else
#include <termios.h>
#define COUNT int
#define PADSIZE 5 //  /dev/
#endif

typedef struct BAUD_RESOURCE {
  #ifdef _WIN32
  HANDLE handle;
  #else
  int fd;
  #endif
  COUNT count;
  const char* error;
  char path[MAXPATH + 1];
  char device[MAXPATH + 1];
  char config[3 + 1];
} BAUD_RESOURCE;

void serial_open(BAUD_RESOURCE *res, int speed);
void serial_close(BAUD_RESOURCE *res);
void serial_release(BAUD_RESOURCE *res);
void serial_available(BAUD_RESOURCE *res);
void serial_read(BAUD_RESOURCE *res, unsigned char *buffer, COUNT size);
void serial_read_char(BAUD_RESOURCE *res, unsigned char *buffer);
void serial_write(BAUD_RESOURCE *res, unsigned char *buffer, COUNT size);

#endif
