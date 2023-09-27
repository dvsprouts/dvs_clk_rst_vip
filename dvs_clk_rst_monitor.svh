//------------------------------------------------------------------------------//
//   Copyright 2023 dvsprouts
//
//   Licensed under the Apache License, Version 2.0 (the
//   "License"); you may not use this file except in
//   compliance with the License.  You may obtain a copy of
//   the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in
//   writing, software distributed under the License is
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//   CONDITIONS OF ANY KIND, either express or implied.  See
//   the License for the specific language governing
//   permissions and limitations under the License.
//------------------------------------------------------------------------------//

// **************************************************************************** //
// dvs_clk_rst monitor
// **************************************************************************** //
class dvs_clk_rst_monitor#(int unsigned N_CLKS = 1, N_RSTS = 1) extends uvm_monitor;

    dvs_clk_rst_cfg#(N_CLKS, N_RSTS) cfg;
    virtual dvs_clk_rst_if#(N_CLKS, N_RSTS) vif;
    realtime clks_period[N_CLKS] = '{default:0.0};
    bit active_clks[N_CLKS] = '{default:0.0};
    uvm_analysis_port#(dvs_clk_rst_item) ap;

    `uvm_component_param_utils_begin(dvs_clk_rst_monitor#(N_CLKS, N_RSTS))
    `uvm_component_utils_end

    //------------------------------//
    function new(string name, uvm_component parent = null);
        super.new(name, parent);
        this.ap = new("ap", this);
    endfunction

    //------------------------------//
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_resource_db#(dvs_clk_rst_cfg#(N_CLKS, N_RSTS))::read_by_type(get_full_name(), cfg, this)) begin
            `uvm_fatal(get_type_name(), "cfg object hasn't been set!!!");
        end
        this.vif = this.cfg.vif;
    endfunction

    //------------------------------//
    virtual task run_phase(uvm_phase phase);
        fork
            this.monitor_clks();
            this.monitor_rsts();
        join
    endtask

    //------------------------------//
    task monitor_clks();
        for(int unsigned i = 0; i < N_CLKS; i++) begin
            fork 
                automatic int unsigned ai = i;
                this.monitor_clk(ai);
            join_none
        end
    endtask

    //------------------------------//
    task monitor_rsts();
        for(int unsigned i = 0; i < N_RSTS; i++) begin
            fork 
                automatic int unsigned ai = i;
                this.monitor_reset(ai, 1'b1);
                this.monitor_reset(ai, 1'b0);
            join_none
        end
    endtask

    //------------------------------//
    task monitor_clk(int unsigned idx);
        realtime pn = 0;
        realtime po = 0;
        bit clk_stopped = 1'b0;
        forever begin
            fork 
                this.mon_clk_period(idx, pn, po, clk_stopped);
                this.clk_watchdog(idx, po, clk_stopped);    	  	  
            join_any
            disable fork;
        end
    endtask : monitor_clk

    //------------------------------//
    task mon_clk_period(int unsigned idx, ref realtime pn, po, bit clk_stopped);
        realtime t0 = 0;
        dvs_clk_rst_item clk_mon_item;

        @(posedge vif.clk[idx]) t0 = $realtime();
        @(posedge vif.clk[idx]) pn = $realtime()-t0;

        if(pn != po) begin
            this.clks_period[idx] = pn;
            clk_mon_item = dvs_clk_rst_item::type_id::create("clk_mon_item");
            clk_mon_item.idx = idx;
            if(clk_stopped) begin
                clk_stopped = 1'b0;
                this.active_clks[idx] = 1'b1;
                clk_mon_item.action = dvs_clk_rst_pkg::DVS_CLK_RST_RESTART_CLK;
            end else if (po != 0) begin
                clk_mon_item.action = dvs_clk_rst_pkg::DVS_CLK_RST_RECONFIG_CLK;
            end else begin
                clk_mon_item.action = dvs_clk_rst_pkg::DVS_CLK_RST_START_CLK;
            end
            if ((real'(pn-int'(pn)) != 0)) begin
                clk_mon_item.clk_period_type = dvs_clk_rst_pkg::DVS_CLK_RST_REAL;
                clk_mon_item.clk_period_real = pn;
                clk_mon_item.clk_period_int = 0;
            end else begin
                clk_mon_item.clk_period_type = dvs_clk_rst_pkg::DVS_CLK_RST_INT;
                clk_mon_item.clk_period_int = pn;
                clk_mon_item.clk_period_real = 0.0;
            end
            po = pn;	
            this.ap.write(clk_mon_item);
        end
    endtask : mon_clk_period

    //------------------------------//
    task clk_watchdog(int unsigned idx, ref realtime po, bit clk_stopped);
        dvs_clk_rst_item clk_mon_item;
        if(clk_stopped) wait(!clk_stopped);
        #(this.cfg.clk_stoppage_limit*1);
        if (po != 0) begin 
            clk_stopped = 1'b1;
            this.active_clks[idx] = 1'b0;
        end
        clk_mon_item = dvs_clk_rst_item::type_id::create("clk_mon_item");
        clk_mon_item.idx = idx;
        clk_mon_item.action = dvs_clk_rst_pkg::DVS_CLK_RST_STOP_CLK;
        this.ap.write(clk_mon_item);
    endtask : clk_watchdog 

    //------------------------------//
    task monitor_reset(int unsigned idx, bit high_low);

        int unsigned rst_assrt_cnt = 0;
        
        forever begin
            fork
                this.mon_reset_period(idx, high_low, rst_assrt_cnt);
                this.reset_watchdog(idx, high_low, rst_assrt_cnt);
            join_any
            disable fork;  
        end
    endtask : monitor_reset

    //------------------------------//
    task mon_reset_period(int unsigned idx, bit high_low, ref int unsigned rst_assrt_cnt);
        realtime t0;
        realtime reset_period;
        dvs_clk_rst_item rst_mon_item;

        if (high_low) wait(this.vif.rst[idx] === 1'b1);
        else wait(this.vif.rst_n[idx] === 1'b0);     
        t0 = $realtime();
        if (high_low) wait(this.vif.rst[idx] === 1'b0);
        else wait(this.vif.rst_n[idx] === 1'b1);     
        rst_assrt_cnt++;
        reset_period = $realtime() - t0;
        rst_mon_item = dvs_clk_rst_item::type_id::create("rst_mon_item");
        rst_mon_item.idx = idx;
        if ((real'(reset_period-int'(reset_period)) != 0)) begin
            rst_mon_item.reset_period_type = dvs_clk_rst_pkg::DVS_CLK_RST_REAL;
            rst_mon_item.reset_period_real = reset_period;
            rst_mon_item.reset_period_int  = 0;
        end else begin
            rst_mon_item.reset_period_type = dvs_clk_rst_pkg::DVS_CLK_RST_INT;
            rst_mon_item.reset_period_int  = reset_period;
            rst_mon_item.reset_period_real = 0.0;
        end

        if (this.check_sync_reset(reset_period, rst_mon_item.rst_sync_clk_idx, rst_mon_item.rst_sync_n_clk)) begin
            if (high_low) rst_mon_item.action = dvs_clk_rst_pkg::DVS_CLK_RST_RESET_SYNC_ACTIVE_HIGH;
            else rst_mon_item.action = dvs_clk_rst_pkg::DVS_CLK_RST_RESET_SYNC_ACTIVE_LOW;
        end else begin
            if (high_low) rst_mon_item.action = dvs_clk_rst_pkg::DVS_CLK_RST_RESET_ASYNC_ACTIVE_HIGH;
            else rst_mon_item.action = dvs_clk_rst_pkg::DVS_CLK_RST_RESET_ASYNC_ACTIVE_LOW;
        end
        this.ap.write(rst_mon_item);
    endtask : mon_reset_period

    //------------------------------//
    function bit check_sync_reset(realtime reset_period, ref int unsigned sync_idx, sync_n_clk);
        real div;
        // Loop through clk_period and check rst deassert period
        foreach(this.clks_period[i]) begin
            div = this.clks_period[i]/reset_period;
            if (this.active_clks[i] && (real'(div-int'(div)) != 0)) begin
                sync_idx = i;
                sync_n_clk = div;
                return 1;
            end 
        end
        return 0;
    endfunction : check_sync_reset

    //------------------------------//
    task reset_watchdog(int unsigned idx, bit high_low, ref int unsigned rst_assrt_cnt);
        dvs_clk_rst_item rst_mon_item;
        if(!rst_assrt_cnt) wait(rst_assrt_cnt);
        if (high_low) wait(this.vif.rst[idx] === 1'b1);
        else wait(this.vif.rst_n[idx] === 1'b0);
        #(this.cfg.rst_stoppage_limit*1);
        rst_assrt_cnt++;
        rst_mon_item = dvs_clk_rst_item::type_id::create("rst_mon_item");
        rst_mon_item.idx = idx;
        if (high_low) rst_mon_item.action = dvs_clk_rst_pkg::DVS_CLK_RST_RESET_ACTIVE_HIGH_ASSERT;
        else rst_mon_item.action = dvs_clk_rst_pkg::DVS_CLK_RST_RESET_ACTIVE_LOW_DEASSERT;
        this.ap.write(rst_mon_item);
        if (high_low) wait(this.vif.rst[idx] === 1'b0);
        else wait(this.vif.rst_n[idx] === 1'b1);
    endtask : reset_watchdog

endclass : dvs_clk_rst_monitor