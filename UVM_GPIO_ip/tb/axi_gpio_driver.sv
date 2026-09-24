
class axi_gpio_driver extends uvm_driver #(axi_gpio_seq_item);
    `uvm_component_utils(axi_gpio_driver)

    virtual axi4lite_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual axi4lite_if)::get(this, "", "vif", vif))
            `uvm_fatal("DRV", "Failed to get virtual interface")
    endfunction

    task run_phase(uvm_phase phase);
        init_signals();
        @(posedge vif.clk iff vif.awready === 1'bx || 1);
        repeat(5) @(posedge vif.clk);

        forever begin
            seq_item_port.get_next_item(req);
            `uvm_info("DRV", $sformatf("Got item: rw=%0b addr=0x%0h wdata=0x%08h",
                      req.rw, req.addr, req.wdata), UVM_MEDIUM)
            if (req.rw) drive_write(req);
            else        drive_read(req);
            seq_item_port.item_done();
        end
    endtask

    task drive_write(axi_gpio_seq_item item);
        @(posedge vif.clk);
        vif.awaddr  <= item.addr;
        vif.awprot  <= 3'b000;
        vif.awvalid <= 1'b1;
        vif.wdata   <= item.wdata;
        vif.wstrb   <= item.wstrb;
        vif.wvalid  <= 1'b1;
        vif.bready  <= 1'b1;

        @(posedge vif.clk iff (vif.awready === 1'b1 && vif.wready === 1'b1));
        vif.awvalid <= 1'b0;
        vif.wvalid  <= 1'b0;

        @(posedge vif.clk iff vif.bvalid === 1'b1);
        vif.bready  <= 1'b0;

        @(posedge vif.clk);
    endtask

    // --------------------------------------------------
    // Read Transaction
    // --------------------------------------------------
    task drive_read(axi_gpio_seq_item item);
        @(posedge vif.clk);
        vif.araddr  <= item.addr;
        vif.arprot  <= 3'b000;
        vif.arvalid <= 1'b1;
        vif.rready  <= 1'b1;

        @(posedge vif.clk iff vif.arready === 1'b1);
        vif.arvalid <= 1'b0;

        @(posedge vif.clk iff vif.rvalid === 1'b1);
        vif.rready  <= 1'b0;

        @(posedge vif.clk);
    endtask

    task init_signals();
        vif.awaddr  <= 0;
        vif.awprot  <= 0;
        vif.awvalid <= 0;
        vif.wdata   <= 0;
        vif.wstrb   <= 0;
        vif.wvalid  <= 0;
        vif.bready  <= 0;
        vif.araddr  <= 0;
        vif.arprot  <= 0;
        vif.arvalid <= 0;
        vif.rready  <= 0;
    endtask
endclass

