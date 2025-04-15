`ifndef ROUTER_SINGLE_PKT_TEST_SV
`define ROUTER_SINGLE_PKT_TEST_SV

class router_single_pkt_test extends router_base_test;
    `uvm_component_utils(router_single_pkt_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_test_sequence();
        router_single_pkt_sequence seq;
        seq = router_single_pkt_sequence::type_id::create("seq");

        // Configurar parámetros (ejemplo: terminal 0 -> terminal 1)
        seq.source_terminal = 0;
        seq.target_terminal = 1;
        seq.mode = 0; // Modo columna-primero

        // Iniciar secuencia SOLO en el secuenciador de la terminal origen
        seq.start(env.agents[seq.source_terminal].sequencer);
    endtask
endclass

`endif // ROUTER_SINGLE_PKT_TEST_SV