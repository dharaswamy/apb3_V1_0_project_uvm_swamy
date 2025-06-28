
class apb_master_environment extends uvm_env;

  //factory registration
`uvm_component_utils(apb_master_environment)
  
// apb maste config agent class handle declaration.
 apb_master_config_agent m_cfg_agt;

// apb master agent class handle declaration.
apb_master_agent m_agt;

//apb scoreboard class handle declaration.
apb_scoreboard apb_scb;
  
//apb functional coverage class handle declaration.
apb_functional_coverage apb_fc;
  

  function new(string name,uvm_component parent);
    super.new(name,parent);
    `uvm_info("TRACE",$sformatf("%m"),UVM_HIGH)
  endfunction:new
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_cfg_agt = apb_master_config_agent::type_id::create("m_cfg_agt");
  //m_cfg_agt is pass to lower lever components
    uvm_config_db#(apb_master_config_agent)::set(this,"*","m_cfg_agt",m_cfg_agt);
  //master agent class instantiation
    m_agt = apb_master_agent::type_id::create("m_agt",this);
    //apb scoreboard class instantiation
    apb_scb = apb_scoreboard::type_id::create("apb_scb",this);
    //abp functional coverage instantiation
    apb_fc = apb_functional_coverage::type_id::create("apb_fc",this); 
  endfunction:build_phase
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    m_agt.analysis_port.connect(apb_scb.analysis_import);
    m_agt.analysis_port.connect(apb_fc.analysis_import);
  endfunction:connect_phase
 
  
endclass:apb_master_environment