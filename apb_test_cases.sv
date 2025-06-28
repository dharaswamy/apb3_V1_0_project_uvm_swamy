
class apb_test_case1 extends apb_base_test;

//factory registration
`uvm_component_utils(apb_test_case1) 

// apb maste config agent class handle declaration.
apb_master_config_agent m_cfg_agt;

//sequence class declaration.
apb_master_base_sequence b_sequ;

//default constructor.
function new(string name,uvm_component parent);
  super.new(name,parent);
  `uvm_info("TRACE",$sformatf("%m"),UVM_HIGH)
endfunction:new

virtual function void build_phase(uvm_phase phase);
  super.build_phase(phase);
m_cfg_agt = apb_master_config_agent::type_id::create("m_cfg_agt");
    //creationg base sequence
  b_sequ = apb_master_base_sequence::type_id::create("b_sequ",this);
endfunction:build_phase


virtual task run_phase(uvm_phase phase);
  super.run_phase(phase);
  phase.raise_objection(this);
  if(m_cfg_agt.is_active == UVM_ACTIVE) begin
  b_sequ.start(apb_m_env.m_agt.m_seqr);
  end
  phase.drop_objection(this);
  phase.phase_done.set_drain_time(this,100);
endtask:run_phase

endclass:apb_test_case1

//*****************************************************************************************************************


class apb_test_wr_flwd_rd_s_low_adr extends apb_base_test;
  
//factory registration
`uvm_component_utils(apb_test_wr_flwd_rd_s_low_adr) 
 


// apb maste config agent class handle declaration.
apb_master_config_agent m_cfg_agt;

//sequence class declaration.
apb_wr_flwd_rd_same_adr_sequ wr_f_rd_sequ;
//default constructor.
function new(string name,uvm_component parent);
  super.new(name,parent);
  `uvm_info("TRACE",$sformatf("%m"),UVM_HIGH)
endfunction:new

virtual function void build_phase(uvm_phase phase);
  super.build_phase(phase);
  super.item_count =20;
  uvm_config_db#(int unsigned)::set(this,"apb_m_env.m_agt*","item_count",item_count);
set_type_override_by_type(apb_master_seq_item::get_type(), apb_master_seq_item_adr_low_fc::get_type());
m_cfg_agt = apb_master_config_agent::type_id::create("m_cfg_agt");
    //creationg base sequence
wr_f_rd_sequ = apb_wr_flwd_rd_same_adr_sequ::type_id::create("wr_f_rd_sequ");
endfunction:build_phase


virtual task run_phase(uvm_phase phase);
  super.run_phase(phase);
  phase.raise_objection(this);
  if(m_cfg_agt.is_active == UVM_ACTIVE) begin
  wr_f_rd_sequ.start(apb_m_env.m_agt.m_seqr);
  end
  phase.drop_objection(this);
  phase.phase_done.set_drain_time(this,100);
endtask:run_phase

endclass:apb_test_wr_flwd_rd_s_low_adr

//**************************************************************************************************************

//-------------------------------------------------------------------

//test case3:for the checking the "write only address ,we can read now in this test case ,see the slave dut thrown slverr error or not.
//for this you need to override the base class constraint with same because it is a hardconstraint(it is not a soft constraint).
//constraint adr_wr_rd_lmt_const{ paddr != (60 || 70 || 90 || 255||25 || 40 ||80||200);}
//note :we know that addresses 25,40,80,200 are only write only ,they are not allowed to read .so we write and then read this addrres ,this is checking for the dut feature.
//note:for this test we use the "apb_wr_only_adrs_rd_slverr_seq_item ,apb_wr_only_adrs_rd_slverr_sequence ",see we need to type override the apb_master_seq_item ".



class apb_wr_only_adrs_rd_slverr_test3 extends apb_base_test;
  
//factory registration
`uvm_component_utils(apb_wr_only_adrs_rd_slverr_test3) 
 


// apb maste config agent class handle declaration.
apb_master_config_agent m_cfg_agt;

//sequence class declaration.
apb_wr_only_adrs_rd_slverr_sequence  wr_only_adrs_rd_err_sequ;
  
//default constructor.
  function new(string name=" apb_wr_only_adrs_rd_slverr_test3",uvm_component parent=null);
  super.new(name,parent);
  `uvm_info("TRACE",$sformatf("%m"),UVM_HIGH)
endfunction:new

virtual function void build_phase(uvm_phase phase);
  super.build_phase(phase);
  super.item_count =1;
  uvm_config_db#(int unsigned)::set(this,"apb_m_env.m_agt*","item_count",item_count);
  //type override the main transaction class with the "apb_wr_only_adrs_rd_slverr_seq_item"
