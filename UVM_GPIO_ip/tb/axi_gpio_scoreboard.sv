class axi_gpio_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(axi_gpio_scoreboard)

    uvm_analysis_imp #(axi_gpio_seq_item, axi_gpio_scoreboard) ap;

    logic [7:0] exp_cr  = 8'h00;
    logic [7:0] exp_odr = 8'h00;

    int resp_pass_cnt = 0;
    int resp_fail_cnt = 0;
    int reg_pass_cnt  = 0;
    int reg_fail_cnt  = 0;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
    endfunction

    function void write(axi_gpio_seq_item item);
        if (item.rw) write_check(item);
        else         read_check(item);
    endfunction

    function void write_check(axi_gpio_seq_item item);
        check_resp("BRESP", {30'b0, item.bresp}, 32'h0);

        case (item.addr)
            4'h0: begin
                if (item.wstrb[0]) exp_cr = item.wdata[7:0];
                `uvm_info("SB", $sformatf("CR  updated → 0x%02h", exp_cr), UVM_MEDIUM)
            end
            4'h4: begin
                `uvm_info("SB", "IDR write ignored (read-only pin)", UVM_MEDIUM)
            end
            4'h8: begin
                if (item.wstrb[0]) exp_odr = item.wdata[7:0];
                `uvm_info("SB", $sformatf("ODR updated → 0x%02h", exp_odr), UVM_MEDIUM)
            end
            default: ;
        endcase
    endfunction

    function void read_check(axi_gpio_seq_item item);
        check_resp("RRESP", {30'b0, item.rresp}, 32'h0);

        case (item.addr)
            4'h0: reg_check("CR",  item.rdata[7:0], exp_cr);
            4'h4: begin
                `uvm_info("SB", $sformatf("IDR read = 0x%02h (pin-direct, no predict)",
                          item.rdata[7:0]), UVM_MEDIUM)
            end
            4'h8: reg_check("ODR", item.rdata[7:0], exp_odr);
            default: ;
        endcase
    endfunction

    function void reg_check(string name, logic [7:0] got, logic [7:0] exp);
        if (got !== exp) begin
            `uvm_error("SB", $sformatf("[FAIL] %s | got=0x%02h | exp=0x%02h", name, got, exp))
            reg_fail_cnt++;
        end else begin
            `uvm_info("SB",  $sformatf("[PASS] %s | 0x%02h", name, got), UVM_LOW)
            reg_pass_cnt++;
        end
    endfunction

    function void check_resp(string name, logic [31:0] got, logic [31:0] exp);
        if (got !== exp) begin
            `uvm_error("SB", $sformatf("[FAIL] %s | got=0x%0h | exp=0x%0h", name, got, exp))
            resp_fail_cnt++;
        end else begin
            `uvm_info("SB",  $sformatf("[PASS] %s | OKAY", name), UVM_LOW)
            resp_pass_cnt++;
        end
    endfunction

    function void report_phase(uvm_phase phase);
        `uvm_info("SB", "==========================================", UVM_NONE)
        `uvm_info("SB", "         SCOREBOARD RESULT               ", UVM_NONE)
        `uvm_info("SB", "==========================================", UVM_NONE)
        `uvm_info("SB", $sformatf(" RESP  CHECK : PASS=%0d / FAIL=%0d",
                  resp_pass_cnt, resp_fail_cnt), UVM_NONE)
        `uvm_info("SB", $sformatf(" REG   CHECK : PASS=%0d / FAIL=%0d",
                  reg_pass_cnt,  reg_fail_cnt),  UVM_NONE)
        `uvm_info("SB", $sformatf(" TOTAL CHECK : PASS=%0d / FAIL=%0d",
                  resp_pass_cnt + reg_pass_cnt,
                  resp_fail_cnt + reg_fail_cnt), UVM_NONE)
        `uvm_info("SB", "==========================================", UVM_NONE)
    endfunction

endclass