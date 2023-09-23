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
// dvs_clk_rst configuration object
// **************************************************************************** //
class dvs_clk_rst_cfg#(int unsigned N_CLKS = 1, N_RSTS = 1) extends uvm_object;

  virtual dvs_clk_rst_if#(N_CLKS, N_RSTS) vif;
  // Active/passive knobs are split between driver-sequencer and monitor to have 
  // more flexibility over the creation of driver-sequencer or monitor.
  // Driver-Sequencer active/passive knob
  uvm_active_passive_enum  drv_sqr_active = UVM_ACTIVE;
  // Monitor active/passive
  uvm_active_passive_enum  mon_active = UVM_ACTIVE;
  // Coverage configuration knobs
  bit cov_en = 1'b1;
  bit clk_cov_en[N_CLKS]   = '{default:1'b1};
  bit rst_cov_en[N_RSTS]   = '{default:1'b1};
  bit rst_n_cov_en[N_RSTS] = '{default:1'b1};
  bit sync_cov_en[N_RSTS]  = '{default:1'b0};
  bit async_cov_en[N_RSTS] = '{default:1'b1};
  // Stoppage limit knobs, which means those values are considered in deciding whether 
  // a clock has been stopped or not, and also if the rst has been asserted or desasserted
  // for a long time(it's different than sequence item field reset_period_*)
  realtime clk_stoppage_limit = 50.0;
  realtime rst_stoppage_limit = 50.0;

  `uvm_object_param_utils_begin(dvs_clk_rst_cfg#(N_CLKS, N_RSTS))
  `uvm_object_utils_end

  function new(string name="dvs_clk_rst_cfg");
    super.new(name);
  endfunction : new

endclass : dvs_clk_rst_cfg