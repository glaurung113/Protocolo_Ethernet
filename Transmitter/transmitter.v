/* ================================================================
 * Módulo: Transmitter
 * Descripción:
 *   Este módulo es un "wrapper" que integra los dos bloques principales 
 *   del transmisor Ethernet 1000BASE-X:
 *     - pcs_tx_o_set: Genera los símbolos de control (ordered sets) 
 *       y determina cuándo iniciar y finalizar paquetes.
 *     - pcs_tx_cg: Realiza la codificación 8b/10b de datos y símbolos 
 *       para transmitirlos en la línea.
 *
 * Entradas:
 *   - TX_EN: Habilita la transmisión de datos.
 *   - TX_ER: Indica un error en la transmisión.
 *   - GTX_CLK: Reloj de transmisión (Gigabit Transmit Clock).
 *   - TXD: Datos paralelos (8 bits) a codificar.
 *   - mr_main_reset: Reset principal para los bloques.
 *   - xmit: Estado de transmisión externo (IDLE, DATA, etc.).
 *   - power_on: Habilita el bloque de generación de code-groups.
 *
 * Salidas:
 *   - transmitting: Indica si se está transmitiendo un paquete.
 *   - tx_code_group: Salida codificada (10 bits) lista para la línea.
 * ================================================================
 */

`include "pcs_tx_cg.v"
`include "pcs_tx_o_set.v"

module Transmitter(
    input TX_EN
    ,input TX_ER
    ,input GTX_CLK
    ,input [7:0] TXD
    ,input mr_main_reset
    ,input [2:0] xmit
    ,input power_on

    ,output transmitting 
    ,output [9:0] tx_code_group
);

    wire    TX_OSET_indicate;
    wire    tx_even;
    wire    [7:0] tx_o_set;

    pcs_tx_o_set tx_o_set_dut(
        .TX_EN(TX_EN)
        ,.TX_ER(TX_ER)
        ,.TX_OSET_indicate(TX_OSET_indicate)
        ,.GTX_CLK(GTX_CLK)
        ,.tx_even(tx_even)
        ,.mr_main_reset(mr_main_reset)
        ,.xmit(xmit)

        ,.transmitting(transmitting)
        ,.tx_o_set(tx_o_set)
    );

    pcs_tx_cg tx_cg_dut(
        .clk(GTX_CLK)
        ,.rst(mr_main_reset)
        ,.power_on(power_on)
        ,.tx_o_set(tx_o_set)
        ,.TXD(TXD)
        ,.tx_code_group(tx_code_group)
        ,.tx_oset_indicate(TX_OSET_indicate)
        ,.tx_even(tx_even)
    );
endmodule
