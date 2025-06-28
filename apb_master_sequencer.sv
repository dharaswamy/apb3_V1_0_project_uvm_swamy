

class apb_master_sequencer extends uvm_sequencer#(apb_master_seq_item);
 
int unsigned item_count=1;//by default item_count is 1;
  
//factory registration
`uvm_component_utils(apb_master_sequencer)
  
  //default constructor.
  function new(string name ,uvm_component parent);
    super.new(name,parent);
    `uvm_info("TRACE",$sformatf("%m"),UVM_HIGH)
  endfunction:new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if( !uvm_config_db#(int unsigned)::get(this, " ","item_count",item_count)) begin
      `uvm_info(get_name()," CONFIG DB GET FATAL ERROR ,SO FIRST SET THE \" item_count \" INTO THE config db from top",UVM_NONE);
      `uvm_info(get_name(),$sformatf("\n so sequencer no the get the item_count from the top/test,so the default item_cout=%0d is passed to the required sequence ",item_count),UVM_NONE);
    end
    else `uvm_info(get_name(),$sformatf(" apb_master_sequecer got the item_count=%0d",item_count),UVM_NONE);
  endfunction:build_phase
  
  
endclass:apb_master_sequencer