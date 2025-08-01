/* ================================================================
 * Módulo: Synchronizer
 * Descripción:
 *   Este módulo implementa la lógica de sincronización de la capa PCS
 *   para alinear correctamente los code-groups recibidos en la interfaz
 *   de recepción Ethernet (8b/10b). Realiza la detección de comas,
 *   adquisición de sincronización y mantiene la paridad (rx_even).
 *
 * Entradas:
 *   - reset               : Señal de reinicio del sistema.
 *   - rx_clk              : Reloj de recepción.
 *   - rx_code_group    : Code-group de entrada (10 bits).
 *
 * Salidas:
 *   - SUDI   			   : rx_even_out y Code-group alineado (11 bits).
 *   - sync_status    : Indica si la sincronización fue adquirida.
 * ================================================================
 */

`include "pcs_cg_defs.vh"
`include "pcs_defs.vh"

module Synchronizer(reset, rx_clk, rx_code_group, SUDI, 
                     sync_status);

    input wire rx_clk, reset;
    input wire [9:0] rx_code_group;
	output reg [10:0] SUDI; 
	
	
	// Declaracion de variables de estado
	output reg sync_status;
	reg next_sync_status;

	reg rx_even, next_rx_even;
	reg [1:0] good_cgs, next_good_cgs;
	reg [16:0] state, next_state;

	// Declaracion de estados
	parameter LOSS_OF_SYNC    = 16'b0000_0000_0000_0001;
	parameter COMMA_DETECT_1  = 16'b0000_0000_0000_0010; 
	parameter ACQUIRE_SYNC_1  = 16'b0000_0000_0000_0100;
	parameter COMMA_DETECT_2  = 16'b0000_0000_0000_1000;
	parameter ACQUIRE_SYNC_2  = 16'b0000_0000_0001_0000;
	parameter COMMA_DETECT_3  = 16'b0000_0000_0010_0000; 
	parameter SYNC_AQUIRED_1  = 16'b0000_0000_0100_0000; 
	parameter SYNC_AQUIRED_2  = 16'b0000_0000_1000_0000; 
	parameter SYNC_AQUIRED_2A = 16'b0000_0001_0000_0000; 

	// Declaracion de constantes
	parameter FAIL = 0;
	parameter OK = 1;

	parameter FALSE = 0;
	parameter TRUE = 1; 

	parameter ODD = 0;
	parameter EVEN = 1;


	// Declaracion de logica secuencial con FF
	always @(posedge rx_clk ) begin
		if (~reset) begin
			state <= LOSS_OF_SYNC;
			rx_even <= 1;
			sync_status <= FAIL;
		end
		else begin
			state <= next_state;
			rx_even <= next_rx_even;
			sync_status <= next_sync_status;
		end
	end

	function data_valid;
		    input [9:0] codegroup_data;
            		  begin
				case (codegroup_data)
					`D0_0_decmenos : data_valid = 1;
					`D1_0_decmenos : data_valid = 1;
					`D2_0_decmenos : data_valid = 1;
					`D3_0_decmenos : data_valid = 1;
					`D4_0_decmenos : data_valid = 1;
					`D5_0_decmenos : data_valid = 1;
					`D6_0_decmenos : data_valid = 1;
					`D7_0_decmenos : data_valid = 1;
					`D8_0_decmenos : data_valid = 1;
					`D9_0_decmenos : data_valid = 1;
					`D0_0_decmas   : data_valid = 1;
					`D1_0_decmas   : data_valid = 1;
					`D2_0_decmas   : data_valid = 1;
					`D3_0_decmas   : data_valid = 1;
					`D4_0_decmas   : data_valid = 1;
					`D5_0_decmas   : data_valid = 1;
					`D6_0_decmas   : data_valid = 1;
					`D7_0_decmas   : data_valid = 1;
					`D8_0_decmas   : data_valid = 1;
					`D9_0_decmas   : data_valid = 1;
					`D5_6_decmas   : data_valid = 1;
				    `D5_6_decmenos : data_valid = 1;
					`D16_2_decmas  : data_valid = 1;
				    `D16_2_decmenos: data_valid = 1;
                    `K23_7_RDN     : data_valid = 1;
                    `K23_7_RDP     : data_valid = 1;
                    `K27_7_RDN     : data_valid = 1;
                    `K27_7_RDP     : data_valid = 1;
                    `K29_7_RDN     : data_valid = 1;
                    `K29_7_RDP     : data_valid = 1;
					default        : data_valid = 0;
				endcase
	        end	
		endfunction

		function code_group_comma;
            input [9:0] posible_comma;
			if ((posible_comma == `K28_5_RDN) || (posible_comma == `K28_5_RDP)) begin
                    code_group_comma = 1;
			end
		    else code_group_comma = 0;
		endfunction

		function cggood;
		    input [9:0] data;	 
                cggood = (data_valid(data) ^ code_group_comma(data));
	    endfunction

		function [10:0] sync_unitdata_indicate;
			input [9:0] latched_value_code_group;
			input latched_state_rx_even;
			parameter TRUE = 1;
			parameter EVEN = 1;
			parameter ODD = 0;
			begin
				if (latched_state_rx_even == TRUE) begin
					sync_unitdata_indicate = {EVEN,latched_value_code_group};
				end
				else sync_unitdata_indicate = {ODD,latched_value_code_group};
			end
			
		endfunction

	always @(*) begin

		next_state = state;						
        next_rx_even = rx_even;
		next_sync_status = sync_status;

		case (state)
			LOSS_OF_SYNC:   
			begin
				next_sync_status = FAIL;
				next_rx_even = ~rx_even;
				SUDI = sync_unitdata_indicate(rx_code_group,rx_even);
				if (code_group_comma(rx_code_group)) 
				begin
					next_state = COMMA_DETECT_1;
				end
				else begin 
					next_state = LOSS_OF_SYNC;
				end
			end

			COMMA_DETECT_1:   
			begin 
				next_rx_even = TRUE;
				SUDI = sync_unitdata_indicate(rx_code_group,rx_even);
				if (data_valid(rx_code_group)) next_state = ACQUIRE_SYNC_1;
				else next_state = LOSS_OF_SYNC;

			end

			ACQUIRE_SYNC_1:   
			begin
				next_rx_even = ~rx_even;
				SUDI = sync_unitdata_indicate(rx_code_group,rx_even);
				if (code_group_comma(rx_code_group)) next_state = COMMA_DETECT_2;
				else if (data_valid(rx_code_group)) next_state = ACQUIRE_SYNC_1;
				else next_state = LOSS_OF_SYNC;

			end

			COMMA_DETECT_2:   
			begin 
				next_rx_even = TRUE;
				SUDI = sync_unitdata_indicate(rx_code_group,rx_even);
				if (data_valid(rx_code_group)) next_state = ACQUIRE_SYNC_2;
				else next_state = LOSS_OF_SYNC;
			end

			ACQUIRE_SYNC_2:   
			begin
				next_rx_even = ~rx_even;
				SUDI = sync_unitdata_indicate(rx_code_group,rx_even);
				if (code_group_comma(rx_code_group)) next_state = COMMA_DETECT_3;
				else if (data_valid(rx_code_group)) next_state = ACQUIRE_SYNC_2;
				else next_state = LOSS_OF_SYNC;									
			end

			COMMA_DETECT_3:   
			begin
				next_rx_even = TRUE;
				SUDI = sync_unitdata_indicate(rx_code_group,rx_even); 
				if (data_valid(rx_code_group)) next_state = SYNC_AQUIRED_1;
				else next_state = LOSS_OF_SYNC;
			end

			SYNC_AQUIRED_1:   
			begin
				next_sync_status = OK;
				next_rx_even = ~rx_even;
				SUDI = sync_unitdata_indicate(rx_code_group,rx_even); 
				if (cggood(rx_code_group)) next_state = SYNC_AQUIRED_1;
				else next_state = SYNC_AQUIRED_2;
			end
			

			SYNC_AQUIRED_2:   
			begin
				next_rx_even = ~rx_even;
				SUDI = sync_unitdata_indicate(rx_code_group,rx_even); 
				if (cggood(rx_code_group)) next_state = SYNC_AQUIRED_2A;
				else next_state = LOSS_OF_SYNC;
				next_good_cgs = 0;
			end
			
			SYNC_AQUIRED_2A:   
			begin
				next_rx_even = ~rx_even;
				SUDI = sync_unitdata_indicate(rx_code_group,rx_even);
				next_good_cgs = good_cgs+1; 
				if (cggood(rx_code_group))  
					begin 
					if (good_cgs < 3) 
					begin 
						next_state = SYNC_AQUIRED_2A;
					end
					else next_state = SYNC_AQUIRED_1;
				end 
				else next_state = LOSS_OF_SYNC;	
			end		
		endcase
	end

endmodule