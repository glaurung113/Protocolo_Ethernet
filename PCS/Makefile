# # ================================
# # Makefile de PCS
# # ================================

IVERILOG = iverilog

VVP = vvp
GTKWAVE = gtkwave
GTKW = $(wildcard *.gtkw)
IFLAGS   = -I../include -I../Transmitter -I../Receiver -I../Synchronizer

# Archivos fuente
SRC = $(wildcard *.v)
TB = $(wildcard *_tb.v)

# Archivos generados
OUT = salida
WAVE = $(wildcard *.vcd)


# Default target
all: wave

wave: 
	$(IVERILOG) -o salida.out pcs_tb.v $(IFLAGS)
	vvp salida.out
	$(GTKWAVE) pcs_waveform.vcd $(GTKW)

# Limpiar archivos generados
clean:
	rm -f *.out $(WAVE)  

.PHONY: all simulate wave clean
