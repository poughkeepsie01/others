CREATE OR REPLACE PACKAGE BODY APPS.TIPEHDPIPROC010 IS
/**********************************************************************************************************************************
*
*  Package Name :  TIPEHDPIPROC010
*  Description  :  EHD Physical Inventory Regist to Linedata Processing to Count
*  Version      :  2.00
*
*  Program List
*  ------------------------  ----------    ---------      ----------------------------------------------
*          Name                 Type           Ret          Description
*  ------------------------  ----------    ---------      ----------------------------------------------
*   PROC_REG_LINE_MAIN           P                          BOM Explosion for Regist Data to Line Data
*   PROC_UPD_PKG_MAT_TRANS       P                          Update of Packaging Materials in Line Data
*   PROC_REG_LINE_TRANS          P                          Transfer and Explode Regist Data to Line Data
*   PROC_HSA_LINE_EXPL           P                          Explode and Update HSA in Line Data
*   PROC_REG_LINE_MAIN           P                          Transfer Group Line Data to Count Data
*   PROC_CHECK_ITEM_SETUP        P                          Checking and update flag of items in regist w/o setup MSI,BOM
*   PROC_INS_BOM_REP             P                          Insert BOM REP in Regist data
*   PROC_FGIS_REG_COUNT          P                          Transfer FGIS data to Count Data Snapshot
*   PROC_INS_CATEGORY            P                          Transfer FGIS data to Count Data Snapshot
*
*  Change Record
*  -----------------------     ----------     ------------------    ----------------------------------------------
*           Date                  Ver.            Editor                 Description
*  -----------------------     ----------     ------------------    ----------------------------------------------
*       07-MAY-2019               4.01            N.Roberto             Newly created(v4.01)
*       04-DEC-2019               4.02            K.Solas               Enhancement(v4.02)
*                                                                       Added Procedure checking of MSI and BOM Setup in regist
*                                                                       Added FGIS Tag num in REG to LINE TRANS
*                                                                       Added FGIS Tag num in packg mat
*                                                                       Added Procedure Insertion of BOM REP in regist
*       15-JUN-2020               4.03           P.Abello               Enhancement (v4.03)
*                                                                       Added validation for Asyy Tyoe mismatch in Regist Data
*                                                                       Remove hardcoded values in insert script for HSA Explosion
*       09-JUN-2021               4.04           P.Abello               Added Function FGIS Regist to Count Program (v4.04)
*                                                                       Added Function to insert raw materials category during Auto Count explosion program
*       07-DEC-2021               4.05           R. De Villa            Development of EHD PI Actual PCBA capturing from EIDEA (v4.05)

*       25-OCT-2023               4.06           A. Santos                Consider SPM Assy type to include in TIP_PHYSICAL_INVENTORY_COUNT data.
***********************************************************************************************************************************/


--=============================================
-- DECLARATION OF INSIDE PROCEDURE/FUNCTION
--=============================================

PROCEDURE    PROC_REG_LINE_TRANS(
             iv_assy_hda    IN     VARCHAR2
            ,iv_assy_sfg    IN     VARCHAR2
-- Add start Lib_ver.4.06
            ,iv_assy_spm    IN     VARCHAR2
-- Add end Lib_ver.4.06
            ,iv_user_id     IN     NUMBER
            ,iv_org_id      IN     NUMBER
            ,iv_tag_number  IN     VARCHAR2 -- Add Start Lib_ver.4.02 add tag number
            ,iv_pcba_group  IN     VARCHAR2 -- Add Start Lib_ver.4.05
            ,iv_tagnot_xcld IN     VARCHAR2 -- Add Start Lib_ver.4.05
            ,o_ins_cnt      OUT    NUMBER
            ,o_upd_cnt      OUT    NUMBER
);

PROCEDURE    PROC_HSA_LINE_EXPL(
             iv_assy_hsa    IN     VARCHAR2
            ,iv_user_id     IN     NUMBER
            ,iv_org_id      IN     NUMBER
            ,o_ins_cnt      OUT    NUMBER
            ,o_upd_cnt      OUT    NUMBER
);

PROCEDURE  PROC_LINE_COUNT_MAIN(
            iv_physinv_id    IN    NUMBER                   --physical inventory id
           ,iv_user_id       IN    NUMBER                   --user id
           ,iv_subinventory  IN    VARCHAR2                 --subinventory
           ,o_ins_cnt        OUT   NUMBER                   --inserted count
           ,o_err_cnt        OUT   NUMBER                   --error count
);
PROCEDURE PROC_CHECK_ITEM_SETUP(
             iv_assy_hda    IN     VARCHAR2
            ,iv_assy_sfg    IN     VARCHAR2
            ,iv_code_hde    IN     VARCHAR2 --Add Start Lib_ver.4.03
-- Add start Lib_ver. 4.06
            ,iv_assy_spm    IN     VARCHAR2
-- Add end Lib_ver. 4.06
            ,iv_user_id     IN     NUMBER
            ,iv_org_id      IN     NUMBER
            ,iv_tag_number  IN     VARCHAR2
            ,o_no_msi_cnt   OUT    VARCHAR2
            ,o_no_bom_cnt   OUT    VARCHAR2
            ,o_ng_assy_type OUT    VARCHAR2    --Add Start Lib_ver.4.03
);
--Add start Lib_ver.4.04
PROCEDURE  PROC_FGIS_REG_COUNT
        (
            p_org_id               NUMBER
           ,p_physinv_id           NUMBER   DEFAULT NULL
           ,p_excld_process        VARCHAR2
           ,p_fg_tag               VARCHAR2
           ,o_ins_cnt       OUT    VARCHAR2
           ,o_rga_cnt       OUT    VARCHAR2
           ,o_error_cnt     OUT    VARCHAR2
        );
--Add end Lib_ver.4.04
--=====================================
-- MAIN MODULE
--=====================================
PROCEDURE  PROC_REG_LINE_MAIN
        (
            ov_errbuf    OUT   VARCHAR2 --error message
           ,ov_retcode   OUT   VARCHAR2 --return code
           ,p_process_id       NUMBER --process type
           ,p_org_id           NUMBER --organization id
           ,l_process_type     VARCHAR2 DEFAULT NULL
           ,p_physinv_id       NUMBER   DEFAULT NULL --physical inventory id
        )
IS
--=====================================
-- DECLARATION OF  LOCAL WORK VARIABLE
--=====================================

    --TIME VARIABLE
    WK_START_TIME       VARCHAR2(20);
    WK_END_TIME         VARCHAR2(20);

    --USER, ORGANIZATION, PROCESS TYPE VARIABLE
    WK_USER_ID          NUMBER;
    WK_ORG_ID           NUMBER;
    WK_PROCESS_TYPE_ID  NUMBER;

    --ASSEMBLY VARIABLE
    WK_ASSY_CODE_HDA    VARCHAR2(3);
    WK_ASSY_CODE_SFG    VARCHAR2(3);
    WK_ASSY_CODE_HSA    VARCHAR2(3);
-- Add start Lib_ver.4.06
    WK_ASSY_CODE_SPM    VARCHAR2(3);
-- Add end Lib_ver.4.06
    WK_TAG_NUMBER       VARCHAR2(40);  -- Added Lib_ver.4.02
    WK_ASSY_CODE_HDE    VARCHAR2(3);  --Add Start Lib_ver.4.03
    WK_PCBA_GROUP       VARCHAR2(100);  -- Added Lib_ver.4.05
    WK_TAGNOT_XCLD      VARCHAR2(100);  -- Added Lib_ver.4.05

    --PHYSICAL INVENTORY VARIABLE
    WK_PHYS_SUBINV_NAME VARCHAR2(40);
    WK_PHYSINV_ID       NUMBER;

    --COUNT VARIABLE
    WK_INS_CNT          NUMBER;
    WK_UPD_CNT          NUMBER;
    WK_ERR_CNT          NUMBER;
    WK_EXIST_COUNT      NUMBER;
    WK_REGIST_COUNT     NUMBER;
    WK_HSA_COUNT        NUMBER;
    WK_NO_MSI_CNT       NUMBER;
    WK_NO_BOM_CNT       NUMBER;
    WK_NG_ASSY_TYPE     NUMBER; -- Add Start Lib_Ver.4.03

    -- Add start Lib_Ver.4.04
    WK_INS_CNT1         NUMBER;
    WK_RGA_CNT          NUMBER;
    WK_ERR_CNT1         NUMBER;
    WK_FG_EX_PROCESS    VARCHAR2(50);
    WK_FG_TAG_NUM       VARCHAR2(50);
    -- Add end Lib_Ver.4.04

    --ERROR VARIABLE
    WK_SQLCODE          NUMBER;
    WK_SQLERRM          VARCHAR2(4000);
    WK_MESSAGE          VARCHAR2(2000);


BEGIN
    --ASSIGN START TIME
    WK_START_TIME    :=    TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS');

    --ASSIGN INPUT VARIABLE
    WK_USER_ID := fnd_global.USER_ID;
    WK_ORG_ID  := P_ORG_ID;
    WK_PROCESS_TYPE_ID := P_PROCESS_ID;
    WK_PHYSINV_ID := P_PHYSINV_ID;

    --CHECKING OF REGIST DATA
    BEGIN
        SELECT COUNT(*)
        INTO WK_REGIST_COUNT
        FROM TIPEHDD_PHYSINV_REGISTDATA_IF
        WHERE PROCESS_FLAG = 0;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            fnd_file.put_line(fnd_file.output,'Completed with errors.');
            fnd_file.put_line(fnd_file.output,'Message     = ' ||'No data was found in REGIST DATA Interface');
            ov_errbuf    := WK_SQLERRM;
            ov_retcode   := 2;
    END;

    --CHECKING OF SETUP FOR ASSEMBLY TYPE HDA IN TIP_DEFAULT_VALUES
    BEGIN
        SELECT DEFAULT_VALUE
        INTO WK_ASSY_CODE_HDA
        FROM TIP_DEFAULT_VALUES
        WHERE TABLE_NAME LIKE 'TIP_EHD_PHYSICAL_INVENTORY'
        AND FIELD_NAME = 'ITEM_TYPE'
        AND ADDITIONAL_KEY = 'XXMFG_HDA'
        AND ORGANIZATION_ID = P_ORG_ID;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            fnd_file.put_line(fnd_file.output,'Completed with errors.');
            fnd_file.put_line(fnd_file.output,'Message     = ' ||'Kindly check setup of Item Type(HDA) in TIP Default Values');
            ov_errbuf    := WK_SQLERRM;
            ov_retcode   := 2;
    END;
-- Add start Lib_ver.4.06
    BEGIN
        SELECT DEFAULT_VALUE
        INTO WK_ASSY_CODE_SPM
        FROM TIP_DEFAULT_VALUES
        WHERE TABLE_NAME LIKE 'TIP_EHD_PHYSICAL_INVENTORY'
        AND FIELD_NAME = 'ITEM_TYPE'
        AND ADDITIONAL_KEY = 'XXMFG_SPM'
        AND ORGANIZATION_ID = P_ORG_ID;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            fnd_file.put_line(fnd_file.output,'Completed with errors.');
            fnd_file.put_line(fnd_file.output,'Message     = ' ||'Kindly check setup of Item Type(SPM) in TIP Default Values');
            ov_errbuf    := WK_SQLERRM;
            ov_retcode   := 2;
    END;
