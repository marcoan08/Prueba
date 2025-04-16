//test para mesh con 1 disp
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

        // Set bus_if y terminal_id para cada agente
        //for (int i = 0; i < 4; i++) begin
            uvm_config_db#(virtual bus_if)::set(this, $sformatf("e0.agt*"), "bus_if", vif);
            //uvm_config_db#(int)::set(this, $sformatf("e0.agts[%0d]*", i), "terminal_id", i);
        //end

        sequences = normal_sequence::type_id::create("sequences");  // Creacion de las secuencias
        sequences.randomize(); // Aleatorizacion de las secuencias
    endfunction

    virtual task run_phase(uvm_phase phase);

    phase.raise_objection(this);
        
        // Esperar inicialización del DUT
        #100;
        
        // Crear e iniciar una secuencia independiente para cada agente
        //foreach (e0.agts[i]) begin
            //fork
                //automatic int j = i;
                //begin
                    normal_sequence seq;
                    seq = normal_sequence::type_id::create("seq");
                    seq.randomize();
                    seq.start(e0.agt.s0);
                //end
            //join_none
        //end
        
        // Esperar a que todas las secuencias completen
        //wait fork;
        
        // Esperar tiempo adicional si es necesario
        #10000;
        
        phase.drop_objection(this);
        //phase.raise_objection(this);
        //if (e0.agts[3].s0 == null) begin
        //    `uvm_error("TEST", $sformatf("Sequencer s0 en agts 3 es NULL"))
        //end
        //sequences.start(e0.agts[3].s0);
        //#10000;
        //phase.drop_objection(this); // Objecion para terminar test
    endtask
endclass