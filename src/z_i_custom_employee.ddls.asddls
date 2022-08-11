@EndUserText.label: 'Custom Employee'

@ObjectModel.query.implementedBy: 'ABAP:ZCL_CUSTOM_EMPLOYEE'
@UI: {
  headerInfo: {
    typeName: 'Custom Employee', 
    typeNamePlural: 'Custom Employees', 
    title: {
      type: #STANDARD, 
      label: 'Custom Employee', 
      value: 'e_number'
    }
  }
, 
  presentationVariant: [ {
    sortOrder: [ {
      by: 'e_number', 
      direction: #DESC
    } ], 
    visualizations: [ {
      type: #AS_LINEITEM
    } ]
  } ]
}

define root custom entity Z_I_CUSTOM_EMPLOYEE 
{

    //Employee  
  key client     : abap.clnt ;
  
   @UI.facet: [{ id: 'Employees',
  purpose: #STANDARD,
  type: #IDENTIFICATION_REFERENCE,
  label: 'Employee',
  position: 10 }]
  @Search.defaultSearchElement: true
  @UI: {
  lineItem: [{ position: 10, label: 'Employee
Number', importance: #HIGH },
{ type: #FOR_ACTION, dataAction: 'CompleteEMP', label: 'Complete Employee', position: 10 }
],
  identification: [{ position: 10, label:
  'Employee Number' }] }
  key e_number   : sysuuid_x16;
  
  @UI: {
  lineItem: [{ position: 20, label: 'Employee Name',
  importance: #HIGH }],
  identification: [{ position: 20, label: 'Employee
Name' }],
  selectionField: [{ position: 10 }] }
  e_name         : abap.char(40);
  
   @UI: {
  lineItem: [{ position: 20, label: 'Employee
Department', importance: #HIGH }],
  identification: [{ position: 20, label: ' Employee
Department' }],
  selectionField: [{ position: 20 }] }
  e_department   : abap.numc(8);
  
  @UI: {
  lineItem: [{ position: 30, label: 'Status',
  importance: #HIGH }],
  identification: [{ position: 30, label: 'Status'
  }] }
  status         : abap.char(1);
  
  @UI: {
  lineItem: [{ position: 40, label: 'Job Title',
  importance: #MEDIUM }],
  identification: [{ position: 40, label: 'Job
Title' }],
  selectionField: [{ position: 30 }] }
  job_title      : abap.numc(8);
  
   @UI: {
  lineItem: [{ position: 50, label: 'Start Date',
  importance: #LOW }],
  identification: [{ position: 50, label: 'Start
Date' }] }
  start_date     : abap.dats;
  
  @UI: {
  lineItem: [{ position: 60, label: 'End Date',
  importance: #LOW }],
  identification: [{ position: 60, label: 'End Date'
  }] }
  end_date       : abap.dats;
  
  @UI: {
  lineItem: [{ position: 70, label: 'Email',
  importance: #MEDIUM }],
  identification: [{ position: 70, label: 'Email' }]
  }
  email          : abap.char(60);
  
   @UI: {
  lineItem: [{ position: 80, label: 'Manager
Number', importance: #HIGH }],
  identification: [{ position: 80, label: 'Manager
Number' }] }
  m_number       : abap.numc(8);
  
  @UI: {
  lineItem: [{ position: 90, label: 'Manager Name',
  importance: #HIGH }],
  identification: [{ position: 90, label: 'Manager
Name' }] }
  m_name         : abap.char(40);
  
   @UI: {
  lineItem: [{ position: 100, label: 'Manager
Department', importance: #MEDIUM }],
  identification: [{ position: 100, label: ' Manager
Department' }] }
  m_department   : abap.numc(8);
  
  @UI.hidden: true
  crea_date_time : timestampl;
  
  @UI.hidden: true
  crea_uname     : syuname;
  
  @UI.hidden: true
  lchg_date_time : timestampl;
  
  @UI.hidden: true
  lchg_uname     : syuname;    
    
}
