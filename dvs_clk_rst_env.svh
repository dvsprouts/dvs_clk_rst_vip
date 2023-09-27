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

// *********************************************************************** //
// Example
// - Here is an environment where a default agent with N_CLKS=1 an N_RSTS=1 is created,
//   and another one with N_CLKS=4 and N_RSTS = 3
// - For simplicity, the configuration objects are created in the environment, instead of in 
//   the test. 
// ********************************************************************** //
class dvs_clk_rst_env extends uvm_env;

    dvs_clk_rst_agent#() single_clk_rst_agent;
    dvs_clk_rst_cfg#()   single_clk_rst_cfg;

    dvs_clk_rst_agent#(4,3) multi_clk_rst_agent;
    dvs_clk_rst_cfg#(4,3)   multi_clk_rst_cfg;

    `uvm_component_utils(dvs_clk_rst_env)

    //------------------------------//
    function new(string name = "", uvm_component parent=null);
        super.new(name, parent);
    endfunction : new

    //------------------------------//
    virtual function void build_phase(uvm_phase phase);

        super.build_phase(phase);
        uvm_factory::get().print();
        this.single_clk_rst_cfg = dvs_clk_rst_cfg#()::type_id::create("single_clk_rst_cfg", this);
        this.single_clk_rst_agent = dvs_clk_rst_agent#()::type_id::create("single_clk_rst_agent", this);
        // Getting the virtual interface
        if(!uvm_resource_db#(virtual dvs_clk_rst_if#())::read_by_type("single_clk_rst", single_clk_rst_cfg.vif, this)) begin
            `uvm_fatal(get_type_name(), "Single clock/reset virtual interface hasn't been set!!!");
        end 
        uvm_resource_db#(dvs_clk_rst_cfg#())::set(this.single_clk_rst_agent.get_full_name(), "cfg", single_clk_rst_cfg, this);

        this.multi_clk_rst_cfg   = dvs_clk_rst_cfg#(4,3)::type_id::create("multi_clk_rst_cfg", this);
        this.multi_clk_rst_agent = dvs_clk_rst_agent#(4,3)::type_id::create("multi_clk_rst_agent", this);
        // Getting the virtual interface
        if(!uvm_resource_db#(virtual dvs_clk_rst_if#(4,3))::read_by_type("multi_clk_rst", multi_clk_rst_cfg.vif, this)) begin
            `uvm_fatal(get_type_name(), "Multi clocks/resets virtual interface hasn't been set!!!");
        end 
        uvm_resource_db#(dvs_clk_rst_cfg#(4,3))::set(this.multi_clk_rst_agent.get_full_name(), "cfg", multi_clk_rst_cfg, this);
    endfunction : build_phase

endclass : dvs_clk_rst_env