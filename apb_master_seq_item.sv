class apb_master_seq_item extends uvm_sequence_item;
  
  //required randomized fields.
  rand bit        pselx;
  rand bit        penable;
  rand bit [31:0] paddr;
  rand bit        pwrite;
  rand bit [31:0] pwdata;
  
  typedef enum{READ,WRITE}  wr_rd_enum;
 
  
  //analysis fields
  bit [31:0] prdata;
  bit        pready;
  bit        pslverr;
  
  //based addr size take one temp_addr;
  bit [31:0] temp_addr;
  
//adresses 25,40,80,200 are write only registers so not read this registers and adresses 60,70,90,255 so write to this registers slave thrown error and if addr>= 2**16,addr>=65536 slave thrown an error because this addrs are not allow to write and read transction for this slave.
//  constraint adr_wr_rd_lmt_const{!paddr inside{60,70,90,255,25,40,80,200};}
constraint adr_wr_rd_lmt_const{ paddr != (60 || 70 || 90 || 255||25 || 40 ||80||200);}
constraint addr_limit_const{paddr<2**16;}
  
  //implicit extern constraints.
 constraint pselx_const; 
 constraint penable_const;
  
  
  //default constructor
  function new(string name = "apb_master_seq_item");
    super.new(name);
    `uvm_info("TRACE",$sformatf("%m"),UVM_HIGH)
  endfunction:new
  
 //object and fields are registered with factory.
  `uvm_object_utils_begin(apb_master_seq_item)
  `uvm_field_int(pselx,UVM_ALL_ON)
  `uvm_field_int(penable,UVM_ALL_ON)
  `uvm_field_int(paddr,UVM_ALL_ON)
  `uvm_field_int(pwrite,UVM_ALL_ON)
  `uvm_field_int(pwdata,UVM_ALL_ON)
  `uvm_field_int(prdata,UVM_ALL_ON)
  `uvm_field_int(pready,UVM_ALL_ON)
  `uvm_field_int(pslverr,UVM_ALL_ON)
  `uvm_object_utils_end
  
  
  virtual function void display();
    `uvm_info(get_full_name(),"\n\n===---------====--- apb_master_seq_item---========------====",UVM_NONE);
  endfunction:display
  
endclass:apb_master_seq_item

