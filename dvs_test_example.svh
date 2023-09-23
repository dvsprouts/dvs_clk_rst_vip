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
// dvs_clk_rst test_example
// ********************************************************************** //
class dvs_test_example extends uvm_test;

    dvs_clk_rst_env dvs_env;

    `uvm_component_utils(dvs_test_example)

    //------------------------------//
    function new(string name = "", uvm_component parent=null);
        super.new(name, parent);
    endfunction : new

    //------------------------------//
    virtual function void build_phase(uvm_phase phase);   	
        super.build_phase(phase);
        this.dvs_env = dvs_clk_rst_env::type_id::create("dvs_env", this);
    endfunction : build_phase

    //------------------------------//
    virtual task main_phase(uvm_phase phase);
        dvs_clk_rst_n_async_seq single_clk_rst_seq;
        dvs_clk_rst_n_async_seq multi_clk_rst_seq;
        dvs_stop_clk_seq stop_clk_seq;
        dvs_reconfig_real_clk_seq reconfig_real_clk_seq;
        dvs_restart_clk_seq restart_clk_seq;
        dvs_deassert_rst_n_seq deassert_rst_n_seq;

        super.main_phase(phase);
        phase.raise_objection(this);
        // Starting all clocks
        fork
            begin
                single_clk_rst_seq = dvs_clk_rst_n_async_seq::type_id::create("single_clk_rst_seq");
                single_clk_rst_seq.start(this.dvs_env.single_clk_rst_agent.sqr);
            end
            begin
                multi_clk_rst_seq = dvs_clk_rst_n_async_seq::type_id::create("multi_clk_rst_seq");
                multi_clk_rst_seq.nr_clks = 4;
                multi_clk_rst_seq.nr_rsts = 3;
                multi_clk_rst_seq.start(this.dvs_env.multi_clk_rst_agent.sqr);
            end
        join

        #100;

        // Stops clk[0] on multi_clk_rst_agent
        stop_clk_seq = dvs_stop_clk_seq::type_id::create("stop_clk_seq");
        stop_clk_seq.idx = 0;
        stop_clk_seq.start(this.dvs_env.multi_clk_rst_agent.sqr);

        // Reconfig clk[2] on multi_clk_rst_agent
        reconfig_real_clk_seq = dvs_reconfig_real_clk_seq::type_id::create("reconfig_real_clk_seq");
        reconfig_real_clk_seq.idx = 2;
        reconfig_real_clk_seq.start(this.dvs_env.multi_clk_rst_agent.sqr);

        #100;

        // Restart clk[0] on multi_clk_rst_agent
        restart_clk_seq = dvs_restart_clk_seq::type_id::create("restart_clk_seq");
        restart_clk_seq.idx = 0;
        restart_clk_seq.start(this.dvs_env.multi_clk_rst_agent.sqr);

        #100;

        // De-assert rst_n[1] on multi_clk_rst_agent
        deassert_rst_n_seq = dvs_deassert_rst_n_seq::type_id::create("deassert_rst_n_seq");
        deassert_rst_n_seq.idx = 1;
        deassert_rst_n_seq.start(this.dvs_env.multi_clk_rst_agent.sqr);

        #100;

        phase.drop_objection(this);
    endtask : main_phase 

endclass : dvs_test_example