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
// dvs_clk_rst driver
// **************************************************************************** //
class dvs_clk_rst_driver#(int unsigned N_CLKS = 1, N_RSTS = 1) extends uvm_driver#(dvs_clk_rst_item);

	// Configuration object
	dvs_clk_rst_cfg#(N_CLKS, N_RSTS) cfg;
	virtual dvs_clk_rst_if#(N_CLKS, N_RSTS) vif;
	uvm_analysis_port#(dvs_clk_rst_item) ap;

	`uvm_component_param_utils_begin(dvs_clk_rst_driver#(N_CLKS, N_RSTS))
	`uvm_component_utils_end

	//------------------------------//
	function new(string name, uvm_component parent = null);
		super.new(name, parent);
		this.ap = new("ap", this);
	endfunction

	//------------------------------//
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_resource_db#(dvs_clk_rst_cfg#(N_CLKS, N_RSTS))::read_by_type(get_full_name(), cfg, this))
			`uvm_fatal(get_type_name(), "cfg object hasn't been set!!!");
		this.vif = this.cfg.vif;
	endfunction

	//------------------------------//
	virtual task run_phase(uvm_phase phase);
		forever begin
			seq_item_port.get_next_item(this.req);
			this.drv_req();
			seq_item_port.item_done();
			this.ap.write(this.req);
		end
	endtask

	//------------------------------//
	virtual task drv_req();
		// Action
		case (this.req.action)
			dvs_clk_rst_pkg::DVS_CLK_RST_START_CLK : begin
				this.vif.init_clk(this.req.clk_init_val, this.req.idx);
				this.set_clk_period_type();
				this.vif.start_clk(this.req.idx);
			end
			dvs_clk_rst_pkg::DVS_CLK_RST_STOP_CLK : begin
				this.vif.set_clk_hold_val(this.req.clk_hold_val, this.req.idx);
				this.vif.stop_clk(this.req.idx);
			end
			dvs_clk_rst_pkg::DVS_CLK_RST_RESTART_CLK : begin
				this.vif.start_clk(this.req.idx);
			end
			dvs_clk_rst_pkg::DVS_CLK_RST_RECONFIG_CLK : begin
				this.set_clk_period_type();
			end
			dvs_clk_rst_pkg::DVS_CLK_RST_RESET_SYNC_ACTIVE_HIGH : begin
				this.vif.init_rst(this.req.rst_init_val, this.req.idx);
				this.set_reset_period_type();
				this.vif.rst_active_high_sync(this.req.idx, this.req.rst_sync_n_clk, this.req.rst_sync_clk_idx);
			end
			dvs_clk_rst_pkg::DVS_CLK_RST_RESET_SYNC_ACTIVE_LOW : begin
				this.vif.init_rst(this.req.rst_init_val, this.req.idx);
				this.set_reset_period_type();
				this.vif.rst_active_low_sync(this.req.idx, this.req.rst_sync_n_clk, this.req.rst_sync_clk_idx);
			end
			dvs_clk_rst_pkg::DVS_CLK_RST_RESET_ASYNC_ACTIVE_HIGH : begin
				this.vif.init_rst(this.req.rst_init_val, this.req.idx);
				this.set_reset_period_type();
				this.vif.rst_active_high_async(this.req.idx);
			end
			dvs_clk_rst_pkg::DVS_CLK_RST_RESET_ASYNC_ACTIVE_LOW : begin
				this.vif.init_rst(this.req.rst_init_val, this.req.idx);
				this.set_reset_period_type();
				this.vif.rst_active_low_async(this.req.idx);
			end
			dvs_clk_rst_pkg::DVS_CLK_RST_RESET_ACTIVE_HIGH_ASSERT : begin
				this.vif.assert_rst_active_high(this.req.idx);
			end
			dvs_clk_rst_pkg::DVS_CLK_RST_RESET_ACTIVE_LOW_DEASSERT : begin 
				this.vif.deassert_rst_active_low(this.req.idx);
			end
			default : begin `uvm_fatal(get_type_name(), " Uknown action!!!"); end
		endcase
	endtask : drv_req

	//------------------------------//
	virtual function void set_clk_period_type();
		case (this.req.clk_period_type)
			dvs_clk_rst_pkg::DVS_CLK_RST_INT:  this.vif.set_clk_period(this.req.clk_period_int, this.req.idx);
			dvs_clk_rst_pkg::DVS_CLK_RST_REAL: this.vif.set_clk_period(this.req.clk_period_real, this.req.idx);
			default : begin `uvm_fatal(get_type_name(), " Unkown clk_period_type!!!"); end
		endcase
	endfunction : set_clk_period_type

	//------------------------------//
	virtual function void set_reset_period_type();
		case (this.req.reset_period_type)
			dvs_clk_rst_pkg::DVS_CLK_RST_INT  : this.vif.set_reset_period(this.req.reset_period_int, this.req.idx);
			dvs_clk_rst_pkg::DVS_CLK_RST_REAL : this.vif.set_reset_period(this.req.reset_period_real, this.req.idx);
			default : begin `uvm_fatal(get_type_name(), " Uknown rst_period_type!!!"); end
		endcase
	endfunction : set_reset_period_type

endclass : dvs_clk_rst_driver