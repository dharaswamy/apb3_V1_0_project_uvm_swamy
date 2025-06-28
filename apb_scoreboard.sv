`define mem_depth 16 //which take due to the dut have depth=16.

class apb_scoreboard extends uvm_scoreboard;
  
//we need for one memory for memicing the apb slave behaviour.
reg [31:0] memory[2**`mem_depth-1:0];
//factory registration
`uvm_component_utils(apb_scoreboard)
  
//analysis import class 
  uvm_analysis_imp#(apb_master_seq_item,apb_scoreboard) analysis_import;
  
  //APB MASTER TRANSACTION CLASS HANDLE
  apb_master_seq_item pkt;
  
//default constructor
  function new(string name,uvm_component parent);
    super.new(name,parent);
    `uvm_info("TRACE",$sformatf("%m"),UVM_HIGH);
    foreach(memory[i]) begin
     memory[i]=i;
    end
    analysis_import = new("analysis_import",this);
  endfunction:new
  
  virtual function void write(apb_master_seq_item trans);
    pkt = trans;
`uvm_info(get_name(),$sformatf(" APB SCOREBOARD GOT THE PKT FORM MASTER MONITOR \N %0s",pkt.sprint()),UVM_DEBUG);
    write_read_compare(pkt);
  endfunction:write
  
//task for the compare logic and pass or fail transaction ,it is a just reflected type of the apb slave dut.l
virtual function void write_read_compare(apb_master_seq_item pkt);
  
//first checking the access state behaviour.
  if(pkt.pselx && pkt.penable && pkt.pready) begin:pslx_pen_prdy
  
if(apb_master_seq_item::WRITE == pkt.pwrite) begin:write_logic
  
if(pkt.paddr>=(2**`mem_depth)) begin:invalid_adrs
  