-- Add end Lib_ver.4.06
    --CHECKING OF SETUP FOR ASSEMBLY TYPE SFG IN TIP_DEFAULT_VALUES
    BEGIN
       SELECT DEFAULT_VALUE
       INTO WK_ASSY_CODE_SFG
       FROM TIP_DEFAULT_VALUES
       WHERE TABLE_NAME LIKE 'TIP_EHD_PHYSICAL_INVENTORY'
       AND FIELD_NAME = 'ITEM_TYPE'
       AND ADDITIONAL_KEY = 'XXMFG_SFG'
       AND ORGANIZATION_ID = P_ORG_ID;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            fnd_file.put_line(fnd_file.output,'Completed with errors.');
            fnd_file.put_line(fnd_file.output,'Message     = ' ||'Kindly check setup of Item Type(SFG) in TIP Default Values');
            ov_errbuf    := WK_SQLERRM;
            ov_retcode   := 2;

    END;

    --CHECKING OF SETUP FOR ASSEMBLY TYPE HSA IN TIP_DEFAULT_VALUES
    BEGIN
        SELECT DEFAULT_VALUE
        INTO WK_ASSY_CODE_HSA
        FROM TIP_DEFAULT_VALUES
        WHERE TABLE_NAME LIKE 'TIP_EHD_PHYSICAL_INVENTORY'
        AND FIELD_NAME = 'ITEM_TYPE'
        AND ADDITIONAL_KEY = 'XXMFG_HSA'
        AND ORGANIZATION_ID = P_ORG_ID;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            fnd_file.put_line(fnd_file.output,'Completed with errors.');
            fnd_file.put_line(fnd_file.output,'Message     = ' ||'Kindly check setup of Item Type(HSA) in TIP Default Values');
            ov_errbuf    := WK_SQLERRM;
            ov_retcode   := 2;
    END;

    --Add Start Lib_ver.4.03
    --CHECKING OF SETUP FOR ASSEMBLY TYPE HDE IN TIP_DEFAULT_VALUES
    BEGIN
        SELECT DEFAULT_VALUE
          INTO WK_ASSY_CODE_HDE
          FROM TIP_DEFAULT_VALUES
         WHERE     TABLE_NAME LIKE 'TIP_EHD_PHYSICAL_INVENTORY'
               AND FIELD_NAME = 'ITEM_TYPE'
               AND ADDITIONAL_KEY = 'XXMFG_HDE'
               AND ORGANIZATION_ID = P_ORG_ID;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            fnd_file.put_line(fnd_file.output,'Completed with errors.');
            fnd_file.put_line(fnd_file.output,'Message     = ' ||'Kindly check setup of Item Type(HDE) in TIP Default Values');
            ov_errbuf    := WK_SQLERRM;
            ov_retcode   := 2;
    END;
    --Add End Lib_ver.4.03

    -- Add Start Lib_ver.4.02 added FGIS tag number in REG to LINE TRANS
    --CHECKING OF SETUP OF %TAG_NUMBER IN TIP_DEFAULT_VALUES
    BEGIN
        SELECT DEFAULT_VALUE
        INTO WK_TAG_NUMBER
        FROM TIP_DEFAULT_VALUES
        WHERE TABLE_NAME LIKE 'TIP_EHD_PHYSICAL_INVENTORY'
        AND FIELD_NAME = 'TAG_NUMBER_TYPE'
        AND ADDITIONAL_KEY = 'TAG_NUM'
        AND ORGANIZATION_ID = P_ORG_ID;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
            fnd_file.put_line(fnd_file.output,'Completed with errors.');
            fnd_file.put_line(fnd_file.output,'Message     = ' ||'Kindly check setup of tag number (%TAG) in TIP Default Values');
            ov_errbuf    := WK_SQLERRM;
            ov_retcode   := 2;
    END;
      -- Add End Lib_ver.4.02 added FGIS tag number in REG to LINE TRANS

      -- Add Start Lib_ver.4.05
    --PCBA Exclusion identification based on MSI description
    BEGIN
        SELECT DEFAULT_VALUE
        INTO WK_PCBA_GROUP
        FROM TIP_DEFAULT_VALUES
        WHERE TABLE_NAME LIKE 'TIP_EHD_PHYSICAL_INVENTORY'
        AND FIELD_NAME = 'PCBA_GROUP'
        AND ADDITIONAL_KEY = 'EXCLUDE'
        AND ORGANIZATION_ID = P_ORG_ID;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
            fnd_file.put_line(fnd_file.output,'Completed with errors.');
            fnd_file.put_line(fnd_file.output,'Message     = ' ||'Kindly check setup of PCBA_GROUP in TIP Default Values');
            WK_PCBA_GROUP := NULL;
            ov_errbuf    := WK_SQLERRM;
            ov_retcode   := 2;
    END;


    BEGIN
        SELECT DEFAULT_VALUE
        INTO WK_TAGNOT_XCLD
        FROM TIP_DEFAULT_VALUES
        WHERE TABLE_NAME LIKE 'TIP_EHD_PHYSICAL_INVENTORY'
        AND FIELD_NAME = 'PCBA_GROUP'
        AND ADDITIONAL_KEY = 'NOT_EXCLUDE'
        AND ORGANIZATION_ID = P_ORG_ID;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
            fnd_file.put_line(fnd_file.output,'Completed with errors.');
            fnd_file.put_line(fnd_file.output,'Message     = ' ||'Kindly check setup of Tag number not to exclude in PCBA capturing in TIP Default Values');
            WK_TAGNOT_XCLD := NULL;
            ov_errbuf    := WK_SQLERRM;
            ov_retcode   := 2;
    END;
      -- Add End Lib_ver.4.05 added FGIS tag number in REG to LINE TRANS

    --CHECKING OF HSA COUNT DATA
      BEGIN
        SELECT COUNT(*)
        INTO WK_HSA_COUNT
        FROM TIPEHDD_PHYSINV_LINEDATA_IF
        WHERE PROCESS_FLAG = 0
        AND ITEM_CODE like '%'||WK_ASSY_CODE_HSA||'%';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            fnd_file.put_line(fnd_file.output,'Completed with errors.');
            fnd_file.put_line(fnd_file.output,'Message     = ' ||'No HSA data was found in LINE DATA Interface');
            ov_errbuf    := WK_SQLERRM;
            ov_retcode   := 2;
    END;

    --CHECKING OF SETUP FOR EHD SUBINVENTORY IN TIP_DEFAULT_VALUES
    BEGIN
        SELECT DEFAULT_VALUE
        INTO WK_PHYS_SUBINV_NAME
        FROM TIP_DEFAULT_VALUES
        WHERE TABLE_NAME LIKE 'TIP_EHD_PHYSICAL_INVENTORY'
        AND FIELD_NAME = 'PHYS_NAME'
        AND ADDITIONAL_KEY = 'SUBINVENTORY_NAME'
        AND ORGANIZATION_ID = P_ORG_ID;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            fnd_file.put_line(fnd_file.output,'Completed with errors.');
            fnd_file.put_line(fnd_file.output,'Message     = ' ||'Kindly check setup of Subinventory Name Setup in TIP Default Values');
            ov_errbuf    := WK_SQLERRM;
            ov_retcode   := 2;
    END;

    --VALIDATION OF PHYSICAL INVENTORY IF EXISTING IN TIP_PHYSICAL_INVENTORY_COUNT
    BEGIN
       SELECT COUNT(*)
       INTO WK_EXIST_COUNT
       FROM TIP_PHYSICAL_INVENTORY_COUNT
       WHERE PHYSICAL_INVENTORY_ID = WK_PHYSINV_ID;

           IF WK_EXIST_COUNT > 0 THEN
               WK_SQLCODE := SQLCODE;
               WK_SQLERRM := SQLERRM;
               fnd_file.put_line(fnd_file.output,'Completed with errors.');
               fnd_file.put_line(fnd_file.output,'Message     = ' ||'Cannot Transfer Linedata to Count. Please check Physical Inventory Name');
               ov_errbuf    := WK_SQLERRM;
               ov_retcode   := 2;
           END IF;
    END;

    --add start Lib_ver 4.04
     BEGIN
        SELECT DEFAULT_VALUE
        INTO WK_FG_EX_PROCESS
        FROM TIP_DEFAULT_VALUES
        WHERE TABLE_NAME LIKE 'TIP_EHD_PHYSICAL_INVENTORY'
        AND FIELD_NAME = 'PROCESS_FG'
        AND ADDITIONAL_KEY = 'EXCLUDE_PROCESS'
        AND ORGANIZATION_ID = P_ORG_ID;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
            fnd_file.put_line(fnd_file.output,'Completed with errors.');
            fnd_file.put_line(fnd_file.output,'Message     = ' ||'Kindly check setup of FG Exclude process in TIP Default Values');
            ov_errbuf    := WK_SQLERRM;
            ov_retcode   := 2;
    END;

    BEGIN
        SELECT DEFAULT_VALUE
        INTO WK_FG_TAG_NUM
        FROM TIP_DEFAULT_VALUES
        WHERE TABLE_NAME LIKE 'TIP_EHD_PHYSICAL_INVENTORY'
        AND FIELD_NAME = 'PROCESS_FG'
        AND ADDITIONAL_KEY = 'FG_TAG_NUM'
        AND ORGANIZATION_ID = P_ORG_ID;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
            fnd_file.put_line(fnd_file.output,'Completed with errors.');
            fnd_file.put_line(fnd_file.output,'Message     = ' ||'Kindly check setup of FG tag number (%TAG) in TIP Default Values');
            ov_errbuf    := WK_SQLERRM;
            ov_retcode   := 2;
    END;
    --add end Lib_ver 4.04

    --CHECK ASSIGNED PROCESS TYPE ID
    --Transfer Registdata to Linedata   =   1
    --HSA Explosion in Linedata         =   2
    --Transfer Linedata to Count        =   3
    --Checking ITEM setup               =   4
    IF WK_PROCESS_TYPE_ID = 1 THEN
        --PROCEDURE FOR TRANSFER REGISTDATA TO LINEDATA
        PROC_REG_LINE_TRANS(WK_ASSY_CODE_HDA
                           ,WK_ASSY_CODE_SFG
-- Add start Lib_ver.4.06
                           ,WK_ASSY_CODE_SPM
-- Add end Lib_ver.4.06
                           ,WK_USER_ID
                           ,WK_ORG_ID
                           ,WK_TAG_NUMBER -- Added Lib_ver.4.02
                            ,WK_PCBA_GROUP -- Added Lib_ver.4.05
                           ,WK_TAGNOT_XCLD -- Added Lib_ver.4.05
                           ,WK_INS_CNT
                           ,WK_UPD_CNT);
        --ASSIGN END TIME
        WK_END_TIME    :=    TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS');

        --RE-CHECKING OF REGIST DATA WITH PROCESS FLAG IS ZERO
        BEGIN
            SELECT COUNT(*)
            INTO WK_REGIST_COUNT
            FROM TIPEHDD_PHYSINV_REGISTDATA_IF
            WHERE PROCESS_FLAG = 0;
                IF WK_REGIST_COUNT <> WK_UPD_CNT THEN
                    fnd_file.put_line(fnd_file.output,'Kindly Re-run Transfer Registdata to Linedata');
                END IF;
        END;

        --OUTPUT RESULT OF TRANSFER REGISTDATA TO LINEDATA
        fnd_file.put_line(fnd_file.output,'----------TIP EHD PHYSICAL INVENTORY PROCESSING INFORMATION----------');
        fnd_file.put_line(fnd_file.output,'--');
        fnd_file.put_line(fnd_file.output,'---NORMALLY COMPLETED');
        fnd_file.put_line(fnd_file.output,'--');
        fnd_file.put_line(fnd_file.output,'---EXECUTE TIME');
        fnd_file.put_line(fnd_file.output,'--   START : '||WK_START_TIME);
        fnd_file.put_line(fnd_file.output,'--   END   : '||WK_END_TIME);
        fnd_file.put_line(fnd_file.output,'--');
        fnd_file.put_line(fnd_file.output,'--------- TRANSFER REGISDATA TO LINEDATA -------------------');
        fnd_file.put_line(fnd_file.output,'--  Record count in REGISTDATA       = '|| WK_REGIST_COUNT);
        fnd_file.put_line(fnd_file.output,'--  Record(s) inserted to LINEDATA   = '|| WK_INS_CNT);
        fnd_file.put_line(fnd_file.output,'--  Record(s) updated in REGISTDATA  = '|| WK_UPD_CNT);
        fnd_file.put_line(fnd_file.output,'--');
        fnd_file.put_line(fnd_file.output,'---------------------------------------------------------------------');
    ELSIF WK_PROCESS_TYPE_ID = 2 THEN
        --PROCEDURE FOR HSA EXPLOSION IN LINEDATA
        PROC_HSA_LINE_EXPL(WK_ASSY_CODE_HSA
                          ,WK_USER_ID
                          ,WK_ORG_ID
                          ,WK_INS_CNT
                          ,WK_UPD_CNT);

        --ASSIGN END TIME
        WK_END_TIME    :=    TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS');

        --OUTPUT RESULT OF HSA EXPLOSION IN LINEDATA
        fnd_file.put_line(fnd_file.output,'----------TIP EHD PHYSICAL INVENTORY PROCESSING INFORMATION----------');
        fnd_file.put_line(fnd_file.output,'--');
        fnd_file.put_line(fnd_file.output,'---NORMALLY COMPLETED');
        fnd_file.put_line(fnd_file.output,'--');
        fnd_file.put_line(fnd_file.output,'---EXECUTE TIME');
        fnd_file.put_line(fnd_file.output,'--   START : '||WK_START_TIME);
        fnd_file.put_line(fnd_file.output,'--   END   : '||WK_END_TIME);
        fnd_file.put_line(fnd_file.output,'--');
        fnd_file.put_line(fnd_file.output,'--------- HSA EXPLOSION IN LINEDATA -------------------');
        fnd_file.put_line(fnd_file.output,'--  Record count of HSA                  = '|| WK_HSA_COUNT);
        fnd_file.put_line(fnd_file.output,'--  Record(s) exploded to LINEDATA       = '|| WK_INS_CNT);
        fnd_file.put_line(fnd_file.output,'--  Record(s) updated in LINEDATA(HSA)   = '|| WK_UPD_CNT);
        fnd_file.put_line(fnd_file.output,'--');
        fnd_file.put_line(fnd_file.output,'---------------------------------------------------------------------');
    ELSIF WK_PROCESS_TYPE_ID = 3 AND WK_EXIST_COUNT = 0 THEN
        --PROCEDURE FOR TRANSFER LINEDATA TO COUNT
        PROC_LINE_COUNT_MAIN(WK_PHYSINV_ID
                            ,WK_USER_ID
                            ,WK_PHYS_SUBINV_NAME
                            ,WK_INS_CNT
                            ,WK_ERR_CNT);
        --ASSING END TIME
        WK_END_TIME    :=    TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS');

        --OUTPUT RESULT OF TRANSFER LINEDATA TO COUNT
        fnd_file.put_line(fnd_file.output,'----------TIP EHD PHYSICAL INVENTORY PROCESSING INFORMATION----------');
        fnd_file.put_line(fnd_file.output,'--');
        fnd_file.put_line(fnd_file.output,'---NORMALLY COMPLETED');
        fnd_file.put_line(fnd_file.output,'--');
        fnd_file.put_line(fnd_file.output,'---EXECUTE TIME');
        fnd_file.put_line(fnd_file.output,'--   START : '||WK_START_TIME);
        fnd_file.put_line(fnd_file.output,'--   END   : '||WK_END_TIME);
        fnd_file.put_line(fnd_file.output,'--');
        fnd_file.put_line(fnd_file.output,'--------- TRANSFER LINEDATA TO COUNT -------------------');
        fnd_file.put_line(fnd_file.output,'--  Record count of LINEDATA      = '|| WK_INS_CNT);
        fnd_file.put_line(fnd_file.output,'--  Record(s) inserted to COUNT   = '|| WK_INS_CNT);
        fnd_file.put_line(fnd_file.output,'--  Record(s) error in LINEDATA   = '|| WK_ERR_CNT);
        fnd_file.put_line(fnd_file.output,'--');
        fnd_file.put_line(fnd_file.output,'---------------------------------------------------------------------');
    -- Add Start Lib_ver.4.02 Checking of ITEM Setup
    ELSIF WK_PROCESS_TYPE_ID = 4 THEN
        --PROCEDURE FOR CHECKING OF ITEM SETUP for REGIST KATABAN and ITEM CODE
        PROC_CHECK_ITEM_SETUP(WK_ASSY_CODE_HDA
                           ,WK_ASSY_CODE_SFG
                           ,WK_ASSY_CODE_HDE    -- Added Lib_ver.4.03
-- Add start Lib_ver.4.06
                           ,WK_ASSY_CODE_SPM
-- Add end Lib_ver.4.06
                           ,WK_USER_ID
                           ,WK_ORG_ID
                           ,WK_TAG_NUMBER
                           ,WK_NO_MSI_CNT
                           ,WK_NO_BOM_CNT
                           ,WK_NG_ASSY_TYPE );     -- Added Lib_ver.4.03
        --ASSIGN END TIME
        WK_END_TIME    :=    TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS');

        --OUTPUT RESULT ON CHECKING OF ITEM SETUP for REGIST KATABAN and ITEM CODE
        fnd_file.put_line(fnd_file.output,'----------TIP EHD PHYSICAL INVENTORY PROCESSING INFORMATION----------');
        fnd_file.put_line(fnd_file.output,'--');
        fnd_file.put_line(fnd_file.output,'---NORMALLY COMPLETED');
        fnd_file.put_line(fnd_file.output,'--');
        fnd_file.put_line(fnd_file.output,'---EXECUTE TIME');
        fnd_file.put_line(fnd_file.output,'--   START : '||WK_START_TIME);
        fnd_file.put_line(fnd_file.output,'--   END   : '||WK_END_TIME);
        fnd_file.put_line(fnd_file.output,'--');
        fnd_file.put_line(fnd_file.output,'--------- NO SET-UP ITEMS IN REGIST -------------------');
        fnd_file.put_line(fnd_file.output,'--  Record(s) without MSI set-up  = '|| WK_NO_MSI_CNT);
        fnd_file.put_line(fnd_file.output,'--  Record(s) without BOM set-up   = '|| WK_NO_BOM_CNT);
        fnd_file.put_line(fnd_file.output,'--  Record(s) with mismatch assy_type   = '|| WK_NG_ASSY_TYPE);
        fnd_file.put_line(fnd_file.output,'--');
        fnd_file.put_line(fnd_file.output,'---------------------------------------------------------------------');
    -- Add End Lib_ver.4.02 Checking of ITEM Setup

    -- Add start Lib_Ver.4.04
    ELSIF WK_PROCESS_TYPE_ID = 5 THEN

        PROC_FGIS_REG_COUNT( WK_ORG_ID
                            ,WK_PHYSINV_ID
                            ,WK_FG_EX_PROCESS
                            ,WK_FG_TAG_NUM
                            ,WK_INS_CNT1
                            ,WK_RGA_CNT
                            ,WK_ERR_CNT1 );

       --ASSIGN END TIME
       WK_END_TIME    :=    TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS');

       --OUTPUT RESULT OF TRANSFER REGISTDATA TO LINEDATA
       fnd_file.put_line(fnd_file.output,'----------TIP EHD PHYSICAL INVENTORY PROCESSING INFORMATION----------');
       fnd_file.put_line(fnd_file.output,'--');
       fnd_file.put_line(fnd_file.output,'---NORMALLY COMPLETED');
       fnd_file.put_line(fnd_file.output,'--');
       fnd_file.put_line(fnd_file.output,'---EXECUTE TIME');
       fnd_file.put_line(fnd_file.output,'--   START : '||WK_START_TIME);
       fnd_file.put_line(fnd_file.output,'--   END   : '||WK_END_TIME);
       fnd_file.put_line(fnd_file.output,'--');
       fnd_file.put_line(fnd_file.output,'--------- TRANSFER REGISDATA TO COUNT -------------------');
       fnd_file.put_line(fnd_file.output,'--  Record(s) inserted to COUNT DATA      = '|| WK_INS_CNT1);
       fnd_file.put_line(fnd_file.output,'--  Record(s) of RGA excluded             = '|| WK_RGA_CNT);
       fnd_file.put_line(fnd_file.output,'--  Record(s) with errors during transfer = '|| WK_ERR_CNT1);
       fnd_file.put_line(fnd_file.output,'--');
       fnd_file.put_line(fnd_file.output,'---------------------------------------------------------------------');

    END IF;

