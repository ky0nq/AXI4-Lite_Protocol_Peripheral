`include "uvm_macros.svh"
package axi_gpio_pkg;
    import uvm_pkg::*;
    // include file write : dependency priority (inner -> outer)
    `include "axi_gpio_seq_item.sv"
    `include "axi_gpio_sequence.sv"
    `include "axi_gpio_driver.sv"
    `include "axi_gpio_monitor.sv"
    `include "axi_gpio_agent.sv"
    `include "axi_gpio_scoreboard.sv"
    `include "axi_gpio_coverage.sv"
    `include "axi_gpio_env.sv"
    `include "axi_gpio_test.sv"
endpackage
