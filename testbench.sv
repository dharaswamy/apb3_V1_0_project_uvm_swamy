
// Eda link : https://www.edaplayground.com/x/EGVQ 

// ( swamy ) please copy the code but don't change/modify the code here.

//==========================================================================================================================

// Project Name: APB (Adavanced Peripheral Bus) (APB3 VERSION 1.0)

// language and methodlogy:sv & uvm.

//==========================================================================================================================

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "apb_master_interface.sv"
`include "apb_assertion.sv"
`include "apb_master_seq_item.sv"
`include "apb_master_sequencer.sv"
`include "apb_master_base_sequence.sv"
`include "apb_master_driver.sv"
`include "apb_master_monitor.sv"
`include "apb_master_config_agent.sv"
`include "apb_master_agent.sv"
`include "apb_scoreboard.sv"
`include "apb_functional_coverage.sv"
`include "apb_master_environment.sv"
`include "apb_base_test.sv"
`include "apb_test_cases.sv"
`include "dummy_test.sv"

//`include "master_package.sv"

module tb_top_apb_slave();
 
bit pclk=0;
bit preset_n=0;
 
//clock generation with time period of 10ns.
initial begin
forever #5 pclk  = ~pclk; 
end
  
//reset generation
initial begin
#22 preset_n=1'b1;
end
  
//slave interface handle declaration.
apb_master_interface m_vintf(.pclk(pclk),.preset_n(preset_n));

//dut instantiation of apb slave.
  apb_mem#(8)  apb_mem_inst1(          ._PCLK(m_vintf.pclk),
                                       ._PRESETn(m_vintf.preset_n), 
                                       ._PSEL1(m_vintf.pselx), 
                                       ._PWRITE(m_vintf.pwrite), 
                                       ._PENABLE(m_vintf.penable),
                                       ._PADDR(m_vintf.paddr),
                                       ._PWDATA(m_vintf.pwdata),
                                       ._PRDATA(m_vintf.prdata), 
                                       ._PREADY(m_vintf.pready), 
                                       ._PSLVERR(m_vintf.pslverr)
                                      );
  
  
//binding the assertions module to 'DUT" .
bind apb_mem_inst1 apb_assertion_module apb_assrt_mdu(.pclk(_PCLK),
                                                        .preset_n(_PRESETn),
                                                        .pselx(_PSEL1),
                                                        .pwrite(_PWRITE),
                                                        .penable(_PENABLE),
                                                        .paddr(_PADDR),
                                                        .pwdata(_PWDATA),
                                                        .prdata(_PRDATA),
                                                        .pready(_PREADY),
                                                        .pslverr(_PSLVERR));
                                                        
  
initial begin
  //                                            set(< null or uvm_root::get>,<pass to>,<reference_name>,<what do you put>);
  uvm_config_db#(virtual apb_master_interface)::set(uvm_root::get,"*","m_vintf",m_vintf);
 end
  
initial begin
  run_test("apb_test_wr_flwd_rd_s_low_adr");
end
  
initial begin
  $dumpfile("dump.vcd");
  $dumpvars;
end

endmodule:tb_top_apb_slave
