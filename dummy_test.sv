// this test for inst override checking : doubt there

class dummy_test extends apb_base_test;

//factory registration
`uvm_component_utils(dummy_test) 

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
  //factory.set_inst_override_by_name("apb_master_seq_item", "dummy", "*");
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

endclass:dummy_test
