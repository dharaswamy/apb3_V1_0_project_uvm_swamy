
class apb_master_base_sequence extends uvm_sequence#(apb_master_seq_item);
  
  int unsigned item_count;
  
//factory registration
  `uvm_object_utils(apb_master_base_sequence)
  
 
  
  //default new constructor.
  function new(string name = "apb_master_base_sequence" );
    super.new(name);
    `uvm_info("TRACE",$sformatf("%m"),UVM_HIGH)
  endfunction:new
  
  virtual task pre_start();
    
  endtask:pre_start
  
//body task
virtual task body();
  req = apb_master_seq_item::type_id::create("req");
 // req.display();
 
  start_item(req);
  //  req = apb_master_seq_item::type_id::create("req");

  assert(req.randomize() with{pselx == 1'b1; pwrite == 1'b1;paddr == 10;})
    else `uvm_info(get_name()," RANDOMIZATION IS FAILED IN \" apb_master_base_sequence \" ",UVM_NONE);
  `uvm_info(get_name(),$sformatf("%0s",req.sprint()),UVM_NONE);
  finish_item(req);
  
  
  start_item(req);
  assert(req.randomize() with{pselx == 1'b1; pwrite == 1'b0; paddr ==10;})
    else `uvm_info(get_name()," RANDOMIZATION IS FAILED IN \" apb_master_base_sequence \" ",UVM_NONE);
  `uvm_info(get_name(),$sformatf("%0s",req.sprint()),UVM_NONE);
  finish_item(req); 
  
endtask:body
  
  
endclass:apb_master_base_sequence

//******************************************************************************************

class apb_wr_flwd_rd_same_adr_sequ extends apb_master_base_sequence;
  
  //temp addr;
  bit [31:0] temp_addr;
  int item_count ;
//factory registration
  `uvm_object_utils(apb_wr_flwd_rd_same_adr_sequ)
  
  //p_sequencer for accessing the " what ever this sequence class from the top/test via this parent sequencer "
  `uvm_declare_p_sequencer(apb_master_sequencer)
  
//default constructor
  function new(string name =" apb_wr_flwd_rd_same_adr_sequ");
  super.new(name);              
 endfunction:new
  
  
               
  task body();
    
  req = apb_master_seq_item::type_id::create("req");
`uvm_info(get_name(),$sformatf(" sequcence got the item_count =%0d ",p_sequencer.item_count),UVM_NONE)
 repeat(p_sequencer.item_count) begin
   start_item(req);
   assert(req.randomize() with{pwrite == apb_master_seq_item::WRITE;})
   else `uvm_fatal(get_name(),"RANDOMIZATION FAILED-FATAL");
   temp_addr=req.paddr;
   `uvm_info(get_name(),$sformatf("%0s",req.sprint()),UVM_NONE);

   finish_item(req);
  
   start_item(req);
   assert(req.randomize() with{pwrite == apb_master_seq_item::READ;paddr == local::temp_addr;})
     else `uvm_fatal(get_full_name(),"RANDOMIZATION FAILED-FATAL ERROR");
   `uvm_info(get_name(),$sformatf("%0s",req.sprint()),UVM_NONE);
    //temp_addr = req.paddr;
   finish_item(req);
   
 end
    
  endtask:body
  
               
endclass:apb_wr_flwd_rd_same_adr_sequ
 
//---------------------------------------------------------------------------------

//*************************************************************************************

//test case3:for the checking the "write only address ,we can read now in this test case ,see the slave dut thrown slverr error or not.
//for this you need to override the base class constraint with same because it is a hardconstraint(it is not a soft constraint).
//note :we know that addresses 25,40,80,200 are only write only ,they are not allowed to read .so we write and then read this addrres ,this is checking for the dut feature.
//for this i am using one drived class" apb_spcfd_rd_adrs_slverr_seq_item ".

class apb_wr_only_adrs_rd_slverr_sequence extends apb_master_base_sequence;
  
  //temp addr;
  bit [31:0] temp_addr;
  int item_count ;
//factory registration
  `uvm_object_utils(apb_wr_only_adrs_rd_slverr_sequence)
  
  //p_sequencer for accessing the " what ever this sequence class from the top/test via this parent sequencer "
  `uvm_declare_p_sequencer(apb_master_sequencer)
  
//default constructor
  function new(string name =" apb_wr_only_adrs_rd_slverr_sequence");
  super.new(name);              
 endfunction:new
  
  
               
virtual  task body();
req = apb_master_seq_item::type_id::create("req");
`uvm_info(get_name(),$sformatf(" sequcence got the item_count =%0d ",p_sequencer.item_count),UVM_NONE)
 repeat(p_sequencer.item_count) begin
   start_item(req);
   assert(req.randomize() with{pwrite == apb_master_seq_item::WRITE;})
     else `uvm_fatal(get_full_name(),"RANDOMIZATION FAILED-FATAL ERROR");
   temp_addr=req.paddr;
   `uvm_info(get_name(),$sformatf("%0s",req.sprint()),UVM_NONE);

   finish_item(req);
  
   start_item(req);
   assert(req.randomize() with{pwrite == apb_master_seq_item::READ;paddr == local::temp_addr;})
     else `uvm_fatal(get_full_name(),"RANDOMIZATION FAILED-FATAL ERROR");
   `uvm_info(get_name(),$sformatf("%0s",req.sprint()),UVM_NONE);

   finish_item(req);
   
   end
    
  endtask:body
  
               
endclass:apb_wr_only_adrs_rd_slverr_sequence

//----------------------------------------------------------------------

//********************************************************************

