CLASS zfmb_fill_so_84 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZFMB_FILL_SO_84 IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

 DATA: lt_vbak TYPE STANDARD TABLE OF zfmb_vbak,
       lw_vbak TYPE zfmb_vbak,
       lt_vbap TYPE STANDARD TABLE OF zfmb_vbap,
       lw_vbap TYPE zfmb_vbap,
       lv_index(3) type n,
       lv_posnr(6) TYPE n.

       DO 100 TIMES.
       add 1 to lv_index.

       CLEAR lw_vbak.

       lw_vbak-vbeln = lv_index.
       lw_vbak-erdat = sy-datum.
       lw_vbak-ernam = sy-uname.
       lw_vbak-auart = |A { lv_index }|.
       lw_vbak-waerk = 'USD'.
       lw_vbak-netwr = lv_index * 10.
       lw_vbak-vkorg = |V { lv_index }|.
       lw_vbak-spart = lv_index+1(2).

       clear lv_posnr.

       do 10 times.

       add 10 to lv_posnr.

       clear lw_vbap.
       lw_vbap-vbeln = lw_vbak-vbeln.
       lw_vbap-posnr = lv_posnr.
       lw_vbap-matnr = |M { lv_index }|.
       lw_vbap-matkl = |K { lv_index }|.
       lw_vbap-meins = 'UN'.
       lw_vbap-waerk = 'USD'.
       lw_vbap-netwr = lv_index * 10.
       lw_vbap-erdat = sy-datum.
       lw_vbap-ernam = sy-uname.
       lw_vbap-netpr = lv_index * 10.

       append lw_vbap to lt_vbap.

       enddo.

       APPEND lw_vbak TO lt_vbak.

       ENDDO.

       try.
       delete from zfmb_vbak.
       commit work and wait.
       endtry.

       try.
       delete from zfmb_vbap.
       commit work and wait.
       endtry.

       try.
       modify zfmb_vbak from table @lt_vbak.
       commit work and wait.
       endtry.

       try.
       modify zfmb_vbap from table @lt_vbap.
       commit work and wait.
       endtry.

       out->write( 'DONE!' ).

  ENDMETHOD.
ENDCLASS.
