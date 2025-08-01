/* ================================================================
 * Módulo: receiver_tb
 * Descripción:
 *   Banco de pruebas (testbench) para el módulo Receiver.
 *   Instancia el módulo Receiver (Device Under Test, DUT) y
 *   el generador de estímulos (receiver_tester).
 *   Permite capturar las señales en un archivo VCD para
 *   visualización en GTKWave.
 *
 * Entradas (al DUT):
 *   - rx_clk      : Reloj de recepción.
 *   - sync_status : Estado de sincronización.
 *   - SUDI        : Code-group recibido (10 bits).
 *   - rx_even     : Paridad actual del receptor (even/odd).
 *
 * Salidas (del DUT):
 *   - RXD         : Datos paralelos decodificados (8 bits).
 *   - RX_DV       : Señal que indica datos válidos.
 * ================================================================
 */

module receiver_tb;

    wire rx_clk, sync_status, rx_even;
    wire [9:0] SUDI;
    wire [7:0] RXD;
    wire RX_DV;

    Receiver dut (
        .rx_clk(rx_clk),
        .sync_status(sync_status),
        .SUDI(SUDI),
        .rx_even(rx_even),
        .RXD(RXD),
        .RX_DV(RX_DV)
    );

    receiver_tester test (
        .rx_clk(rx_clk),
        .sync_status(sync_status),
        .SUDI(SUDI),
        .rx_even(rx_even),
        .RXD(RXD),
        .RX_DV(RX_DV)
    );

    initial begin
        $dumpfile("receiver_waveform.vcd");
        $dumpvars(-1, dut);
    end

endmodule