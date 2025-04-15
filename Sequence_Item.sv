`ifndef ROUTER_ITEM_SV
`define ROUTER_ITEM_SV

class router_item extends uvm_sequence_item;
    // Packet fields
    rand bit [7:0] target_id;         // Target terminal ID
    rand bit [3:0] target_row;        // Target row in mesh
    rand bit [3:0] target_col;        // Target column in mesh
    rand bit mode;                    // Routing mode (0: column first, 1: row first)
    rand bit [7:0] source_id;         // Source terminal ID
    rand bit [7:0] packet_id;         // Unique packet ID
    rand bit [pckg_sz-34:0] payload;  // Payload data
    
    // Control fields
    rand int delay;                   // Delay before sending
    bit is_response;                  // Is this a response packet?
    
    // Parameters
    parameter pckg_sz = 40;
    
    // Constraints
    constraint valid_target {
        target_id inside {[0:4]};     // 0-3 for terminals, 4 for broadcast
        target_row inside {[1:4]};    // Assuming 4x4 mesh
        target_col inside {[1:4]};    // Assuming 4x4 mesh
    }
    
    constraint valid_delay {
        delay inside {[0:5]};
    }
    
    // UVM macros
    `uvm_object_utils_begin(router_item)
        `uvm_field_int(target_id, UVM_ALL_ON)
        `uvm_field_int(target_row, UVM_ALL_ON)
        `uvm_field_int(target_col, UVM_ALL_ON)
        `uvm_field_int(mode, UVM_ALL_ON)
        `uvm_field_int(source_id, UVM_ALL_ON)
        `uvm_field_int(packet_id, UVM_ALL_ON)
        `uvm_field_int(payload, UVM_ALL_ON)
        `uvm_field_int(delay, UVM_ALL_ON)
        `uvm_field_int(is_response, UVM_ALL_ON)
    `uvm_object_utils_end
    
    // Constructor
    function new(string name = "router_item");
        super.new(name);
    endfunction
    
    // Convert packet to 40-bit bus format
    function bit [pckg_sz-1:0] pack();
        return {target_id, target_row, target_col, mode, source_id, packet_id, payload};
    endfunction
    
    // Unpack 40-bit bus format to packet fields
    function void unpack(bit [pckg_sz-1:0] data);
        target_id  = data[pckg_sz-1:pckg_sz-8];
        target_row = data[pckg_sz-9:pckg_sz-12];
        target_col = data[pckg_sz-13:pckg_sz-16];
        mode       = data[pckg_sz-17];
        source_id  = data[pckg_sz-18:pckg_sz-25];
        packet_id  = data[pckg_sz-26:pckg_sz-33];
        payload    = data[pckg_sz-34:0];
    endfunction
    
    // Pretty print for debugging
    function string convert2string();
        return $sformatf("TargetID: %0d, TargetRow: %0d, TargetCol: %0d, Mode: %0d, SourceID: %0d, PacketID: %0d, Payload: %h, Delay: %0d, IsResponse: %0d",
                         target_id, target_row, target_col, mode, source_id, packet_id, payload, delay, is_response);
    endfunction
endclass

`endif // ROUTER_ITEM_SV