EXCEPTION
WHEN OTHERS THEN
    --CHECK UNNECESSARY ERROR, THEN ROLLBACK AND OUTPUT ERROR MESSAGE
    ROLLBACK;

    WK_SQLCODE := SQLCODE;
    WK_SQLERRM := SQLERRM;
    fnd_file.put_line(fnd_file.output,'Completed with errors.');
    fnd_file.put_line(fnd_file.output,'Message     = ' ||WK_SQLERRM);
    fnd_file.put_line(fnd_file.output,'Return Code = ' ||WK_SQLCODE);
    ov_errbuf    := WK_SQLERRM;
    ov_retcode   := 2;

END PROC_REG_LINE_MAIN;
--============================================================
-- PROCEDURE_NAME    : PROC_REG_LINE_TRANS
-- ARGUMENTS         : HDA, SFG, HSA, USER ID, ORGANIZATION ID
-- OUTPUT            : INSERT COUNT, UPDATE COUNT
-- CREATED           : 2019-05-07
--============================================================
PROCEDURE PROC_REG_LINE_TRANS(
             iv_assy_hda    IN     VARCHAR2
            ,iv_assy_sfg    IN     VARCHAR2
-- Add start Lib_ver.4.06
            ,iv_assy_spm    IN     VARCHAR2
-- Add end Lib_ver.4.06
            ,iv_user_id     IN     NUMBER
            ,iv_org_id      IN     NUMBER
            ,iv_tag_number  IN     VARCHAR2 -- Add Start Lib_ver.4.02 add tag number
            ,iv_pcba_group  IN     VARCHAR2 -- Add Start Lib_ver.4.05
            ,iv_tagnot_xcld  IN     VARCHAR2 -- Add Start Lib_ver.4.05
            ,o_ins_cnt      OUT    NUMBER
            ,o_upd_cnt      OUT    NUMBER
)
IS

--=====================================
-- DECLARATION OF  LOCAL WORK VARIABLE
--=====================================

    --ASSIGN INPUT VARIABLE
    WK_ASSY_HDA         VARCHAR2(5) := iv_assy_hda;
    WK_ASSY_SFG         VARCHAR2(5) := iv_assy_sfg;
-- Add start Lib_ver.4.06
    WK_ASSY_SPM         VARCHAR2(5) := iv_assy_spm;
-- Add end Lib_ver.4.06
    WK_ORG_ID           NUMBER      := iv_org_id;
    WK_USER_ID          NUMBER      := iv_user_id;
    WK_TAG_NUMBER       VARCHAR2(50):= iv_tag_number; -- Add Start Lib_ver.4.02 add tag number
    WK_PCBA_GROUP       VARCHAR2(100)   := iv_pcba_group; -- Add Start Lib_ver.4.05
    WK_TAGNOT_XCLD   VARCHAR2(100)   := iv_tagnot_xcld; -- Add Start Lib_ver.4.05

    --CURSOR TO GET DATA IN REGIST
    CURSOR GETREGISTDATA
        IS
            SELECT  ASSY_TYPE,PROCESS_NAME,KATABAN_CODE,TYPE_CODE,TAG_NUMBER,LOCATION_NAME,INV_COUNT_QTY,INV_COUNT_TYPE,
                    CASE
                        WHEN ASSY_TYPE = iv_assy_hda THEN TYPE_CODE
                        WHEN ASSY_TYPE = iv_assy_sfg THEN KATABAN_CODE
-- Add start Lib_ver.4.06
                        WHEN ASSY_TYPE = iv_assy_spm THEN TYPE_CODE
-- Add end Lib_ver.4.06

                    END ASSY_CODE
            FROM    TIPEHDD_PHYSINV_REGISTDATA_IF
                        --,table(sys.dbms_debug_vc2coll('%Z','%X','%D','%B')) WS
            --WHERE   TAG_NUMBER LIKE WS.column_value
            -- Add Start Lib_ver.4.02 added FGIS tag number in REG to LINE TRANS
            WHERE   REGEXP_LIKE (TAG_NUMBER, WK_TAG_NUMBER)
            -- Add End Lib_ver.4.02 added FGIS tag number in REG to LINE TRANS
            AND     PROCESS_FLAG = 0
