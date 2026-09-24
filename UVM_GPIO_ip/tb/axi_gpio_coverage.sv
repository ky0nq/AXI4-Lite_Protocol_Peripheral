
class axi_gpio_coverage extends uvm_subscriber #(axi_gpio_seq_item);
    `uvm_component_utils(axi_gpio_coverage)

    axi_gpio_seq_item item;

    // --------------------------------------------------
    // Covergroup
    // --------------------------------------------------
    covergroup gpio_cg;

        cp_addr: coverpoint item.addr {
            bins cr_addr  = {4'h0};
            bins idr_addr = {4'h4};
            bins odr_addr = {4'h8};
            bins reg3_addr= {4'hC};
        }

        cp_rw: coverpoint item.rw {
            bins write_op = {1'b1};
            bins read_op  = {1'b0};
        }

        cp_wstrb: coverpoint item.wstrb {
            bins byte0_only = {4'b0001};
            bins byte01     = {4'b0011};
            bins all_bytes  = {4'b1111};
        }

        cp_cr_pattern: coverpoint item.wdata[7:0] {
            bins all_output = {8'hFF};
            bins all_input  = {8'h00};
            bins mixed      = default;
        }

        cp_odr_pattern: coverpoint item.wdata[7:0] {
            bins all_high   = {8'hFF};
            bins all_low    = {8'h00};
            bins toggle     = {8'hAA, 8'h55};
            bins others     = default;
        }

        cp_bresp: coverpoint item.bresp {
            bins okay = {2'b00};
        }
        cp_rresp: coverpoint item.rresp {
            bins okay = {2'b00};
        }

		cx_addr_rw: cross cp_addr, cp_rw {
   	 		bins cr_write  = binsof(cp_addr.cr_addr)  && binsof(cp_rw.write_op);
    		bins cr_read   = binsof(cp_addr.cr_addr)  && binsof(cp_rw.read_op);
    		bins idr_read  = binsof(cp_addr.idr_addr) && binsof(cp_rw.read_op);
		    bins odr_write = binsof(cp_addr.odr_addr) && binsof(cp_rw.write_op);
		    bins odr_read  = binsof(cp_addr.odr_addr) && binsof(cp_rw.read_op);
		    bins reg3_write= binsof(cp_addr.reg3_addr) && binsof(cp_rw.write_op);
		    bins reg3_read = binsof(cp_addr.reg3_addr) && binsof(cp_rw.read_op);
		    ignore_bins idr_write = binsof(cp_addr.idr_addr) && binsof(cp_rw.write_op);
		}

        cx_addr_wstrb: cross cp_addr, cp_wstrb;

    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        gpio_cg = new();
    endfunction

    function void write(axi_gpio_seq_item t);
        item = t;
        gpio_cg.sample();
    endfunction

    function void report_phase(uvm_phase phase);
        `uvm_info("COV", $sformatf("=== Functional Coverage: %.2f%% ===",
                  gpio_cg.get_coverage()), UVM_NONE)
    endfunction
endclass