set_type_override_by_type(apb_master_seq_item::get_type(),apb_wr_only_adrs_rd_slverr_seq_item::get_type());
m_cfg_agt = apb_master_config_agent::type_id::create("m_cfg_agt");
    //creationg base sequence
wr_only_adrs_rd_err_sequ = apb_wr_only_adrs_rd_slverr_sequence::type_id::create("wr_only_adrs_rd_err_sequ");
endfunction:build_phase


virtual task run_phase(uvm_phase phase);
  super.run_phase(phase);
  
  phase.raise_objection(this);
  if(m_cfg_agt.is_active == UVM_ACTIVE) begin
  wr_only_adrs_rd_err_sequ.start(apb_m_env.m_agt.m_seqr);
  end
  phase.drop_objection(this);
  phase.phase_done.set_drain_time(this,100);
endtask:run_phase

endclass:apb_wr_only_adrs_rd_slverr_test3

//--------------------------------------------------------------------


//test case4:for the checking the "read only address locations ,we can write in this test case,see that slave dut thrown an slverr error or not.
//for this you need to override the base class constraint with same because it is a hardconstraint(it is not a soft constraint).
//constraint adr_wr_rd_lmt_const{ paddr != (60 || 70 || 90 || 255||25 || 40 ||80||200);}
//note :we know that addresses 60,70,90,255 are read only ,they are not allowed to write .so we write this addrres ,this is checking for the dut feature.
//note:for this test we use the "apb_rd_only_adrs_wr_pslverr_seq_item ,apb_rd_only_adrs_wr_pslverr_sequence ",see we need to type override the apb_master_seq_item ".


class apb_rd_only_adrs_wr_pslverr_test4 extends apb_base_test;
  
//factory registration
`uvm_component_utils(apb_rd_only_adrs_wr_pslverr_test4) 
 


// apb maste config agent class handle declaration.
apb_master_config_agent m_cfg_agt;

//sequence class declaration.
apb_rd_only_adrs_wr_pslverr_sequence  rd_only_adrs_wr_pslverr_sequ;
//default constructor.
function new(string name,uvm_component parent);
  super.new(name,parent);
  `uvm_info("TRACE",$sformatf("%m"),UVM_HIGH)
endfunction:new

virtual function void build_phase(uvm_phase phase);
  super.build_phase(phase);
  super.item_count =10;
  uvm_config_db#(int unsigned)::set(this,"apb_m_env.m_agt*","item_count",item_count);
  //type override the main transaction class with the "apb_wr_only_adrs_rd_slverr_seq_item"
set_type_override_by_type(apb_master_seq_item::get_type(),apb_rd_only_adrs_wr_pslverr_seq_item::get_type());
m_cfg_agt = apb_master_config_agent::type_id::create("m_cfg_agt");
    //creationg base sequence
rd_only_adrs_wr_pslverr_sequ = apb_rd_only_adrs_wr_pslverr_sequence::type_id::create("rd_only_adrs_wr_pslverr_sequ");
endfunction:build_phase


virtual task run_phase(uvm_phase phase);
  super.run_phase(phase);
  phase.raise_objection(this);
  if(m_cfg_agt.is_active == UVM_ACTIVE) begin
  rd_only_adrs_wr_pslverr_sequ.start(apb_m_env.m_agt.m_seqr);
  end
  phase.drop_objection(this);
  phase.phase_done.set_drain_time(this,10);
endtask:run_phase

endclass:apb_rd_only_adrs_wr_pslverr_test4

//----------------------------------------------------------------------------------

//----------------------------------------------------------------------------------

//test case5:if the pwdata ,any one bit "x" or "z"  then ,then dut thrown the pslverr .
//for the we take the "logic pwdata" data for sending the "x" to write any memory location.see that any error thrown pslverr or not.
//for that we take one sequence "apb_wr_pwdata_unknown_values_sequence".


//class apb_wr_pwdata_lgc_unknown_values_pslverr_test5 extends apb_base_test;

class apb_wr_pwdata_lgc_unknown_values_pslverr_test5 extends uvm_test;
  
int unsigned item_count;
    
//factory registration
`uvm_component_utils(apb_wr_pwdata_lgc_unknown_values_pslverr_test5) 
  
// apb maste config agent class handle declaration.
apb_master_config_agent m_cfg_agt;

//sequence class declaration.
apb_wr_pwdata_unknown_values_sequence  wr_pwdata_lgc_sequ;
  
 
  
 //apb master environment class.
 apb_master_environment   apb_m_env;
  
  uvm_factory   factory;
  
 uvm_coreservice_t cs=uvm_coreservice_t::get(); 
  

  
//default constructor.
function new(string name,uvm_component parent);
  super.new(name,parent);
  `uvm_info("TRACE",$sformatf("%m"),UVM_HIGH)