-- Mod start Lib_ver.4.06
           -- AND     ASSY_TYPE IN (WK_ASSY_SFG ,WK_ASSY_HDA )
            AND     ASSY_TYPE IN (WK_ASSY_SFG ,WK_ASSY_HDA,WK_ASSY_SPM )
-- Mod end Lib_ver.4.06
            AND     ORG_ID = WK_ORG_ID;

    --CURSOR VARIABLE
     R1                  GETREGISTDATA%rowtype;

BEGIN

    --ASSIGN INTIAL VALUE FOR INSERT COUNT AND UPDATE COUNT
    o_ins_cnt  := 0;
    o_upd_cnt  := 0;

    --OPEN CURSOR GETREGISTDATA
    OPEN GETREGISTDATA;
        LOOP
            FETCH GETREGISTDATA INTO R1;
            EXIT WHEN GETREGISTDATA%NOTFOUND;
            --IF FOR CHECKING OF ASSEMBLY TYPE
            --CHECKING OF ASSEMBLY TYPE IF SFG
            IF R1.ASSY_TYPE = WK_ASSY_SFG THEN
                --CURSOR FOR EXPLOSION OF SFG
                FOR R2 IN
                    (
                    SELECT     bbm.assembly_item_id, bic.bill_sequence_id, bic.component_sequence_id,
                            bic.component_item_id, msi.segment1, msi.description,bic.component_quantity
                    FROM     bom_bill_of_materials bbm,
                            bom_inventory_components bic,
                            mtl_system_items msi
                    WHERE     bbm.bill_sequence_id = bic.bill_sequence_id
                    AND     msi.inventory_item_id = bic.component_item_id
                    AND     msi.organization_id = bbm.organization_id
                    AND     msi.organization_id = WK_ORG_ID
                    AND     bbm.alternate_bom_designator = 'MPL'
                    AND     bic.effectivity_date <= sysdate
                    AND     NVL(trunc(bic.disable_date), SYSDATE+1 ) > SYSDATE
                    AND     msi.segment1 not like '%HDA%'
                    AND     bbm.assembly_item_id = (SELECT     msi1.inventory_item_id
                                                    FROM     mtl_system_items msi1
                                                    WHERE     msi1.organization_id = WK_ORG_ID
                                                    AND     msi1.segment1 = R1.ASSY_CODE)
                    UNION
                    SELECT     bbm.assembly_item_id, bic.bill_sequence_id, bic.component_sequence_id,
                            bic.component_item_id, msi.segment1, msi.description,bic.component_quantity
                    FROM     bom_bill_of_materials bbm,
                            bom_inventory_components bic,
                            mtl_system_items msi
                    WHERE     bbm.bill_sequence_id = bic.bill_sequence_id
                    AND     msi.inventory_item_id = bic.component_item_id
                    AND     msi.organization_id = bbm.organization_id
                    AND     msi.organization_id = WK_ORG_ID
                    AND     bbm.alternate_bom_designator = 'MPL'
                    AND     bic.effectivity_date <= sysdate
                    AND     NVL(trunc(bic.disable_date), SYSDATE+1 ) > SYSDATE
                    and msi.segment1 not like '%HSA%'
                    AND     bbm.assembly_item_id = (SELECT     msi1.inventory_item_id
                                                    FROM     mtl_system_items msi1
                                                    WHERE     msi1.organization_id = WK_ORG_ID
                                                    AND     msi1.segment1 = (SELECT msi2.segment1 || SUBSTRB(R1.ASSY_CODE,13,1) || SUBSTRB(R1.ASSY_CODE,14,2) || SUBSTRB(R1.ASSY_CODE,16,1)
                                                                             FROM     bom_bill_of_materials bbm,
                                                                                    bom_inventory_components bic,
                                                                                    mtl_system_items msi2
                                                                             WHERE     bbm.bill_sequence_id = bic.bill_sequence_id
                                                                             AND     msi2.inventory_item_id = bic.component_item_id
                                                                             AND     msi2.organization_id = bbm.organization_id
                                                                             AND     msi2.organization_id = WK_ORG_ID
                                                                             AND     bbm.alternate_bom_designator = 'MPL'
                                                                             AND     bic.effectivity_date <= sysdate
                                                                             AND     NVL(trunc(bic.disable_date), SYSDATE+1 ) > SYSDATE
                                                                             AND     msi2.segment1 like '%HDA%'
                                                                             AND bbm.assembly_item_id = (SELECT msi3.inventory_item_id
                                                                                                         FROM     mtl_system_items msi3
                                                                                                         WHERE     msi3.organization_id = WK_ORG_ID
                                                                                                         AND     msi3.segment1 = R1.ASSY_CODE)))
                    UNION
                    SELECT    bbm.assembly_item_id, bic.bill_sequence_id, bic.component_sequence_id,
                            bic.component_item_id, msi.segment1, msi.description,bic.component_quantity
                    FROM     bom_bill_of_materials bbm,
                            bom_inventory_components bic,
                            mtl_system_items msi
                    WHERE    bbm.bill_sequence_id = bic.bill_sequence_id
                    AND        msi.inventory_item_id = bic.component_item_id
                    AND        msi.organization_id = bbm.organization_id
                    AND        msi.organization_id = WK_ORG_ID
                    AND        bbm.alternate_bom_designator = 'MPL'
                    AND        bic.effectivity_date <= SYSDATE
                    AND        NVL(TRUNC(bic.disable_date), SYSDATE+1 ) > SYSDATE
                    AND     bbm.assembly_item_id = (SELECT msi1.inventory_item_id
                                                    FROM mtl_system_items msi1
                                                    WHERE msi1.organization_id = WK_ORG_ID
                                                    AND msi1.segment1 = (SELECT msi2.segment1 || SUBSTRB(R1.ASSY_CODE,13,1) || SUBSTRB(msi2.segment1,11,2) || SUBSTRB(R1.ASSY_CODE,16,1)
                                                                        FROM bom_bill_of_materials bbm,
                                                                            bom_inventory_components bic,
                                                                            mtl_system_items msi2
                                                                        WHERE bbm.bill_sequence_id = bic.bill_sequence_id
                                                                        AND msi2.inventory_item_id = bic.component_item_id
                                                                        AND msi2.organization_id = bbm.organization_id
                                                                        AND msi2.organization_id = WK_ORG_ID
                                                                        AND bbm.alternate_bom_designator = 'MPL'
                                                                        AND bic.effectivity_date <= SYSDATE
                                                                        AND NVL(TRUNC(bic.disable_date), SYSDATE+1 ) > SYSDATE
                                                                        AND msi2.segment1 LIKE '%HSA%'
                                                                        AND bbm.assembly_item_id = (SELECT msi3.inventory_item_id
                                                                                                    FROM mtl_system_items msi3
                                                                                                    WHERE msi3.organization_id = WK_ORG_ID
                                                                                                    AND msi3.segment1 = (SELECT msi4.segment1 || SUBSTRB(R1.ASSY_CODE,13,1) || SUBSTRB(R1.ASSY_CODE,14,2) || SUBSTRB(R1.ASSY_CODE,16,1)
                                                                                                                        FROM bom_bill_of_materials bbm,
                                                                                                                            bom_inventory_components bic,
                                                                                                                            mtl_system_items msi4
                                                                                                                        WHERE bbm.bill_sequence_id = bic.bill_sequence_id
                                                                                                                        AND msi4.inventory_item_id = bic.component_item_id
                                                                                                                        AND msi4.organization_id = bbm.organization_id
                                                                                                                        AND msi4.organization_id = WK_ORG_ID
                                                                                                                        AND bbm.alternate_bom_designator = 'MPL'
                                                                                                                        AND bic.effectivity_date <= SYSDATE
                                                                                                                        AND NVL(TRUNC(bic.disable_date), SYSDATE+1 ) > SYSDATE
                                                                                                                        AND msi4.segment1 LIKE '%HDA%'
                                                                                                                        AND bbm.assembly_item_id = (SELECT msi5.inventory_item_id
                                                                                                                                                    FROM mtl_system_items msi5
                                                                                                                                                    WHERE msi5.organization_id = WK_ORG_ID
                                                                                                                                                    AND msi5.segment1 = R1.ASSY_CODE)))))
                    )

                LOOP
                    --INSERT SFG DATA IN LINEDATA
                    INSERT INTO TIPEHDD_PHYSINV_LINEDATA_IF
                                    (ORG_ID
                                    ,ASSY_TYPE
                                    ,PROCESS_NAME
                                    ,TAG_NUMBER
                                    ,KATABAN_CODE
                                    ,ITEM_CODE
                                    ,FINAL_COUNT_QTY
                                    ,FINAL_COUNT_TYPE
                                    ,LOCATION_NAME
                                    ,PROCESS_FLAG
                                    ,UPLOADED_DATE
                                    ,UPLOADED_BY)

                    VALUES
                                    (WK_ORG_ID
                                    ,R1.ASSY_TYPE
                                    ,R1.PROCESS_NAME
                                    ,R1.TAG_NUMBER
                                    ,R1.KATABAN_CODE
                                    ,R2.SEGMENT1
                                    ,R1.INV_COUNT_QTY * R2.COMPONENT_QUANTITY
                                    ,R1.INV_COUNT_TYPE
                                    ,R1.LOCATION_NAME
                                    ,0
                                    ,SYSDATE
                                    ,WK_USER_ID);
                    --ASSIGN INCREMENT COUNT FOR INSERT COUNT
                    o_ins_cnt  := o_ins_cnt + 1;

                    COMMIT;

                END LOOP;
            --CHECKING OF ASSEMBLY TYPE IF SFG
            ELSIF R1.ASSY_TYPE = WK_ASSY_HDA THEN
                --CURSOR FOR EXPLOSION OF HDA
                FOR R3 IN
                    (
                    SELECT    bbm.assembly_item_id, bic.bill_sequence_id, bic.component_sequence_id,
                            bic.component_item_id, msi.segment1, msi.description,bic.component_quantity
                    FROM    bom_bill_of_materials bbm,
                            bom_inventory_components bic,
                            mtl_system_items msi
                    WHERE   bbm.bill_sequence_id = bic.bill_sequence_id
                    AND     msi.inventory_item_id = bic.component_item_id
                    AND     msi.organization_id = bbm.organization_id
                    AND     msi.organization_id = WK_ORG_ID
                    AND     bbm.alternate_bom_designator = 'MPL'
                    AND     bic.effectivity_date <= SYSDATE
                    AND     NVL(TRUNC(bic.disable_date), SYSDATE+1 ) > SYSDATE
                    AND     msi.segment1 NOT LIKE '%HSA%'
                    AND     bbm.assembly_item_id = (SELECT    msi1.inventory_item_id
                                                    FROM    mtl_system_items msi1
                                                    WHERE    msi1.organization_id = WK_ORG_ID
                                                    AND     msi1.segment1 = R1.ASSY_CODE)
                    UNION
                    SELECT  bbm.assembly_item_id, bic.bill_sequence_id, bic.component_sequence_id,
                            bic.component_item_id, msi.segment1, msi.description,bic.component_quantity
                    FROM    bom_bill_of_materials bbm,
                            bom_inventory_components bic,
                            mtl_system_items msi
                    WHERE   bbm.bill_sequence_id = bic.bill_sequence_id
                    AND     msi.inventory_item_id = bic.component_item_id
                    AND     msi.organization_id = bbm.organization_id
                    AND     msi.organization_id = WK_ORG_ID
                    AND     bbm.alternate_bom_designator = 'MPL'
                    AND     bic.effectivity_date <= SYSDATE
                    AND     NVL(TRUNC(bic.disable_date), SYSDATE+1 ) > SYSDATE
                    AND     bbm.assembly_item_id = (SELECT    msi1.inventory_item_id
                                                    FROM    mtl_system_items msi1
                                                    WHERE   msi1.organization_id = WK_ORG_ID
                                                    AND     msi1.segment1 = (SELECT msi2.segment1 ||SUBSTRB(R1.ASSY_CODE,13,1)  || SUBSTRB(msi2.segment1,11,2) || SUBSTRB(R1.ASSY_CODE,16,1)
                                                                             FROM    bom_bill_of_materials bbm,
                                                                                    bom_inventory_components bic,
                                                                                    mtl_system_items msi2
                                                                             WHERE  bbm.bill_sequence_id = bic.bill_sequence_id
                                                                             AND    msi2.inventory_item_id = bic.component_item_id
                                                                             AND    msi2.organization_id = bbm.organization_id
                                                                             AND    msi2.organization_id = WK_ORG_ID
                                                                             AND    bbm.alternate_bom_designator = 'MPL'
                                                                             AND    bic.effectivity_date <= SYSDATE
                                                                             AND    NVL(TRUNC(bic.disable_date), SYSDATE+1 ) > SYSDATE
                                                                             AND    msi2.segment1 LIKE '%HSA%'
                                                                             AND     bbm.assembly_item_id = (SELECT    msi3.inventory_item_id
                                                                                                            FROM    mtl_system_items msi3
                                                                                                            WHERE   msi3.organization_id = WK_ORG_ID
                                                                                                            AND     msi3.segment1 = R1.ASSY_CODE)))

                    )

                LOOP
                    --INSERT HDA DATA IN LINEDATA
                    INSERT INTO TIPEHDD_PHYSINV_LINEDATA_IF
                                    (ORG_ID
                                    ,ASSY_TYPE
                                    ,PROCESS_NAME
                                    ,TAG_NUMBER
                                    ,KATABAN_CODE
                                    ,ITEM_CODE
                                    ,FINAL_COUNT_QTY
                                    ,FINAL_COUNT_TYPE
                                    ,LOCATION_NAME
                                    ,PROCESS_FLAG
                                    ,UPLOADED_DATE
                                    ,UPLOADED_BY)
                    VALUES
                                    (WK_ORG_ID
                                    ,R1.ASSY_TYPE
                                    ,R1.PROCESS_NAME
                                    ,R1.TAG_NUMBER
                                    ,R1.KATABAN_CODE
                                    ,R3.SEGMENT1
                                    ,R1.INV_COUNT_QTY * R3.COMPONENT_QUANTITY
                                    ,R1.INV_COUNT_TYPE
                                    ,R1.LOCATION_NAME
                                    ,0
                                    ,SYSDATE
                                    ,WK_USER_ID);
                    --ASSIGN INCEREMENT COUNT IN INSERT COUNT
                    o_ins_cnt  := o_ins_cnt + 1;

                    COMMIT;

                END LOOP;
