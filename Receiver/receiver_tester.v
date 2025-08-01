/* ================================================================
 * Módulo: receiver_tester
 * Descripción:
 *   Banco de pruebas (testbench) para el módulo Receiver.
 *   Genera estímulos de reloj, sincronización y code-groups
 *   para simular la recepción de datos en la subcapa PCS.
 *
 * Entradas:
 *   - RXD   : Datos paralelos decodificados recibidos (8 bits).
 *   - RX_DV : Señal que indica si los datos son válidos.
 *
 * Salidas:
 *   - rx_clk      : Reloj de recepción.
 *   - sync_status : Estado de sincronización (1 = sincronizado).
 *   - SUDI        : Code-group recibido (10 bits).
 *   - rx_even     : Paridad actual del receptor (even/odd).
 * ================================================================
 */

module receiver_tester(
    output reg rx_clk,
    output reg sync_status,
    output reg [9:0] SUDI,
    output reg rx_even,
    input [7:0] RXD,
    input RX_DV
);

    initial begin
        // Fase 1: Secuencia de recepción normal
        rx_clk = 0;
        sync_status = 0;
        SUDI = 10'b0;
        rx_even = 0;

        // Adquirir sincronización
        #10 sync_status = 1; 
        SUDI = 10'b0011111010; // /K28.5/
        rx_even = 1;
        #20 SUDI = 10'b0110110101; // Datos válidos
        #20 SUDI = 10'b1101101000;
        #20 SUDI = 10'b0110011011;
        #20 SUDI = 10'b1110001011; 
        #20 SUDI = 10'b1011101000;
        #20 SUDI = 10'b1110101000;
        #20 SUDI = 10'b0011111010; // /K28.5/

        // Datos adicionales
        #10 SUDI = 10'b0011111010; 
        #10 SUDI = 10'b0011111010; 
        #10 SUDI = 10'b0011111010;
        #20 SUDI = 10'b0110110101;
        #20 SUDI = 10'b1101101000;
        #20 SUDI = 10'b0001101011;                
        #20 SUDI = 10'b1001010100;
        #20 SUDI = 10'b1011101000; 
        #20 SUDI = 10'b1110101000;
        #20 SUDI = 10'b0011111010; // /K28.5/

        // Fase 2: Forzar pérdida de sincronización
        #20 SUDI = 10'b1111111111; // Code-group inválido
        sync_status = 0;           // Simular pérdida de sincronización
        #20 SUDI = 10'b0000000000; // Mantener estado inválido
        #20 SUDI = 10'b0000000000;

        // Fase 3: Recuperar sincronización con /K28.5/
        #20 SUDI = 10'b0011111010; // /K28.5/
        sync_status = 1;           // Recupera sincronización
        #20 SUDI = 10'b0110110101; // Datos válidos
        #20 SUDI = 10'b1101101000;

        // Fin de prueba
        #100 $finish;
    end

    // Generación de reloj
    always #5 rx_clk = ~rx_clk;

endmodule
