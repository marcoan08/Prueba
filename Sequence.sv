`ifndef ROUTER_SINGLE_PKT_SEQUENCE_SV
`define ROUTER_SINGLE_PKT_SEQUENCE_SV

class router_single_pkt_sequence extends uvm_sequence #(router_item);
    `uvm_object_utils(router_single_pkt_sequence)

    // Parámetros configurables (pueden setearse desde el test)
    int source_terminal = 0;  // Terminal origen (0-3)
    int target_terminal = 1;  // Terminal destino (0-3)
    bit [3:0] target_row = 1; // Fila destino (para ruteo)
    bit [3:0] target_col = 1; // Columna destino (para ruteo)
    bit mode = 0;             // 0: columna primero, 1: fila primero

    function new(string name = "router_single_pkt_sequence");
        super.new(name);
    endfunction

    task body();
        router_item pkt;
        pkt = router_item::type_id::create("pkt");

        // Configurar el paquete
        pkt.target_id  = target_terminal;
        pkt.source_id  = source_terminal;
        pkt.target_row = target_row;
        pkt.target_col = target_col;
        pkt.mode       = mode;
        pkt.packet_id  = 1;           // ID único
        pkt.payload    = 8'hA5;       // Payload fijo (para verificación fácil)
        pkt.delay      = 5;           // Sin delay
        pkt.is_response = 0;

        `uvm_info("SEQ", $sformatf("Enviando paquete SINGLE desde terminal %0d -> %0d: %s", 
                                  source_terminal, target_terminal, pkt.convert2string()), UVM_LOW)

        // Enviar el paquete
        start_item(pkt);
        finish_item(pkt);
    endtask
endclass

`endif // ROUTER_SINGLE_PKT_SEQUENCE_SV