endfunction:new

virtual function void build_phase(uvm_phase phase);
  super.build_phase(phase);
//type override the main transaction class with the "apb_lgc_pwdata_seq_item"
set_type_override_by_type(apb_master_seq_item::get_type(),apb_lgc_pwdata_seq_item::get_type());
//super.item_count =40;
 item_count=5;
//apb master env class handle declaration
apb_m_env=apb_master_environment::type_id::create("apb_m_env",this);
  
uvm_config_db#(int unsigned)::set(this,"apb_m_env.m_agt*","item_count",item_count);
//creating the apb configaration agent class.
m_cfg_agt = apb_master_config_agent::type_id::create("m_cfg_agt");
//creating  sequence
wr_pwdata_lgc_sequ = apb_wr_pwdata_unknown_values_sequence::type_id::create("wr_pwdata_lgc_sequ");
endfunction:build_phase
  
  //end_of_elaboration_phase for any final adjustments in components before going of start_run_phase.
  virtual function void end_of_elaboration_phase(uvm_phase phase);
      super.end_of_elaboration_phase(phase);
      this.print();
   factory=cs.get_factory();
    factory.print();
  endfunction
  
  //start of simulation phase
  virtual function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
     uvm_top.print_topology();
   endfunction:start_of_simulation_phase



virtual task run_phase(uvm_phase phase);
 
  super.run_phase(phase);
  phase.raise_objection(this);
  if(m_cfg_agt.is_active == UVM_ACTIVE) begin
  wr_pwdata_lgc_sequ.start(apb_m_env.m_agt.m_seqr);
   end
  phase.drop_objection(this);
  phase.phase_done.set_drain_time(this,100);
endtask:run_phase
  
endclass:apb_wr_pwdata_lgc_unknown_values_pslverr_test5 


//*********************************************************************************

//test case6: this test case for the paddr>=2**depath; here the depath=16 ,if paddr is greater than or equal to the "2**depath=65536" then apb slave thrown an pslverr=1; for these test case ,i can override apb_master_seq_item transaction class ,in that i can override the constriant of  " constraint addr_limit_const{paddr<2**16;} " because this test case i need the paddr  is paddr>2**16;
//for that we take the driverd transaction class "apb_paddr_grtr_than_mem_depath_sequence" from base class " apb_master_seq_item "
//for that we need one sequence"apb_paddr_grtr_than_mem_depath_sequence" .

class apb_paddr_grtr_than_mem_depath_test6 extends apb_base_test;
  
//factory registration.
`uvm_component_utils(apb_paddr_grtr_than_mem_depath_test6)
  
// apb maste config agent class handle declaration.
apb_master_config_agent m_cfg_agt;

 
//sequence class handle declaration.
apb_paddr_grtr_than_mem_depath_sequence  paddr_grtr_mem_dep_sequ;
  
//default constructor
  function new(string name,uvm_component parent);
    super.new(name,parent);
  endfunction:new
  
virtual function void build_phase(uvm_phase phase);
`uvm_info("UVM_TEST:apb_paddr_grtr_than_mem_depath_test6"," Build phase is started",UVM_MEDIUM)
super.build_phase(phase);
item_count=2;
  //uvm_top.set_report_verbosity_level_hier(UVM_FULL);
uvm_config_db#(int unsigned)::set(this,"apb_m_env.m_agt*","item_count",item_count);
//type override the main transaction class with the "apb_paddr_grtr_than_mem_depath_sequence"
set_type_override_by_type(apb_master_seq_item::get_type(),apb_paddr_grtr_than_mem_depath::get_type());
//apb master config agent class instantiation.
m_cfg_agt = apb_master_config_agent::type_id::create("m_cfg_agt");
//apb sequence class instantiation.
paddr_grtr_mem_dep_sequ = apb_paddr_grtr_than_mem_depath_sequence::type_id::create("paddr_grtr_mem_dep_sequ");
  
endfunction:build_phase
                                                                          
virtual task run_phase(uvm_phase phase);
`uvm_info("UVM_TEST:apb_paddr_grtr_than_mem_depath_test6"," Run phase is started",UVM_MEDIUM)
super.run_phase(phase);
phase.raise_objection(this);
if(m_cfg_agt.is_active == UVM_ACTIVE) begin
paddr_grtr_mem_dep_sequ.start(apb_m_env.m_agt.m_seqr); 
end
phase.drop_objection(this); 
  phase.phase_done.set_drain_time(this,20);
endtask:run_phase
                                                                          
endclass:apb_paddr_grtr_than_mem_depath_test6






