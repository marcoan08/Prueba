`ifndef TESTBENCH_SV
`define TESTBENCH_SV

`include "Router_library.sv"
import uvm_pkg::*;
`include "uvm_macros.svh"
// 2. Incluir todos los componentes UVM con tus nombres exactos
`include "Interface.sv"          // Interface del router
`include "Sequence_Item.sv"      // Transacción UVM
`include "Sequence.sv"           // Secuencias de prueba
`include "Driver.sv"             // Driver UVM
`include "Monitor.sv"            // Monitor UVM
`include "Agent.sv"              // Agente UVM
`include "Scoreboard.sv"         // Verificador
`include "Environment.sv"        // Ambiente UVM
`include "Test.sv"               // Casos de prueba

module Testbench;
    timeunit 1ns;
    timeprecision 1ps;
    
    // Parámetros del diseño
    parameter pckg_sz = 40;
    parameter fifo_depth = 4;
    parameter bdcst = {8{1'b1}};
    
    // Señales globales
    bit clk;
    bit reset;
    
    // Generación de reloj
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Interfaces para las 4 terminales
    Interface #(pckg_sz) vif0(clk, reset);
    Interface #(pckg_sz) vif1(clk, reset);
    Interface #(pckg_sz) vif2(clk, reset);
    Interface #(pckg_sz) vif3(clk, reset);
    
    // Instancia del DUT (Router)
    router_bus_gnrtr #(
        .pck_sz(pckg_sz),
        .num_ntrfs(4),
        .broadcast(bdcst),
        .fifo_depth(fifo_depth),
        .id_c(1),
        .id_r(1),
        .columns(4),
        .rows(4)
    ) dut (
        .clk(clk),
        .reset(reset),
        .data_out_i_in('{vif0.data_out_i_in, vif1.data_out_i_in, vif2.data_out_i_in, vif3.data_out_i_in}),
        .pndng_i_in('{vif0.pndng_i_in, vif1.pndng_i_in, vif2.pndng_i_in, vif3.pndng_i_in}),
        .pop('{vif0.pop, vif1.pop, vif2.pop, vif3.pop}),
        .popin('{vif0.popin, vif1.popin, vif2.popin, vif3.popin}),
        .pndng('{vif0.pndng, vif1.pndng, vif2.pndng, vif3.pndng}),
        .data_out('{vif0.data_out, vif1.data_out, vif2.data_out, vif3.data_out})
    );
    
    // Configuración UVM
    initial begin
        // Registrar interfaces
        uvm_config_db#(virtual Interface)::set(null, "uvm_test_top.env*", "vif0", vif0);
        uvm_config_db#(virtual Interface)::set(null, "uvm_test_top.env*", "vif1", vif1);
        uvm_config_db#(virtual Interface)::set(null, "uvm_test_top.env*", "vif2", vif2);
        uvm_config_db#(virtual Interface)::set(null, "uvm_test_top.env*", "vif3", vif3);
        
        // Ejecutar test
        run_test();
    end
    
    // Generación de reset
    initial begin
        reset = 1;
        #100 reset = 0;
    end
    
    // Volcado de waveforms
    initial begin
        $dumpfile("waveforms.vcd");
        $dumpvars(0, Testbench);
    end
    
    // Timeout de simulación
    initial begin
        #100000; // 100us de timeout
        $display("Timeout: Simulación terminada");
        $finish;
    end
endmodule

`endif // TESTBENCH_SV