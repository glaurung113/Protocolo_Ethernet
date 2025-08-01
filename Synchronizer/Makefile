# ================================
# Makefile de Synchronizer
# ================================

IVERILOG = iverilog
VVP      = vvp
GTKWAVE  = gtkwave

VFLAGS   = -I../include
SRC      = synchronizer.v synchronizer_tb.v synchronizer_tester.v
SIM_FILE = synchronizer_sim.out
WAVE_FILE = synchronizer_waveform.vcd
GTK_FILE  = synchronizer.gtkw

all: compile run wave

compile: $(SRC)
	$(IVERILOG) $(VFLAGS) -o $(SIM_FILE) $(SRC)

run: $(SIM_FILE)
	$(VVP) $(SIM_FILE)

wave: $(WAVE_FILE)
	$(GTKWAVE) $(GTK_FILE) &

clean:
	rm -f $(SIM_FILE) $(WAVE_FILE)
