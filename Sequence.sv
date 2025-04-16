//Sequence para Mesh con 1 disp

class normal_sequence  #(
    parameter pckg_sz = 40,
    parameter num_ntrfs = 4,
    parameter broadcast = {8{1'b1}},
    parameter fifo_depth = 4,
    parameter columns = 4,
    parameter rows = 4,
    parameter id_c = 0,
    parameter id_r = 0
)extends uvm_sequence #(Item);
    `uvm_object_utils(normal_sequence); 

   
    function new(string name="normal_sequence");
        super.new(name);
    endfunction

    int num = 1; 

    virtual task body();
        //for(int i = 0; i < num; i++)begin
            Item item = Item::type_id::create("item");

            //item.const_retardo_c.constraint_mode(1);
            //item.input_terminal_c.constraint_mode(1);
            //item.target_col_c.constraint_mode(1);
            //item.target_row_c.constraint_mode(1);
            start_item(item); 
            item.randomize();
            item.post_randomize();
            
            item.D_in = {item.nxt_jump, item.target_row, item.target_col, item.mode, item.payload};
            `uvm_info("SEQ", $sformatf("Dato del secuenciador [%0h], en la input terminal[%0d]", item.D_in, item.input_terminal), UVM_HIGH)
            finish_item(item);
        //end
        `uvm_info("SEQ", $sformatf("Se generaron %0d items para la secuencia",num), UVM_HIGH)

    endtask
endclass