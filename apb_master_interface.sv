
interface apb_master_interface(input logic pclk, preset_n);//apb slave dut is a active low resest
  
  logic [31:0] paddr;
  logic        pselx;
  logic        penable;
  logic        pwrite;//if pwrite=1 -> write operation and if pwrite=0 -> read operation.
  logic [31:0] pwdata;
  logic        pready;
  logic [31:0] prdata;
  logic        pslverr;
  
//modport for the apb master driver.
  modport driver_mdp(input pclk,preset_n,prdata,pready,pslverr,output pselx,penable,pwrite,paddr,pwdata);
  
//modport for the apb master monitor.
modport monitor_mdp(input pclk,preset_n,prdata,pready,pslverr,pselx,penable,pwrite,paddr,pwdata);
  
endinterface:apb_master_interface