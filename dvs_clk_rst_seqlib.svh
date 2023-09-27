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
// dvs_clk_rst sequences
// ********************************************************************** //
// *********************************************************************** //
// This sequence starts all the clocks and asynchornous active low resets according 
// to nr_clks and nr_rsts values.
// ********************************************************************** //
class dvs_clk_rst_n_async_seq extends uvm_sequence#(dvs_clk_rst_item);

    int unsigned nr_clks = 1;
    int unsigned nr_rsts = 1;

    `uvm_object_utils(dvs_clk_rst_n_async_seq)

    //------------------------------//
    function new(string name = "");
        super.new(name);
    endfunction

    //------------------------------//
    task body();
        fork
            for (int i = 0; i < this.nr_clks; i++ ) begin 
                dvs_clk_rst_item clk_req = dvs_clk_rst_item::type_id::create($sformatf("clk_%0d_req", i));
                this.start_item(clk_req);
                if(!clk_req.randomize() with {action == dvs_clk_rst_pkg::DVS_CLK_RST_START_CLK; idx == i;}) begin
                    `uvm_fatal(this.get_full_name(),"Couldn't randmomizea a clk_req");
                end
                this.finish_item(clk_req);
            end
            for (int i = 0; i < this.nr_rsts; i++ ) begin 
                dvs_clk_rst_item rst_n_req = dvs_clk_rst_item::type_id::create($sformatf("rst_n_%0d_req", i));
                this.start_item(rst_n_req);
                if(!rst_n_req.randomize() with {action == dvs_clk_rst_pkg::DVS_CLK_RST_RESET_ASYNC_ACTIVE_LOW; idx == i;}) begin
                    `uvm_fatal(this.get_full_name(),"Couldn't randmomizea a rst_n_req");
                end
                this.finish_item(rst_n_req);
            end
        join
    endtask : body
endclass : dvs_clk_rst_n_async_seq

// *********************************************************************** //
// This sequence stops a clock on a specific index
// ********************************************************************** //
class dvs_stop_clk_seq extends uvm_sequence#(dvs_clk_rst_item);

    int unsigned idx = 1;

    `uvm_object_utils(dvs_stop_clk_seq)

    //------------------------------//
    function new(string name = "");
        super.new(name);
    endfunction

    //------------------------------//
    task body();
        dvs_clk_rst_item clk_req = dvs_clk_rst_item::type_id::create($sformatf("clk_%0d_req", this.idx));
        this.start_item(clk_req);
        if(!clk_req.randomize() with {action == dvs_clk_rst_pkg::DVS_CLK_RST_STOP_CLK; idx == local::idx;}) begin
            `uvm_fatal(this.get_full_name(),"Couldn't randmomizea a clk_req");
        end
        this.finish_item(clk_req);
    endtask : body
endclass : dvs_stop_clk_seq

// *********************************************************************** //
// This sequence restarts a clock on a specific index
// ********************************************************************** //
class dvs_restart_clk_seq extends uvm_sequence#(dvs_clk_rst_item);

    int unsigned idx = 1;

    `uvm_object_utils(dvs_restart_clk_seq)

    //------------------------------//
    function new(string name = "");
        super.new(name);
    endfunction

    //------------------------------//
    task body();
        dvs_clk_rst_item clk_req = dvs_clk_rst_item::type_id::create($sformatf("clk_%0d_req", this.idx));
        this.start_item(clk_req);
        if(!clk_req.randomize() with {action == dvs_clk_rst_pkg::DVS_CLK_RST_RESTART_CLK; idx == local::idx;}) begin
            `uvm_fatal(this.get_full_name(),"Couldn't randmomizea a clk_req");
        end
        this.finish_item(clk_req);
    endtask : body
endclass : dvs_restart_clk_seq

// *********************************************************************** //
// This sequence reconfigures a clock on a specific index with a real value
// ********************************************************************** //
class dvs_reconfig_real_clk_seq extends uvm_sequence#(dvs_clk_rst_item);

    int unsigned idx = 1;
    realtime clk_period_real = 5.50; 

    `uvm_object_utils(dvs_reconfig_real_clk_seq)

    //------------------------------//
    function new(string name = "");
        super.new(name);
    endfunction

    //------------------------------//
    task body();
        dvs_clk_rst_item clk_req = dvs_clk_rst_item::type_id::create($sformatf("clk_%0d_req", this.idx));
        this.start_item(clk_req);
        if(!clk_req.randomize() with {action == dvs_clk_rst_pkg::DVS_CLK_RST_RECONFIG_CLK; 
        idx == local::idx;
        clk_period_type == dvs_clk_rst_pkg::DVS_CLK_RST_REAL;}) begin
            `uvm_fatal(this.get_full_name(),"Couldn't randmomizea a clk_req");
        end
        clk_req.clk_period_real = this.clk_period_real;
        this.finish_item(clk_req);
    endtask : body
endclass : dvs_reconfig_real_clk_seq

// *********************************************************************** //
// This sequence de-assert an active low reset on a specific index
// ********************************************************************** //
class dvs_deassert_rst_n_seq extends uvm_sequence#(dvs_clk_rst_item);

    int unsigned idx = 1;

    `uvm_object_utils(dvs_deassert_rst_n_seq)

    //------------------------------//
    function new(string name = "");
        super.new(name);
    endfunction

    //------------------------------//
    task body();
        dvs_clk_rst_item rst_n_req = dvs_clk_rst_item::type_id::create($sformatf("rst_n_%0d_req", this.idx));
        this.start_item(rst_n_req);
        if(!rst_n_req.randomize() with {action == dvs_clk_rst_pkg::DVS_CLK_RST_RESET_ACTIVE_LOW_DEASSERT; 
                                        idx == local::idx;}) begin
            `uvm_fatal(this.get_full_name(),"Couldn't randmomizea a rst_n_req");
        end
        this.finish_item(rst_n_req);
    endtask : body
endclass : dvs_deassert_rst_n_seq