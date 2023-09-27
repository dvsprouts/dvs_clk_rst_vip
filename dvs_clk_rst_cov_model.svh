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
// dvs_clk_rst coverage
// ********************************************************************** //
class dvs_clk_rst_cov_model#(int unsigned N_CLKS = 1, int unsigned N_RSTS = 1) extends uvm_subscriber#(dvs_clk_rst_item);

    //------------------------------//
    class dvs_clk_cov_wrapper;

        covergroup dvs_clk_cg(string name) with function sample (dvs_clk_rst_item cov_item);
            option.name = name;
            option.per_instance = 1;
            cp_action: coverpoint cov_item.action {
                bins start_clk    = {dvs_clk_rst_pkg::DVS_CLK_RST_START_CLK};
                bins stop_clk     = {dvs_clk_rst_pkg::DVS_CLK_RST_STOP_CLK};
                bins restart_clk  = {dvs_clk_rst_pkg::DVS_CLK_RST_RESTART_CLK};
                bins reconfig_clk = {dvs_clk_rst_pkg::DVS_CLK_RST_RECONFIG_CLK};
            }
        endgroup : dvs_clk_cg

        function new (string name = "");
            this.dvs_clk_cg = new ({"dvs_clk_cg", name});
        endfunction : new
    endclass : dvs_clk_cov_wrapper

    //------------------------------//
    class dvs_rst_cov_wrapper;

        covergroup dvs_rst_cg(string name, bit sync_en, bit async_en) with function sample (dvs_clk_rst_item cov_item);
            option.name = name;
            option.per_instance = 1;
            cp_action: coverpoint cov_item.action {
                bins sync_active_high   = {dvs_clk_rst_pkg::DVS_CLK_RST_RESET_SYNC_ACTIVE_HIGH}  with ((item | 1) && sync_en);
                bins async_activ_high   = {dvs_clk_rst_pkg::DVS_CLK_RST_RESET_ASYNC_ACTIVE_HIGH} with ((item | 1) && async_en);
                bins reset_active_high  = {dvs_clk_rst_pkg::DVS_CLK_RST_RESET_ACTIVE_HIGH_ASSERT};
            }
            endgroup : dvs_rst_cg

        function new (string name = "", bit sync_en = 1'b0, bit async_en = 1'b1);
            this.dvs_rst_cg = new ({"dvs_rst_cg", name}, sync_en, async_en);
        endfunction : new
    endclass : dvs_rst_cov_wrapper

    //------------------------------//
    class dvs_rst_n_cov_wrapper;

        covergroup dvs_rst_n_cg(string name, bit sync_en, bit async_en) with function sample (dvs_clk_rst_item cov_item);
        option.name = name;
        option.per_instance = 1;
        cp_action: coverpoint cov_item.action {
            bins sync_active_low   = {dvs_clk_rst_pkg::DVS_CLK_RST_RESET_SYNC_ACTIVE_LOW}  with ((item | 1) && sync_en);
            bins async_activ_low   = {dvs_clk_rst_pkg::DVS_CLK_RST_RESET_ASYNC_ACTIVE_LOW} with ((item | 1) && async_en);
            bins reset_active_low  = {dvs_clk_rst_pkg::DVS_CLK_RST_RESET_ACTIVE_LOW_DEASSERT};
        }
        endgroup : dvs_rst_n_cg

        function new (string name = "", bit sync_en = 1'b0, bit async_en = 1'b1);
            this.dvs_rst_n_cg = new ({"dvs_rst_n_cg", name}, sync_en, async_en);
        endfunction : new
    endclass : dvs_rst_n_cov_wrapper

    //------------------------------//
    dvs_clk_cov_wrapper   dvs_clk_cov[N_CLKS];
    dvs_rst_cov_wrapper   dvs_rst_cov[N_RSTS];
    dvs_rst_n_cov_wrapper dvs_rst_n_cov[N_RSTS];
    dvs_clk_rst_cfg#(N_CLKS, N_RSTS) cfg;

    `uvm_component_param_utils(dvs_clk_rst_cov_model#(N_CLKS, N_RSTS))

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

        foreach (this.cfg.clk_cov_en[i]) begin
            if(this.cfg.clk_cov_en[i]) this.dvs_clk_cov[i] = new($sformatf("%0d", i));
        end

        foreach (this.cfg.rst_cov_en[i]) begin
            if(this.cfg.rst_cov_en[i]) this.dvs_rst_cov[i] = new($sformatf("%0d", i), this.cfg.sync_cov_en[i], this.cfg.async_cov_en[i]);
        end

        foreach (this.cfg.rst_n_cov_en[i]) begin
            if(this.cfg.rst_n_cov_en[i]) this.dvs_rst_n_cov[i] = new($sformatf("%0d", i), this.cfg.sync_cov_en[i], this.cfg.async_cov_en[i]);
        end
    endfunction

    //------------------------------//
    virtual function void sample_coverage (dvs_clk_rst_item cov_item);
        if (this.dvs_clk_cov[cov_item.idx] != null)   this.dvs_clk_cov[cov_item.idx].dvs_clk_cg.sample(cov_item);
        if (this.dvs_rst_cov[cov_item.idx] != null)   this.dvs_rst_cov[cov_item.idx].dvs_rst_cg.sample(cov_item);
        if (this.dvs_rst_n_cov[cov_item.idx] != null) this.dvs_rst_n_cov[cov_item.idx].dvs_rst_n_cg.sample(cov_item);
    endfunction : sample_coverage

    //------------------------------//
    virtual function void write(dvs_clk_rst_item t);
        this.sample_coverage(t);
    endfunction

endclass : dvs_clk_rst_cov_model