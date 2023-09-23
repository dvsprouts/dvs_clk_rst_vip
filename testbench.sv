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

`include "dvs_clk_rst_if.sv"
`include "dvs_clk_rst_pkg.sv"

module testbench;
    import uvm_pkg::*;
    import dvs_clk_rst_pkg::*;

    dvs_clk_rst_if #() single_vif();
    dvs_clk_rst_if #(4,3) multi_vif();

    initial begin
        // set the virtual interfaces
        uvm_resource_db#(virtual dvs_clk_rst_if #())::set("single_clk_rst", "vif", single_vif);
        uvm_resource_db#(virtual dvs_clk_rst_if #(4,3))::set("multi_clk_rst", "vif", multi_vif);
        run_test("dvs_test_example");
    end

endmodule : testbench
