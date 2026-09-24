
class axi_gpio_env extends uvm_env;
    `uvm_component_utils(axi_gpio_env)

    axi_gpio_agent      agent;
    axi_gpio_scoreboard scoreboard;
    axi_gpio_coverage   coverage;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent      = axi_gpio_agent     ::type_id::create("agent",      this);
        scoreboard = axi_gpio_scoreboard::type_id::create("scoreboard", this);
        coverage   = axi_gpio_coverage  ::type_id::create("coverage",   this);
    endfunction

    function void connect_phase(uvm_phase phase);
        // Monitor ap → Scoreboard & Coverage
        agent.ap.connect(scoreboard.ap);
        agent.ap.connect(coverage.analysis_export);
    endfunction
endclass

