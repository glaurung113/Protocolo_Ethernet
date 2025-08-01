/* ================================================================
 * Módulo: synchronizer_tester
 * Descripción:
 *   Este módulo genera estímulos para probar el módulo Synchronizer.
 *   Proporciona una secuencia de code-groups con diferentes disparidades
 *   y controla las señales de reloj y reset para simular condiciones
 *   de operación.
 *
 * Entradas:
 *   - rx_code_group_out : Code-group alineado proveniente del Synchronizer.
 *   - rx_even_out       : Señal de paridad generada por el Synchronizer.
 *   - code_sync_status  : Estado de sincronización (1 = sincronizado).
 *
 * Salidas:
 *   - clk               : Señal de reloj.
 *   - reset             : Señal de reinicio.
 *   - rx_code_group_in  : Code-group de entrada al Synchronizer.
 * ================================================================
 */

`include "pcs_cg_defs.vh"
`include "pcs_defs.vh"

module synchronizer_tester(
    output reg clk,
    output reg reset,
    output reg [9:0] rx_code_group_in,
    input [9:0] rx_code_group_out,
    input rx_even_out,
    input code_sync_status
);

    initial begin
        // Fase 1: Sincronización inicial
        clk = 0;
        reset = 1;
        rx_code_group_in = 10'b0;

        #10 reset = 0; // Reset activo
        #10 reset = 1; // Reset desactivado

        #10 rx_code_group_in = `D16_2_decmas;
        #10 rx_code_group_in = `D16_2_decmenos;
        #10 rx_code_group_in = `K28_5_decmas;
        #10 rx_code_group_in = `D16_2_decmenos;
        #10 rx_code_group_in = `K28_5_decmas;

        // Enviar más datos válidos
        #10 rx_code_group_in = `D16_2_decmas;
        #10 rx_code_group_in = `D5_6_decmenos;
        #10 rx_code_group_in = `D16_2_decmas;

        // Fase 2: Forzar pérdida de sincronización
        #10 rx_code_group_in = 10'b000000_0000; // Código inválido
        #10 rx_code_group_in = 10'b111111_1111; // Código inválido
        #10 rx_code_group_in = 10'b101010_1010; // Código inválido

        // Fase 3: Recuperación de sincronización
        #10 rx_code_group_in = `K28_5_decmas;
        #10 rx_code_group_in = `D5_6_decmas;

        // Fase 4 (PLUS): Repetir pérdida/recuperación
        #10 rx_code_group_in = 10'b000000_0000; // Código inválido
        #10 rx_code_group_in = `K28_5_decmas;   // Recupera

        // Fin de prueba
        #100 $finish;
    end

    // Generación del reloj
    always #5 clk = ~clk;

endmodule
