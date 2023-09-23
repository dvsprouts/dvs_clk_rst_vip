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
// dvs_clk_rst sequence item
// **************************************************************************** //
class dvs_clk_rst_item extends uvm_sequence_item;

	// clk/rst index
	rand int unsigned idx;
	// Action that will be taken.
	rand dvs_clk_rst_pkg::dvs_clk_rst_item_action_t  action;
	// Clock initial value
	rand dvs_clk_rst_pkg::dvs_clk_rst_value_t        clk_init_val;
	// rst_n initial value
	rand dvs_clk_rst_pkg::dvs_clk_rst_value_t        rst_n_init_val;
	// rst initial value
	rand dvs_clk_rst_pkg::dvs_clk_rst_value_t        rst_init_val;
	// Clock hold value, when clock is stopped, this value will be assigned to clock
	rand dvs_clk_rst_pkg::dvs_clk_rst_value_t        clk_hold_val;
	// Clock period type, either integer value or real value
	rand dvs_clk_rst_pkg::dvs_clk_rst_period_type_t  clk_period_type;
	// Clock integer period value
	rand int unsigned clk_period_int;
	// Clock real period value, it can't be a random value
	realtime clk_period_real = 1.0;

	// reset period type, either integer value or real value
	rand dvs_clk_rst_pkg::dvs_clk_rst_period_type_t  reset_period_type;
	// Reset integer period value
	rand int unsigned reset_period_int;
	// Number of clock cycles that waited for in case of synchronous reset
	rand int unsigned rst_sync_n_clk;
	// Clock index that to which the reset will synchronized
	rand int unsigned rst_sync_clk_idx;
	// Reset real period value
	realtime reset_period_real = 1.0;

	`uvm_object_utils_begin(dvs_clk_rst_item)
		`uvm_field_enum(dvs_clk_rst_pkg::dvs_clk_rst_item_action_t, action , UVM_DEFAULT)
		`uvm_field_enum(dvs_clk_rst_pkg::dvs_clk_rst_value_t, clk_init_val , UVM_DEFAULT)
		`uvm_field_enum(dvs_clk_rst_pkg::dvs_clk_rst_value_t, rst_n_init_val , UVM_DEFAULT)
		`uvm_field_enum(dvs_clk_rst_pkg::dvs_clk_rst_value_t, rst_init_val , UVM_DEFAULT)
		`uvm_field_enum(dvs_clk_rst_pkg::dvs_clk_rst_value_t, clk_hold_val , UVM_DEFAULT)
		`uvm_field_enum(dvs_clk_rst_pkg::dvs_clk_rst_period_type_t, clk_period_type , UVM_DEFAULT)
		`uvm_field_enum(dvs_clk_rst_pkg::dvs_clk_rst_period_type_t, reset_period_type , UVM_DEFAULT)
		`uvm_field_int(idx, UVM_DEFAULT)
		`uvm_field_int(clk_period_int, UVM_DEFAULT)
		`uvm_field_int(reset_period_int, UVM_DEFAULT)
		`uvm_field_int(rst_sync_n_clk, UVM_DEFAULT)
		`uvm_field_int(rst_sync_clk_idx, UVM_DEFAULT)
		`uvm_field_real(clk_period_real, UVM_DEFAULT)
		`uvm_field_real(reset_period_real, UVM_DEFAULT)
	`uvm_object_utils_end

	//----------------------------------------------------------//
	function new(string name = "dvs_clk_rst_item");
		super.new(name);
	endfunction : new

	//----------------------------------------------------------//
	// Default Values
	constraint c_default_clk_period_type {
		soft this.clk_period_type == dvs_clk_rst_pkg::DVS_CLK_RST_INT;
		soft this.clk_period_int == 1;
	}

	constraint c_default_rst_deassert_period_type {
		soft this.reset_period_type == dvs_clk_rst_pkg::DVS_CLK_RST_INT;
		soft this.reset_period_int == 1;
	}

	constraint c_default_idx {soft this.idx == 0;}

	constraint c_default_rst_sync_clk_idx {soft this.rst_sync_clk_idx == this.idx;}

	constraint c_default_init_vals {
		soft this.clk_init_val == 1'b0;
		soft this.rst_init_val == 1'b0;
	}

	constraint c_default_clk_hold_val {soft this.clk_hold_val == 1'b0;}

endclass : dvs_clk_rst_item