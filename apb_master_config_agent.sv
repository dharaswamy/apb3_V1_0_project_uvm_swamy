
class apb_master_config_agent extends uvm_object;
  
//factory registration.
  `uvm_object_utils(apb_master_config_agent)
  
  uvm_active_passive_enum is_active = UVM_ACTIVE ;
  
  function new(string name = "apb_master_config_agent");
    super.new(name);
    `uvm_info("TRACE",$sformatf("%m"),UVM_HIGH)
  endfunction:new
  
endclass:apb_master_config_agent