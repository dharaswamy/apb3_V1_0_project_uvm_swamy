//apb assertion based verification include cover property;

module apb_assertion_module(pclk,preset_n,pselx,penable,pready,paddr,pwrite,pwdata,prdata,pslverr);

input pclk;
input preset_n;
input pselx;
input penable;
input pready;
input [31:0] paddr;
input pwrite;//if pwrite=1 write operation and if pwrite= 0 read operation.
input [31:0] pwdata;
input [31:0] prdata;
input pslverr;
  

`define TYPE_ID_FOR_APB_ASSRTNS  "APB_ASSERTION_MODULE"


//----------------------------------------------------------------------------
  
//sequence for the idle state behaviour ,we know "apb" psel=0,penable=0;
  
sequence idle_state_sequ();
((!pselx) && (!penable));
endsequence:idle_state_sequ
  
//for set_up_state of the "apb" you know that in stepup state the pselx=1,penable=0,pready=0.
  
sequence setup_state_sequ();
($rose(pselx) && (!penable) && (!pready));   
endsequence:setup_state_sequ
  
//sequence for the access_state of the "apb" you know that in the access state the
//pselx,pwrite,pwdata,paddr all are stable upto the pready comes.
sequence access_state_sequ();
  ($rose(penable) && $stable(pselx) && $stable(pwrite) && $stable(paddr) && $stable(pwdata));   
endsequence:access_state_sequ

//--------------------------------------------------------------------------------------------------------------
  
//property1:checking the apb protocol states flow idle state->setup_state->access_state->(idle_state || setup_state).  
  
property apb_states_transition_prpty();
@(posedge pclk) disable iff(!preset_n)//active low reset.
  (idle_state_sequ) |=> setup_state_sequ ##1 access_state_sequ ##[0:$] pready ##1 ((idle_state_sequ) or (pselx && $fell(penable)));  
endproperty:apb_states_transition_prpty
  
assrt_apb_states_transition_prpty:assert property(apb_states_transition_prpty)
  `uvm_info(`TYPE_ID_FOR_APB_ASSRTNS,"\n============ASSERTION IS PASSED:\"Property Name: apb_states_transition_prpty \"===================",UVM_NONE)
else begin
`uvm_error(`TYPE_ID_FOR_APB_ASSRTNS,$sformatf("\n ===========================ASSERTION FAILED THE PROPERTY NAME: \" apb_states_transition_prpty \" \n =============IN APB PROTOCOL STATES TRANSITION FORM IDLE TO SETUP TO ACCESS TO (IDLE OR STEUP STATE) BUT IT IS  NOT WORKING ACCORDING TO THE SPECIFICATION================= \n =====================SO DEBUG THIS ERROR BE CAREFULLY===================")); 
end
  
//----------------------------------------------------------------------------------------------------
  
//checking the protocol rules violation for the transition of state from  idle state to access state directly.
  
property apb_idle_to_access_state_transition();
  @(posedge pclk) disable iff(! preset_n)
  idle_state_sequ |=> ( ($rose(pselx))&&(!$rose(penable) )); //doubt is there.
endproperty:apb_idle_to_access_state_transition
  
assrt_apb_idle_to_access_state_transition:assert property(apb_idle_to_access_state_transition)
  else `uvm_error(`TYPE_ID_FOR_APB_ASSRTNS,"\n ----------------------------------------------------ASSERTION FAILED-----------------------------------------------------------------\n---------Property Name:apb_idle_to_access_state_transition is FAILED \"(its directly state transition from idle to access state) \" \n --------------------- SO APB PROTOCOL STATE TRANSTION NOT WORKING ACCORDING TO SPECIFICATION DOCUMENT SO DEBUD IT -------\n--------------------------------------------------------------------------------------------------------------------------------------");

  
  
//-------------------------------------------------------------------------------------------------
  
//property: for checking the stable values of all variables until pready comes high.
// property apb_stable_values_property();
// @(posedge pclk) disable iff(!preset_n)//active low reset.
//   idle_state_sequ |=> setup_state_sequ ##1 access_state_sequ ##0  ($stable(pselx)) until $rose(pready);
// endproperty:apb_stable_values_property
  
  
// assrt_apb_stable_values_propety:assert property(apb_stable_values_property)
// `uvm_info("APB_ASSRT",$sformatf("\n --\" ASSERTON IS PASSED Property Name: apb_stable_values_property \" sampled values of pselx=%0b penable=%0b pwrite=%0b paddr=%0h pwdata=%0h",$sampled(pselx),$sampled(penable),$sampled(pwrite),$sampled(paddr),$sampled(pwdata)),UVM_NONE);
                                
//----------------------------------------------------------------------------------------------------                               
            
//if pselx =1 then next clock cyce penabl=1 should.
            
property apb_pselx_fwd_nxt_cycle_penable_prpty();
@(posedge pclk) disable iff(! preset_n)
$rose(pselx) |=> $rose(penable);
endproperty:apb_pselx_fwd_nxt_cycle_penable_prpty
            
assrt_apb_pselx_fwd_nxt_cycle_penable_prpty:assert property(apb_pselx_fwd_nxt_cycle_penable_prpty)
`uvm_info(`TYPE_ID_FOR_APB_ASSRTNS,$sformatf("\n---->>>> ASSERTION PASSED ,THE PROPERTY NAME:\"apb_pselx_fwd_nxt_cycle_penable_prpty \" sampled values pslex=%0b,penable=%0b-->>>> ",$sampled(pselx),$sampled(penable)),UVM_NONE)
else  `uvm_error(`TYPE_ID_FOR_APB_ASSRTNS,$sformatf( "\n-----------------------------------------ASSERTION FAILED-----------------------------------\n ---------PROPERTY NAME: \" apb_pselx_fwd_nxt_cycle_penable_prpty \" sampled values $sampled(pselx)=%b $sampled(penable)=%b------------ ",$sampled(pselx),$sampled(penable))); 
  
cover_apb_pselx_fwd_nxt_cycle_penable_prpty:cover property(apb_pselx_fwd_nxt_cycle_penable_prpty);

  
//------------------------------------------------------------------------------------------------------------
  
property apb_signals_changing_x_z_prpty();
@ (posedge pclk) disable iff(! preset_n) //active low reset.
  ( (!$isunknown(pselx)) && (!$isunknown(penable)) && (!$isunknown(pwrite)) && (!$isunknown(paddr)) && (!$isunknown(pwdata)) && (!$isunknown(prdata)) && (!$isunknown(pslverr)));
 endproperty:apb_signals_changing_x_z_prpty
  
//all signals not changing to the unknown/high impendace values.
assrt_apb_signals_changing_x_z_prpty:assert property(apb_signals_changing_x_z_prpty)
else `uvm_error(`TYPE_ID_FOR_APB_ASSRTNS,$sformatf("\n ---->>>>>---->>>>>>--->>>>>>ASSERATION FAILED PROPERTY NAME:\" apb_signals_changing_x_z_prpty\" ----<<<<<---<<<<<----<<<<<-\n ------------sampled values pselx=%0b ,penable=%0b,pwrite=%0b,paddr=%b,pwdata=%b,prdata=%b,pslverr=%0b------------",$sampled(pselx),$sampled(penable),$sampled(pwrite),$sampled(paddr),$sampled(pwdata),$sampled(prdata),$sampled(pslverr)));
  
  
cover_apb_signals_changing_x_z_prpty:cover property(apb_signals_changing_x_z_prpty);
  
//---------------------------------------------------------------------------------------------------------
  
  
endmodule:apb_assertion_module
  