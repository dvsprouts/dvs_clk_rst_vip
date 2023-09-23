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
// dvs_clk_rst sequencer
// ********************************************************************** //
class dvs_clk_rst_sequencer#(int unsigned N_CLKS = 1, N_RSTS = 1) extends uvm_sequencer #(dvs_clk_rst_item);

    dvs_clk_rst_cfg#(N_CLKS, N_RSTS) cfg;

    `uvm_component_param_utils(dvs_clk_rst_sequencer#(N_CLKS, N_RSTS))

    function new(input string name, uvm_component parent=null);
        super.new(name, parent);
    endfunction : new

    //------------------------------//
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_resource_db#(dvs_clk_rst_cfg#(N_CLKS, N_RSTS))::read_by_type(get_full_name(), cfg, this)) begin
        `uvm_fatal(get_type_name(), "cfg object hasn't been set!!!");
        end
    endfunction

endclass : dvs_clk_rst_sequencer