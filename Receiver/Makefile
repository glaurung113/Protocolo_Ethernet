# ================================
# Makefile de Receiver
# ================================

IVERILOG = iverilog
VVP      = vvp
GTKWAVE  = gtkwave

SRC = receiver.v receiver_tester.v receiver_tb.v
SIM_FILE = receiver_sim.out
WAVE_FILE = receiver_waveform.vcd
GTK_FILE  = receiver.gtkw

all: compile run wave

compile: $(SRC)
	$(IVERILOG) -o $(SIM_FILE) $(SRC)

run: $(SIM_FILE)
	$(VVP) $(SIM_FILE)

wave: $(WAVE_FILE) $(GTK_FILE)
	$(GTKWAVE) $(WAVE_FILE) $(GTK_FILE) &

clean:
	rm -f $(SIM_FILE) $(WAVE_FILE)
