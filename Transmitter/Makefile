# ================================
# Makefile de Transmitter
# ================================

IVERILOG = iverilog
VVP      = vvp
GTKWAVE  = gtkwave

VFLAGS   = -I.
SRC      = transmitter_tb.v
SIM_FILE = tx_sim.out
WAVE_FILE = pcs_tx_waves.vcd

GTK_FILE  = transmitter.gtkw

all: compile run wave

compile: $(SRC)
	$(IVERILOG) $(VFLAGS) -o $(SIM_FILE) $(SRC)

run: $(SIM_FILE)
	$(VVP) $(SIM_FILE)

wave: $(WAVE_FILE)
	$(GTKWAVE) $(GTK_FILE) &

clean:
	rm -f $(SIM_FILE) $(WAVE_FILE)
