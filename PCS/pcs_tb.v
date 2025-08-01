/* ================================================================
 * Módulo: pcs_tb
 * Descripción:
 *   Banco de pruebas para el módulo PCS. Instancia el DUT (Device
 *   Under Test) y el módulo tester para simular y verificar el
 *   comportamiento de la subcapa PCS.
 *
 * Entradas: (N/A)
 * Salidas: (N/A)
 * ================================================================
 */
`include "pcs.v"
`include "pcs_tester.v"

module pcs_tb;
    wire TX_CLK;
    wire RX_CLK;
    wire [7:0] TXD;
    wire TX_EN;
    wire [9:0] loop_code_group;
    wire [7:0] RXD;
    wire RX_DV;
    wire [1:0] PCS_STATUS;
    wire mr_main_reset;
    wire power_on;

    initial begin
        $dumpfile("pcs_waveform.vcd");
        $dumpvars;
    end

    PCS 
    pcs_inst(
        .mr_main_reset(mr_main_reset)
        ,.power_on(power_on)
        ,.TX_CLK(TX_CLK)
        ,.RX_CLK(RX_CLK)
        ,.TXD(TXD)
        ,.TX_EN(TX_EN)
        ,.TX_ER(TX_ER)
        ,.rx_code_group(loop_code_group)
        
        ,.RXD(RXD)
        ,.RX_DV(RX_DV)
        ,.tx_code_group(loop_code_group)
        ,.PCS_STATUS(PCS_STATUS)
    );

    pcs_tester 
    pcs_tester_inst(
        .TX_EN(TX_EN)
        ,.TX_ER(TX_ER)
        ,.TX_CLK(TX_CLK)
        ,.RX_CLK(RX_CLK)
        ,.TXD(TXD)
        ,.mr_main_reset(mr_main_reset)
        ,.power_on(power_on)
    );

    //assign rx_code_group = tx_code_group;
endmodule
