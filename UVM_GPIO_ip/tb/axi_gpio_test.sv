class axi_gpio_test extends uvm_test;
    `uvm_component_utils(axi_gpio_test)

    axi_gpio_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = axi_gpio_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        string test_seq;

        gpio_output_seq  seq_out;
        gpio_input_seq   seq_in;
        gpio_mixed_seq   seq_mix;
        gpio_toggle_seq  seq_tog;
        gpio_wstrb_seq   seq_wstrb;
        axi_gpio_random_seq seq_rand;

        phase.raise_objection(this);

        if (!$value$plusargs("SEQ=%s", test_seq))
            test_seq = "random";

        case (test_seq)
            "output" : begin
                seq_out = gpio_output_seq::type_id::create("seq");
                seq_out.start(env.agent.sequencer);
            end
            "input" : begin
                seq_in = gpio_input_seq::type_id::create("seq");
                seq_in.start(env.agent.sequencer);
            end
            "mixed" : begin
                seq_mix = gpio_mixed_seq::type_id::create("seq");
                seq_mix.start(env.agent.sequencer);
            end
            "toggle" : begin
                seq_tog = gpio_toggle_seq::type_id::create("seq");
                seq_tog.start(env.agent.sequencer);
            end
            "wstrb" : begin
                seq_wstrb = gpio_wstrb_seq::type_id::create("seq");
                seq_wstrb.start(env.agent.sequencer);
            end
            default : begin
                seq_rand = axi_gpio_random_seq::type_id::create("seq");
                seq_rand.start(env.agent.sequencer);
            end
        endcase

        phase.drop_objection(this);
    endtask

    function void report_phase(uvm_phase phase);
        `uvm_info("TEST", "==========================================", UVM_NONE)
        `uvm_info("TEST", "       AXI GPIO UVM FINAL SUMMARY        ", UVM_NONE)
        `uvm_info("TEST", "==========================================", UVM_NONE)
        `uvm_info("TEST", " SCOREBOARD : check report above         ", UVM_NONE)
        `uvm_info("TEST", "==========================================", UVM_NONE)
    endfunction

endclass