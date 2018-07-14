# ADSBox Makefile

# Use for cross compile
#CC = arm-linux-gcc
CC = gcc
INCLUDE =
LIBS = -lsqlite3 -lpthread -lm -lrt -ldl -lz
CFLAGS = -Wall -g
SQLITEFLAGS = -D SQLITE_THREADSAFE=1 -D SQLITE_DEFAULT_AUTOVACUUM=1
WITH_RTLSDR = yes
WITH_MLAT = no

DEPS = $*
OBJS = adsb.o http.o misc.o file.o serial.o tcp_avr.o tcp_beast.o udp_avr.o tcp_sbs3.o db.o main.o

ifeq ($(WITH_RTLSDR),yes)
RTLSDR_O_FILE = rtlsdr.o
LIBS +=  $(RTLSDR_LIBS) -lrtlsdr
DRTLSDR = -DRTLSDR
endif

ifeq ($(WITH_MLAT),yes)
INCLUDE += -I../mlat
MLATLIB = ../mlat/mlat.a
DMLAT = -DMLAT
endif


all: mlat adsbox

adsbox: $(OBJS) $(RTLSDR_O_FILE)
	$(CC) $(OBJS) $(RTLSDR_O_FILE) $(MLATLIB) $(LIBS) -o adsbox
	@printf "Done.\n"

%.o: %.c $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS)

adsb: adsb.c
	$(CC) $(INCLUDE) $(DRTLSDR) $(DMLAT) -c adsb.c $(CFLAGS)

misc: misc.c
	$(CC) $(INCLUDE) $(DMLAT) -c misc.c $(CFLAGS)

rtlsdr: rtlsdr.c
ifeq ($(WITH_RTLSDR),yes)
	$(CC) $(RTLSDR_INC) -c rtlsdr.c $(CFLAGS)
else
	@printf "librtlsdr support is disabled. Enable with WITH_RTLSDR=yes option in Makefile.\n"
endif

main:	main.c
	$(CC) $(INCLUDE) $(DRTLSDR) $(DMLAT) -c main.c $(CFLAGS)

mlat:
ifeq ($(WITH_MLAT),yes)
	cd ../mlat; make
endif

clean:
	rm -f ./*.o ./adsbox