constraint apb_master_seq_item::pselx_const{soft pselx==1'b1;}
constraint apb_master_seq_item::penable_const{soft penable == 1'b1;}

//--------------------------------------------------------------------------------------


class dummy extends apb_master_seq_item;
  `uvm_object_utils(dummy)
  
  function new(string name = "dummy");
    super.new(name);
  endfunction:new
  
  virtual function void display();
    $display(get_full_name(),"\n\n=============-------- dummy -------========----------=======",UVM_NONE);
  endfunction:display
  
endclass:dummy

//***********************************************************************************

//test case2:apb_test_wr_flwd_rd_s_low_adr
class apb_master_seq_item_adr_low_fc extends apb_master_seq_item;
  
 //factory registration
  `uvm_object_utils(apb_master_seq_item_adr_low_fc)
  
//adresses 25,40,80,200 are write only registers so not read this registers and adresses 60,70,90,255
  constraint addr_low_const{paddr inside{[0:255]};}
  
  function new(string name="apb_master_seq_item_adr_low_fc");
    super.new();
  endfunction:new
  
endclass:apb_master_seq_item_adr_low_fc

//----------------------------------------------------------------------------------------

//************************************************************************************

//test case3:for the checking the "write only address ,we can read now in this test case ,see the slave dut thrown slverr error or not.
//for this you need to override the base class constraint with same because it is a hardconstraint(it is not a soft constraint).
//constraint adr_wr_rd_lmt_const{ paddr != (60 || 70 || 90 || 255||25 || 40 ||80||200);}
//note :we know that addresses 25,40,80,200 are only write only ,they are not allowed to read .so we write and then read this addrres ,this is checking for the dut feature.

class  apb_wr_only_adrs_rd_slverr_seq_item extends apb_master_seq_item;

//factory registration.
`uvm_object_utils(apb_wr_only_adrs_rd_slverr_seq_item)
  
//constraint adr_wr_rd_lmt_const{ paddr == (25 || 40 ||80||200);} //base constraint override with same name.
constraint adr_wr_rd_lmt_const{paddr inside{25,40,80,200};}

  function new(string name ="apb_wr_only_adrs_rd_slverr_seq_item");
    super.new(name);
  endfunction:new
  
endclass:apb_wr_only_adrs_rd_slverr_seq_item 


//---------------------------------------------------------------------------------

//*********************************************************************************//

//test case4:for the checking the "read only address locations ,we can write in this test case,see that slave dut thrown an slverr error or not.
//for this you need to override the base class constraint with same because it is a hardconstraint(it is not a soft constraint).
//constraint adr_wr_rd_lmt_const{ paddr != (60 || 70 || 90 || 255||25 || 40 ||80||200);}
//note :we know that addresses 60,70,90,255 are read only ,they are not allowed to write .so we write this addrres ,this is checking for the dut feature.



class apb_rd_only_adrs_wr_pslverr_seq_item  extends apb_master_seq_item;
  
  //factory registration.
  `uvm_object_utils(apb_rd_only_adrs_wr_pslverr_seq_item)
  

  constraint adr_wr_rd_lmt_const{soft paddr inside{60,70,90,255};}
  
  function new(string name = "apb_rd_only_adrs_wr_pslverr_seq_item");
    super.new(name);  
  endfunction:new
  
endclass:apb_rd_only_adrs_wr_pslverr_seq_item


//--------------------------------------------------------------------------------------
	

//--------------------------------------------------------------------------------------

//test case5:if the wdata ,any one bit "x" or "z"  then ,then dut thrown the pslverr .
//for the we take the "logic pwdata" data for sending the "x" to write any memory location.see that any error thrown pslverr or not.

class apb_lgc_pwdata_seq_item extends apb_master_seq_item;

  rand logic [31:0] pwdata;
  
 //factory registration
  `uvm_object_utils_begin(apb_lgc_pwdata_seq_item)
  `uvm_field_int(pwdata,UVM_ALL_ON)
  `uvm_object_utils_end
  
  
 
  
  //default constructor.
  function new(string name = "apb_lgc_pwdata_seq_item");
    super.new(name);
  endfunction:new
  
  function void post_randomize(); //1,2,4,8,12,16,20,32 ,8 values  
    bit [2:0] x;
    std::randomize(x);
    case (x) 
    1:pwdata=32'b0101_1010_1x11_1010_0001_0011_0101_0100;
    2:pwdata=32'b0101_1010_1011_1x10_0001_0011_01x1_0100;
    3:pwdata=32'b0x01_1010_1x11_1010_0001_00x1_0101_x100;
    4:pwdata=32'h5x78_39x7; 
    5:pwdata=32'h5x78_x9x7; 
    6:pwdata=32'h5x7x_x9x7; 
    7:pwdata=32'hxx7x_x9x7;
    0:pwdata=32'hxxxx_xxxx;
    endcase
   // $display("post _randomize() logic pwdata=%b",pwdata);
  endfunction:post_randomize
  
endclass:apb_lgc_pwdata_seq_item


//-----------------------------------------------------------------------------------------------------------

//test case5a:if the wdata ,any one bit "x" or "z"  then ,then dut thrown the pslverr .
//for the we take the "logic pwdata" data for sending the "x" to write any memory location.see that any error thrown pslverr or not.
/*
class apb_lgc_pwdata_seq_item extends uvm_sequence_item;

 
  
  //required randomized fields.
  rand bit        pselx;
  rand bit        penable;
  rand bit [31:0] paddr;
  rand bit        pwrite;
  rand logic [31:0] pwdata;
  
  typedef enum{READ,WRITE}  wr_rd_enum;
 
  
  //analysis fields
  bit [31:0] prdata;
  bit        pready;
  bit        pslverr;
  
  //based addr size take one temp_addr;
  bit [31:0] temp_addr;
  
//adresses 25,40,80,200 are write only registers so not read this registers and adresses 60,70,90,255 so write to this registers slave thrown error and if addr>= 2**16,addr>=65536 slave thrown an error because this addrs are not allow to write and read transction for this slave.
//  constraint adr_wr_rd_lmt_const{!paddr inside{60,70,90,255,25,40,80,200};}
constraint adr_wr_rd_lmt_const{ paddr != (60 || 70 || 90 || 255||25 || 40 ||80||200);}
//constraint addr_limit_const{paddr<2**16;}
  
 constraint pselx_const; 
 constraint penable_const;
  
  
 //object and fields are registered with factory.
  `uvm_object_utils_begin(apb_lgc_pwdata_seq_item)
  `uvm_field_int(pselx,UVM_ALL_ON)
  `uvm_field_int(penable,UVM_ALL_ON)
  `uvm_field_int(paddr,UVM_ALL_ON)
  `uvm_field_int(pwrite,UVM_ALL_ON)
  `uvm_field_int(pwdata,UVM_ALL_ON)
  `uvm_field_int(prdata,UVM_ALL_ON)
  `uvm_field_int(pready,UVM_ALL_ON)
  `uvm_field_int(pslverr,UVM_ALL_ON)
  `uvm_object_utils_end
  


  
  //default constructor.
  function new(string name = "apb_lgc_pwdata_seq_item");
    super.new(name);
  endfunction:new
  
  function void post_randomize(); //1,2,4,8,12,16,20,32 ,8 values  
    bit [2:0] x;
    std::randomize(x);
    case (x) 
    1:pwdata=32'b0101_1010_1x11_1010_0001_0011_0101_0100;
    2:pwdata=32'b0101_1010_1011_1x10_0001_0011_01x1_0100;
    3:pwdata=32'b0x01_1010_1x11_1010_0001_00x1_0101_x100;
    4:pwdata=32'h5x78_39x7; 
    5:pwdata=32'h5x78_x9x7; 
    6:pwdata=32'h5x7x_x9x7; 
    7:pwdata=32'hxx7x_x9x7;
    0:pwdata=32'hxxxx_xxxx;
    endcase
    $display("post _randomize() logic pwdata=%b",pwdata);
  endfunction:post_randomize
  
endclass:apb_lgc_pwdata_seq_item

constraint apb_lgc_pwdata_seq_item::pselx_const{soft pselx==1'b1;}
constraint apb_lgc_pwdata_seq_item::penable_const{soft penable == 1'b1;}
  
*/
//-----------------------------------------------------------------------------------------------------------


//-----------------------------------------------------------------------------------------------------------

//test case6: this test case for the paddr>=2**depath; here the depath=16 ,if paddr is greater than or equal to the "2**depath=65536" then apb slave thrown an pslverr=1; for these test case ,i can override apb_master_seq_item transaction class ,in that i can override the constriant of  " constraint addr_limit_const{paddr<2**16;} " because this test case i need the paddr  is paddr>2**16;
//for that we take the driverd transaction class "apb_paddr_grtr_than_mem_depath" from base class " apb_master_seq_item "

class apb_paddr_grtr_than_mem_depath  extends apb_master_seq_item;

//factory registration
`uvm_object_utils(apb_paddr_grtr_than_mem_depath)
  
//overding the base class constriant with same name
constraint addr_limit_const{paddr>=2**16;}
  
function new(string name="apb_paddr_grtr_than_mem_depath");
super.new(name);
endfunction:new
  
  
endclass:apb_paddr_grtr_than_mem_depath

//-------------------------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------
//test case7:  randomly write and read include all memory locations (i.write only locations ii.read only locations ii.paddr >= 2** 16 >= 65536.

class apb_randomly_write_and_read extends apb_master_seq_item;
  
  //factory registration.
  `uvm_object_utils(apb_randomly_write_and_read)
  
 //default constructor.
  function new(string name = " apb_randomly_write_and_read");
    super.new(name);
  endfunction:new
  
  
  
endclass:apb_randomly_write_and_read

//=================================================================================
