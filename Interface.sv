`ifndef ROUTER_IF_SV
`define ROUTER_IF_SV

interface router_if #(parameter pckg_sz = 40) (input clk, input reset);
    // Terminal signals
    logic [pckg_sz-1:0] data_out_i_in;
    logic pndng_i_in;
    logic pop;
    logic popin;
    logic pndng;
    logic [pckg_sz-1:0] data_out;
    
    // Clocking block for driver
    clocking driver_cb @(posedge clk);
        default input #1 output #1;
        output data_out_i_in;
        output pndng_i_in;
        output pop;
        input popin;
        input pndng;
        input data_out;
    endclocking
    
    // Clocking block for monitor
    clocking monitor_cb @(posedge clk);
        default input #1 output #1;
        input data_out_i_in;
        input pndng_i_in;
        input pop;
        input popin;
        input pndng;
        input data_out;
    endclocking
    
    // Modports
    modport DRIVER  (clocking driver_cb, input clk, reset);
    modport MONITOR (clocking monitor_cb, input clk, reset);
    
    // Synchronizer for reset
    logic sync_reset;
    always @(posedge clk) begin
        sync_reset <= reset;
    end
endinterface

`endif // ROUTER_IF_SV