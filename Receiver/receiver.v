/* ================================================================
 * Módulo: Receiver
 * Descripción:
 *   Implementa la lógica de recepción para la subcapa PCS.
 *   Decodifica los code-groups 8b/10b, detecta delimitadores
 *   de paquetes y genera datos válidos para las capas superiores.
 *
 * Entradas:
 *   - rx_clk        : Reloj de recepción.
 *   - sync_status   : Estado de sincronización de la capa PCS (1 = sincronizado).
 *   - SUDI          : Code-group recibido (10 bits).
 *   - rx_even       : Indica paridad del receptor (even/odd).
 *
 * Salidas:
 *   - RXD           : Datos paralelos recibidos (8 bits).
 *   - RX_DV         : Señal de datos válidos (1 = datos válidos).
 * ================================================================
 */

`include "pcs_defs.vh"

module Receiver(
    input rx_clk,           
    input sync_status,     
    input [9:0] SUDI,  
    input rx_even,    
    output reg [7:0] RXD,  
    output reg RX_DV 
);

    reg [3:0] state, next_state; 
    
    reg receiving;

    reg [9:0] previous_code_group;
    reg [9:0] second_previous_code_group;

    localparam LINK_FAILED     = 4'b0000,
               WAIT_FOR_K      = 4'b0001,
               RX_K            = 4'b0010,
               IDLE_D          = 4'b0011,
               START_OF_PACKET = 4'b0100,
               RECEIVE         = 4'b0101,
               RX_DATA         = 4'b0110,
               TRR_RRI         = 4'b0111,
               RECEIVED_T      = 4'b1000,
               RECEIVED_R      = 4'b1001; 
    
    always @(negedge rx_clk) begin
        if (sync_status == 1'b0 && SUDI) begin
            state <= LINK_FAILED; 
            RXD <= 8'hFF;
        end else begin
            state <= next_state; 
        end
    end

    always @(*) begin
        next_state = state;
        RX_DV = 1'b0;
        receiving = 1'b0;

        case (state)
            LINK_FAILED: begin

                RX_DV = 1'b0;
                receiving = 1'b0;

                if (sync_status == 1'b1 && SUDI) begin
                    next_state = WAIT_FOR_K;
                end else begin
                    next_state = LINK_FAILED;
                end
            end

            WAIT_FOR_K: begin
                RX_DV = 1'b0;
                receiving = 1'b0;

                if (((SUDI == `K28_5_RDN) || (SUDI == `K28_5_RDP)) && rx_even == 1'b1) begin
                    next_state = RX_K;
                end else begin
                    next_state = WAIT_FOR_K; 
                end
            end

            RX_K: begin 
                RX_DV = 1'b0;
                receiving = 1'b0;

                if ((SUDI == `D16_2_RDN) || (SUDI == `D16_2_RDP)) begin
                    next_state = IDLE_D; 
                end else begin
                    next_state = RX_K;
                end   
            end

            IDLE_D: begin
                RX_DV = 1'b0;
                
                if ((SUDI == `K27_7_RDN) || (SUDI == `K27_7_RDP)) begin
                    receiving = 1'b1;
                    next_state = START_OF_PACKET;
                end else if (((SUDI == `K28_5_RDN) || (SUDI == `K28_5_RDP)) || is_data_char(SUDI)) begin
                    next_state = RX_K;
                end
            end

            START_OF_PACKET: begin
                RX_DV = 1'b1;
                RXD = 8'b01010101;
                next_state = RECEIVE;
            end

            RECEIVE: begin
                RX_DV = 1'b1;
                
                if (is_data_char(SUDI)) begin
                    next_state = RX_DATA; 
                end else if (rx_even && ((SUDI == `K29_7_RDN) || (SUDI == `K29_7_RDP)) )  begin
                    next_state = RECEIVED_T;
                end

            end
            RECEIVED_T: begin
                if (rx_even && ((SUDI == `K23_7_RDN) || (SUDI == `K23_7_RDP)) ) begin
                    next_state = RECEIVED_R;
                end
            end
            RECEIVED_R: begin
                if (rx_even && ((SUDI == `K28_5_RDN) || (SUDI == `K28_5_RDP)) ) begin
                    next_state = WAIT_FOR_K;
                end
            end

            RX_DATA: begin
                RX_DV = 1'b1;
                RXD = decode(SUDI);

                if (is_data_char(SUDI)) begin
                    next_state = RECEIVE; 
                end
            end

            TRR_RRI: begin
                receiving = 1'b0;
                RX_DV = 1'b0;
                next_state = WAIT_FOR_K;
            end

            default: next_state = WAIT_FOR_K;
        endcase
    end

    function [7:0] decode;
        input [9:0] code_group;
        begin
            case (code_group)
                `D0_0_RDN, `D0_0_RDP: decode = `D0_0; 
                `D1_0_RDN, `D1_0_RDP: decode = `D1_0; 
                `D2_0_RDN, `D2_0_RDP: decode = `D2_0; 
                `D3_0_RDN, `D3_0_RDP: decode = `D3_0; 
                `D4_0_RDN, `D4_0_RDP: decode = `D4_0; 
                `D5_0_RDN, `D5_0_RDP: decode = `D5_0; 
                `D6_0_RDN, `D6_0_RDP: decode = `D6_0; 
                `D7_0_RDN, `D7_0_RDP: decode = `D7_0; 
                `D8_0_RDN, `D8_0_RDP: decode = `D8_0; 
                `D9_0_RDN, `D9_0_RDP: decode = `D9_0; 
                default: decode = 8'h00;          
            endcase
        end
    endfunction

    function check_end;
        input [9:0] current_code_group;
        begin
            check_end = (((second_previous_code_group == `K29_7_RDN) || (second_previous_code_group == `K29_7_RDP)) && 
                        ((previous_code_group == `K23_7_RDN) || (previous_code_group == `K23_7_RDP)) &&
                        ((current_code_group == `K28_5_RDN) || (current_code_group == `K28_5_RDP)));
        end
    endfunction
 
    function is_data_char;
        input [9:0] code_group;
        begin
            case (code_group)
                `D0_0_RDN, `D0_0_RDP,
                `D1_0_RDN, `D1_0_RDP,
                `D2_0_RDN, `D2_0_RDP,
                `D3_0_RDN, `D3_0_RDP,
                `D4_0_RDN, `D4_0_RDP,
                `D5_0_RDN, `D5_0_RDP,
                `D6_0_RDN, `D6_0_RDP,
                `D7_0_RDN, `D7_0_RDP,
                `D8_0_RDN, `D8_0_RDP,
                `D9_0_RDN, `D9_0_RDP: is_data_char = 1; 
                default: is_data_char = 0;
            endcase
        end
    endfunction

endmodule