if(pkt.pslverr == 1'b1) begin
  `uvm_info(get_name(),$sformatf("\n---------------------------------TEST PASSED WRITE TRANSACTION------------------------------------------------------\n-----------------------APB master want to \" write the data \" into slave device but address is more than limits in slave device  so slave thrown pslverr--------------------------------- \n--------------------------pwrite=%b paddr(deci)=%0d paddr(hexa)=%h  EXPCTD pslverr=%0b ,ACTUAL pslverr=%0b-----------------------------\n --------------------------------------------------------------------------------------------------",pkt.pwrite,pkt.paddr,pkt.paddr,1'b1,pkt.pslverr),UVM_NONE);
end
else begin
  `uvm_error(get_name(),$sformatf("\n ----------------------------------- \"TEST FAILED WRITE TRANSACTION\" ---------------------------------\n ------------------------APB master want to \" write the data \" into slave device but address is more than limits in slave device  so slave thrown pslverr---------------------- \n----------------------------pwrite=%b paddr(deci)=%0d paddr=%0h  EXPCTD pslverr=%0b, ACTUAL pslverr=%0b ----------------------------\n --------------------------------------------------------------------------------------------------------------------------",pkt.pwrite,pkt.paddr,pkt.paddr,1'b1,pkt.pslverr)); 
end
end:invalid_adrs
  
  else if((pkt.paddr =='H3C) || (pkt.paddr == 'H46) || (pkt.paddr == 'H5a) || (pkt.paddr == 'Hff)) begin:read_only_locations //decimal form 60 || 70 || 90 || 255
`uvm_info("read_only","------------------read only ----------------------",UVM_NONE);
if(pkt.pslverr == 1'b1) begin
  `uvm_info(get_name(),$sformatf("\n-------------------------- TEST PASSED WRITE TRANSACTION----------------------------\n ----------------APB master want to \" write data into read only \"RO\" paddr locations\" in slave device so slave thrown pslverr -------------- \n--------------------- pwrite=%0b paddr=%0h so EXPCTD pslverr=%0b, ACTUAL pslverr=%0b -------------------------\n--------------------------------------------------------------------------------------------------------------------",pkt.pwrite,pkt.paddr,1'b1,pkt.pslverr),UVM_NONE);    
end
else begin
  `uvm_error(get_name(),$sformatf("\n -----------------------------------------------------\"TEST FAILED WRITE TRANSACTION\" ---------------------------------------------\n -----------------------APB master want to\" write data into read  only\"RO\" addr locations \" in slave device  so slave thrown pslverr----------------------- \n----------------------- pwrite=%0b paddr=%0d so EXPCTD pslverr=%0b,ACTUAL pslverr=%0b-----------------------------\n --------------------------------------------------------------------------------------------------------",pkt.pwrite,pkt.paddr,1'b1,pkt.pslverr));
end
end:read_only_locations
  
else if($isunknown(pkt.pwdata) == 1'b1) begin:pwdata_have_x_z_values
  
if(pkt.pslverr == 1'b1) begin
  `uvm_info(get_name(),$sformatf("\n--------------------TEST PASSED WRITE TRANSACTION---------------------------------\n ------------------------------- APB master \"write the data into slave device \" ,but data contains x(unknown),z(high_impendane) values so slave thrown pslverr------------------------------- \n ----------------------------------- pwrite=%0b ,paddr=%0h ,pwdata=%b EXPCTD pslverr=%0b , ACTUAL pslverr=%b ------------------------------------------\n --------------------------------------------------------------------------------------------------",pkt.pwrite,pkt.paddr,pkt.pwdata,1'B1,pkt.pslverr),UVM_NONE); 
  end
else begin
  `uvm_error(get_name(),$sformatf("\n------------------------------\"TEST FAILED WRITE TRANSACTION\"---------------------\n ---------------------APB master \" write the data into slave device\" ,but data contains x(unknown),z(high_impendane) values so slave thrown pslverr-------------------- \n--------------------pwrite=%0b ,paddr=%0h ,pwdata=%b EXPCTD pslverr=%0b , ACTUAL pslverr=%b---------------------------\n ---------------------------------------------------------------------------------------------------",pkt.pwrite,pkt.paddr,pkt.pwdata,1'B1,pkt.pslverr));   
end
end:pwdata_have_x_z_values

else begin:store_pwdata
  
if(pkt.pslverr !== 1'b1) begin
memory[pkt.paddr] = pkt.pwdata;
  `uvm_info(get_name(),$sformatf(" \n---------\" WRITE TRANSACTION SCOREBOARD MEMORY STORED THE pwdata=%0h in paddr=%0h,pwrite=%b \"----------------------",pkt.pwdata,pkt.paddr,pkt.pwrite),UVM_NONE);
end
 
if(pkt.pslverr == 1'b1) begin
memory[pkt.paddr] = pkt.pwdata;
`uvm_error(get_name(),$sformatf(" \n------------\" APB MASTER want to write the data into slave device  valid  Paddr locations and slave stored the data but slave thrown an pslverr \"---------------- \n -------------pslverr=%0b pwdata=%0h in paddr=%0h,pwrite=%b so see waveforms and confirm the bug based on this paddr can \"write access or not \".------------------ \n ----------------------------------------------------------------------------------------------------------------------------------",pkt.pslverr,pkt.pwdata,pkt.paddr,pkt.pwrite));
end
end:store_pwdata
  
end:write_logic
  
if(apb_master_seq_item::READ == pkt.pwrite) begin:read_logic //pwrite = 0 read operation.
  
if(pkt.paddr>=(2**`mem_depth)) begin:invalid_adrs_read
if(pkt.pslverr == 1'b1) begin
  `uvm_info(get_name(),$sformatf("\n --------------------------TEST PASSED READ TRANSACTION -----------------------\n ------------APB master want to \" read  the data \" from the slave device but address is more than limits in slave device  so slave thrown pslverr----------------\n----------------------pwrite=%b paddr(deci)=%0d paddr(hexa)=%0H  EXPCTD pslverr=%0b ,ACTUAL pslverr=%0b -----------------------------\n--------------------------------------------------------------------------------------------------------",pkt.pwrite,pkt.paddr,pkt.paddr,1'b1,pkt.pslverr),UVM_NONE);
end
else begin
  `uvm_error(get_name(),$sformatf("\n--------------------------\"TEST FAILED READ TRANSACTION\"----------------------------\n-------------------APB master want to \"read the data \" from slave device but address is more than limits in  slave device  so slave thrown pslverr----------------------- \n---------------------pwrite=%b paddr(deci)=%0d paddr=%0H  EXPCTD pslverr=%0b, ACTUAL pslverr=%0b---------------------------------\n --------------------------------------------------------------------------------------------------------------------------------",pkt.pwrite,pkt.paddr,pkt.paddr,1'b1,pkt.pslverr)); 
end
end:invalid_adrs_read

  else if( (pkt.paddr == 'h19)  || (pkt.paddr == 'h28) || (pkt.paddr == 'h50) || (pkt.paddr == 'hc8)) begin:write_only_addr_locations //write only paddr locations decimal form:25 || 40 || 80 || 200
if(pkt.pslverr == 1'b1) begin
  `uvm_info(get_name(),$sformatf("\n-------------------------------TEST PASSED READ TRNSACTION--------------------------\n------------------------APB master want to \" read data from write only \" WO \" addr locations\" from slave device so slave thrown pslverr---------------------\n---------------------------------pwrite=%0b paddr=%0H so EXPCTDpslverr=%0b, ACTUAL pslverr=%0b--------------------------------\n-----------------------------------------------------------------------------------------------------",pkt.pwrite,pkt.paddr,1,pkt.pslverr),UVM_NONE);    
end
else begin
  `uvm_error(get_name(),$sformatf("\n--------------------\"TEST FAILED READ TRANSACTION\"-------------------------------------\n ------------------APB master want to\" read data from write only \"WO\" addr locations \" from slave device  so slave thrown pslverr---------------- \n--------------------pwrite=%0b paddr=%0h so EXPCTD pslverr=%0b,ACTUAL pslverr=%0b-------------------------------\n ---------------------------------------------------------------------------------------------------------------------",pkt.pwrite,pkt.paddr,1,pkt.pslverr));
end
end:write_only_addr_locations
  
else begin:read_data
  
if(pkt.pslverr !== 1'b1) begin:begin_pslverr0_read
  
if(memory[pkt.paddr] === pkt.prdata) begin
  `uvm_info(get_name(),$sformatf("\n-----------------------------------TEST PASSED READ TRANSACTION-----------------------------\n--------------------------------- pwrite=%b,paddr=%0h EXPCTD prdata=%0h and ACTUAL prdata=%0h --------------------------------\n-------------------------------------------------------------------------------------------------------------------------------",pkt.pwrite,pkt.paddr,memory[pkt.paddr],pkt.prdata),UVM_NONE);    
end
else begin
  `uvm_error(get_name(),$sformatf(" \"\n----------------------------\" TEST FAILED READ TRANSACTION \"-----------------------------\n----------------------- pwrite=%b,paddr=%0h EXPCTD prdata=%0h and ACTUAL prdata=%0h -------------------------------------------------\n ----------------------------------------------------------------------------------------------------------------------",pkt.pwrite,pkt.paddr,memory[pkt.paddr],pkt.prdata));    
end
end:begin_pslverr0_read
  
else if(pkt.pslverr == 1'b1) begin 
  `uvm_error(get_name(),$sformatf("\n-------------------\"APB master read data from valid addr locations \"WR\" in slave device \" but slave device thrown pslverr------------\n------------------ plsverr=%b \n pwrite=%b,paddr=%0h so see this paddr is valid addr for \"read access is there\" in specfication and see waveforms confirm the bug-----------------\n---------------------------------------------------------------------------------------------------------------------------",pkt.pslverr,pkt.pwrite,pkt.paddr));
end
  
end:read_data 
  
end:read_logic
  
end:pslx_pen_prdy
  
endfunction:write_read_compare
  
endclass:apb_scoreboard