-- Add start Lib_ver.4.06
                ELSIF R1.ASSY_TYPE = WK_ASSY_SPM THEN

                 INSERT INTO TIPEHDD_PHYSINV_LINEDATA_IF
                                    (ORG_ID
                                    ,ASSY_TYPE
                                    ,PROCESS_NAME
                                    ,TAG_NUMBER
                                    ,KATABAN_CODE
                                    ,ITEM_CODE
                                    ,FINAL_COUNT_QTY
                                    ,FINAL_COUNT_TYPE
                                    ,LOCATION_NAME
                                    ,PROCESS_FLAG
                                    ,UPLOADED_DATE
                                    ,UPLOADED_BY)
                    VALUES
                                    (WK_ORG_ID
                                    ,R1.ASSY_TYPE
                                    ,R1.PROCESS_NAME
                                    ,R1.TAG_NUMBER
                                    ,R1.KATABAN_CODE
                                    ,R1.TYPE_CODE
                                    ,R1.INV_COUNT_QTY
                                    ,R1.INV_COUNT_TYPE
                                    ,R1.LOCATION_NAME
                                    ,0
                                    ,SYSDATE
                                    ,WK_USER_ID);
                    --ASSIGN INCEREMENT COUNT IN INSERT COUNT
                    o_ins_cnt  := o_ins_cnt + 1;

                    COMMIT;

-- Add end Lib_ver.4.06
                END IF;
                --END IF FOR CHECKING OF ASSEMBLY TYPE

                --UPDATE REGIST DATA PROCESS FLAG FROM ZERO TO ONE(ALREADY TRANSFERRED TO LINEDATA)
                UPDATE TIPEHDD_PHYSINV_REGISTDATA_IF
                SET PROCESS_FLAG = 1
                WHERE TAG_NUMBER = R1.TAG_NUMBER
                AND PROCESS_FLAG = 0;

                --ASSIGN INCREMENT COUNT IN UPDATE COUNT
                o_upd_cnt  := o_upd_cnt + 1;

                COMMIT;

        END LOOP;

    CLOSE GETREGISTDATA;

       --Exclude PCBA Item code
    -- Add start Lib_ver.4.05
     UPDATE TIPEHDD_PHYSINV_LINEDATA_IF tlpi
     SET tlpi.process_flag = 6
     WHERE EXISTS
              (SELECT msi.description
                 FROM MTL_SYSTEM_ITEMS msi
                WHERE     tlpi.org_id = msi.organization_id
                      AND tlpi.item_code = msi.segment1
                      AND REGEXP_LIKE (msi.description, WK_PCBA_GROUP))
     AND NOT REGEXP_LIKE (TAG_NUMBER,'Y$|R$');

     COMMIT;
    -- Add end Lib_ver.4.05

END PROC_REG_LINE_TRANS;
--============================================================
-- PROCEDURE_NAME    : PROC_HSA_LINE_EXPL
-- ARGUMENTS         : HSA, USER ID, ORGANIZATION ID
-- OUTPUT            : INSERT COUNT, UPDATE COUNT
-- CREATED           : 2019-05-07
--============================================================
PROCEDURE    PROC_HSA_LINE_EXPL(
             iv_assy_hsa    IN     VARCHAR2
            ,iv_user_id     IN     NUMBER
            ,iv_org_id      IN     NUMBER
            ,o_ins_cnt        OUT       NUMBER
            ,o_upd_cnt      OUT    NUMBER
)
IS
--=====================================
-- DECLARATION OF  LOCAL WORK VARIABLE
--=====================================

    --CURSOR TO GETHSA LINEDATA
    CURSOR GETHSA
        IS
          SELECT  ORG_ID,ASSY_TYPE,TAG_NUMBER,ITEM_CODE,FINAL_COUNT_QTY
                  --Add Start Lib_ver.4.03
                  ,PROCESS_NAME , LOCATION_NAME
                  --Add End Lib_ver.4.03
          FROM    TIPEHDD_PHYSINV_LINEDATA_IF
          WHERE   PROCESS_FLAG = 0
          AND     ITEM_CODE like '%'|| iv_assy_hsa ||'%';
BEGIN
      --ASSIGN INTIAL VALUE FOR INSERT COUNT AND UPDATE COUNT
      o_ins_cnt  := 0;
      o_upd_cnt  := 0;

      --OPEN CURSOR GETHSA
      FOR R1 IN GETHSA
            LOOP
                --OPEN CURSOR FOR EXPLOSION OF HSA
                FOR R2 IN
                    (
                        select msi.organization_id,msi.segment1,msi.description,bic.component_quantity
                        from apps.mtl_system_items msi, apps.bom_inventory_components bic
                        where msi.organization_id = 132
                        and msi.inventory_item_id = bic.component_item_id
                        and (trunc(disable_date,'DD')    >    trunc(sysdate,'DD') or  disable_date  is null)
                            and trunc(effectivity_date,'DD') <= trunc(sysdate,'DD')
                            and bic.bill_sequence_id in (select bom.bill_sequence_id
                                from apps.mtl_system_items msi,apps.bom_bill_of_materials bom
                                where  msi.organization_id = 132
                                and bom.organization_id = msi.organization_id
                                and  msi.inventory_item_id = bom.assembly_item_id
                                and bom.alternate_bom_designator = 'MPL'
                                and substr(msi.segment1,1,12) = R1.ITEM_CODE)
                            order by segment1
                        )
                        LOOP

                        --INSERT HSA DATA IN LINEDATA
                        INSERT INTO TIPEHDD_PHYSINV_LINEDATA_IF(
                                    ORG_ID                        ,ASSY_TYPE                                     ,PROCESS_NAME
                                   ,TAG_NUMBER                    ,KATABAN_CODE                                  ,TYPE_CODE
                                   ,ITEM_CODE                     ,FINAL_COUNT_QTY                               ,FINAL_COUNT_TYPE
                                   ,LOCATION_NAME                 ,U_CODE                                        ,PROCESS_FLAG
                                   ,ATTRIBUTE1                    ,ATTRIBUTE4                                    ,ATTRIBUTE3
                                   ,ATTRIBUTE2                    ,ATTRIBUTE5                                    ,ATTRIBUTE6
                                   ,UPLOADED_DATE                 ,UPLOADED_BY                                   ,TRANSFERRED_DATE
                                   ,TRANSFERRED_BY                ,ERROR_LOG)
                        --Mod Start Lib_ver.4.03
                        VALUES(
                                    iv_org_id                     ,R1.ASSY_TYPE                                  ,R1.PROCESS_NAME --'PARTIAL'
                                   ,R1.TAG_NUMBER                 ,NULL                                          ,NULL
                                   ,R2.SEGMENT1                   ,R1.FINAL_COUNT_QTY * R2.COMPONENT_QUANTITY    ,'P'
                                   ,R1.LOCATION_NAME/*'LOCATOR'*/,NULL                                          ,0
                                   ,SYSDATE                       ,NULL                                          ,NULL
                                   ,'Exploded HSA' /*'RGT'*/     ,NULL                                          ,NULL
                                   ,NULL                          ,NULL                                          ,NULL
                                   ,NULL                          ,NULL);
                        --Mod End Lib_ver.4.03
                        --ASSIGN INCREMENT COUNT IN INSERT COUNT
                        o_ins_cnt  := o_ins_cnt + 1;

                        COMMIT;
                END LOOP;
                    --UPDATE LINE DATA PROCESS FLAG FROM ZERO TO FIVE(HSA)
                    UPDATE TIPEHDD_PHYSINV_LINEDATA_IF
                    SET PROCESS_FLAG = 5
                       ,ATTRIBUTE1 = TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')
                       ,ATTRIBUTE2 = iv_assy_hsa
                    WHERE PROCESS_FLAG = 0
                    AND TAG_NUMBER = R1.TAG_NUMBER
                    AND ITEM_CODE = R1.ITEM_CODE;

                    --ASSIGN INCREMENT COUNT IN UPDATE COUNT
                    o_upd_cnt := o_upd_cnt + 1;

                    COMMIT;
            END LOOP;
END PROC_HSA_LINE_EXPL;
--============================================================
-- PROCEDURE_NAME    : PROC_LINE_COUNT_MAIN
-- ARGUMENTS         : PHYSICAL INVENTORY ID, USER ID, SUBINVENTORY NAME
-- OUTPUT            : INSERT COUNT, ERROR COUNT
-- CREATED           : 2019-05-07
--============================================================
PROCEDURE  PROC_LINE_COUNT_MAIN
        (
            iv_physinv_id    IN    NUMBER
           ,iv_user_id       IN    NUMBER
           ,iv_subinventory  IN    VARCHAR2
           ,o_ins_cnt        OUT   NUMBER
           ,o_err_cnt        OUT   NUMBER
        )
IS
     --ASSIGN INPUT VARIABLE
     WK_PHYSINV_ID      NUMBER         := iv_physinv_id;
     WK_USER_ID         NUMBER         := iv_user_id;
     WK_SUBINVENTORY    VARCHAR2(20)   := iv_subinventory;

     --ITEM ID VARIABLE
     WK_ITEM_ID         MTL_SYSTEM_ITEMS.INVENTORY_ITEM_ID%TYPE;

    --CURSOR GETLINEDATA
    CURSOR GETLINEDATA
        IS
            SELECT      ORG_ID,ASSY_TYPE,PROCESS_NAME,ITEM_CODE,SUM(FINAL_COUNT_QTY) as FINAL_COUNT_QTY
            FROM        TIPEHDD_PHYSINV_LINEDATA_IF
            WHERE       PROCESS_FLAG = 0
            GROUP BY    ORG_ID,ASSY_TYPE,PROCESS_NAME,ITEM_CODE
            ORDER BY    ASSY_TYPE,PROCESS_NAME;

    --CURSOR VARIABLE
    R1 GETLINEDATA%rowtype;

