


`define MNTR_IF m_vintf.monitor_mdp

class apb_master_monitor extends uvm_monitor;
  
   //factory registration.
`uvm_component_utils(apb_master_monitor)
  
  
//slave interface handle declaration.
 virtual apb_master_interface m_vintf;
  
    //apb slave transaction classs handle declaration
    apb_master_seq_item   trans_clctd;
  
  //uvm analysis port declaration
  uvm_analysis_port#(apb_master_seq_item) analysis_port;
  
 
//default new constructor.
  function new(string name,uvm_component parent);
    super.new(name,parent);
    `uvm_info("TRACE",$sformatf("%m"),UVM_HIGH)
    analysis_port = new ("analysis_port",this);
  endfunction:new
  

  
  virtual function void build_phase(uvm_phase phase);
  super.build_phase(phase);
  if(! uvm_config_db#(virtual apb_master_interface)::get(this," ","m_vintf",m_vintf)) begin
      `uvm_fatal("MASTER_MNTR_COFIG_FATAL"," First set the \" slv_vintf \" virtual apb_master_interface handle into config dg")
    end
  endfunction:build_phase
  
  
   virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
       wait( `MNTR_IF.preset_n);
     forever begin:forever_begin
    trans_clctd = apb_master_seq_item::type_id::create("trans_clctd");
    
       //wait(`MNTR_IF.pselx && `MNTR_IF.penable);
      
       wait(`MNTR_IF.pselx && `MNTR_IF.penable && `MNTR_IF.pready );
       
        @(negedge `MNTR_IF.pclk);
       
       if(`MNTR_IF.pselx && `MNTR_IF.penable && `MNTR_IF.pready) begin:collection_start
       
       if(apb_master_seq_item::WRITE == `MNTR_IF.pwrite) begin:write_collection
       trans_clctd.pselx=`MNTR_IF.pselx;
       trans_clctd.penable=`MNTR_IF.penable;
       trans_clctd.paddr=`MNTR_IF.paddr;  
       trans_clctd.pwrite=`MNTR_IF.pwrite;
       trans_clctd.pwdata=`MNTR_IF.pwdata;
      // trans_clctd.prdata=`MNTR_IF.prdata;
       trans_clctd.pready = `MNTR_IF.pready;
       trans_clctd.pslverr=`MNTR_IF.pslverr;
       `uvm_info("MASTER_MNTR_RUN",$sformatf("WRITE COLLECTION \n %0s",trans_clctd.sprint()),UVM_DEBUG)
       analysis_port.write(trans_clctd);
       end:write_collection
       
       if(apb_master_seq_item::READ == `MNTR_IF.pwrite) begin:read_collection
       trans_clctd.pselx=`MNTR_IF.pselx;
       trans_clctd.penable=`MNTR_IF.penable;
       trans_clctd.paddr=`MNTR_IF.paddr;  
       trans_clctd.pwrite=`MNTR_IF.pwrite;
       trans_clctd.prdata=`MNTR_IF.prdata;
       //trans_clctd.pwdata=`MNTR_IF.pwdata;
       trans_clctd.pready = `MNTR_IF.pready;
       trans_clctd.pslverr=`MNTR_IF.pslverr;
         `uvm_info("MASTER_MNTR_RUN",$sformatf("READ COLLECTION \n %0s",trans_clctd.sprint()),UVM_DEBUG)
      analysis_port.write(trans_clctd);
         end:read_collection 
         
       end:collection_start
       

      
       
    end:forever_begin
     
endtask:run_phase
  
endclass:apb_master_monitor