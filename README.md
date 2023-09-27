# dvs_clk_rst_vip

Features:
--------

- The clock and reset interface is parameterized by a number of clocks (N_CLKS) and a number of resets (N_RSTS).
  ![image](https://github.com/dvsprouts/dvs_clk_rst_vip/assets/143346539/767aff67-23c0-40b7-b02c-9073ca8bc28c)


- The interface is designer-friendly which means for basic usage it can be used to drive clocks and resets without the need to create an uvm environment, as it has tasks to do that.

- The interface has active high resets (rst) and active low resets (rst_n).

- The following actions are supported:
	- Starting a clock with an index that varies between 0 and N_CLKS-1
	- Stopping a clock with an index that varies between 0 and N_CLKS-1
	- Restart a clock with an index that has been stopped
	- Reconfigure on the fly a clock with an index  between 0 and N_CLKS-1, i.e. changing the clock period
	- Triggering a synchronous active high reset with an index that varies between 0 and N_RSTS-1
	- Triggering a synchronous active low reset with an index that varies between 0 and N_RSTS-1
	- Triggering an asynchronous active high reset with an index that varies between 0 and N_RSTS-1
	- Triggering an asynchronous active low reset with an index that varies between 0 and N_RSTS-1
	- Asserting an active high reset with an index that varies between 0 and N_RSTS-1
	- Deasserting an active low reset with an index that varies between 0 and N_RSTS-1

- For synchronous resets, the clock index to which the reset will be synced could have any value between 0 and N_RSTS-1. e.g. rst[1] could be synchronized to clk[3].

- In case of synchronous resets, the interface will be under reset with a specific number of clock cycles, otherwise, the default value is 1 clock cycle.

- Clock period and reset period could be integer values or real values.

- The initial values of clocks and reset could be specified, and it could be 0, 1, or X.

- When a clock is requested to be stopped the value that the clock will have could be specified (hold value).

- The VIP will not have a timescale, it will inherit it from the environment which makes it more flexible. The only caveat is to make sure the timeprecision is at least half of the timeunit.

- If there is no need to create the monitor, that could be configured. i.e. only the driver and sequencer will be created.

- The coverage model could be enabled/disabled and there are other knobs for clock, active_high, active_low, synchronous, and asynchronous coverage.

- The coverage is only over the action, but it could be extended as needed.
  
- For more information and help with how to integrate it, please write to support@dvsprouts.com
