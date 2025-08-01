/* ================================================================
 * Módulo: pcs_tx_cg
 * Descripción:
 *   Módulo codificador 8b/10b de la capa PCS (Physical Coding Sublayer).
 *   - Transforma datos paralelos de 8 bits (TXD) y símbolos de control
 *     (tx_o_set) en grupos de códigos de 10 bits (tx_code_group).
 *   - Gestiona la disparidad para mantener el equilibrio DC en la transmisión.
 *   - Incluye una máquina de estados finitos (FSM) para manejar datos,
 *     símbolos especiales y estados de inactividad.
 *
 * Entradas:
 *   clk             - Reloj de transmisión.
 *   rst             - Reset asíncrono activo alto.
 *   power_on        - Señal para habilitar la transmisión.
 *   tx_o_set [7:0]  - Símbolos de control (Idle, SOP, EOP, etc.).
 *   TXD      [7:0]  - Datos paralelos a codificar.
 *
 * Salidas:
 *   tx_code_group [9:0] - Grupo de códigos codificado 8b/10b listo para TX.
 *   tx_oset_indicate    - Indica si se transmitió un símbolo de control.
 *   tx_even             - Estado de paridad para sincronización.
 * ================================================================
 */

`include "pcs_defs.vh"

module pcs_tx_cg(
    input wire clk, rst, power_on,
    input wire [7:0] tx_o_set,
    input wire [7:0] TXD,
    output reg [9:0] tx_code_group,
    output reg tx_oset_indicate,
    output reg tx_even
);

    reg [7:0] state, next_state;
    reg prev_tx_even;
    reg tx_disparity;

    localparam  GENERATE_CODE_GROUPS = 3'b000,
                SPECIAL_GO           = 3'b001,
                DATA_GO              = 3'b010,
                IDLE_DISPARITY_OK    = 3'b011,
                IDLE_I2B             = 3'b100,
                IDLE_DISPARITY_TEST  = 3'b101;

    reg [9:0] LUT [255:0][1:0];

    initial begin

        LUT[`D0_0][`NEGATIVE] = `D0_0_RDN; LUT[`D0_0][`POSITIVE] = `D0_0_RDP;
        LUT[`D1_0][`NEGATIVE] = `D1_0_RDN; LUT[`D1_0][`POSITIVE] = `D1_0_RDP;
        LUT[`D2_0][`NEGATIVE] = `D2_0_RDN; LUT[`D2_0][`POSITIVE] = `D2_0_RDP;
        LUT[`D3_0][`NEGATIVE] = `D3_0_RDN; LUT[`D3_0][`POSITIVE] = `D3_0_RDP;
        LUT[`D4_0][`NEGATIVE] = `D4_0_RDN; LUT[`D4_0][`POSITIVE] = `D4_0_RDP;
        LUT[`D5_0][`NEGATIVE] = `D5_0_RDN; LUT[`D5_0][`POSITIVE] = `D5_0_RDP;
        LUT[`D6_0][`NEGATIVE] = `D6_0_RDN; LUT[`D6_0][`POSITIVE] = `D6_0_RDP;
        LUT[`D7_0][`NEGATIVE] = `D7_0_RDN; LUT[`D7_0][`POSITIVE] = `D7_0_RDP;
        LUT[`D8_0][`NEGATIVE] = `D8_0_RDN; LUT[`D8_0][`POSITIVE] = `D8_0_RDP;
        LUT[`D9_0][`NEGATIVE] = `D9_0_RDN; LUT[`D9_0][`POSITIVE] = `D9_0_RDP;
        LUT[`D16_2][`NEGATIVE] = `D16_2_RDN; LUT[`D16_2][`POSITIVE] = `D16_2_RDP;
        
        LUT[`K28_5][`NEGATIVE] = `K28_5_RDN; LUT[`K28_5][`POSITIVE] = `K28_5_RDP;
        LUT[`K27_7][`NEGATIVE] = `K27_7_RDN; LUT[`K27_7][`POSITIVE] = `K27_7_RDP;
        LUT[`K23_7][`NEGATIVE] = `K23_7_RDN; LUT[`K23_7][`POSITIVE] = `K23_7_RDP;
        LUT[`K29_7][`NEGATIVE] = `K29_7_RDN; LUT[`K29_7][`POSITIVE] = `K29_7_RDP;
    end

    function rdp;
        input [9:0] tx_code_group;
        input init_rdp;
        integer i;
        integer j;
        integer first_sb_ones;
        integer first_sb_zeros;
        integer second_sb_ones;
        integer second_sb_zeros;
        reg [5:0] first_sb;
        reg [3:0] second_sb;
        reg first_sb_last_rdp;
        reg first_sb_rdp;
        reg second_sb_last_rdp;
        reg second_sb_rdp;
        begin
            first_sb_ones = 0;
            first_sb_zeros = 0;
            second_sb_ones = 0;
            second_sb_zeros = 0;

            first_sb = tx_code_group[9:4];
            second_sb = tx_code_group[3:0];

            for (i = 0; i < 6; i = i + 1) begin
                if(first_sb[i] == 1)
                    first_sb_ones = first_sb_ones + 1;
                else
                    first_sb_zeros = first_sb_zeros + 1;
            end

            for (j = 0; j < 4; j = j + 1) begin
                if (second_sb[j] == 1)
                    second_sb_ones = second_sb_ones + 1;
                else
                    second_sb_zeros = second_sb_zeros + 1;
            end
            
            first_sb_last_rdp = init_rdp;

            if ((first_sb_ones > first_sb_zeros) || first_sb == 6'b000111)
                first_sb_rdp = 1;
            else if ((first_sb_ones < first_sb_zeros) || first_sb == 6'b111000)
                first_sb_rdp = 0;
            else
                first_sb_rdp = first_sb_last_rdp;

            second_sb_last_rdp = first_sb_rdp;

            if ((second_sb_ones > second_sb_zeros) || second_sb == 4'b0011)
                second_sb_rdp = 1;
            else if ((second_sb_ones < second_sb_zeros) || second_sb == 4'b1100)
                second_sb_rdp = 0;
            else
                second_sb_rdp = second_sb_last_rdp;
           
            if (second_sb_rdp == 1)
                rdp = 1;
            else
                rdp = 0;
        end
    endfunction

    always @(posedge clk) begin
        if (~rst) begin
            state <= GENERATE_CODE_GROUPS;
            tx_even <= 0;
            tx_oset_indicate <= 0;
            tx_disparity <= `NEGATIVE;
        end else begin
            state <= next_state;
            prev_tx_even <= tx_even;
        end
    end

    always @(*) begin
        next_state = state;
        tx_oset_indicate = 0;
    
        case (state)
            GENERATE_CODE_GROUPS: begin
                if (power_on) begin
                    if (tx_o_set == `K28_5) begin  
                        next_state = IDLE_DISPARITY_TEST;
                    end else if (tx_o_set == `D) begin   
                        next_state = DATA_GO;    
                    end else if (tx_o_set == `K27_7 || tx_o_set == `K29_7 || tx_o_set == `K23_7) begin 
                        next_state = SPECIAL_GO;    
                    end
                end
            end

            IDLE_DISPARITY_TEST: begin
                if (tx_disparity == `NEGATIVE)
                    next_state = IDLE_DISPARITY_OK;
                else begin
                    next_state = GENERATE_CODE_GROUPS;
                    tx_disparity = `NEGATIVE;
                end
            end 

            IDLE_DISPARITY_OK: begin
                tx_code_group = LUT[`K28_5][tx_disparity];
                tx_disparity = rdp(tx_code_group,tx_disparity);
                tx_even = 1;
                next_state = IDLE_I2B;
            end

            IDLE_I2B: begin                
                tx_code_group = LUT[`D16_2][tx_disparity]; 
                tx_disparity = rdp(tx_code_group,tx_disparity);
                tx_even = 0;
                tx_oset_indicate = 1;
                next_state = GENERATE_CODE_GROUPS;
            end

            DATA_GO: begin
                tx_code_group = LUT[TXD][tx_disparity];
                tx_disparity = rdp(tx_code_group,tx_disparity);
                tx_even = !prev_tx_even;
                next_state = GENERATE_CODE_GROUPS;
                tx_oset_indicate = 1;
            end

            SPECIAL_GO: begin
                if (tx_o_set == `K27_7) begin            
                    tx_code_group = LUT[`K27_7][tx_disparity]; 
                end else if (tx_o_set == `K29_7) begin   
                    tx_code_group = LUT[`K29_7][tx_disparity];  
                end else if (tx_o_set == `K23_7) begin   
                    tx_code_group = LUT[`K23_7][tx_disparity];   
                end    
                tx_disparity = rdp(tx_code_group,tx_disparity);
                tx_oset_indicate = 1;
                next_state = GENERATE_CODE_GROUPS;
                tx_even = !prev_tx_even;
            end

            default: next_state = GENERATE_CODE_GROUPS;
        endcase
    end
endmodule
