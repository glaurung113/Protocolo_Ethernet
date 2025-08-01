/* ================================================================
 * Módulo: PCS
 * Descripción:
 *   Este módulo implementa la subcapa PCS (Physical Coding Sublayer)
 *   para Ethernet 1000BASE-X. Integra los bloques de transmisión
 *   (Transmitter), sincronización (Synchronizer) y recepción (Receiver),
 *   permitiendo la codificación y decodificación 8b/10b de datos.
 *
 * Entradas:
 *   - mr_main_reset : Reset principal del sistema.
 *   - power_on      : Habilita la operación del PCS.
 *   - TX_CLK        : Reloj de transmisión.
 *   - RX_CLK        : Reloj de recepción.
 *   - TXD           : Datos paralelos (8 bits) a transmitir.
 *   - TX_EN         : Habilita la transmisión de datos.
 *   - TX_ER         : Señal de error en transmisión.
 *   - rx_code_group : Code-group recibido (10 bits).
 *
 * Salidas:
 *   - RXD           : Datos paralelos decodificados (8 bits).
 *   - RX_DV         : Señal que indica datos válidos en RXD.
 *   - tx_code_group : Code-group codificado para transmisión (10 bits).
 *   - PCS_STATUS    : Estado del PCS (00 = sin sincronización,
 *                                    01 = ocioso,
 *                                    10 = transmitiendo,
 *                                    11 = recibiendo).
 * ================================================================
 */
 
`include "pcs_defs.vh"
`include "transmitter.v"
`include "receiver.v"
`include "synchronizer.v"

module PCS(
    input mr_main_reset,
    input power_on,
    input wire TX_CLK,
    input wire RX_CLK,
    input wire [7:0] TXD,
    input wire TX_EN,    
    input wire TX_ER,
    input wire [9:0] rx_code_group,      

    output [7:0] RXD,          
    output RX_DV,               
    output [9:0] tx_code_group,  
    output reg [1:0] PCS_STATUS     
);

    wire [9:0] rx_codegroup;         
    wire sync_status;                 
    wire rx_even;                    
    wire [9:0] SUDI_in;

    reg [2:0] xmit;
    
    initial begin
        xmit = `IDLE;
        #50 xmit = `DATA;
    end

    Transmitter transmitter_inst (
        .TX_EN(TX_EN)
        ,.TX_ER(TX_ER)
        ,.GTX_CLK(TX_CLK)
        ,.TXD(TXD)
        ,.mr_main_reset(mr_main_reset)
        ,.xmit(xmit)
        ,.power_on(power_on)

        ,.transmitting(transmitting)
        ,.tx_code_group(tx_code_group)
    );


    Synchronizer synchronizer_inst (
        .reset(mr_main_reset),
        .rx_clk(RX_CLK),
        .sync_status(sync_status),
        .rx_code_group(rx_code_group),
        .SUDI({rx_even,SUDI_in})
    );

    Receiver receiver_inst (
        .rx_clk(RX_CLK),
        .sync_status(sync_status),
        .rx_even(rx_even),
        .SUDI(SUDI_in),
        .RXD(RXD),               
        .RX_DV(RX_DV)               
    );

    always @(posedge TX_CLK) begin
        if (!sync_status) begin
            PCS_STATUS <= 2'b00;
        end else if (TX_EN) begin
            PCS_STATUS <= 2'b10; 
        end else if (RX_DV) begin
            PCS_STATUS <= 2'b11;
        end else begin
            PCS_STATUS <= 2'b01;
        end
    end

endmodule
