//25,40,80,200(hexa:19,28,50,c8) wirte only locations.
//60,70,90,255(hexa:3c,46,5a,ff) read only locations.
 

class apb_functional_coverage extends uvm_subscriber#(apb_master_seq_item);
 
//factory registration
`uvm_component_utils(apb_functional_coverage)
  
//analysis import declaration.
uvm_analysis_imp#(apb_master_seq_item,apb_functional_coverage) analysis_import;
//apb master transaction class handle declaration.
apb_master_seq_item pkt;
//virtaul interface handle declaration.
virtual apb_master_interface m_vintf;
  

  
  virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
 if(! uvm_config_db#(virtual apb_master_interface)::get(this," ","m_vintf",m_vintf) ) begin
 `uvm_fatal(get_name(),$sformatf(" virtaul apb_master_interface \" m_vintf \" was not set in configaration database for %0s",get_full_name()));
 end
 endfunction:build_phase
  
//coverage group for the apb 
  covergroup  apb_cgp(string instance_name);
option.per_instance=1;
option.name=instance_name;
pselx_covp:coverpoint pkt.pselx;
penable_covp:coverpoint pkt.penable;
paddr_covp: coverpoint pkt.paddr{bins very_low_adr   = {[0:15]};//4bit
                                   bins   low_adr      ={[16:255]};//8bit
                                   bins medium_adr     ={[256:1024]}; //10  bit
                                   bins  high_adr      ={[1025:4096]};//
                                   bins very_high_adr  ={[4095:16384]};//
                                   bins ultra_high_adr ={[16385:65535]};//
                                   ignore_bins addr_grtr_65535={[65536:$]}; }//
pwrite_covp:coverpoint pkt.pwrite;
pwdata_covp:coverpoint pkt.pwdata;
pready_covp:coverpoint pkt.pready;
pslverr_covp:coverpoint pkt.pslverr;
prdata_covp:coverpoint pkt.prdata;

pwr_padr_cross:cross pwrite_covp,paddr_covp;

endgroup:apb_cgp
  
//this covergroup just monitor the togling of the signals pselx,penable,pready,pslverr.
  covergroup   apb_tggling_and_transition_cgp(string instance_name);
    option.per_instance=1;
    option.name=instance_name;
    cvp_taggle_nd_transition_pselx: coverpoint m_vintf.pselx{ 
                                                bins pselx_low={0};
                                                bins pselx_low_to_high_transition=(0=>1);
                                                bins pselx_high_to_low_transition_wait_state1=(1=>1=>0);
                                                bins pselx_high_to_low_transition_wait_state2=(1=>1=>1=>0);
                                                bins pselx_high_to_low_transition_wait_state3=(1=>1=>1=>1=>0);}
    
    cvp_taggle_nd_transition_penable:coverpoint m_vintf.penable{
                                                  bins penable_low={0};
                                                  bins penable_low_to_high_transition=(0=>1);
                                                  bins penable_high_to_low_transition=(1=>0);
                                                  bins penable_high_to_low_transition_wait_state1=(1=>1=>0);
                                                  bins penable_high_to_low_transition_wait_state2=(1=>1=>1=>0);
                                                  bins penable_high_to_low_transition_wait_state3=(1=>1=>1=>1=>0);
                                                  }
    
    cvp_taggle_nd_transition_pready:coverpoint m_vintf.pready{
                                                bins pready_low={0};
                                                bins pready_low_to_high_transition=(0=>1);
                                                bins pready_high_to_low_transition=(1=>0);
                                                }
 
endgroup:apb_tggling_and_transition_cgp
  
 
  
//default constructor
  function new(string name ,uvm_component parent);
    super.new(name,parent);
    analysis_import = new("analysis_import",this);
    apb_cgp=new("apb_cgp");
    apb_tggling_and_transition_cgp=new("apb_tggling_and_transition_cgp");
    `uvm_info("TRACE",$sformatf("%m"),UVM_HIGH)
  endfunction:new
    

  //WRITE METHOD
virtual function void write(apb_master_seq_item   t);
      pkt = t;
    `uvm_info(get_name(),$sformatf(" APB FUNCTIONAL UNIT GOT THE PKT FROM THE APB MASTER MONITOR \n %0S",pkt.sprint()),UVM_DEBUG)
  apb_cgp.sample();//sampling the apb_cgp covergroup.
  endfunction:write

//calling the run_phase
  
virtual task run_phase(uvm_phase phase);
  super.run_phase(phase);
  forever begin:forever_end
  //`uvm_info("FUNCTIONAL-COVERAGE_DEBUG","ENTERED INTO THE RUN_PHASE",UVM_NONE);
  @(negedge m_vintf.pclk);
 // `uvm_info("FUNCTIONAL-COVERAGE_DEBUG","AFTER NEGEDGE IN THE RUN PHASE ",UVM_NONE);
apb_tggling_and_transition_cgp.sample(); 
  end:forever_end
endtask:run_phase
  
endclass:apb_functional_coverage


