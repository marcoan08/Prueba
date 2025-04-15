// Archivo: router_single_pkt_test.sv
`ifndef ROUTER_SINGLE_PKT_TEST_SV
`define ROUTER_SINGLE_PKT_TEST_SV

class router_single_pkt_test extends uvm_test;
    `uvm_component_utils(router_single_pkt_test)

    // Variables de configuración del test
    int source_terminal = 0;  // Terminal origen (0-3)
    int target_terminal = 1;  // Terminal destino (0-3)
    bit mode = 0;             // 0: columna primero, 1: fila primero
    
    // Referencia al environment
    router_env env;

    function new(string name = "router_single_pkt_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // Crear environment
        env = router_env::type_id::create("env", this);
        
        // Configurar parámetros del test
        uvm_config_db#(int)::set(this, "*", "source_terminal", source_terminal);
        uvm_config_db#(int)::set(this, "*", "target_terminal", target_terminal);
        uvm_config_db#(bit)::set(this, "*", "mode", mode);
    endfunction

    task run_phase(uvm_phase phase);
        // Declarar la secuencia (que ya existe en otro archivo)
        router_single_pkt_sequence seq;
        
        phase.raise_objection(this);
        
        `uvm_info("TEST/START", $sformatf("Iniciando test: Paquete Terminal %0d -> Terminal %0d, Mode: %0d", 
                                        source_terminal, target_terminal, mode), UVM_LOW)
        
        // Crear e iniciar la secuencia en el agente de origen
        seq = router_single_pkt_sequence::type_id::create("seq");
        seq.start(env.agents[source_terminal].sequencer);
        
        // Esperar a que termine la secuencia
        #100; // Pequeño delay para completar transacción
        
        `uvm_info("TEST/END", "Test completado", UVM_LOW)
        phase.drop_objection(this);
    endtask
    
    function void report_phase(uvm_phase phase);
        // Reporte final
        `uvm_info("TEST/REPORT", $sformatf("Test finalizado: Paquete enviado desde Terminal %0d", source_terminal), UVM_LOW)
    endfunction
endclass

`endif // ROUTER_SINGLE_PKT_TEST_SV