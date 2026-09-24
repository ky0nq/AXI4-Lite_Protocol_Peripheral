class axi_gpio_base_seq extends uvm_sequence #(axi_gpio_seq_item);
    `uvm_object_utils(axi_gpio_base_seq)
    function new(string name = "axi_gpio_base_seq");
        super.new(name);
    endfunction
endclass

// output mode test
class gpio_output_seq extends axi_gpio_base_seq;
    `uvm_object_utils(gpio_output_seq)
    function new(string name = "gpio_output_seq"); super.new(name); endfunction

    task body();
        `uvm_info("SEQ", "=== gpio_output_seq START ===", UVM_LOW)

        // CR = 0xFF
        `uvm_do_with(req, { addr==4'h0; wdata==32'h0000_00FF; wstrb==4'hF; rw==1'b1; })
        // ODR = 0xA5
        `uvm_do_with(req, { addr==4'h8; wdata==32'h0000_00A5; wstrb==4'hF; rw==1'b1; })
        // CR readback
        `uvm_do_with(req, { addr==4'h0; rw==1'b0; })
        // ODR readback
        `uvm_do_with(req, { addr==4'h8; rw==1'b0; })

        `uvm_info("SEQ", "=== gpio_output_seq END ===", UVM_LOW)
    endtask
endclass

// input mode test
class gpio_input_seq extends axi_gpio_base_seq;
    `uvm_object_utils(gpio_input_seq)
    function new(string name = "gpio_input_seq"); super.new(name); endfunction

    task body();
        `uvm_info("SEQ", "=== gpio_input_seq START ===", UVM_LOW)

        // CR = 0x00 
        `uvm_do_with(req, { addr==4'h0; wdata==32'h0000_0000; wstrb==4'hF; rw==1'b1; })
        // IDR read 
        `uvm_do_with(req, { addr==4'h4; rw==1'b0; })

        `uvm_info("SEQ", "=== gpio_input_seq END ===", UVM_LOW)
    endtask
endclass

class gpio_mixed_seq extends axi_gpio_base_seq;
    `uvm_object_utils(gpio_mixed_seq)
    function new(string name = "gpio_mixed_seq"); super.new(name); endfunction

    task body();
        `uvm_info("SEQ", "=== gpio_mixed_seq START ===", UVM_LOW)
        `uvm_do_with(req, { addr==4'h0; wdata==32'h0000_00F0; wstrb==4'hF; rw==1'b1; })
        `uvm_do_with(req, { addr==4'h8; wdata==32'h0000_00A0; wstrb==4'hF; rw==1'b1; })
        `uvm_do_with(req, { addr==4'h4; rw==1'b0; })
        `uvm_do_with(req, { addr==4'h0; rw==1'b0; })
        `uvm_info("SEQ", "=== gpio_mixed_seq END ===", UVM_LOW)
    endtask
endclass

class gpio_toggle_seq extends axi_gpio_base_seq;
    `uvm_object_utils(gpio_toggle_seq)
    function new(string name = "gpio_toggle_seq"); super.new(name); endfunction

    task body();
        `uvm_info("SEQ", "=== gpio_toggle_seq START ===", UVM_LOW)

        `uvm_do_with(req, { addr==4'h0; wdata==32'h0000_00FF; wstrb==4'hF; rw==1'b1; })

        repeat(4) begin
            `uvm_do_with(req, { addr==4'h8; wdata==32'h0000_00AA; wstrb==4'hF; rw==1'b1; })
            `uvm_do_with(req, { addr==4'h8; rw==1'b0; })
            `uvm_do_with(req, { addr==4'h8; wdata==32'h0000_0055; wstrb==4'hF; rw==1'b1; })
            `uvm_do_with(req, { addr==4'h8; rw==1'b0; })
        end

        `uvm_info("SEQ", "=== gpio_toggle_seq END ===", UVM_LOW)
    endtask
endclass

class gpio_wstrb_seq extends axi_gpio_base_seq;
    `uvm_object_utils(gpio_wstrb_seq)
    function new(string name = "gpio_wstrb_seq"); super.new(name); endfunction

    task body();
        `uvm_info("SEQ", "=== gpio_wstrb_seq START ===", UVM_LOW)

        `uvm_do_with(req, { addr==4'h0; wdata==32'hDEAD_BEEF; wstrb==4'b0001; rw==1'b1; })
        `uvm_do_with(req, { addr==4'h0; rw==1'b0; })
        `uvm_do_with(req, { addr==4'h0; wdata==32'hCAFE_BABE; wstrb==4'b0011; rw==1'b1; })
        `uvm_do_with(req, { addr==4'h0; rw==1'b0; })
        `uvm_do_with(req, { addr==4'h0; wdata==32'h0000_00FF; wstrb==4'b1111; rw==1'b1; })
        `uvm_do_with(req, { addr==4'h0; rw==1'b0; })

        `uvm_info("SEQ", "=== gpio_wstrb_seq END ===", UVM_LOW)
    endtask
endclass

class axi_gpio_random_seq extends uvm_sequence #(axi_gpio_seq_item);
    `uvm_object_utils(axi_gpio_random_seq)

    function new(string name = "axi_gpio_random_seq");
        super.new(name);
    endfunction

    task body();
        axi_gpio_seq_item item;

        repeat(100) begin
            item = axi_gpio_seq_item::type_id::create("item");
            start_item(item);
            if (!item.randomize())
                `uvm_fatal("SEQ", "randomize failed")
            finish_item(item);
        end
    endtask
endclass