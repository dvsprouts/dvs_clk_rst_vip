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
// dvs_clk_rst interface
// ********************************************************************** //
interface dvs_clk_rst_if #(int unsigned N_CLKS = 1, N_RSTS = 1) (output logic [N_CLKS-1:0] clk,
																 output logic [N_RSTS-1:0] rst_n,
																 output logic [N_RSTS-1:0] rst);


	realtime clk_period    [N_CLKS] = '{default:1.0};
	process  clk_prc       [N_CLKS];
	logic    clk_hold_vals [N_CLKS] = '{default:0};
	realtime reset_period  [N_RSTS] = '{default:1.0};

	//----------------------------------------------------------//
	// Functions/Tasks
	//----------------------------------------------------------//
	// CLOCK
	function automatic void init_clk(logic init_val = '0, int unsigned idx = 0);
		clk[idx] <= init_val;
	endfunction : init_clk

	//----------------------------------------------------------//
	function automatic void set_clk_period(realtime period, int unsigned idx = 0);
		clk_period[idx] = period;
	endfunction : set_clk_period

	//----------------------------------------------------------//
	function automatic void set_clk_hold_val(logic hold_val, int unsigned idx = 0);
		clk_hold_vals[idx] = hold_val;
	endfunction : set_clk_hold_val

	//----------------------------------------------------------//
	function automatic void start_clk(int unsigned idx = 0);
		if(clk_prc[idx] != null) begin
			if (clk_prc[idx].status !== process::KILLED) $warning("Trying to start a clock on idx %0d that's already active", idx);
		end
		fork 
			automatic int unsigned a_idx = idx;
			forever begin
				if(clk_prc[a_idx] == null) clk_prc[a_idx] = process::self();
				#((clk_period[a_idx]/2.0)*1);
				case (clk[a_idx])
					'0: clk[a_idx] = 1;
					'1: clk[a_idx] = 0;
					'X: clk[a_idx] = 0;
				endcase
			end
		join_none
	endfunction : start_clk

	//----------------------------------------------------------//
	function automatic void stop_clk(int unsigned idx = 0);
		if(clk_prc[idx] !== null)  begin
			clk[idx] <= clk_hold_vals[idx];
			clk_prc[idx].kill();
		end
		else $warning("Trying to stop a clock that hasn't been started");
	endfunction : stop_clk

	// RESET
	//----------------------------------------------------------//
	function automatic void init_rst(logic rst_n_init_val = '0, int unsigned idx = 0, logic rst_init_val = rst_n_init_val);
		rst_n[idx] <= rst_n_init_val;
		rst[idx]   <= rst_init_val;
	endfunction : init_rst

	//----------------------------------------------------------//
	function automatic void set_reset_period(realtime period, int unsigned idx = 0);
		reset_period[idx] = period;
	endfunction : set_reset_period

	//----------------------------------------------------------//
	// Sync is assumed to happen on posedge of clk
	task automatic rst_active_high_sync(int unsigned idx = 0, n_clks = 1, sync_idx = idx);
		fork 
			begin
				rst[idx]   <= 1'b1;
				repeat(n_clks) @(posedge clk[sync_idx]);
				rst[idx]   <= 1'b0;
			end
		join_none
	endtask : rst_active_high_sync

	//----------------------------------------------------------//
	// Sync is assumed to happen on posedge of clk
	task automatic rst_active_low_sync(int unsigned idx = 0, n_clks = 1, sync_idx = idx);
		fork 
			begin
				rst_n[idx]   <= 1'b0;
				repeat(n_clks) @(posedge clk[sync_idx]);
				rst_n[idx]   <= 1'b1;
			end
		join_none
	endtask : rst_active_low_sync

	//----------------------------------------------------------//
	task automatic rst_active_high_async(int unsigned idx = 0);
		fork 
			begin
				rst[idx]   <= 1'b1;
				#(reset_period[idx]*1);
				rst[idx]   <= 1'b0;
			end
		join_none
	endtask : rst_active_high_async

	//----------------------------------------------------------//
	task automatic rst_active_low_async(int unsigned idx = 0);
		fork 
			begin
				rst_n[idx]   <= 1'b0;
				#(reset_period[idx]*1);
				rst_n[idx]   <= 1'b1;
			end
		join_none 
	endtask : rst_active_low_async

	//----------------------------------------------------------//
	function automatic void assert_rst_active_high(int unsigned idx = 0);
		rst[idx]  <= 1'b1;
	endfunction : assert_rst_active_high

	//----------------------------------------------------------//
	function automatic void deassert_rst_active_low(int unsigned idx = 0);
		rst_n[idx]  <= 1'b0;
	endfunction : deassert_rst_active_low

endinterface : dvs_clk_rst_if
