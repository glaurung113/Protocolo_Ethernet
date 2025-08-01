/* ================================================================
 * Módulo: pcs_tx_o_set
 * Descripción:
 *   Este módulo implementa la lógica para seleccionar los símbolos
 *   Ordered Sets (OSet) en la transmisión de la capa PCS.
 *   Controla el inicio, transmisión y terminación de paquetes,
 *   determinando qué símbolos de control o datos deben enviarse.
 *   Incluye una FSM (Finite State Machine) para manejar estados
 *   como START_OF_PACKET, TX_PACKET y END_OF_PACKET.
 *
 * Entradas:
 *   TX_EN              - Habilita la transmisión de datos.
 *   TX_ER              - Señal de error en la transmisión.
 *   TX_OSET_indicate   - Indica cuándo se debe enviar un Ordered Set.
 *   GTX_CLK            - Reloj de transmisión.
 *   tx_even            - Bit de paridad para sincronización.
 *   mr_main_reset      - Reset maestro.
 *   xmit        [2:0]  - Estado actual de transmisión (IDLE/DATA).
 *
 * Salidas:
 *   transmitting       - Indica si se está transmitiendo un paquete.
 *   tx_o_set    [7:0]  - Ordered Set seleccionado para transmitir.
 * ================================================================
 */

`include "pcs_defs.vh"

module pcs_tx_o_set(
    input   TX_EN,
    input  TX_ER,
    input  TX_OSET_indicate,
    input  GTX_CLK,
    input  tx_even,
    input  mr_main_reset,
    input  [2:0] xmit,

    output reg transmitting,
    output reg [7:0] tx_o_set
);

    localparam
        XMIT_DATA = 8'd2,
        START_OF_PACKET = 8'd4,
        TX_PACKET = 8'd8,
        TX_DATA = 8'd16,
        END_OF_PACKET_NOEXT = 8'd32,
        EPD2_NOEXT = 8'd64,
        EPD3 = 8'd128;

    function [7:0] VOID;
        input [7:0] x;

        VOID = x;
    endfunction

    reg next_transmitting;
    reg [7:0] next_tx_o_set;


    reg [7:0] state, next_state;


    always @(posedge GTX_CLK) begin
        if(~mr_main_reset)
        begin
            state <= XMIT_DATA;
            transmitting <= `FALSE;
            tx_o_set <= `K28_5;
        end 
        else begin
            state <= next_state;
            transmitting <= next_transmitting;
            tx_o_set <= next_tx_o_set;

        end
    end

    always @(*) begin
        next_state = state;
        case (state)

            XMIT_DATA: begin
                next_tx_o_set = `K28_5; 
                if (TX_EN == `FALSE && TX_OSET_indicate)
                    next_state = XMIT_DATA;
                else if (TX_EN == `TRUE && TX_ER == `FALSE && TX_OSET_indicate)
                    next_state = START_OF_PACKET;
            end
            START_OF_PACKET: begin
                next_transmitting  = `TRUE;
                next_tx_o_set = `K27_7;
                if (TX_OSET_indicate)
                    next_state = TX_PACKET;
            end
            TX_PACKET: begin
                if (TX_EN == `TRUE) 
                    next_state = TX_DATA;
                else if (TX_EN == `FALSE && TX_ER == `FALSE)
                    next_state = END_OF_PACKET_NOEXT;
            end
            TX_DATA: begin
                next_tx_o_set = VOID(`D);
                if (TX_OSET_indicate)
                    next_state = TX_PACKET;
            end
            END_OF_PACKET_NOEXT: begin
                next_tx_o_set = `K29_7;
                if (tx_even == `FALSE) begin
                    next_transmitting = `FALSE;
                    if (TX_OSET_indicate) begin
                        next_state = EPD2_NOEXT;
                    end 
                end
            end
            EPD2_NOEXT: begin
                next_transmitting = `FALSE;
                next_tx_o_set = `K29_7;
                if (tx_even == `FALSE && TX_OSET_indicate)
                    next_state = XMIT_DATA;
                else if (tx_even == `TRUE && TX_OSET_indicate)
                    next_state = EPD3;
            end
            EPD3: begin
                next_tx_o_set = `K23_7;
                if (TX_OSET_indicate)
                    next_state = XMIT_DATA;
            end
            default: begin
                next_state = XMIT_DATA;
            end
        endcase 
    end
endmodule 
