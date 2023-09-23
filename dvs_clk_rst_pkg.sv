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
// dvs_clk_rst package
// **************************************************************************** //
package dvs_clk_rst_pkg;

    `include "uvm_macros.svh"
    import uvm_pkg::*;

    typedef enum {
        DVS_CLK_RST_START_CLK,
        DVS_CLK_RST_STOP_CLK,
        DVS_CLK_RST_RESTART_CLK,
        DVS_CLK_RST_RECONFIG_CLK,
        DVS_CLK_RST_RESET_SYNC_ACTIVE_HIGH,
        DVS_CLK_RST_RESET_SYNC_ACTIVE_LOW,
        DVS_CLK_RST_RESET_ASYNC_ACTIVE_HIGH,
        DVS_CLK_RST_RESET_ASYNC_ACTIVE_LOW, 
        DVS_CLK_RST_RESET_ACTIVE_HIGH_ASSERT,
        DVS_CLK_RST_RESET_ACTIVE_LOW_DEASSERT } dvs_clk_rst_item_action_t;

    typedef enum {
        DVS_CLK_RST_VALUE_0,
        DVS_CLK_RST_VALUE_1,
        DVS_CLK_RST_VALUE_X} dvs_clk_rst_value_t;

    typedef enum {
        DVS_CLK_RST_INT,
        DVS_CLK_RST_REAL} dvs_clk_rst_period_type_t;

    `include "dvs_clk_rst_item.svh"
    `include "dvs_clk_rst_cfg.svh"
    `include "dvs_clk_rst_driver.svh"
    `include "dvs_clk_rst_monitor.svh"
    `include "dvs_clk_rst_sequencer.svh"
    `include "dvs_clk_rst_cov_model.svh"
    `include "dvs_clk_rst_agent.svh"
    // EXAMPLE
    `include "dvs_clk_rst_env.svh"
    `include "dvs_clk_rst_seqlib.svh"
    `include "dvs_test_example.svh"

endpackage : dvs_clk_rst_pkg