//test case4:for the checking the "read only address locations ,we can write in this test case,see that slave dut thrown an slverr error or not.
//note :we know that addresses 60,70,90,255 are read only ,they are not allowed to write .so we write this addrres ,this is checking for the dut feature.


class apb_rd_only_adrs_wr_pslverr_sequence extends apb_master_base_sequence;
  
  //temp addr;
 bit [31:0] temp_addr;

//factory registration
  `uvm_object_utils(apb_rd_only_adrs_wr_pslverr_sequence)
  
  //p_sequencer for accessing the " what ever this sequence class from the top/test via this parent sequencer "
  `uvm_declare_p_sequencer(apb_master_sequencer)
  
//default constructor
  function new(string name =" apb_rd_only_adrs_wr_pslverr_sequence");
  super.new(name);              
 endfunction:new
  
  
               
virtual  task body();
req = apb_master_seq_item::type_id::create("req");
`uvm_info(get_name(),$sformatf(" sequcence got the item_count =%0d ",p_sequencer.item_count),UVM_NONE)
repeat(p_sequencer.item_count) begin
start_item(req);
assert(req.randomize() with{pwrite == apb_master_seq_item::WRITE;})
  else `uvm_fatal(get_full_name(),"RANDOMIZATION FAILED-FATAL ERROR");
`uvm_info(get_name(),$sformatf("%0s",req.sprint()),UVM_NONE);
finish_item(req);
  
start_item(req);
assert(req.randomize() with{pwrite == apb_master_seq_item::READ;})
  else `uvm_fatal(get_full_name(),"RANDOMIZATION FAILED-FATAL ERROR");
`uvm_info(get_name(),$sformatf("%0s",req.sprint()),UVM_NONE);
finish_item(req);
    
 end
endtask:body
  
endclass:apb_rd_only_adrs_wr_pslverr_sequence

//----------------------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------

//test case5:if the wdata ,any one bit "x" or "z"  then ,then dut thrown the pslverr .
//for the we take the "logic pwdata" data for sending the "x" to write any memory location.see that any error thrown pslverr or not.
//for that we take one sequence.
class apb_wr_pwdata_unknown_values_sequence extends apb_master_base_sequence;
//class apb_wr_pwdata_unknown_values_sequence extends uvm_sequence#(apb_lgc_pwdata_seq_item);
 
  //factory registration
  `uvm_object_utils(apb_wr_pwdata_unknown_values_sequence)
    
    //p_sequencer for accessing the " what ever this sequence class from the top/test via this parent sequencer "
`uvm_declare_p_sequencer(apb_master_sequencer)
  
    
    function new(string name ="apb_wr_pwdata_unknown_values_sequence");
      super.new(name);
    endfunction:new
    
virtual task body();
 
req =apb_master_seq_item::type_id::create("req");
`uvm_info(get_name(),$sformatf(" sequcence got the item_count =%0d ",p_sequencer.item_count),UVM_NONE)
repeat(p_sequencer.item_count) begin
  start_item(req);
  assert(req.randomize() with{pwrite == apb_master_seq_item::WRITE;})
else `uvm_fatal(get_full_name(),"RANDOMIZATION FAILED-FATAL ERROR");
  `uvm_info("sequence_debug()",$sformatf(" req.pwdata=%b",req.pwdata),UVM_NONE);
  `uvm_info(get_name(),$sformatf("%0s",req.sprint()),UVM_NONE);
  finish_item(req);
end        
endtask:body
  
endclass:apb_wr_pwdata_unknown_values_sequence


//---------------------------------------------------------------------------------------------


//---------------------------------------------------------------------------------------------

//test case6: this test case for the paddr>=2**depath; here the depath=16 ,if paddr is greater than or equal to the "2**depath=65536" then apb slave thrown an pslverr=1; for these test case ,i can override apb_master_seq_item transaction class ,in that i can override the constriant of  " constraint addr_limit_const{paddr<2**16;} " because this test case i need the paddr  is paddr>2**16;
//for that we take the driverd transaction class "apb_paddr_grtr_than_mem_depath_sequence" from base class " apb_master_seq_item "
//for that we need one sequence"apb_paddr_grtr_than_mem_depath_sequence" .
class apb_paddr_grtr_than_mem_depath_sequence extends apb_master_base_sequence;

//factory registration.
  `uvm_object_utils(apb_paddr_grtr_than_mem_depath_sequence)
  
//p_sequencer for accessing the " what ever this sequence class from the top/test via this parent sequencer "
`uvm_declare_p_sequencer(apb_master_sequencer)
  
  
//default constructor.
function new(string name = "apb_paddr_grtr_than_mem_depath_sequence");
super.new(name);
endfunction:new
  

virtual task body();
  `uvm_info(get_name(),"\n====================SEQUENCE NAME : apb_paddr_grtr_than_mem_depath_sequence  BODY TASK IS STARTED===================",UVM_NONE)
  
// creating the trnasaction class object.
req=apb_master_seq_item::type_id::create("req");
 
repeat(p_sequencer.item_count) begin:repeat_begin
start_item(req);
assert(req.randomize())
  else `uvm_fatal(get_full_name(),"\n====================RANDMIZATION FAILED  FATAL ERROR=========================");
finish_item(req);
end:repeat_begin
 
`uvm_info(get_name(),"\n====================SEQUENCE NAME : apb_paddr_grtr_than_mem_depath_sequence  BODY TASK IS COMPLETED===================",UVM_NONE)

endtask:body
  
  
endclass:apb_paddr_grtr_than_mem_depath_sequence


//=================================================================================================


//----------------------------------------------------------------------------------



//==================================================================================






 
