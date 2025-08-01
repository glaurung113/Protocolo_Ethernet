/* ================================================================
 * Módulo: pcs_tx_tester
 * Descripción:
 *   Generador de estímulos para el banco de pruebas del transmisor.
 *   Produce secuencias de datos y señales de control para validar
 *   el comportamiento del módulo Transmitter.
 *
 * Entradas:
 *   Ninguna (este módulo solo genera estímulos).
 *
 * Salidas:
 *   - TX_EN: Habilita la transmisión de datos.
 *   - TX_ER: Señal de error para probar condiciones especiales.
 *   - GTX_CLK: Reloj de transmisión (Gigabit Transmit Clock).
 *   - TXD: Datos paralelos de 8 bits a codificar.
 *   - mr_main_reset: Señal de reinicio global.
 *   - power_on: Habilita la lógica de transmisión.
 *   - xmit: Estado externo de transmisión (IDLE/DATA).
 * ================================================================
 */

`include "pcs_defs.vh"

module transmitter_tester(
    output reg TX_EN,
    output reg TX_ER,
    output reg GTX_CLK,
    output reg [7:0] TXD,
    output reg mr_main_reset,
    output reg power_on,
    output reg [2:0] xmit
);

    initial begin
        // Fase 1: Transmisión normal (tu bloque original)
        TX_EN = `FALSE;
        TX_ER = `FALSE;
        GTX_CLK = 1'b0;
        TXD = 8'h01;
        mr_main_reset = ~`TRUE;
        power_on = 1'b1;
        xmit = `IDLE;

        #10 mr_main_reset = ~`FALSE;
        #10 xmit = `DATA;
        #50 TX_EN = `TRUE;
        #65 TXD = 8'h00;
        #20 TXD = 8'h01;
        #20 TXD = 8'h02;
        #20 TXD = 8'h03;
        #20 TXD = 8'h04;

        // Fase 2: Prueba de error (nuevo)
        #20 TX_ER = `TRUE;  // Simula un error de transmisión
        #20 TXD = 8'hFF;    // Datos inválidos durante el error
        #20 TX_ER = `FALSE; // Vuelve al estado normal

        // Fase 3: Continuación normal
        #20 TXD = 8'h05;
        #20 TXD = 8'h06;
        #20 TXD = 8'h07;

        // Finaliza transmisión
        #20 TX_EN = `FALSE;

        // Fin de prueba
        #200 $finish;
    end

    // Generación del reloj GTX_CLK
    always begin
        #5 GTX_CLK = ~GTX_CLK;
    end
endmodule
