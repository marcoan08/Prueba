class test extends uvm_test;
    `uvm_component_utils(test)
    function new(string name = "test", uvm_component parent=null);
        super.new(name, parent);
    endfunction
    
    // Interfaces del ambiente, secuencias e interfaz virtual
    env e0;
    normal_sequence sequences;
    virtual bus_if vif;
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        e0 = env::type_id::create("e0", this); // Creacion del ambiente
        if (!uvm_config_db#(virtual bus_if)::get(this, "", "bus_if", vif)) begin
            `uvm_fatal("TEST", "Did not get vif")
        end else begin
            $display("TEST: Interfaz obtenida con éxito");
        end

        uvm_config_db#(virtual bus_if)::set(this, $sformatf("e0.agt*"), "bus_if", vif);
        sequences = normal_sequence::type_id::create("sequences");  // Creacion de las secuencias
        sequences.randomize(); // Aleatorizacion de las secuencias
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        
        // Esperar inicialización del DUT
        #100;
        
        // Usar la secuencia ya creada en build_phase
        sequences.start(e0.agt.s0);
        
        // Esperar tiempo adicional si es necesario
        #10000;
        
        phase.drop_objection(this);
    endtask
endclass