BEGIN
    --ASSIGN INTIAL VALUE FOR INSERT COUNT AND UPDATE COUNT
    o_ins_cnt := 0;
    o_err_cnt := 0;

    --OPEN CURSOR FOR GETLINEDATA
    OPEN    GETLINEDATA;
    LOOP
        FETCH   GETLINEDATA INTO R1;
        EXIT WHEN   GETLINEDATA%NOTFOUND;

          BEGIN
               --VALIDATE ITEM CODE IN MTL_SYSTEM_ITEMS(MSI)
               BEGIN
                   SELECT    INVENTORY_ITEM_ID
                   INTO        WK_ITEM_ID
                   FROM        MTL_SYSTEM_ITEMS
                   WHERE    ORGANIZATION_ID = R1.ORG_ID
                   AND        SEGMENT1 = R1.ITEM_CODE;
               EXCEPTION
               WHEN NO_DATA_FOUND THEN
                    --UPDATE LINE DATA PROCESS FLAG FROM ZERO TO THREE(NOT EXISTING IN MSI)
                    UPDATE TIPEHDD_PHYSINV_LINEDATA_IF
                    SET PROCESS_FLAG = 3
                       ,ATTRIBUTE1 = TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')
                       ,ERROR_LOG = 'Not existing in Material System Items'
                    WHERE PROCESS_FLAG = 0
                    AND ITEM_CODE = R1.ITEM_CODE;
                    --ASSIGN INCREMENT COUNT IN ERROR COUNT
                    o_err_cnt := o_err_cnt + 1;

                    COMMIT;
               END;
                    --INSERT LINEDATA TO COUNT
                    INSERT INTO TIP_PHYSICAL_INVENTORY_COUNT
                            (PHYSICAL_INVENTORY_ID
                            ,SUBINVENTORY_NAME
                            ,ITEM_TYPE
                            ,INVENTORY_ITEM_ID
                            ,COUNT_QTY
                            ,PROCESS_FLAG
                            ,ORGANIZATION_ID
                            ,LOCATION
                            ,ITEM_CODE
                            ,CREATION_DATE
                            ,CREATED_BY)
                    VALUES
                            (WK_PHYSINV_ID -- change physical_inventory_id
                            ,WK_SUBINVENTORY
                            ,'BUY'
                            ,WK_ITEM_ID
                            ,R1.FINAL_COUNT_QTY
                            ,'0'
                            ,R1.ORG_ID
                            ,R1.PROCESS_NAME
                            ,R1.ITEM_CODE
                            ,SYSDATE
                            ,WK_USER_ID);
                    --ASSIGN INCREMENT COUNT IN INSERT COUNT
                    o_ins_cnt := o_ins_cnt + 1;

                    COMMIT;
        END;

       END LOOP;
            --UPDATE LINE DATA PROCESS FLAG FROM ZERO TO ONE(ALREADY TRANSFERRED TO COUNT DATA)
            UPDATE TIPEHDD_PHYSINV_LINEDATA_IF
            SET PROCESS_FLAG = 1
               ,ATTRIBUTE1 = TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')
               ,ATTRIBUTE3 = WK_PHYSINV_ID
            WHERE PROCESS_FLAG = 0;

            COMMIT;

EXCEPTION
WHEN OTHERS THEN
    ROLLBACK;
    --PROC_XXPUR_ERROR_LOG_SET(TO_CHAR(SQLCODE), SQLERRM);    -- 2015/03/11 <Add>
    --PROC_XXPUR_ERROR_LOG_INS;    -- 2015/03/11 <Add>

END PROC_LINE_COUNT_MAIN;
--============================================================
-- PROCEDURE_NAME    : PROC_UPD_PKG_MAT_TRANS
-- ARGUMENTS         : PARTS CODE
-- CREATED           : 2019-05-07
--============================================================
PROCEDURE    PROC_UPD_PKG_MAT_TRANS(
             iv_parts_code IN     VARCHAR2
)
IS
    --PARTS CODE VARIABLE
    WK_PARTS_CODE VARCHAR2(40);

    --CHECK UPDATE VARIABLE
    WK_CHK_UPDATE NUMBER;

    --ERROR VARIABLE
    WK_EXCEPTION_ERROR EXCEPTION;
    WK_ERROR VARCHAR2(3000);

BEGIN
    BEGIN

        --VALIDATE ITEM CODE IN MATERIAL SYSTEM ITEMS(MSI)
        SELECT SEGMENT1
        INTO WK_PARTS_CODE
        FROM MTL_SYSTEM_ITEMS
        WHERE SEGMENT1 = iv_parts_code
        AND ORGANIZATION_ID = 132;

        IF WK_PARTS_CODE IS NOT NULL THEN
            --UPDATE LINE DATA PROCESS FLAG FROM ZERO TO FOUR(PACKAGING MATERIALS)
            UPDATE TIPEHDD_PHYSINV_LINEDATA_IF
            SET PROCESS_FLAG = 4
               ,ATTRIBUTE1 = TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS')
               ,ATTRIBUTE2 = 'PACKAGING MATERIALS'
            WHERE PROCESS_FLAG = 0
--            AND SUBSTR(TAG_NUMBER,7,1) NOT IN ('Y','U','F')
            -- Add Start Lib_ver.4.02 added FGIS tag number in packg mat
            AND SUBSTR(TAG_NUMBER,7,1) NOT IN (SELECT  DEFAULT_VALUE
                                                FROM   TIP_DEFAULT_VALUES
                                                WHERE TABLE_NAME = 'TIP_EHD_PHYSICAL_INVENTORY'
                                                AND FIELD_NAME = 'PACKAGING_MAT')
            -- Add End Lib_ver.4.02 added FGIS tag number in packg mat
            AND ITEM_CODE = iv_parts_code;

            --ASSIGN INCREMENT COUNT TO CHECK UPDATE COUNT
            WK_CHK_UPDATE := sql%rowcount;

                IF WK_CHK_UPDATE >= 1 THEN
                    COMMIT;
                ELSE
                    raise WK_EXCEPTION_ERROR;
                END IF;

        END IF;
    EXCEPTION
        --ERROR EXCEPTION TO CHECK IF PACKAGING MATERIALS ALREADY UPDATED
        WHEN WK_EXCEPTION_ERROR THEN
            WK_ERROR := 'Packaging Materials already updated ' || SQLERRM;
            raise_application_error(-20002, WK_ERROR);
        --ERROR EXCEPTION TO WHEN PACKAGING MATERIALS NOT IN LINE DATA
        WHEN NO_DATA_FOUND THEN
            raise_application_error(-20000,'Packaging Materials does not exists ' || 'Error Code: ' || SQLCODE || ' Error Message: ' || SQLERRM);
        WHEN OTHERS THEN
            raise_application_error (-20000, SQLCODE || ':' || SQLERRM);
    END;

EXCEPTION WHEN others THEN
    raise_application_error (-20000, SQLCODE || ':' || SQLERRM);
END PROC_UPD_PKG_MAT_TRANS;

--============================================================
-- PROCEDURE_NAME    : PROC_CHECK_ITEM_SETUP
-- ARGUMENTS         : HDA, SFG, HSA, SPM, USER ID, ORGANIZATION ID
-- OUTPUT            : INSERT COUNT, UPDATE COUNT
-- CREATED           : 2019-10-09
--============================================================
PROCEDURE PROC_CHECK_ITEM_SETUP(
             iv_assy_hda    IN     VARCHAR2
            ,iv_assy_sfg    IN     VARCHAR2
            ,iv_code_hde    IN     VARCHAR2
-- Add start Lib_ver. 4.06
            ,iv_assy_spm    IN     VARCHAR2
-- Add end Lib_ver. 4.06
            ,iv_user_id     IN     NUMBER
            ,iv_org_id      IN     NUMBER
            ,iv_tag_number  IN     VARCHAR2
            ,o_no_msi_cnt   OUT    VARCHAR2
            ,o_no_bom_cnt   OUT    VARCHAR2
            ,o_ng_assy_type OUT    VARCHAR2
)
IS
    --ASSIGN INPUT VARIABLE
    WK_ASSY_HDA         VARCHAR2(5) := iv_assy_hda;
    WK_ASSY_SFG         VARCHAR2(5) := iv_assy_sfg;
-- Add start Lib_ver.4.06
    WK_ASSY_SPM         VARCHAR2(5) := iv_assy_spm;
-- Add end Lib_ver.4.06
    WK_ASSY_HDE         VARCHAR2(5) := iv_code_hde;
    WK_ORG_ID           NUMBER      := iv_org_id;
    WK_USER_ID          NUMBER      := iv_user_id;
    WK_TAG_NUMBER       VARCHAR2(50):= iv_tag_number;

    --CHECK UPDATE VARIABLE
    WK_CHK_UPDATE_1 NUMBER;
    WK_CHK_UPDATE_2 NUMBER;
    WK_CHK_UPDATE_3 NUMBER;
    WK_CHK_UPDATE_4 NUMBER;
    WK_CHK_UPDATE_5 NUMBER;
    WK_CHK_UPDATE_6 NUMBER;
    WK_NO_MSI       NUMBER;
    WK_NO_BOM       NUMBER;


BEGIN

    BEGIN
        --UPDATE KATABAN CODE W/O MSI SETUP
        UPDATE TIPEHDD_PHYSINV_REGISTDATA_IF
        SET PROCESS_FLAG = 3,
            ATTRIBUTE1 = 'NO_MSI_SETUP_KTBN'
        WHERE KATABAN_CODE IN (SELECT KATABAN_CODE
                                FROM APPS.TIPEHDD_PHYSINV_REGISTDATA_IF
                                WHERE REGEXP_LIKE (TAG_NUMBER, WK_TAG_NUMBER)
                                AND ASSY_TYPE = WK_ASSY_SFG
                                AND PROCESS_FLAG = 0
                                AND KATABAN_CODE <> '-'
                                AND KATABAN_CODE NOT IN (SELECT SEGMENT1
                                                        FROM APPS.MTL_SYSTEM_ITEMS
                                                        WHERE ORGANIZATION_ID = WK_ORG_ID)
                                GROUP BY    KATABAN_CODE);
        WK_CHK_UPDATE_1 := sql%rowcount;
    END;

    BEGIN
        --UPDATE ITEM CODE W/O MSI SETUP
        UPDATE TIPEHDD_PHYSINV_REGISTDATA_IF
        SET PROCESS_FLAG = 3,
            ATTRIBUTE1 = 'NO_MSI_SETUP_TYPC'
        WHERE TYPE_CODE IN (SELECT TYPE_CODE
                            FROM APPS.TIPEHDD_PHYSINV_REGISTDATA_IF
                            WHERE REGEXP_LIKE (TAG_NUMBER, WK_TAG_NUMBER)
                            AND ASSY_TYPE = WK_ASSY_HDA
                            AND PROCESS_FLAG = 0
                            AND TYPE_CODE <> '-'
                            AND TYPE_CODE NOT IN (SELECT SEGMENT1
                                                  FROM APPS.MTL_SYSTEM_ITEMS
                                                  WHERE ORGANIZATION_ID = WK_ORG_ID)
                            GROUP BY    TYPE_CODE);
        WK_CHK_UPDATE_2 := sql%rowcount;
    END;
-- Add start Lib_ver.4.06
    BEGIN
        --UPDATE ITEM CODE W/O MSI SETUP
        UPDATE TIPEHDD_PHYSINV_REGISTDATA_IF
        SET PROCESS_FLAG = 3,
            ATTRIBUTE1 = 'NO_MSI_SETUP_TYPC'
        WHERE TYPE_CODE IN (SELECT TYPE_CODE
                            FROM APPS.TIPEHDD_PHYSINV_REGISTDATA_IF
                            WHERE REGEXP_LIKE (TAG_NUMBER, WK_TAG_NUMBER)
                            AND ASSY_TYPE = WK_ASSY_SPM
                            AND PROCESS_FLAG = 0
                            AND TYPE_CODE <> '-'
                            AND TYPE_CODE NOT IN (SELECT SEGMENT1
                                                  FROM APPS.MTL_SYSTEM_ITEMS
                                                  WHERE ORGANIZATION_ID = WK_ORG_ID)
                            GROUP BY    TYPE_CODE);
        WK_CHK_UPDATE_2 := sql%rowcount;
    END;
