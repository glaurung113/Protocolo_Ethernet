/* ================================================================
 * Módulo: synchronizer_tb
 * Descripción:
 *   Banco de pruebas (testbench) para el módulo Synchronizer.
 *   Instancia tanto el Synchronizer como el synchronizer_tester para
 *   simular su comportamiento y registrar las señales en un archivo VCD.
 *
 * Entradas: (no aplica, todas las señales son internas al testbench)
 * Salidas: (no aplica, todas las señales son internas al testbench)
 * ================================================================
 */
 
module synchronizer_tb;

    wire reset, clk;
    wire rx_even_out;
    wire code_sync_status;
    wire [9:0] rx_code_group_in, rx_code_group_out;

    initial begin
        $dumpfile("synchronizer_waveform.vcd");
        $dumpvars(-1, dut);
        $dumpvars(-1, dut_p.rx_even_out);
    end

    Synchronizer dut(
        .rx_clk(clk),
        .reset(reset),
        .rx_code_group(rx_code_group_in),
        .SUDI({rx_even_out,rx_code_group_out}),
        .sync_status(code_sync_status)
    );

    synchronizer_tester dut_p (
        .reset(reset),
        .clk(clk),
        .rx_code_group_in(rx_code_group_in),
        .rx_code_group_out(rx_code_group_out),
        .rx_even_out(rx_even_out),
        .code_sync_status(code_sync_status)
    );

endmodule
