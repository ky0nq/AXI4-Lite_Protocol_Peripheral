
class axi_gpio_monitor extends uvm_monitor;
    `uvm_component_utils(axi_gpio_monitor)

    virtual axi4lite_if vif;
    uvm_analysis_port #(axi_gpio_seq_item) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db #(virtual axi4lite_if)::get(this, "", "vif", vif))
            `uvm_fatal("MON", "Failed to get virtual interface")
    endfunction

    task run_phase(uvm_phase phase);
        fork
            monitor_write();
            monitor_read();
        join
    endtask

// Write Transacion
    task monitor_write();
        forever begin
            axi_gpio_seq_item item;
            item = axi_gpio_seq_item::type_id::create("mon_write");
            item.rw = 1'b1;

            // AW channel handshake
            @(posedge vif.clk iff (vif.awvalid === 1'b1 && vif.awready === 1'b1));
            item.addr  = vif.awaddr;
            item.wdata = vif.wdata;
            item.wstrb = vif.wstrb;

            // B channel handshake (Write Response)
            @(posedge vif.clk iff (vif.bvalid === 1'b1 && vif.bready === 1'b1));
            item.bresp = vif.bresp;

            `uvm_info("MON", $sformatf("WRITE addr=0x%0h data=0x%08h strb=0x%0h bresp=%0b",
                      item.addr, item.wdata, item.wstrb, item.bresp), UVM_MEDIUM)
            ap.write(item);
        end
    endtask

// Read Transacion
    task monitor_read();
        forever begin
            axi_gpio_seq_item item;
            item = axi_gpio_seq_item::type_id::create("mon_read");
            item.rw = 1'b0;

            // AR channel handshake
            @(posedge vif.clk iff (vif.arvalid === 1'b1 && vif.arready === 1'b1));
            item.addr = vif.araddr;

            // R channel handshake (Read Data)
            @(posedge vif.clk iff (vif.rvalid === 1'b1 && vif.rready === 1'b1));
            item.rdata = vif.rdata;
            item.rresp = vif.rresp;

            `uvm_info("MON", $sformatf("READ  addr=0x%0h data=0x%08h rresp=%0b",
                      item.addr, item.rdata, item.rresp), UVM_MEDIUM)
            ap.write(item);
        end
    endtask
endclass

