
class axi_gpio_agent extends uvm_agent;
    `uvm_component_utils(axi_gpio_agent)

    axi_gpio_driver  driver;
    axi_gpio_monitor monitor;
    uvm_sequencer #(axi_gpio_seq_item) sequencer;

    uvm_analysis_port #(axi_gpio_seq_item) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        driver    = axi_gpio_driver ::type_id::create("driver",    this);
        monitor   = axi_gpio_monitor::type_id::create("monitor",   this);
        sequencer = uvm_sequencer #(axi_gpio_seq_item)::type_id::create("sequencer", this);
        ap        = new("ap", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        driver.seq_item_port.connect(sequencer.seq_item_export);
        monitor.ap.connect(ap);
    endfunction
endclass