-- Add end Lib_ver.4.06
    BEGIN
        --UPDATE KATABAN CODE W/O BOM SETUP
        UPDATE TIPEHDD_PHYSINV_REGISTDATA_IF
        SET PROCESS_FLAG = 3,
            ATTRIBUTE1 = 'NO_BOM_SETUP_KTBN'
        WHERE KATABAN_CODE IN (SELECT KATABAN_CODE
                                FROM    (SELECT KATABAN_CODE,INVENTORY_ITEM_ID
                                        FROM ( SELECT A.KATABAN_CODE, B.INVENTORY_ITEM_ID
                                        FROM TIPEHDD_PHYSINV_REGISTDATA_IF A,
                                             MTL_SYSTEM_ITEMS B
                                        WHERE A.ASSY_TYPE = WK_ASSY_SFG
                                        AND REGEXP_LIKE (A.TAG_NUMBER,  WK_TAG_NUMBER)
                                        AND A.KATABAN_CODE = B.SEGMENT1
                                        AND A.ORG_ID = B.ORGANIZATION_ID
                                        AND B.ORGANIZATION_ID = WK_ORG_ID
                                        AND A.KATABAN_CODE IN (SELECT SEGMENT1
                                                                FROM APPS.MTL_SYSTEM_ITEMS
                                                                WHERE ORGANIZATION_ID = WK_ORG_ID)
                                        GROUP BY    A.KATABAN_CODE, B.INVENTORY_ITEM_ID)
                                        WHERE INVENTORY_ITEM_ID NOT IN (SELECT ASSEMBLY_ITEM_ID
                                                                        FROM APPS.BOM_BILL_OF_MATERIALS
                                                                        WHERE ORGANIZATION_ID = WK_ORG_ID
                                                                        AND ALTERNATE_BOM_DESIGNATOR = 'MPL')));
        WK_CHK_UPDATE_3 := sql%rowcount;
    END;

    BEGIN
        --UPDATE KATABAN CODE W/O BOM SETUP
        UPDATE TIPEHDD_PHYSINV_REGISTDATA_IF
        SET PROCESS_FLAG = 3,
            ATTRIBUTE1 = 'NO_BOM_SETUP_TYPC'
        WHERE TYPE_CODE IN  (SELECT TYPE_CODE
                             FROM   (SELECT TYPE_CODE,INVENTORY_ITEM_ID
                                        FROM ( SELECT A.TYPE_CODE, B.INVENTORY_ITEM_ID
                                                FROM TIPEHDD_PHYSINV_REGISTDATA_IF A,
                                                     MTL_SYSTEM_ITEMS B
                                                WHERE A.ASSY_TYPE = WK_ASSY_HDA
                                                AND REGEXP_LIKE (A.TAG_NUMBER, WK_TAG_NUMBER)
                                                AND A.TYPE_CODE = B.SEGMENT1
                                                AND A.ORG_ID = B.ORGANIZATION_ID
                                                AND B.ORGANIZATION_ID = WK_ORG_ID
                                                AND A.TYPE_CODE IN (SELECT SEGMENT1
                                                                        FROM APPS.MTL_SYSTEM_ITEMS
                                                                        WHERE ORGANIZATION_ID = WK_ORG_ID )
                                                GROUP BY    A.TYPE_CODE,B.INVENTORY_ITEM_ID)
                                                WHERE INVENTORY_ITEM_ID NOT IN (SELECT ASSEMBLY_ITEM_ID
                                                                                FROM APPS.BOM_BILL_OF_MATERIALS
                                                                                WHERE ORGANIZATION_ID = WK_ORG_ID
                                                                                AND ALTERNATE_BOM_DESIGNATOR = 'MPL')));
        WK_CHK_UPDATE_4 := sql%rowcount;
    END;

    --Add Start Lib_ver.4.03
    BEGIN
        --UPDATE MISMATCH KATABAN_CODE WITH ASSY TYPE
        UPDATE  TIPEHDD_PHYSINV_REGISTDATA_IF
        SET     PROCESS_FLAG = 3,
                ATTRIBUTE1 = 'MISMATCH ASSY_TYPE'
        WHERE   assy_type =  WK_ASSY_SFG
        AND     kataban_code LIKE '%' || WK_ASSY_HDA || '%';

        WK_CHK_UPDATE_5 := sql%rowcount;
    END;

    BEGIN
        UPDATE  TIPEHDD_PHYSINV_REGISTDATA_IF
        SET     PROCESS_FLAG = 3,
                ATTRIBUTE1 = 'MISMATCH ASSY_TYPE'
        WHERE   assy_type = WK_ASSY_HDA
        AND     type_code LIKE '%' || WK_ASSY_HDE || '%';

        WK_CHK_UPDATE_6 := sql%rowcount;
    END;
    --Add End Lib_ver.4.03

    COMMIT;

        o_no_msi_cnt := WK_CHK_UPDATE_1 + WK_CHK_UPDATE_2;
        o_no_bom_cnt := WK_CHK_UPDATE_3 + WK_CHK_UPDATE_4;
        --Add Start Lib_ver.4.03
        o_ng_assy_type :=  WK_CHK_UPDATE_5 + WK_CHK_UPDATE_6;
        --Add End Lib_ver.4.03

    END PROC_CHECK_ITEM_SETUP;

--============================================================
-- PROCEDURE_NAME    : PROC_INS_BOM_REP
-- ARGUMENTS         : KATABAN and TYPE CODE
-- CREATED           : 2019-05-07
--============================================================
PROCEDURE    PROC_INS_BOM_REP(
              iv_assy_type      IN      VARCHAR2
             ,iv_process_name   IN      VARCHAR2
             ,iv_kataban_code   IN      VARCHAR2
             ,iv_type_code      IN      VARCHAR2
             ,iv_inv_count_qty  IN      NUMBER
             ,iv_inv_count_type IN      VARCHAR2
             ,iv_tag_number     IN      VARCHAR2
             ,iv_location_name  IN      VARCHAR2
             ,iv_u_code         IN      VARCHAR2
             ,iv_interface_type IN      VARCHAR2
             ,iv_model          IN      VARCHAR2
             ,iv_platter        IN      VARCHAR2

)
IS

    --ASSIGN VARIABLE
    WK_ORG_ID           NUMBER;
    WK_USER_ID          NUMBER;
    WK_START_TIME       VARCHAR2(20);

    WK_ITEM_ID          NUMBER;
    WK_ASSY_ID          NUMBER;
    WK_KATABAN_CODE     VARCHAR2(50);
    WK_TYPE_CODE        VARCHAR2(30);
    WK_ASSY_TYPE        VARCHAR2(30);
    WK_ATTRIBUTE1       VARCHAR2(50);

    WK_INS_CNT          NUMBER;
    WK_START_TIME       VARCHAR2(20);
    WK_END_TIME         VARCHAR2(20);

    --ERROR CODE
    WK_ERROR_CODE       VARCHAR2(20);
    WK_ERROR_MESSAGE    VARCHAR2(100);


BEGIN

    WK_ORG_ID           := 132;
    WK_USER_ID          := fnd_global.USER_ID;
    WK_ASSY_TYPE        := iv_assy_type;
    WK_ATTRIBUTE1       := 'INSERT_BOMREP';

        IF WK_ASSY_TYPE = 'SFG' THEN
        --CHECKING OF SET-UP IN MSI

            BEGIN
                SELECT SEGMENT1,INVENTORY_ITEM_ID
                INTO WK_KATABAN_CODE ,WK_ITEM_ID
                FROM MTL_SYSTEM_ITEMS
                WHERE ORGANIZATION_ID = 132
                AND SEGMENT1 = iv_kataban_code;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                WK_ERROR_MESSAGE := 'NO set-up in MSI';
                WK_ERROR_CODE := 'E';
            END;

             BEGIN
                --CHECKING OF BOM SET-UP
                SELECT ASSEMBLY_ITEM_ID
                INTO WK_ASSY_ID
                FROM BOM_BILL_OF_MATERIALS
                WHERE ORGANIZATION_ID = 132
                AND ALTERNATE_BOM_DESIGNATOR = 'MPL'
                AND ASSEMBLY_ITEM_ID = WK_ITEM_ID;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                WK_ERROR_MESSAGE := 'NO set-up in BOM';
                WK_ERROR_CODE := 'E';
            END;

            BEGIN
                INSERT INTO TIPEHDD_PHYSINV_REGISTDATA_IF
                                    (org_id
                                    ,assy_type
                                    ,process_name
                                    ,kataban_code
                                    ,type_code
                                    ,inv_count_qty
                                    ,inv_count_type
                                    ,tag_number
                                    ,location_name
                                    ,u_code
                                    ,interface_type
                                    ,model
                                    ,platter
                                    ,process_flag
                                    ,attribute1
                                    ,created_by )
                 VALUES
                                    (WK_ORG_ID
                                    ,iv_assy_type
                                    ,iv_process_name
                                    ,WK_KATABAN_CODE
                                    ,NULL
                                    ,iv_inv_count_qty
                                    ,iv_inv_count_type
                                    ,iv_tag_number
                                    ,iv_location_name
                                    ,iv_u_code
                                    ,iv_interface_type
                                    ,iv_model
                                    ,iv_platter
                                    ,0
                                    ,'INSERT_BOMREP'
                                    ,WK_USER_ID);
            END;

        ELSIF WK_ASSY_TYPE = 'HDA' THEN

            BEGIN
                SELECT SEGMENT1,INVENTORY_ITEM_ID
                INTO WK_TYPE_CODE, WK_ITEM_ID
                FROM MTL_SYSTEM_ITEMS
                WHERE ORGANIZATION_ID = 132
                AND SEGMENT1 = iv_type_code ;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                WK_ERROR_MESSAGE := 'NO set-up in MSI';
                WK_ERROR_CODE := 'E';
            END;

             BEGIN
                --CHECKING OF BOM SET-UP
                SELECT ASSEMBLY_ITEM_ID
                INTO WK_ASSY_ID
                FROM BOM_BILL_OF_MATERIALS
                WHERE ORGANIZATION_ID = 132
                AND ALTERNATE_BOM_DESIGNATOR = 'MPL'
                AND ASSEMBLY_ITEM_ID = WK_ITEM_ID;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                WK_ERROR_MESSAGE := 'NO set-up in BOM';
                WK_ERROR_CODE := 'E';
            END;

            BEGIN
                INSERT INTO TIPEHDD_PHYSINV_REGISTDATA_IF
                                    (org_id
                                    ,assy_type
                                    ,process_name
                                    ,kataban_code
                                    ,type_code
                                    ,inv_count_qty
                                    ,inv_count_type
                                    ,tag_number
                                    ,location_name
                                    ,u_code
                                    ,interface_type
                                    ,model
                                    ,platter
                                    ,process_flag
                                    ,attribute1
                                    ,created_by )
                 VALUES
                                    (WK_ORG_ID
                                    ,iv_assy_type
                                    ,iv_process_name
                                    ,NULL
                                    ,WK_TYPE_CODE
                                    ,iv_inv_count_qty
                                    ,iv_inv_count_type
                                    ,iv_tag_number
                                    ,iv_location_name
                                    ,iv_u_code
                                    ,iv_interface_type
                                    ,iv_model
                                    ,iv_platter
                                    ,0
                                    ,'INSERT_BOMREP'
                                    ,WK_USER_ID);
            END;

    END IF;


    IF  (WK_ERROR_CODE = 'E') THEN
            raise_application_error(-20000,(WK_ERROR_MESSAGE));
    END IF;

EXCEPTION
    WHEN OTHERS THEN
    raise_application_error(-20102,'Error -'||SQLCODE||'-'||sqlerrm);

    COMMIT;

END PROC_INS_BOM_REP;

