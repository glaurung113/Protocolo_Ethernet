/* ================================================================
 * Módulo: pcs_tx_tb
 * Descripción:
 *   Banco de pruebas (testbench) para los módulos del transmisor.
 *   Instancia y conecta:
 *   - pcs_tx_o_set: Generador de símbolos de control.
 *   - pcs_tx_cg: Codificador 8b/10b de datos y control.
 *   - pcs_tx_tester: Generador de estímulos para la simulación.
 *
 * Entradas:
 *   Ninguna (todas las señales se generan desde pcs_tx_tester).
 *
 * Salidas:
 *   Ninguna (la simulación solo observa las señales internas).
 * ================================================================
 */
`include "transmitter.v"
`include "transmitter_tester.v"

module transmitter_tb;
    wire    TX_EN;
    wire    TX_ER;
    wire    TX_OSET_indicate;
    wire    GTX_CLK;
    wire    tx_even;
    wire    [7:0] TXD;
    wire    mr_main_reset;
    wire    [2:0] xmit;
    wire    transmitting;
    wire    [7:0] tx_o_set;
    wire    power_on;
    wire    [9:0] tx_code_group;

    initial begin
        $dumpfile("pcs_tx_waves.vcd");
        $dumpvars(1,transmitter_dut);
        $dumpvars(1,transmitter_dut.tx_o_set_dut);
        $dumpvars(1,transmitter_dut.tx_cg_dut);
    end

    Transmitter transmitter_dut(
        .TX_EN(TX_EN),
        .TX_ER(TX_ER),
        .GTX_CLK(GTX_CLK),
        .TXD(TXD),
        .mr_main_reset(mr_main_reset),
        .xmit(xmit),
        .power_on(power_on),
        .transmitting(transmitting),
        .tx_code_group(tx_code_group)

    );

    transmitter_tester tx_tester(
        .TX_EN(TX_EN)
        ,.TX_ER(TX_ER)
        ,.GTX_CLK(GTX_CLK)
        ,.TXD(TXD)
        ,.mr_main_reset(mr_main_reset)
        ,.xmit(xmit)
        ,.power_on(power_on)
    );

    initial begin
        $dumpfile("transmitter_waveform.vcd");
        $dumpvars;
    end
    
endmodule 
