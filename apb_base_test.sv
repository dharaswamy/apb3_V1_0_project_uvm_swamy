class apb_base_test extends uvm_test;
 
  int unsigned item_count=1;
  
  //factory registration.
  `uvm_component_utils_begin(apb_base_test)
  `uvm_field_int(item_count,UVM_NONE)
`uvm_component_utils_end
  
  
  

  
  //default constructor
  function new(string name,uvm_component parent);
    super.new(name,parent);
    `uvm_info("TRACE",$sformatf("%m"),UVM_HIGH);
    endfunction
  
  //apb master environment class.
 apb_master_environment   apb_m_env;
  
  uvm_factory   factory;
  
 uvm_coreservice_t cs=uvm_coreservice_t::get(); 
  

  virtual function void build_phase(uvm_phase  phase);
    super.build_phase(phase);
    factory=cs.get_factory();
   //apb master env class handle declaration
    apb_m_env=apb_master_environment::type_id::create("apb_m_env",this);
   uvm_config_db#(int unsigned)::set(this,"*","item_count",item_count);
  endfunction
  
   //end_of_elaboration_phase for any final adjustments in components before going of start_run_phase.
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
      this.print();
   //factory=cs.get_factory();
    factory.print();
    
      endfunction
  
  //start of simulation phase
  virtual function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
     uvm_top.print_topology();
   endfunction:start_of_simulation_phase

  /*virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
    #100;
    phase.drop_objection(this);
    phase.phase_done.set_drain_time(this,100);
  endtask:run_phase*/
  
  
endclass:apb_base_test