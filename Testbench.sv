//tb para mesh con 1 disp
`timescale 1ns / 1ps

////////////////////////////////////////////////
///// Inclusiones de archivos del ambiente /////
////////////////////////////////////////////////
`include "uvm_macros.svh"
import uvm_pkg::*;
`include "Router_library.sv"
`include "Interface.sv"
`include "Sequence_Item.sv"
//`include "coverage.sv"
`include "Sequence.sv"
`include "Driver.sv"
`include "Monitor.sv"
`include "Scoreboard.sv"
`include "Agent.sv"
`include "Environment.sv"
`include "Test.sv"


/////////////////////
///// Testbench /////
/////////////////////
module testbench;

    // Creación del reloj
    reg clk = 0;
    always #10 clk = ~clk;
    
    // Instancia de la interfaz
    bus_if  vif (clk);

    // Instancia del DUT
    router_bus_gnrtr #( .pck_sz (40),  .num_ntrfs (4),  .broadcast ({8{1'b1}}),  .fifo_depth (4), .id_c (2), .id_r (2), .columns (4),  .rows (4)) dut
            (.clk (clk),
            .reset(vif.reset), 
            .data_out_i_in(vif.data_out_i_in),
            .pndng_i_in(vif.pndng_i_in),
            .pop(vif.pop), 
            .popin(vif.popin),
            .pndng(vif.pndng),
            .data_out(vif.data_out)
    );

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars;
        
        uvm_config_db#(virtual bus_if)::set(null, "*", "bus_if", vif);
        //uvm_config_db#(virtual bus_if)::set(null, "uvm_test_top", "bus_if", vif); // Configura la interfaz virtual
        run_test("test"); // Corre el test
    end
endmodule