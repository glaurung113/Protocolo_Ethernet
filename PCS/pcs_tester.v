/* ================================================================
 * Módulo: pcs_tester
 * Descripción:
 *   Este módulo genera los estímulos necesarios para probar el
 *   funcionamiento de la subcapa PCS (Physical Coding Sublayer).
 *   Simula la transmisión de datos, errores y control de reloj.
 *
 * Entradas: (N/A)
 * Salidas:
 *   - TX_EN         : Habilita la transmisión de datos.
 *   - TX_ER         : Señal de error en la transmisión.
 *   - TX_CLK        : Reloj de transmisión.
 *   - RX_CLK        : Reloj de recepción.
 *   - TXD           : Datos paralelos (8 bits) a transmitir.
 *   - mr_main_reset : Reset principal del sistema.
 *   - power_on      : Habilita la operación del PCS.
 * ================================================================
 */

`include "pcs_defs.vh"

module pcs_tester(
    output reg TX_EN
    ,output reg TX_ER
    ,output reg TX_CLK
    ,output reg RX_CLK
    ,output reg [7:0] TXD
    ,output reg mr_main_reset
    ,output reg power_on
);
    initial begin
        // Fase 1: Inicialización y transmisión normal
        TX_EN = `FALSE;
        TX_ER = `FALSE;
        TX_CLK = 1'b0;
        RX_CLK = 1'b0;
        TXD = 8'h01;
        mr_main_reset = ~`TRUE;
        power_on = 1'b1;

        #20 mr_main_reset = ~`FALSE;
        #200 TX_EN = `TRUE;
        #80 TXD = 8'h01;
        #20 TXD = 8'h02;
        #20 TXD = 8'h03;

        // Fase 2: Prueba de error
        #20 TX_ER = `TRUE;   // Simula error en la transmisión
        #20 TXD = 8'hFF;     // Datos erróneos
        #20 TX_ER = `FALSE;  // Vuelve al estado normal

        // Fase 3: Continuación normal
        #20 TXD = 8'h04;
        #20 TXD = 8'h05;
        #20 TXD = 8'h06;
        #20 TXD = 8'h07;
        #20 TX_EN = `FALSE;

        // Fin de prueba
        #200 $finish;
    end

    // Generación de reloj de transmisión
    always begin
        #5 TX_CLK = !TX_CLK;
    end

    // Generación de reloj de recepción
    always begin
        #5 RX_CLK = !RX_CLK;
    end


endmodule 