--Add start Lib_ver.4.4
PROCEDURE  PROC_FGIS_REG_COUNT
        (
            p_org_id               NUMBER                   --organization id
           ,p_physinv_id           NUMBER   DEFAULT NULL    --physical inventory id
           ,p_excld_process        VARCHAR2
           ,p_fg_tag               VARCHAR2
           ,o_ins_cnt       OUT    VARCHAR2
           ,o_rga_cnt       OUT    VARCHAR2
           ,o_error_cnt     OUT    VARCHAR2
        )


--Add end Lib_ver.4.4
IS
--=====================================
-- DECLARATION OF  LOCAL WORK VARIABLE
--=====================================
    --TIME VARIABLE
    WK_START_TIME       VARCHAR2(20);
    WK_END_TIME         VARCHAR2(20);

    --USER, ORGANIZATION, PROCESS TYPE VARIABLE
    WK_USER_ID          NUMBER;
    WK_ORG_ID           NUMBER;
    WK_PROCESS_TYPE_ID  NUMBER;

    --PHYSICAL INVENTORY VARIABLE
    WK_PHYS_SUBINV_NAME VARCHAR2(40);
    WK_PHYSINV_ID       NUMBER;

    --ERROR VARIABLE
    WK_SQLCODE          NUMBER;
    WK_SQLERRM          VARCHAR2(4000);
    WK_MESSAGE          VARCHAR2(2000);

    --COUNT VARIABLE
--    WK_INS_CNT          NUMBER;
--    WK_RGA_CNT          NUMBER;
--    WK_ERR_CNT          NUMBER;
    WK_NO_MSI_CNT       NUMBER;
    WK_NO_BOM_CNT       NUMBER;
    WK_REGIST_COUNT     NUMBER;
    WK_FG_EX_PROCESS    VARCHAR2(50);
    WK_FG_TAG_NUM       VARCHAR2(50);


    V_ERR_FLAG    VARCHAR2(20) := 'N';
    V_SALES_CODE  VARCHAR2(50);
    V_SALES_ID    NUMBER;
    WK_ITEM_ID   MTL_SYSTEM_ITEMS.INVENTORY_ITEM_ID%TYPE;

   CURSOR GETLINEDATA
   IS
        SELECT ORG_ID,
               ASSY_TYPE,
               PROCESS_NAME,
               KATABAN_CODE,
               TAG_NUMBER,
               INV_COUNT_QTY
          FROM TIPEHDD_PHYSINV_REGISTDATA_IF
         WHERE     PROCESS_FLAG = 0
--               AND TAG_NUMBER LIKE '%G'
--               AND PROCESS_NAME NOT LIKE '%RGA%';
               AND REGEXP_LIKE(TAG_NUMBER,WK_FG_TAG_NUM)
               AND NOT REGEXP_LIKE(PROCESS_NAME,WK_FG_EX_PROCESS);

   R1           GETLINEDATA%ROWTYPE;

BEGIN
    --ASSIGN START TIME
    WK_START_TIME    :=    TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS');

    --ASSIGN INPUT VARIABLE
    WK_USER_ID := fnd_global.USER_ID;
    WK_ORG_ID  := P_ORG_ID;
    WK_PHYSINV_ID := P_PHYSINV_ID;
    WK_FG_EX_PROCESS := p_excld_process;
    WK_FG_TAG_NUM    := p_fg_tag;

      --CHECKING OF REGIST DATA
    BEGIN
        SELECT COUNT(*)
        INTO WK_REGIST_COUNT
        FROM TIPEHDD_PHYSINV_REGISTDATA_IF
        WHERE PROCESS_FLAG = 0
        AND REGEXP_LIKE(TAG_NUMBER,WK_FG_TAG_NUM)
        AND NOT REGEXP_LIKE(PROCESS_NAME,WK_FG_EX_PROCESS);

        IF  WK_REGIST_COUNT < 1 THEN
            fnd_file.put_line(fnd_file.output,'Completed with errors.');
            fnd_file.put_line(fnd_file.output,'Message     = ' ||'No FGIS data was found in REGIST DATA Interface');
        END IF;
    END;


    BEGIN

       OPEN GETLINEDATA;

       LOOP
          FETCH GETLINEDATA INTO R1;

          EXIT WHEN GETLINEDATA%NOTFOUND;

          BEGIN
               SELECT INVENTORY_ITEM_ID
               INTO WK_ITEM_ID
               FROM MTL_SYSTEM_ITEMS
               WHERE ORGANIZATION_ID = R1.ORG_ID
               AND SEGMENT1 = R1.KATABAN_CODE;

          EXCEPTION
                WHEN NO_DATA_FOUND THEN
                V_ERR_FLAG := 'Y';

                UPDATE TIPEHDD_PHYSINV_REGISTDATA_IF
                SET PROCESS_FLAG = 3,
                    ATTRIBUTE1 = 'NO_MSI_SETUP_KTBN'
                WHERE KATABAN_CODE   = R1.KATABAN_CODE
                AND TAG_NUMBER = R1.TAG_NUMBER
                AND ASSY_TYPE = R1.ASSY_TYPE;

                fnd_file.put_line(fnd_file.output,'Message     = ' ||'No setup in MSI data was found (MFG code) : ' || R1.KATABAN_CODE);
          END;

          BEGIN
               SELECT SALES_CODE
               INTO V_SALES_CODE
               FROM TIP_INV_ASSEMBLY_ITEM
               WHERE ORGANIZATION_ID = R1.ORG_ID
               AND INVENTORY_ITEM_ID = WK_ITEM_ID;

          EXCEPTION
               WHEN NO_DATA_FOUND THEN
               V_SALES_CODE := NULL;
               V_ERR_FLAG := 'Y';

               UPDATE TIPEHDD_PHYSINV_REGISTDATA_IF
               SET PROCESS_FLAG = 3,
                   ATTRIBUTE1 = 'NO_SETUP_SALESCODE'
               WHERE KATABAN_CODE   = R1.KATABAN_CODE
               AND TAG_NUMBER = R1.TAG_NUMBER
               AND ASSY_TYPE = R1.ASSY_TYPE;

               fnd_file.put_line(fnd_file.output,'Message     = ' ||'No setup in Assembly item was found : ITEM_ID : ' || WK_ITEM_ID);
         END;

         BEGIN
             SELECT INVENTORY_ITEM_ID
             INTO V_SALES_ID
             FROM MTL_SYSTEM_ITEMS
             WHERE ORGANIZATION_ID = R1.ORG_ID
             AND SEGMENT1 = V_SALES_CODE;

         EXCEPTION
            WHEN NO_DATA_FOUND THEN
            V_SALES_ID := NULL;
            V_ERR_FLAG := 'Y';

            UPDATE TIPEHDD_PHYSINV_REGISTDATA_IF
            SET PROCESS_FLAG = 3,
                ATTRIBUTE1 = 'NO_MSI_SETUP_SALESCODE'
            WHERE KATABAN_CODE   = R1.KATABAN_CODE
            AND TAG_NUMBER = R1.TAG_NUMBER
            AND ASSY_TYPE = R1.ASSY_TYPE;

            fnd_file.put_line(fnd_file.output,'Message     = ' ||'No setup in MSI data was found (Sales Code): ' || V_SALES_CODE);

         END;

         IF V_ERR_FLAG = 'N' THEN

             INSERT INTO TIP_PHYSICAL_INVENTORY_COUNT (PHYSICAL_INVENTORY_ID,
                                                       SUBINVENTORY_NAME,
                                                       ITEM_TYPE,
                                                       INVENTORY_ITEM_ID,
                                                       COUNT_QTY,
                                                       PROCESS_FLAG,
                                                       ORGANIZATION_ID,
                                                       LOCATION,
                                                       ITEM_CODE,
                                                       CREATION_DATE,
                                                       CREATED_BY)
              VALUES (WK_PHYSINV_ID,
                      'EHDFIN',
                      'BUY',
                      V_SALES_ID,
                      R1.INV_COUNT_QTY,
                      '0',
                      R1.ORG_ID,
                      R1.PROCESS_NAME,
                      V_SALES_CODE,
                      SYSDATE,
                      WK_USER_ID);

            UPDATE TIPEHDD_PHYSINV_REGISTDATA_IF
            SET PROCESS_FLAG = 1
            WHERE KATABAN_CODE   = R1.KATABAN_CODE
            AND TAG_NUMBER = R1.TAG_NUMBER
            AND ASSY_TYPE = R1.ASSY_TYPE;
         END IF;

         COMMIT;

         V_ERR_FLAG := 'N';

         END LOOP;


         UPDATE TIPEHDD_PHYSINV_REGISTDATA_IF
         SET PROCESS_FLAG = 4,
             ATTRIBUTE1 = 'EXCLUDED'
         WHERE PROCESS_FLAG = 0
         AND REGEXP_LIKE(PROCESS_NAME,WK_FG_EX_PROCESS);

         COMMIT;
   END;

   BEGIN
        SELECT COUNT(*)
        INTO o_ins_cnt
        FROM TIPEHDD_PHYSINV_REGISTDATA_IF
        WHERE     PROCESS_FLAG = 1
        AND REGEXP_LIKE(TAG_NUMBER,WK_FG_TAG_NUM)
        AND NOT REGEXP_LIKE(PROCESS_NAME,WK_FG_EX_PROCESS);

        SELECT COUNT(*)
        INTO o_rga_cnt
        FROM TIPEHDD_PHYSINV_REGISTDATA_IF
        WHERE     PROCESS_FLAG = 4
        AND REGEXP_LIKE(PROCESS_NAME,WK_FG_EX_PROCESS);

        SELECT COUNT(*)
        INTO o_error_cnt
        FROM TIPEHDD_PHYSINV_REGISTDATA_IF
        WHERE     PROCESS_FLAG = 3
        AND REGEXP_LIKE(TAG_NUMBER,WK_FG_TAG_NUM)
        AND NOT REGEXP_LIKE(PROCESS_NAME,WK_FG_EX_PROCESS);
   END;

END PROC_FGIS_REG_COUNT;

PROCEDURE PROC_INS_CATEGORY(
           iv_item_code IN VARCHAR2
          ,iv_category  IN VARCHAR2
)
IS

    --ASSIGN VARIABLE
    WK_ORG_ID           NUMBER;
    WK_USER_ID          NUMBER;

    WK_KATABAN_CODE     VARCHAR2(50);
    WK_PROCESS_FLAG     VARCHAR2(50);
    --ERROR CODE
    WK_ERROR_CODE       VARCHAR2(20);
    WK_ERROR_MESSAGE    VARCHAR2(100);

BEGIN

    WK_ORG_ID           := 132;
    WK_USER_ID          := fnd_global.USER_ID;
    WK_PROCESS_FLAG     := '0';

    BEGIN
        SELECT SEGMENT1
        INTO WK_KATABAN_CODE
        FROM MTL_SYSTEM_ITEMS
        WHERE ORGANIZATION_ID = WK_ORG_ID
        AND SEGMENT1 = iv_item_code;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        WK_ERROR_MESSAGE := 'NO set-up in MSI';
        WK_ERROR_CODE := 'E';
        WK_PROCESS_FLAG     := '3';
    END;

    BEGIN
        INSERT INTO TIPEHDD_RAWMATS_MASTER
                    (ITEM_CODE
                    ,CATEGORY
                    ,CREATION_DATE
                    ,PROCESS_FLAG
                    ,ERROR_MESSAGE
                    ,CREATED_BY)
        VALUES      (iv_item_code
                    ,iv_category
                    ,SYSDATE
                    ,WK_PROCESS_FLAG
                    ,WK_ERROR_MESSAGE
                    ,WK_USER_ID);
    END;



    IF  (WK_ERROR_CODE = 'E') THEN
            COMMIT;
            raise_application_error(-20000,(WK_ERROR_MESSAGE));
--            raise_application_error(-20001,WK_ERROR_MESSAGE);
----            raise_application_error(WK_ERROR_MESSAGE);
    ELSE
        COMMIT;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
    raise_application_error(-20102,'Error -'||SQLCODE||'-'||sqlerrm);



END PROC_INS_CATEGORY;
-- Add end Lib_Ver.4.04

END TIPEHDPIPROC010;
/
