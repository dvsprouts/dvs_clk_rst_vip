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
// dvs_clk_rst agent
// **************************************************************************** //
class dvs_clk_rst_agent #(int unsigned N_CLKS = 1, int unsigned N_RSTS = 1) extends uvm_agent;

    dvs_clk_rst_cfg#(N_CLKS, N_RSTS)       cfg;
    dvs_clk_rst_driver#(N_CLKS, N_RSTS)    drv;
    dvs_clk_rst_sequencer#(N_CLKS, N_RSTS) sqr;
    dvs_clk_rst_monitor#(N_CLKS, N_RSTS)   mon;
    dvs_clk_rst_cov_model#(N_CLKS, N_RSTS) cov_model;

    `uvm_component_param_utils(dvs_clk_rst_agent#(N_CLKS, N_RSTS))

    //------------------------------//
    function new(string name, uvm_component parent = null);
        super.new(name, parent);
    endfunction

    //------------------------------//
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_resource_db#(dvs_clk_rst_cfg#(N_CLKS, N_RSTS))::read_by_type(get_full_name(), cfg, this)) begin
            `uvm_fatal(get_type_name(), "cfg object hasn't been set!!!");
        end
        // Setting configuration object downwards
        uvm_resource_db#(dvs_clk_rst_cfg#(N_CLKS, N_RSTS))::set({get_full_name(), ".*"}, "cfg", cfg, this);
        if (this.cfg.drv_sqr_active == UVM_ACTIVE) begin
            this.drv = dvs_clk_rst_driver#(N_CLKS, N_RSTS)::type_id::create("drv", this);
            this.sqr = dvs_clk_rst_sequencer#(N_CLKS, N_RSTS)::type_id::create("sqr", this);
        end

        if (this.cfg.mon_active == UVM_ACTIVE) begin
            this.mon = dvs_clk_rst_monitor#(N_CLKS, N_RSTS)::type_id::create("mon", this);
        end

        if (this.cfg.cov_en) begin
            this.cov_model = dvs_clk_rst_cov_model#(N_CLKS, N_RSTS)::type_id::create("cov_model", this);
        end

    endfunction : build_phase

    //------------------------------//
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        // Connect driver/sequencer
        if(this.drv !=null && this.sqr != null) begin
            this.drv.seq_item_port.connect(this.sqr.seq_item_export);
        end
        // connect monitor/coverage model
        if(this.mon != null && this.cov_model != null) begin
            this.mon.ap.connect(this.cov_model.analysis_export);
        end
    endfunction : connect_phase

endclass: dvs_clk_rst_agent