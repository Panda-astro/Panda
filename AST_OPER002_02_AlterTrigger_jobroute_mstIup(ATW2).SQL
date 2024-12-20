USE [ATW2_App]
GO
/****** Object:  Trigger [dbo].[jobroute_mstIup]    Script Date: 2024/11/26 下午 02:18:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* $Header: /ApplicationDB/Triggers/jobroute_mstIup.trg 75    10/26/18 3:32a Ychen1 $ */

/*

***************************************************************
*                                                             *
*                           NOTICE                            *
*                                                             *
*   THIS SOFTWARE IS THE PROPERTY OF AND CONTAINS             *
*   CONFIDENTIAL INFORMATION OF INFOR AND/OR ITS AFFILIATES   *
*   OR SUBSIDIARIES AND SHALL NOT BE DISCLOSED WITHOUT PRIOR  *
*   WRITTEN PERMISSION. LICENSED CUSTOMERS MAY COPY AND       *
*   ADAPT THIS SOFTWARE FOR THEIR OWN USE IN ACCORDANCE WITH  *
*   THE TERMS OF THEIR SOFTWARE LICENSE AGREEMENT.            *
*   ALL OTHER RIGHTS RESERVED.                                *
*                                                             *
*   (c) COPYRIGHT 2010 INFOR.  ALL RIGHTS RESERVED.           *
*   THE WORD AND DESIGN MARKS SET FORTH HEREIN ARE            *
*   TRADEMARKS AND/OR REGISTERED TRADEMARKS OF INFOR          *
*   AND/OR ITS AFFILIATES AND SUBSIDIARIES. ALL RIGHTS        *
*   RESERVED.  ALL OTHER TRADEMARKS LISTED HEREIN ARE         *
*   THE PROPERTY OF THEIR RESPECTIVE OWNERS.                  *
*                                                             *
***************************************************************

*/

/* $Archive: /ApplicationDB/Triggers/jobroute_mstIup.trg $
 *
 * SL9.01 75 248810 Ychen1 Fri Oct 26 03:32:14 2018
 * Issue 248810 - Add dbo schema to SP
 *
 * SL9.01.00 74 246873 pgross Tue Jul 24 11:22:33 2018
 * Costing anlaysis alternate copy times out with performance issue
 * minimize overhead of non-indexed search
 *
 * SL9.01 73 RS7102 jkmalaluan Thu Jan 07 06:01:45 2016
 * RS7102-Modified File from Light's tool
 *
 * SL9.01 72 202157 Ehe Thu Sep 10 22:24:52 2015
 * Error message populate when copy BOM
 * 202157 Change the logic of jobroute_mstIup to insert into @TRMatl with distinct jobmatl.RowPointer.
 *
 * SL9.01 71 190392 jhoffman Wed Aug 26 08:38:12 2015
 * Job Material requirement dates are wrong after operation completion
 * MSF 190392 - Fixed file encoding
 *
 * SL9.00 69 184279 Ychen1 Thu Sep 11 02:49:26 2014
 * Code review: form cleanup
 * 184279: Create for  jrt_item if the job is estimate job.
 *
 * SL9.00 68 184286 Ychen1 Tue Sep 02 02:32:01 2014
 * Code Review: Jobroute_mstIup trigger
 * 184286: Amend the message to show more information about job/suffix/opernum.
 *
 * SL9.00 67 178841 Ychen1 Fri Jul 25 03:58:16 2014
 * RS6286 coding and schema
 * 178841(RS6286):If MO_seconds_per_cycle and MO_qty_per_cycle are defined, do not copyt from the main operation.
 *
 * SL9.00 66 178841 Ychen1 Thu Jul 24 23:26:04 2014
 * RS6286 coding and schema
 * 178841(RS6286):update jrt_sch.
 *
 * SL9.00 65 178841 Ychen1 Wed Jul 23 23:27:29 2014
 * RS6286 coding and schema
 * 178841:
 * 1. Add UM conversion
 * 2. Add co-job condition
 *
 * SL9.00 64 178841 Ychen1 Mon Jul 21 22:10:53 2014
 * RS6286 coding and schema
 * 178841(RS6286): Add some check to avoid share some operations.
 *
 * SL9.00 63 178841 Ychen1 Wed Jul 09 03:05:21 2014
 * RS6286 coding and schema
 * 178841(RS6286): If the shared operation with suffix =0 is updated/inserted
 * 1. Update other operations with the same job number, oper num for jobroute
 * 2. Update other operations with the same job number, oper num for jrt_item
 * 3. Update other operations with the same job number, oper num for jrtresourcegroup
 *
 * SL9.00 62 178296 Dmartin Tue Jun 10 10:03:35 2014
 * MSF 178296 - RS 6284 - Added trigger logic for Charging Item
 *
 * SL9.00 61 170739 pgross Fri Oct 25 13:48:29 2013
 * Unable to update or add new operation to Production Schedule Release Operation
 * shift the quantity received to a new first operation
 *
 * SL8.04 60 167268 Ddeng Tue Aug 20 03:09:20 2013
 * Issue 167268: Use A as job type for Costing Analysis.
 *
 * SL8.04 59 151663 vanmmar Fri Jul 19 11:47:07 2013
 * Job Materials still planned when job operation is marked complete
 * 151663
 *
 * SL8.04 58 164502 Lliu Fri Jul 05 03:57:17 2013
 * Issue 164502: Align the code.
 *
 * SL8.04 57 164502 Lliu Fri Jul 05 01:58:57 2013
 * Issue 164502: add loop in the costing alternative area.
 *
 * SL8.04 56 164502 Lliu Thu Jul 04 03:32:08 2013
 * Issue 164502: Delete redundant code.
 *
 * SL8.04 55 164502 Lliu Wed Jul 03 02:04:14 2013
 * Rol Up flag is not enabling on updated Materials or Operations
 * Issue 164502: Add logic to update cost_roll_up_flag in costing_alt_item_mst when the job?s type is ?C?
 *
 * SL8.04 54 RS4615 Jmtao Mon Feb 04 03:24:01 2013
 * RS4615 add the index hints back
 *
 * SL8.04 53 156326 Lzhan Tue Jan 29 08:13:44 2013
 * Issue 156326: re-incorporate sps into triggers.
 *
 * SL8.04 52 RS4615 Jmtao Thu Dec 06 21:50:34 2012
 * RS4615(Multi - Add Site within a Site Functionality).
 *
 * SL8.04 51 RS5860 gwang Mon Nov 26 02:09:07 2012
 * RS5860 merge triggers to base for Printing and Packaging.
 *
 * SL8.03 50 142052 pgross Thu Sep 01 10:24:13 2011
 * Complete? flag not being checked automatically
 * pass complete flag to jobroute_mstIupSub1Sp
 *
 * SL8.03 49 141925 btian Tue Aug 30 05:07:26 2011
 * code review notes
 * 141925, optimize the script of update item shrink factor
 *
 * SL8.03 48 141543 vanmmar Mon Aug 29 15:15:18 2011
 * 141543
 *
 * SL8.03 47 140792 pgross Thu Aug 04 14:07:33 2011
 * When marking later op as control point, SL is unchecking complete flag on previous ops
 * added cntrl_point and complete to snapshot tables
 *
 * SL8.03 46 RS4843 Jgao1 Wed Jun 08 05:53:05 2011
 * RS4843: Remove judgement of @JobType='J'
 *
 * SL8.03 45 RS4843 Sxu Tue Jun 07 05:11:05 2011
 * RS4843 - Modify the UDT and cursor function
 *
 * SL8.03 44 RS4843 Jgao1 Thu Jun 02 03:49:08 2011
 * RS4843: Recalculate shrink factor when jobtype='J'
 *
 * SL8.03 43 RS4843 Sxu Wed Jun 01 21:53:46 2011
 * RS4843 - Modify the parameter definition
 *
 * SL8.03 42 132669 hpurayil Fri Oct 01 15:35:46 2010
 * RS4551-Core- Windows Mobile Solutions ( Home Page for Production Supervisor)
 * 132669 - RS4551 - SL Mobile Access(Alert when the Actual labor hour posting is more than planned and at least one subscriber exists.)
 *
 * SL8.01 40 rs3953 Dahn Tue Aug 26 13:09:54 2008
 * changing the copyright header (rs3953)
 *
 * SL8.01 39 rs3953 Dahn Mon Aug 18 14:15:12 2008
 * changing copyright information(RS3953)
 *
 * SL8.00 38 RS2968 nkaleel Fri Feb 23 07:19:59 2007
 * changing copyright information(RS2968)
 *
 * SL8.00 37 RS2968 prahaladarao.hs Wed Jul 12 10:16:06 2006
 * RS 2968, Name change CopyRight Update.
 *
 * SL8.00 36 90079 NThurn Mon Mar 27 12:29:37 2006
 * Change Cost Rates is taking 17 hours to process
 * Pass more parameters to jobroute_mstIupSub1Sp.  (90079)
 *
 * SL8.00 35 91130 djohnson Fri Jan 13 16:49:59 2006
 * Blocking/deadlocking.
 * Issue #91130, swap jobroute_FK2 check for existence of wc record to an uncommitted read in the trigger to reduce blocking.
 *
 * $NoKeywords: $
 */
ALTER TRIGGER [dbo].[jobroute_mstIup]
on [dbo].[jobroute_mst]
FOR INSERT, UPDATE
AS

IF @@ROWCOUNT = 0 RETURN

IF TRIGGER_NESTLEVEL(OBJECT_ID('dbo.jobroute_mstUpdatePenultimate')) > 0
   RETURN
SET NOCOUNT ON

-- Skip trigger operations as required.
IF dbo.SkipBaseTrigger() = 1
   RETURN

DECLARE
  @InsertFlag TINYINT
, @Severity   INT
, @Infobar    InfobarType
, @RID        RowPointerType
, @Wc         WcType
---ATW_RFID002
, @Site       SiteType
, @OldWc      WcType

SELECT @Site = prm.site
FROM parms AS prm with (readuncommitted)
WHERE prm.parm_key = 0
---

DECLARE @LocalSite SiteType
SELECT @LocalSite = parms.site
from parms

SET @Severity = 0


SELECT
   @InsertFlag = CASE
       WHEN EXISTS ( SELECT 1 FROM deleted ) THEN 0
       ELSE 1
   END

SET @RID = NEWID()

--  In order to reduce recompile times, much of the code in this
-- trigger has been moved off into subroutines.  The data from the
-- inserted and deleted routines is loaded to make this possible.

DECLARE
  @SavedState              LongListType
, @Partition               RowPointerType
, @update_qty_complete     ListYesNoType
, @update_qty_scrapped     ListYesNoType
, @update_effect_date      ListYesNoType
, @update_obs_date         ListYesNoType
, @update_wc               ListYesNoType
, @update_efficiency       ListYesNoType
, @update_qty_moved        ListYesNoType
, @update_run_hrs_t_lbr    ListYesNoType
, @update_run_hrs_t_mch    ListYesNoType
, @update_setup_hrs_t      ListYesNoType
, @update_complete         ListYesNoType
, @InsertStandardRoute     ListYesNoType
, @CostType                CostTypeType
, @CostingAlt              CostingAlternativeType
, @updateCojob             ListYesNoType
, @WCCount                 INT
, @FirstOperNum            OperNumType


IF UPDATE(qty_complete)
   SET @update_qty_complete = 1
ELSE
   SET @update_qty_complete = 0
IF UPDATE(qty_scrapped)
   SET @update_qty_scrapped = 1
ELSE
   SET @update_qty_scrapped = 0
IF UPDATE(effect_date)
   SET @update_effect_date = 1
ELSE
   SET @update_effect_date = 0
IF UPDATE(obs_date)
   SET @update_obs_date = 1
ELSE
   SET @update_obs_date = 0
IF UPDATE(wc)
   SET @update_wc = 1
ELSE
   SET @update_wc = 0

IF UPDATE(efficiency)
   SET @update_efficiency = 1
ELSE
   SET @update_efficiency = 0

IF UPDATE(qty_moved)
   SET @update_qty_moved = 1
ELSE
   SET @update_qty_moved = 0

IF UPDATE(run_hrs_t_lbr)
   SET @update_run_hrs_t_lbr = 1
ELSE
   SET @update_run_hrs_t_lbr = 0
IF UPDATE(run_hrs_t_mch)
   SET @update_run_hrs_t_mch = 1
ELSE
   SET @update_run_hrs_t_mch = 0
IF UPDATE(setup_hrs_t)
   SET @update_setup_hrs_t = 1
ELSE
   SET @update_setup_hrs_t = 0
IF UPDATE(complete)
   SET @update_complete = 1
ELSE
   SET @update_complete = 0

IF UPDATE(complete)
OR UPDATE(MO_shared)
OR UPDATE(bflush_type)
OR UPDATE(run_basis_lbr)
OR UPDATE(run_basis_mch)
OR UPDATE(cntrl_point)
OR UPDATE(setup_rate)
OR UPDATE(efficiency)
OR UPDATE(fovhd_rate_mch)
OR UPDATE(vovhd_rate_mch)
OR UPDATE(run_rate_lbr)
OR UPDATE(varovhd_rate)
OR UPDATE(fixovhd_rate)
OR UPDATE(yield)
OR UPDATE(wc)
   SET @updatecojob = 1
ELSE
   SET @updatecojob = 0

EXEC dbo.ApsSyncDeferSp @Infobar OUTPUT
, @Context = 'jobroute_mstIup'
SET @Partition = dbo.DefinedValue('ApsSyncDeferred')

DECLARE
  @InsertedJob             JobType
, @InsertedSuffix          SuffixType
, @InsertedOperNum         OperNumType
, @InsertedRowPointer      RowPointerType
, @InsertedWc              WcType
, @JobType                 JobTypeType
, @JobCoProductMix         CoProductMixType
, @JobStat                 JobStatusType
, @JobRowPointer           RowPointerType
, @InsertJrtSch            ShortDescType
, @JobQtyReleased          QtyUnitType
, @InsertedQtyScraped      QtyUnitType
, @InsertedQtyCompleted    QtyUnitType
, @DeletedQtyScraped       QtyUnitType
, @DeletedQtyCompleted     QtyUnitType
, @vCalledFromCopy         ListYesNoType
, @vCalledFromJob          ListYesNoType
, @CalledFromEWB           ListYesNoType -- Engineering WorkBench
, @JobItem                 ItemType
, @Item                    ItemType
, @OldEffectDate           DateType
, @NewEffectDate           DateType
, @OldObsDate              DateType
, @NewObsDate              DateType
, @OldCntrlPoint           ListYesNoType
, @NewCntrlPoint           ListYesNoType
, @OldComplete             ListYesNoType
, @NewComplete             ListYesNoType
, @OldFirstOperationRowPointer RowPointerType
, @OldFirstQtyReceived     QtyUnitType
, @Bflush_type             BflushTypeType
, @Run_basis_lbr           RunBasisLbrType
, @Run_basis_mch           RunBasisMchType
, @Setup_rate              RunRateType
, @Efficiency              EfficiencyType
, @Fovhd_rate_mch          OverheadRateType
, @Vovhd_rate_mch          OverheadRateType
, @Run_rate_lbr            RunRateType
, @Varovhd_rate            OverheadRateType
, @Fixovhd_rate            OverheadRateType
, @YieldField              YieldType
, @MOShared                ListYesNoType
, @Cntrl_point             ListYesNoType
, @OtherSuffix             SuffixType
, @OtherJobItem            ItemType
, @UM                      UMType
, @JobMatlItem             ItemType
, @MOFormulaMatlWgt        WeightType
, @MOFormulaMatlWgtUnits   WeightUnitsType
, @MOFormulaMatlWgtPct     MO_OperationWeightPercentType
, @MOMatlWgt               QtyUnitType
, @QtyForBase              QtyPerType
, @QtyConverted            QtyPerType
, @Rgid                    ApsResgroupType
, @QtyRes                  ResourcesType
, @Resactn                 ApsCodeType
, @ResSequence             ApsIntType
---AST_OPER002, Restrict 0 Crew/Machine Ratio, Excluding Outside WC
, @CrewMachRto             EcConvFactorType ---dec 9,6
, @OutSide                 ListYesNoType
, @SchedDrv                SchedDriverType  --20241218 added

DECLARE @NetChange TABLE (
  item nvarchar(40) PRIMARY KEY
)

SET @InsertJrtSch = 1

IF @InsertFlag = 1
BEGIN
   EXEC @Severity = dbo.GetVariableSp
      'vCalledFromCopy', 0, 1, @vCalledFromCopy OUTPUT, @Infobar OUTPUT
   IF @Severity != 0
      RETURN

   EXEC @Severity = dbo.GetVariableSp
      'vCalledFromJob', 0, 0, @vCalledFromJob OUTPUT, @Infobar OUTPUT
   IF @Severity != 0
      RETURN

   exec dbo.GetVariableSp
     @VariableName   = 'InsertJrtSch'
   , @DefaultValue   = 1
   , @DeleteVariable = 1
   , @VariableValue  = @InsertJrtSch OUTPUT
   , @Infobar        = @Infobar OUTPUT


   exec dbo.GetVariableSp
     @VariableName         = 'vCalledFromEngWB'
   , @DefaultValue         = 0
   , @DeleteVariable       = 0
   , @VariableValue        = @CalledFromEWB OUTPUT
   , @Infobar              = @Infobar OUTPUT

end -- if @InsertFlag = 1

-- Skip the whole cursor-loops if they won't do anything!
IF @InsertFlag = 1
-----ATW_RFID002, Export to MES DATA
OR @update_wc = 1
OR UPDATE(cntrl_point)  ---20220114 added
---
OR (@update_qty_complete = 1 or @update_qty_scrapped = 1)
OR @CalledFromEWB = 1
OR (@update_effect_date = 1 OR @update_obs_date = 1)
OR @update_complete = 1
BEGIN
-- define separately so that we can use INNER JOIN to workaround SQL OUTER JOIN bug
IF @InsertFlag = 1
   DECLARE inserted_crs CURSOR LOCAL STATIC FOR
   SELECT
    inserted.job
   ,inserted.suffix
   ,inserted.oper_num
   , inserted.wc
   ,inserted.RowPointer
   , job.type
   , job.co_product_mix
   , job.stat
   , job.RowPointer
   , job.qty_released
   , job.item
   , inserted.qty_complete
   , inserted.qty_scrapped
   , NULL
   , NULL
   , NULL
   , inserted.effect_date
   , NULL
   , inserted.obs_date
   , 0
   , inserted.cntrl_point
   , 0
   , inserted.complete
   , inserted.MO_shared
   , inserted.bflush_type
   , inserted.run_basis_lbr
   , inserted.run_basis_mch
   , inserted.cntrl_point
   , inserted.setup_rate
   , inserted.efficiency
   , inserted.fovhd_rate_mch
   , inserted.vovhd_rate_mch
   , inserted.run_rate_lbr
   , inserted.varovhd_rate
   , inserted.fixovhd_rate
   , inserted.yield
---AST_OPER002, Restrict 0 Crew/Machine Ratio, Excluding Outside WC
   , ISNULL(inserted.crew_mach_rto,0)
---
   FROM inserted
      INNER JOIN job ON
         job.job = inserted.job
         AND job.suffix = inserted.suffix
ELSE
   DECLARE inserted_crs CURSOR LOCAL STATIC FOR
   SELECT
    inserted.job
   , inserted.suffix
   , inserted.oper_num
   , inserted.wc
   , inserted.RowPointer
   , job.type
   , job.co_product_mix
   , job.stat
   , job.RowPointer
   , job.qty_released
   , job.item
   , inserted.qty_complete
   , inserted.qty_scrapped
   , deleted.qty_complete
   , deleted.qty_scrapped
   , deleted.effect_date
   , inserted.effect_date
   , deleted.obs_date
   , inserted.obs_date
   , deleted.cntrl_point
   , inserted.cntrl_point
   , deleted.complete
   , inserted.complete
   , inserted.MO_shared
   , inserted.bflush_type
   , inserted.run_basis_lbr
   , inserted.run_basis_mch
   , inserted.cntrl_point
   , inserted.setup_rate
   , inserted.efficiency
   , inserted.fovhd_rate_mch
   , inserted.vovhd_rate_mch
   , inserted.run_rate_lbr
   , inserted.varovhd_rate
   , inserted.fixovhd_rate
   , inserted.yield
---AST_OPER002, Restrict 0 Crew/Machine Ratio, Excluding Outside WC
   , ISNULL(inserted.crew_mach_rto,0)
---
   FROM inserted
      INNER JOIN job ON
         job.job = inserted.job
         AND job.suffix = inserted.suffix
      INNER JOIN deleted ON
          deleted.RowPointer = inserted.RowPointer

OPEN inserted_crs

WHILE 1 = 1
BEGIN
   fetch inserted_crs into
     @InsertedJob
   , @InsertedSuffix
   , @InsertedOperNum
   , @InsertedWc
   , @InsertedRowPointer
   , @JobType
   , @JobCoProductMix
   , @JobStat
   , @JobRowPointer
   , @JobQtyReleased
   , @JobItem
   , @InsertedQtyCompleted
   , @InsertedQtyScraped
   , @DeletedQtyCompleted
   , @DeletedQtyScraped
   , @OldEffectDate
   , @NewEffectDate
   , @OldObsDate
   , @NewObsDate
   , @OldCntrlPoint
   , @NewCntrlPoint
   , @OldComplete
   , @NewComplete
   , @MOShared
   , @Bflush_type
   , @Run_basis_lbr
   , @Run_basis_mch
   , @Cntrl_point
   , @Setup_rate
   , @Efficiency
   , @Fovhd_rate_mch
   , @Vovhd_rate_mch
   , @Run_rate_lbr
   , @Varovhd_rate
   , @Fixovhd_rate
   , @YieldField
---AST_OPER002, Restrict 0 Crew/Machine Ratio, Excluding Outside WC
   , @CrewMachRto
---
   if @@fetch_status <> 0
      break

   if @InsertJrtSch = 1 and @InsertFlag = 1
      INSERT INTO jrt_sch
        (job
        ,suffix
        ,oper_num)
       VALUES
        (@InsertedJob
        ,@InsertedSuffix
        ,@InsertedOperNum)

   IF @InsertFlag = 1 AND (@JobType = 'J' OR @JobType = 'E') AND @JobCoProductMix = 1
   BEGIN
      /* add jrt-item records */
      IF NOT EXISTS (SELECT 1 FROM jrt_item
                     WHERE job      = @InsertedJob
                       AND suffix   = @InsertedSuffix
                       AND oper_num = @InsertedOperNum)
      BEGIN
         INSERT INTO jrt_item (job, suffix, item, oper_num, labor_pct, mach_pct, material_pct)
         SELECT @InsertedJob, @InsertedSuffix, jobitem.item, @InsertedOperNum, 0, 0, 0
         FROM jobitem
         WHERE jobitem.job = @InsertedJob
           AND jobitem.suffix = @InsertedSuffix
      END

      IF @JobStat = 'R' AND @vCalledFromCopy <> 1 AND @vCalledFromJob <> 1
         UPDATE job SET stat = 'S'
         WHERE RowPointer = @JobRowPointer
   END

   IF @JobType = 'R' AND @JobStat = 'R' AND
      (@update_qty_complete = 1
      OR @update_qty_scrapped = 1)
   BEGIN
      /* unallocated using old values */
      update item
      set item.qty_allocjob = item.qty_allocjob
       - (jobmatl.matl_qty
       * (CASE WHEN jobmatl.units = 'L' THEN 1
       ELSE (@JobQtyReleased - @DeletedQtyCompleted - @DeletedQtyScraped) END))
       / (1 - jobmatl.scrap_fact)
      FROM item, jobmatl
      WHERE item.item = jobmatl.item
      and jobmatl.job = @InsertedJob
      and jobmatl.suffix = @InsertedSuffix
      and jobmatl.oper_num = @InsertedOperNum

     /* Allocate using new values */

      UPDATE item
      SET item.qty_allocjob = item.qty_allocjob
       + (jobmatl.matl_qty
       * (CASE WHEN jobmatl.units = 'L' THEN 1
       ELSE (@JobQtyReleased - @InsertedQtyCompleted - @InsertedQtyScraped) END))
       / (1 - jobmatl.scrap_fact)
      FROM item, jobmatl
      WHERE item.item = jobmatl.item
      and jobmatl.job = @InsertedJob
      and jobmatl.suffix = @InsertedSuffix
      and jobmatl.oper_num = @InsertedOperNum
   END


   IF @CalledFromEWB = 1
   BEGIN
      exec @Severity = dbo.EngWBCreateResourceGroupSp
        @Job     = @InsertedJob
      , @Suffix  = @InsertedSuffix
      , @OperNum = @InsertedOperNum
      , @JrtWc   = @InsertedWc
      , @Infobar = @Infobar  OUTPUT
      if @Severity <> 0 BREAK
   end

   IF @JobType = 'S'
   AND (ISNULL(@OldEffectDate, '1900-01-01') != ISNULL(@NewEffectDate, '1900-01-01')
   OR ISNULL(@OldObsDate, '1900-01-01') != ISNULL(@NewObsDate, '1900-01-01'))
   BEGIN
      -- buffer it up to minimize rework
      if not exists (select 1 from @NetChange where item = @JobItem)
         insert into @NetChange
         values (@JobItem)

      insert into @NetChange
      select distinct jobmatl.item
      from jobmatl
      where jobmatl.job = @InsertedJob
      and jobmatl.suffix = @InsertedSuffix
      and jobmatl.oper_num = @InsertedOperNum
      and not exists (select 1 from @NetChange where item = jobmatl.item)
   end

   IF @NewCntrlPoint = 1
   BEGIN
      if @OldComplete = 0 and @NewComplete = 1
      or @OldComplete = 1 and @NewComplete = 0
      or @OldCntrlPoint = 0 and @NewComplete = 1

      update jobroute
      set complete = @NewComplete
      where job = @InsertedJob
      and suffix = @InsertedSuffix
      and oper_num between (select isnull(max(oper_num),0) from jobroute
            where job = @InsertedJob
            and suffix = @InsertedSuffix
            and oper_num < @InsertedOperNum
            and cntrl_point = 1) + 1
         and (@InsertedOperNum - 1)
   end

   IF @OldComplete = 0 AND @NewComplete = 1
      DELETE production_batch_jobroute
      WHERE job = @InsertedJob
      AND suffix = @InsertedSuffix
      AND oper_num = @InsertedOperNum

   IF @InsertFlag = 1
   BEGIN
      if not exists (select 1 from jobroute with (readuncommitted)
         where jobroute.job = @InsertedJob
         and jobroute.suffix = @InsertedSuffix
         and jobroute.oper_num < @InsertedOperNum)
         begin
            set @OldFirstOperationRowPointer = null
            set @OldFirstQtyReceived = null
            select top 1
              @OldFirstOperationRowPointer = case
               when jobroute.qty_complete = 0
                  and jobroute.qty_scrapped = 0
                  and jobroute.qty_moved = 0
                  and jobroute.setup_hrs_t = 0
                  and jobroute.setup_cost_t = 0
                  and jobroute.run_hrs_t_lbr = 0
                  and jobroute.run_cost_t_lbr = 0
                  and jobroute.run_hrs_t_mch = 0
                  then jobroute.RowPointer
                  else null
                  end
            , @OldFirstQtyReceived = jobroute.qty_received
            from jobroute with (readuncommitted)
            where jobroute.job = @InsertedJob
            and jobroute.suffix = @InsertedSuffix
            and jobroute.oper_num > @InsertedOperNum
            order by jobroute.oper_num

            if @OldFirstOperationRowPointer is not null
            and @OldFirstQtyReceived is not null
            and @OldFirstQtyReceived != 0
            begin
               update jobroute
               set qty_received = 0
               where RowPointer = @OldFirstOperationRowPointer

               update jobroute
               set qty_received = @OldFirstQtyReceived
               where RowPointer = @InsertedRowPointer
            end
         end
   END

-----ATW_RFID002, Export to MES DATA
   ---new create released job's job route
   ---20221111
   ---IF @InsertFlag = 1 AND @JobType = 'J' and @JobStat='R'
   IF @InsertFlag = 1 AND @JobType = 'J' and @JobStat in ('F','R')
      insert ast_jobroute_int (
            site_ref
           ,job
           ,suffix
           ,oper_num
           ,dispatch_type  ---ATW_RFID002, R:RFID Only, M:MES Only
           ,wc
           ,wc_desc
           ,cntrl_point
           ,erp_flag
           ,mes_flag
           ,erp_createdate
           ,mes_receivedate
      ) select
            @Site       ---site_ref
           ,@InsertedJob     ---,job
           ,@InsertedSuffix  ---,suffix
           ,jrt.oper_num ---,oper_num
           ,jrt.dispatch_type  ---,dispatch_type ---ATW_RFID002
           ,jrt.wc        ---,wc
           ,w.description ---,wc_desc
           ,jrt.cntrl_point  ---,cntrl_point
           ,'N'              ---,erp_flag
           ,NULL             ---,mes_flag
           ,getdate()        ---,erp_createdate
           ,NULL             ---,mes_receivedate
      from inserted as jrt
      left join wc as w on w.wc=jrt.wc
      where jrt.RowPointer=@InsertedRowPointer ---jrt.job=@InsertedJob and jrt.suffix=@InsertedSuffix and jrt.oper_num=@InsertedOperNum
      ---20220107,prevent duplicated
      ---20220211,allow insert again when last erp_fg='D' or not exist any 'N' data
      ---and not exists(select 1 from ast_jobroute_int where job=jrt.job and suffix=jrt.suffix and oper_num=jrt.oper_num and erp_flag='N')
      and ( not exists(select 1 from ast_jobroute_int where job=jrt.job and suffix=jrt.suffix and oper_num=jrt.oper_num and erp_flag='N')
           or (select top 1 erp_flag from ast_jobroute_int where job=jrt.job and suffix=jrt.suffix and oper_num=jrt.oper_num
               order by erp_createdate DESC)='D'
         )

   ---Changed released job's job route WC
   select @OldWc = ISNULL(dd.wc,@InsertedWc) from deleted as dd where dd.RowPointer=@InsertedRowPointer
   ---20220114 mod,export to MES with 'U' flag too,also when control point changed
   ---IF @InsertFlag = 0 AND @JobType = 'J' and @JobStat='R' and @InsertedWc<>@OldWc
   ----20221111
   ---IF @InsertFlag = 0 AND @JobType = 'J' and @JobStat='R' and (@InsertedWc<>@OldWc or @NewCntrlPoint<>@OldCntrlPoint)
   IF @InsertFlag = 0 AND @JobType = 'J' and @JobStat in ('F','R') and (@InsertedWc<>@OldWc or @NewCntrlPoint<>@OldCntrlPoint)
      insert ast_jobroute_int (
            site_ref
           ,job
           ,suffix
           ,oper_num
           ,wc
           ,wc_desc
           ,cntrl_point
           ,erp_flag
           ,mes_flag
           ,erp_createdate
           ,mes_receivedate
      ) select
            @Site       ---site_ref
           ,@InsertedJob     ---,job
           ,@InsertedSuffix  ---,suffix
           ,jrt.oper_num ---,oper_num
           ,jrt.wc        ---,wc
           ,w.description ---,wc_desc
           ,jrt.cntrl_point  ---,cntrl_point
           ---20220114 mod,export to MES when control point changed too
           ,'U'              ---,erp_flag
           ,NULL             ---,mes_flag
           ,getdate()        ---,erp_createdate
           ,NULL             ---,mes_receivedate
      from inserted as jrt
      left join wc as w on w.wc=jrt.wc
      where jrt.RowPointer=@InsertedRowPointer ---jrt.job=@InsertedJob and jrt.suffix=@InsertedSuffix and jrt.oper_num=@InsertedOperNum
      ---20221111 added
      and exists(select 1 from ast_jobroute_int where job=jrt.job and suffix=jrt.suffix and oper_num=jrt.oper_num)
-------
   ---AST_OPER002, Restrict 0 Crew/Machine Ratio, Excluding Outside WC
   select top 1 @Outside=ISNULL(outside,0) from wc where wc.wc=@InsertedWc
   ---20241218 added
   select top 1 @SchedDrv=sched_drv from jrt_sch where job=@InsertedJob and suffix=@InsertedSuffix and oper_num=@InsertedOperNum
   ---
   If @JobType='S' and @Outside=0 and @CrewMachRto=0
   ---20241218 added
   and @SchedDrv<>'L'
   and @InsertedWc not in ('OS1510','OS1511')
   BEGIN
      SET @Severity=16
      SET @Infobar=N'廠內製程人機比不可為0 !!!'
      BREAK
   END

END
CLOSE inserted_crs
DEALLOCATE inserted_crs

DECLARE netchangeCrs CURSOR LOCAL fast_forward FOR
SELECT item
FROM @NetChange

OPEN netchangeCrs

WHILE 1 = 1
BEGIN
   FETCH netchangeCrs INTO
     @Item

   IF @@fetch_status != 0
      break

   EXEC dbo.ItemSetNcSp
     @Item = @Item
END
CLOSE netchangeCrs
DEALLOCATE netchangeCrs

END

IF @Severity = 0
BEGIN
-- Date stamp and username retrieved once for performance.
DECLARE @Today DateType
SET @Today = dbo.GetSiteDate(GETDATE())
DECLARE @UserName LongListType
SET @UserName = dbo.UserNameSp()

-- make sure ORDER000 table gets new route information

INSERT INTO TrackRows (SessionId, RowPointer, TrackedOperType, CreateDate, CreatedBy)
select distinct
  @Partition
   , job.RowPointer
   , N'Sync job'
   , @Today
   , @UserName
from inserted
inner join job_mst job with (readuncommitted, index=PK_job_mst)
   on job.site_ref = @LocalSite
   AND job.job = inserted.job
   AND job.suffix = inserted.suffix
and not exists (select 1 from TrackRows with (readuncommitted) where RowPointer = job.RowPointer and SessionId = @Partition)
END
-- Replaces a foreign key check so that the existence check won't block.
IF @Severity = 0 AND UPDATE(wc)
BEGIN
   SELECT TOP 1 @Wc = ii.wc
   FROM inserted ii
   WHERE NOT EXISTS (
     SELECT 1
     FROM wc (readuncommitted)
     WHERE wc.wc = ii.wc)
   IF @Wc IS NOT NULL
   BEGIN
      SET @Infobar = NULL
      EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=NoExist1'
      , '@wc'
      , '@wc.wc'
      , @Wc
   END
END

IF @Severity != 0
BEGIN
   EXEC dbo.RaiseErrorSp @Infobar, @Severity, 1

   EXEC @Severity = dbo.RollbackTransactionSp
   @Severity

   IF @Severity != 0
   BEGIN
      ROLLBACK TRANSACTION
      RETURN
   END
END
set @InsertStandardRoute  = 0

if @insertFlag = 0
begin
   exec dbo.GetVariableSp
     @VariableName   = 'InsertStandardRoute'
   , @DefaultValue   = 0
   , @DeleteVariable = 0
   , @VariableValue  = @InsertStandardRoute OUTPUT
   , @Infobar        = @Infobar OUTPUT
end

if @InsertStandardRoute = 0 AND @Severity = 0
begin
   if @InsertFlag = 0 and @Severity = 0 and
      update(complete)
   begin

      declare
        @jobroute_dd table (
        job sysname
      , suffix SMALLINT
      , oper_num int
      , routeId sysname
      , RowPointer uniqueidentifier
      , unique (routeId, RowPointer)
      )

      declare
        @ApsSync TABLE (
        Key1 NVARCHAR(80)
      , Key2 NVARCHAR(80)
      , SyncType NVARCHAR(30)
      )

      insert into @jobroute_dd (job, suffix, oper_num, routeId, RowPointer)
      select job, suffix, oper_num, dbo.ApsRouteId(job, suffix), RowPointer
      from deleted

      insert into @ApsSync (Key1, Key2, SyncType)
      select JOBSTEP000.PROCPLANID, JOBSTEP000.JSID, 'Del Single Route'
      from @jobroute_dd deleted
      inner join JOBSTEP000 on JOBSTEP000.RefRowPointer = deleted.RowPointer

      insert into @ApsSync (Key1, Key2, SyncType)
      select
         job.item
       , deleted.RouteId
       , 'Del matlpps'
      from @jobroute_dd deleted
      join job on
       job.job = deleted.job and
       job.suffix = deleted.suffix

      insert into @ApsSync (Key1, Key2, SyncType)
      select JOBSTEP000.PROCPLANID,deleted.oper_num, 'Del Single Route BOM'
      from @jobroute_dd deleted
      inner join JOBSTEP000 on JOBSTEP000.RefRowPointer = deleted.RowPointer

      -- Special case for MRP parts, since they have no APS routes
      insert into @ApsSync (Key1, Key2, SyncType)
      select
         jobmatl.RowPointer
       , ''
       , 'Del Single Pbommatl'
      from @jobroute_dd deleted
      join jobmatl on
      jobmatl.job = deleted.job and
      jobmatl.suffix = deleted.suffix and
      jobmatl.oper_num = deleted.oper_num
      join job on
       job.job = deleted.job and
       job.suffix = deleted.suffix
      join item on job.item = item.item
      where
      item.mrp_part = 1 and
      job.type <> 'S'

      insert into tmp_aps_sync (SessionID, Key1, Key2, SyncType)
      select @Partition, Key1, Key2, SyncType
      from @ApsSync
      option (keepfixed plan)
   end

   if @Severity = 0 AND (update(effect_date) or
      update(obs_date) or
      update(wc) or
      update(efficiency) or
      update(qty_complete)  or
      update(qty_scrapped) or
      update(qty_moved) or
      update(run_hrs_t_lbr) or
      update(run_hrs_t_mch) or
      update(setup_hrs_t) or
      update(complete))
   begin
      DECLARE
        @jobroute_ii TABLE (
        job nvarchar(50)
      , suffix smallint
      , oper_num int
      , RowPointer uniqueidentifier
      , primary key (job, suffix, oper_num)
      , unique (RowPointer)
      )
      INSERT INTO @jobroute_ii (job, suffix, oper_num, RowPointer)
      SELECT distinct job, suffix, oper_num, RowPointer
      FROM inserted

      declare @TR table (
        RowPointer uniqueidentifier primary key
      , job nvarchar(20)
      , suffix int
      )

      declare @TRMatl table (
        RowPointer uniqueidentifier primary key
      )

      -- Only call for relevant change
      if @update_effect_date = 1
          or @update_obs_date = 1
          or @update_complete = 1
      begin
         insert into @TR
         select RowPointer, job, suffix
         from @jobroute_ii

         delete @TR from @TR as tr
            inner join TrackRows on
               TrackRows.RowPointer = tr.RowPointer
               and TrackRows.SessionId = @Partition

         insert into TrackRows (
            SessionId, RowPointer, TrackedOperType)
         select
            @Partition
           ,inserted.RowPointer
           ,'Sync jobroute'
         from @TR as inserted

         insert into @TRMatl
         select distinct jobmatl.RowPointer
         from @jobroute_ii as ii
            inner join jobmatl WITH (READUNCOMMITTED) on
               jobmatl.job = ii.job
               and jobmatl.suffix = ii.suffix

         delete @TRMatl from @TRMatl as tr
            inner join TrackRows on
               TrackRows.RowPointer = tr.RowPointer
               and TrackRows.SessionId = @Partition

         insert into TrackRows (
           SessionId, RowPointer, TrackedOperType)
         select
           @Partition
         , jobmatl.RowPointer
         , 'Sync jobmatl'
         from @TRMatl jobmatl
      end

      if @update_effect_date = 1 or
         @update_obs_date = 1 or
         @update_wc = 1 or
         @update_efficiency = 1 or
         @update_qty_complete = 1 or
         @update_qty_scrapped = 1 or
         @update_qty_moved = 1 or
         @update_run_hrs_t_lbr = 1 or
         @update_run_hrs_t_mch = 1 or
         @update_setup_hrs_t = 1 or
         @update_complete = 1
      begin
         if @update_effect_date = 0
         and @update_obs_date = 0
         and @update_complete = 0
            insert into @TR
            select RowPointer, job, suffix
            from @jobroute_ii

         delete @TR from @TR as tr
            inner join TrackRows on
               TrackRows.RowPointer = tr.RowPointer
               and TrackRows.SessionId = @Partition

         insert into TrackRows (
            SessionId, RowPointer, TrackedOperType)
         select
            @Partition
            ,inserted.RowPointer
            ,'Sync jobroute'
         from @TR as inserted
            inner join job on job.job = inserted.job and job.suffix = inserted.suffix
            inner join item WITH (READUNCOMMITTED) on item.item = job.item and item.mrp_part = 0
      end

      if @InsertFlag = 0 and
         @update_complete = 1
      begin
         delete BOM000
         from @jobroute_ii inserted
         join BOM000 on
--            BOM000.MATERIALID = dbo.ApsJobOrderId(inserted.job, inserted.suffix)
            BOM000.PROCPLANID = dbo.ApsRouteId(inserted.job, inserted.suffix)

         delete @TR

         insert into @TR
         select distinct job.RowPointer, job.job, job.suffix
         from @jobroute_ii as inserted
            inner join job on
               job.job = inserted.job
               and job.suffix = inserted.suffix

         delete @TR from @TR as tr
            inner join TrackRows on
               TrackRows.RowPointer = tr.RowPointer
               and TrackRows.SessionId = @Partition

         insert into TrackRows (
            SessionId, RowPointer, TrackedOperType)
         select
             @Partition
            ,tr.RowPointer
            ,'Sync job'
         from @TR as tr
      end

   end

end -- if @InsertStandardRoute = 0

IF @Severity <> 0
BEGIN
   EXEC dbo.RaiseErrorSp  @Infobar, @Severity, 10
   exec @Severity = dbo.RollbackTransactionSp
     @Severity
   if @Severity != 0
   begin
      rollback transaction
      return
   end
end

-- do let this SP wipe out the @Infobar value
exec dbo.ApsSyncImmediateSp @Infobar output
, @Context = 'jobroute_mstIup'

-- Maintenance of Audit-columns is now performed by the generated triggers jobrouteInsert and jobrouteUpdatePenultimate.

-- Maintenance of jobroute_all is now performed by the generated triggers jobrouteInsert and jobrouteUpdatePenultimate.

-- Alert Message
IF @InsertFlag = 0 and UPDATE(run_hrs_t_lbr)
BEGIN
  DECLARE
    @AJob            JobType
  , @ASuffix         SuffixType
  , @AOperNum        OperNumType
  , @PlannedRunHrs   TotalHoursType
  , @ActualRunHrs    TotalHoursType
  , @QtyReleased     QtyUnitType

  SELECT TOP 1
      @AJob             = ii.job
     ,@ASuffix          = ii.suffix
     ,@AOperNum         = ii.oper_num
     ,@ActualRunHrs     = ii.run_hrs_t_lbr
     ,@QtyReleased      = job.qty_released
     ,@PlannedRunHrs    = dbo.JobrouteRunDur(ii.job ,ii.suffix ,ii.oper_num, ii.efficiency)
     FROM inserted ii INNER JOIN job
     ON ii.job = job.job AND ii.suffix = job.suffix

   IF @AJob IS NOT NULL AND @ActualRunHrs > (@PlannedRunHrs * @QtyReleased)
     EXEC dbo.JobOperationHoursAlertSp
          @AJob
        , @ASuffix
        , @AOperNum
        , @PlannedRunHrs
        , @ActualRunHrs
        , @Infobar OUT
END

-- Update Item Shrink Factor
Declare
   @Job          JobType
  ,@JobSuffix    SuffixType
  ,@YieldAll     decimal(5,4)
  ,@Yield        YieldType
  ,@ShrinkFactor ShrinkFactorType

Set @YieldAll =1.0000

Select @JobType=job.[type], @Job=job.[job],@JobSuffix=job.suffix ,@Item=job.item
   from inserted id, [job]
   where id.job=job.[job] and id.suffix=job.suffix and job.type='S' and job.suffix='0'

If @JobType='S' and @JobSuffix='0'
Begin
   If exists (select 1 from jobroute where job =@job and suffix =@JobSuffix)
   Begin
      SELECT @YieldAll = @YieldAll * (yield/100)
      FROM jobroute
      WHERE job = @Job AND suffix = @JobSuffix

      SET @ShrinkFactor = 1 - @YieldAll

      update item
      set item.shrink_fact=@ShrinkFactor
      where item.item = @Item
      and (shrink_fact is null or shrink_fact != @ShrinkFactor)
  End
End
-- End Update Item Shrink Factor

-- Insert PP_jobroute (job, suffix, oper_num)
IF @InsertFlag = 1 and dbo.IsAddonAvailable('PrintingPack') = 1
BEGIN

INSERT PP_jobroute (
     job
   , suffix
   , oper_num
   , number_of_manual_handling_steps
   , number_of_sides_to_print
   )
   Select
     ii.job
   , ii.suffix
   , ii.oper_num
   , parm.number_of_manual_handling_steps
   , parm.number_of_sides_to_print
   FROM inserted ii
   INNER JOIN PP_Job Pjob on Pjob.job=ii.job and Pjob.suffix=ii.suffix
   INNER JOIN PP_parms parm on parm.parm_key = 0

END
-- End Insert PP_jobroute

--TYPE IS C,change the value of cost_roll_up_flag in costing_alt_item
IF EXISTS(SELECT 1 FROM inserted i
                   INNER JOIN job job
                   ON job.job = i.job and job.suffix = i.suffix
                   WHERE job.type = 'A')
BEGIN
   declare @Alt table (
     costing_alt CostingAlternativeType
   , item ItemType
   )

   insert into @Alt
   select costing_alt, job.item
   from inserted
      inner join job with (readuncommitted) on
         job.job = inserted.job
         and job.suffix = inserted.suffix
      inner join costing_alt_item with (readuncommitted) on
         costing_alt_item.item = job.item
         and costing_alt_item.job = inserted.job
         and costing_alt_item.suffix = inserted.suffix

   update costing_alt_item
   set cost_roll_up_flag = 1
   from @Alt as alt
   where alt.costing_alt = costing_alt_item.costing_alt
   and alt.item = costing_alt_item.item


   DECLARE CostingAltCrs cursor LOCAL STATIC FOR
   SELECT DISTINCT costing_alt
   FROM @Alt
   OPEN CostingAltCrs
   WHILE @Severity = 0
   BEGIN
      FETCH  CostingAltCrs
      INTO @CostingAlt

      IF @@FETCH_STATUS = -1
         BREAK

      SELECT @CostType = CASE cost_type WHEN 'A' THEN 0 ELSE 1 END
      FROM costing_alt
      WHERE costing_alt = @CostingAlt

      --Caculate the parents item.
      ;WITH Pitem AS
      (
      SELECT item
      FROM costing_alt_item
      WHERE cost_roll_up_flag = 1 AND costing_alt= @CostingAlt
      UNION ALL
      SELECT i.item
      FROM item i
      INNER JOIN job job on i.job = job.job AND job.suffix = @CostType AND job.type = 'S'
      INNER JOIN jobmatl j on j.job = job.job AND j.suffix = job.suffix
      INNER JOIN Pitem on Pitem.item = j.item
      )
      UPDATE costing_alt_item
         SET cost_roll_up_flag = 1
      FROM costing_alt_item c
      INNER JOIN Pitem p ON c.item = p.item
      WHERE c.cost_roll_up_flag <> 1 AND c.costing_alt= @CostingAlt
   END
   CLOSE CostingAltCrs
   DEALLOCATE CostingAltCrs
END

If dbo.IsAddonAvailable('MoldingPack') = 1
BEGIN

   -- If MO_formula_matl_weight_units is updated, recalculate the qty for material
   -- Do not allow to change the UM if the conversion between material UM failed
   IF @Severity = 0 AND UPDATE(MO_formula_matl_weight_units)
   BEGIN
      DECLARE jobWgt_crs CURSOR LOCAL STATIC FOR
         SELECT inserted.job
               ,inserted.suffix
               ,inserted.oper_num
               ,inserted.MO_formula_matl_weight
               ,inserted.MO_formula_matl_weight_units
               ,jobmatl.MO_formula_matl_weight_pct
               ,jobmatl.u_m
               ,jobmatl.item
         FROM inserted INNER JOIN jobmatl
         ON inserted.job = jobmatl.job AND inserted.suffix = jobmatl.suffix AND inserted.oper_num = jobmatl.oper_num

      OPEN jobWgt_crs

      WHILE 1 = 1
      BEGIN
            FETCH jobWgt_crs INTO
            @InsertedJob
          , @InsertedSuffix
          , @InsertedOperNum
          , @MOFormulaMatlWgt
          , @MOFormulaMatlWgtUnits
          , @MOFormulaMatlWgtPct
          , @UM
          , @JobMatlItem

            IF @@fetch_status <> 0
               break

         SET @MOMatlWgt = @MOFormulaMatlWgt * @MOFormulaMatlWgtPct / 100
         IF @MOMatlWgt > 0
         BEGIN
            EXEC @Severity = dbo.UMConvQtySp
                  @UM                =  @MOFormulaMatlWgtUnits
                  ,@Item              =  @JobMatlItem
                  ,@VendNum           =  NULL
                  ,@Area              =  NULL
                  ,@ConvertToBase     =  1
                  ,@QtyToBeConverted  =  @MOMatlWgt
                  ,@OutQty            =  @QtyForBase OUTPUT
                  ,@Infobar           =  @Infobar OUTPUT

            IF @Severity <> 0
            BEGIN
               CLOSE jobWgt_crs
               DEALLOCATE jobWgt_crs
               GOTO RaiseError
            END

            EXEC @Severity = dbo.UMConvQtySp
                  @UM                =  @UM
                  ,@Item              =  @JobMatlItem
                  ,@VendNum           =  NULL
                  ,@Area              =  NULL
                  ,@ConvertToBase     =  0
                  ,@QtyToBeConverted  =  @QtyForBase
                  ,@OutQty            =  @QtyConverted OUTPUT
                  ,@Infobar           =  @Infobar OUTPUT

            IF @Severity <> 0
            BEGIN
               CLOSE jobWgt_crs
               DEALLOCATE jobWgt_crs
               GOTO RaiseError
            END

            UPDATE jobmatl
            SET matl_qty_conv = @QtyConverted
            WHERE job = @InsertedJob AND suffix = @InsertedSuffix AND oper_num = @InsertedOperNum AND item = @JobMatlItem
         END
      END

      CLOSE jobWgt_crs
      DEALLOCATE jobWgt_crs
   END


   IF @Severity = 0 AND @updatecojob = 1
   BEGIN

      -- If a shared operation with suffix = 0 is set to unshared, then set other operations
      -- with the same job#, oper#, suffix <> 0 to unshared too.
      ;WITH MainSharedChangedOperation AS
      (
         SELECT deleted.job,
                deleted.suffix,
                deleted.oper_num
         FROM inserted
         INNER JOIN deleted
         ON deleted.RowPointer = inserted.RowPointer
         WHERE deleted.MO_shared = 1
         AND inserted.MO_shared = 0
         AND deleted.suffix = 0
      )
      UPDATE jobroute
      SET jobroute.MO_shared = 0
      FROM jobroute
      INNER JOIN MainSharedChangedOperation ON
      jobroute.job = MainSharedChangedOperation.job
      AND jobroute.oper_num = MainSharedChangedOperation.oper_num
      WHERE jobroute.suffix > 0

      -- If a shared operation with suffix = 0 is set to unshared, then delete them from jrt_item
      ;WITH MainSharedChangedOperation AS
      (
         SELECT deleted.job,
                deleted.suffix,
                deleted.oper_num
         FROM inserted
         INNER JOIN deleted
         ON deleted.RowPointer = inserted.RowPointer
         INNER JOIN job
         ON inserted.job = job.job AND inserted.suffix = job.suffix AND job.MO_co_job = 1
         WHERE deleted.MO_shared = 1
         AND inserted.MO_shared = 0
         AND deleted.suffix = 0
      )
      DELETE ji
      FROM jrt_item ji INNER JOIN MainSharedChangedOperation ON ji.job = MainSharedChangedOperation.job AND ji.oper_num = MainSharedChangedOperation.oper_num


      DECLARE insertedCoJob_crs CURSOR LOCAL STATIC FOR
      SELECT
         inserted.job
         , inserted.suffix
         , inserted.oper_num
         , inserted.wc
         , inserted.RowPointer
         , job.item
         , inserted.effect_date
         , inserted.obs_date
         , inserted.cntrl_point
         , inserted.complete
         , inserted.MO_shared
         , inserted.bflush_type
         , inserted.run_basis_lbr
         , inserted.run_basis_mch
         , inserted.cntrl_point
         , inserted.setup_rate
         , inserted.efficiency
         , inserted.fovhd_rate_mch
         , inserted.vovhd_rate_mch
         , inserted.run_rate_lbr
         , inserted.varovhd_rate
         , inserted.fixovhd_rate
         , inserted.yield
         FROM inserted
            INNER JOIN job ON
               job.job = inserted.job
               AND job.suffix = inserted.suffix
               AND job.MO_co_job = 1

      OPEN insertedCoJob_crs

      WHILE 1 = 1
      BEGIN
         FETCH insertedCoJob_crs INTO
         @InsertedJob
         , @InsertedSuffix
         , @InsertedOperNum
         , @InsertedWc
         , @InsertedRowPointer
         , @JobItem
         , @NewEffectDate
         , @NewObsDate
         , @NewCntrlPoint
         , @NewComplete
         , @MOShared
         , @Bflush_type
         , @Run_basis_lbr
         , @Run_basis_mch
         , @Cntrl_point
         , @Setup_rate
         , @Efficiency
         , @Fovhd_rate_mch
         , @Vovhd_rate_mch
         , @Run_rate_lbr
         , @Varovhd_rate
         , @Fixovhd_rate
         , @YieldField


         IF @@fetch_status <> 0
            break


      -- Do not allow to create an operation before the first shared operation.
      IF @MOShared = 0
      BEGIN
         SET @FirstOperNum = (SELECT MIN(oper_num)
                              FROM jobroute
                              INNER JOIN job
                              ON jobroute.job = job.job AND jobroute.suffix = job.suffix AND job.MO_co_job = 1
                              WHERE jobroute.job = @InsertedJob AND jobroute.suffix = @InsertedSuffix AND MO_shared = 1)

         IF @InsertedOperNum < @FirstOperNum
         BEGIN
               EXEC @Severity = dbo.MsgAppSp
                    @Infobar OUTPUT
                    ,'E=IsCompare2'
                    ,'@jobroute.MO_shared'
                    ,'@!No'
                    ,'@!FirstOperation'
                    ,'@job.MO_co_job'
                    ,@InsertedJob
                    ,'@jobtran.suffix'
                    ,0
         END
      END

      -- Do not allow to set to shared if WC is not the same for different suffix
      IF UPDATE(MO_shared) AND @MOShared = 1 AND @InsertedSuffix = 0
      BEGIN
         -- If the operation is set to shared, see if wc are the same with the same job#, oper#
         SET @WCCount = ( SELECT COUNT(DISTINCT wc)
                        FROM jobroute
                        INNER JOIN job
                        ON jobroute.job = job.job AND jobroute.suffix = job.suffix AND job.MO_co_job = 1
                        WHERE jobroute.job = @InsertedJob AND jobroute.oper_num = @InsertedOperNum AND jobroute.suffix <> @InsertedSuffix )
         IF @WCCount = 1
         BEGIN
            IF @InsertedWc <> ( SELECT DISTINCT wc
                              FROM jobroute
                              INNER JOIN job
                              ON jobroute.job = job.job AND jobroute.suffix = job.suffix AND job.MO_co_job = 1
                              WHERE jobroute.job = @InsertedJob AND jobroute.oper_num = @InsertedOperNum AND jobroute.suffix <> @InsertedSuffix )
            BEGIN
               EXEC @Severity = dbo.MsgAppSp
                  @Infobar OUTPUT
                  ,'E=SharedWithWC'
                  ,'@job.MO_co_job'
                  ,@InsertedJob
                  ,'@PP_quote_template_oper.oper_num'
                  ,@InsertedOperNum
            END
         END
         ELSE IF @WCCount > 1
         BEGIN
               EXEC @Severity = dbo.MsgAppSp
                  @Infobar OUTPUT
                  ,'E=SharedWithWC'
                  ,'@job.MO_co_job'
                  ,@InsertedJob
                  ,'@PP_quote_template_oper.oper_num'
                  ,@InsertedOperNum
         END
      END


      -- If the check failed, return error and don't allow to save the record
      IF @Severity <> 0
      BEGIN
         CLOSE insertedCoJob_crs
         DEALLOCATE insertedCoJob_crs
         GOTO RaiseError
      END

      -- If create a shared operation with suffix > 0, update the fields from operation with suffix = 0
      IF @MOShared = 1 AND @InsertedSuffix > 0 AND @InsertFlag = 1
      BEGIN
         --Update the general fields from jobroutes
         ;WITH MainSharedOperation AS
         (
            SELECT  jobroute.job            AS Job
                   ,jobroute.oper_num       AS OperNum
                   ,jobroute.MO_shared      AS MOShared
                   ,jobroute.complete       AS Complete
                   ,jobroute.bflush_type    AS BflushType
                   ,jobroute.run_basis_lbr  AS RunBasisLbr
                   ,jobroute.run_basis_mch  AS RunBasisMch
                   ,jobroute.cntrl_point    AS CntrlPoint
                   ,jobroute.setup_rate     AS SetupRate
                   ,jobroute.efficiency     AS Efficiency
                   ,jobroute.fovhd_rate_mch AS FovhdRateMch
                   ,jobroute.vovhd_rate_mch AS VovhdRateMch
                   ,jobroute.run_rate_lbr   AS RunRateLbr
                   ,jobroute.varovhd_rate   AS VarovhdRate
                   ,jobroute.fixovhd_rate   AS FixovhdRate
                   ,jobroute.yield          AS Yield
            FROM jobroute
            WHERE jobroute.job = @InsertedJob AND jobroute.oper_num = @InsertedOperNum AND jobroute.suffix = 0
         )
         UPDATE jobroute
         SET jobroute.complete        = MainSharedOperation.Complete
            ,jobroute.bflush_type     = MainSharedOperation.BflushType
            ,jobroute.run_basis_lbr   = MainSharedOperation.RunBasisLbr
            ,jobroute.run_basis_mch   = MainSharedOperation.RunBasisMch
            ,jobroute.cntrl_point     = MainSharedOperation.CntrlPoint
            ,jobroute.setup_rate      = MainSharedOperation.SetupRate
            ,jobroute.efficiency      = MainSharedOperation.Efficiency
            ,jobroute.fovhd_rate_mch  = MainSharedOperation.FovhdRateMch
            ,jobroute.vovhd_rate_mch  = MainSharedOperation.VovhdRateMch
            ,jobroute.run_rate_lbr    = MainSharedOperation.RunRateLbr
            ,jobroute.varovhd_rate    = MainSharedOperation.VarovhdRate
            ,jobroute.fixovhd_rate    = MainSharedOperation.FixovhdRate
            ,jobroute.yield           = MainSharedOperation.Yield
         FROM jobroute INNER JOIN MainSharedOperation
         ON jobroute.job = MainSharedOperation.Job AND jobroute.oper_num = MainSharedOperation.OperNum
         AND jobroute.suffix = @InsertedSuffix


        --insert into jrt_item
        IF NOT EXISTS (SELECT 1 FROM jrt_item WITH (readuncommitted)
                       WHERE jrt_item.job = @InsertedJob
                       AND jrt_item.suffix = @InsertedSuffix
                       AND jrt_item.oper_num = @InsertedOperNum
                       AND jrt_item.item = @JobItem)
        BEGIN
              INSERT INTO jrt_item
              (job, suffix, item, oper_num) VALUES
              (@InsertedJob, @InsertedSuffix, @JobItem, @InsertedOperNum)
        END

     -- Update resource group
        DELETE FROM jrtresourcegroup
        WHERE jrtresourcegroup.job = @InsertedJob
        AND jrtresourcegroup.oper_num = @InsertedOperNum
        AND jrtresourcegroup.suffix = @InsertedSuffix

        ;WITH MainSharedOperationRG AS
        (
           SELECT jrtresourcegroup.job            AS Job
                 , @InsertedSuffix                AS Suffix
                 , jrtresourcegroup.oper_num      AS Operation_Number
                 , jrtresourcegroup.rgid          AS Resource_Group_ID
                 , jrtresourcegroup.qty_resources As Quantity_Resources
                 , jrtresourcegroup.resactn       AS Resactn
                 , jrtresourcegroup.sequence      AS Sequence
           FROM jrtresourcegroup
           WHERE jrtresourcegroup.job = @InsertedJob
           AND jrtresourcegroup.oper_num = @InsertedOperNum
           AND jrtresourcegroup.suffix = 0
        )
        INSERT INTO jrtresourcegroup
        (job, suffix, oper_num, rgid, qty_resources, resactn, sequence)
        SELECT Job, Suffix, Operation_Number, Resource_Group_ID, Quantity_Resources, Resactn, Sequence
        FROM MainSharedOperationRG

      END

      -- If a shared operation with suffix = 0 is updated/created, update all other operation with the same job#, oper#
      IF @MOShared = 1 AND @InsertedSuffix = 0 AND @updateCojob = 1
      BEGIN
         DECLARE insertJrt_crs CURSOR LOCAL STATIC FOR
         SELECT jobroute.suffix
               ,job.item
            FROM jobroute
            INNER JOIN job ON jobroute.job = job.job AND jobroute.suffix = job.suffix AND job.MO_co_job = 1
            WHERE jobroute.job = @InsertedJob
            AND jobroute.oper_num = @InsertedOperNum

         OPEN insertJrt_crs

         WHILE 1=1
         BEGIN
            FETCH insertJrt_crs INTO
            @OtherSuffix
           ,@OtherJobItem

            IF @@fetch_status <> 0
               break

            -- If the operation doesn't exist in jrt_item, create a line
            IF NOT EXISTS (SELECT 1 FROM jrt_item WITH (readuncommitted)
                        WHERE jrt_item.job = @InsertedJob
                        AND jrt_item.suffix = @OtherSuffix
                        AND jrt_item.oper_num = @InsertedOperNum
                        AND jrt_item.item = @OtherJobItem)
            BEGIN
               INSERT INTO jrt_item
               (job, suffix, item, oper_num) VALUES
               (@InsertedJob, @OtherSuffix, @OtherJobItem, @InsertedOperNum)
            END
         END
         CLOSE insertJrt_crs
         DEALLOCATE insertJrt_crs

         -- If the fields are updated for shared operations with suffix = 0, then
         -- update other operations with the same job#, oper#, suffix <> 0
         IF EXISTS (SELECT 1 FROM jobroute INNER JOIN job ON jobroute.job = job.job AND jobroute.suffix = job.suffix AND job.MO_co_job = 1
         WHERE jobroute.job = @InsertedJob
         AND jobroute.oper_num = @InsertedOperNum
         AND jobroute.suffix > 0)
         BEGIN
            UPDATE jobroute
               SET jobroute.MO_shared       = @MOShared
                  ,jobroute.complete        = @NewComplete
                  ,jobroute.bflush_type     = @Bflush_type
                  ,jobroute.run_basis_lbr   = @Run_basis_lbr
                  ,jobroute.run_basis_mch   = @Run_basis_mch
                  ,jobroute.cntrl_point     = @Cntrl_point
                  ,jobroute.setup_rate      = @Setup_rate
                  ,jobroute.efficiency      = @Efficiency
                  ,jobroute.fovhd_rate_mch  = @Fovhd_rate_mch
                  ,jobroute.vovhd_rate_mch  = @Vovhd_rate_mch
                  ,jobroute.run_rate_lbr    = @Run_rate_lbr
                  ,jobroute.varovhd_rate    = @Varovhd_rate
                  ,jobroute.fixovhd_rate    = @Fixovhd_rate
                  ,jobroute.yield           = @YieldField
               FROM jobroute
               INNER JOIN job ON jobroute.job = job.job AND jobroute.suffix = job.suffix AND job.MO_co_job = 1
               WHERE jobroute.job = @InsertedJob AND jobroute.oper_num = @InsertedOperNum AND jobroute.suffix > 0
         END

         -- If the operation is updated to shared from unshared with suffix = 0, update the jrt_sch to other operations
         IF UPDATE(MO_shared) AND @MOShared = 1 AND @InsertedSuffix = 0
         BEGIN
            UPDATE tojrs
               SET tojrs.allow_reallocation   = fromjrs.allow_reallocation
                  ,tojrs.batch_definition_id  = fromjrs.batch_definition_id
                  ,tojrs.crsbrkrule           = fromjrs.crsbrkrule
                  ,tojrs.end_date             = fromjrs.end_date
                  ,tojrs.end_tick             = fromjrs.end_tick
                  ,tojrs.finish_hrs           = fromjrs.finish_hrs
                  ,tojrs.freeze_sch           = fromjrs.freeze_sch
                  ,tojrs.matrixtype           = fromjrs.matrixtype
                  ,tojrs.move_hrs             = fromjrs.move_hrs
                  ,tojrs.move_ticks           = fromjrs.move_ticks
                  ,tojrs.offset_hrs           = fromjrs.offset_hrs
                  ,tojrs.pcs_per_lbr_hr       = CASE WHEN( job.MO_qty_per_cycle > 0 AND jobroute.MO_seconds_per_cycle > 0)
                                                   THEN tojrs.pcs_per_lbr_hr
                                                ELSE fromjrs.pcs_per_lbr_hr END
                  ,tojrs.pcs_per_mch_hr       = CASE WHEN( job.MO_qty_per_cycle > 0 AND jobroute.MO_seconds_per_cycle > 0)
                                                   THEN tojrs.pcs_per_mch_hr
                                                ELSE fromjrs.pcs_per_mch_hr END
                  ,tojrs.plannerstep          = fromjrs.plannerstep
                  ,tojrs.prod_batch_id        = fromjrs.prod_batch_id
                  ,tojrs.queue_hrs            = fromjrs.queue_hrs
                  ,tojrs.queue_ticks          = fromjrs.queue_ticks
                  ,tojrs.run_lbr_hrs          = CASE WHEN( job.MO_qty_per_cycle > 0 AND jobroute.MO_seconds_per_cycle > 0)
                                                   THEN tojrs.pcs_per_mch_hr
                                                ELSE fromjrs.run_lbr_hrs END
                  ,tojrs.run_mch_hrs          = CASE WHEN( job.MO_qty_per_cycle > 0 AND jobroute.MO_seconds_per_cycle > 0)
                                                   THEN tojrs.run_mch_hrs
                                                ELSE fromjrs.run_mch_hrs END
                  ,tojrs.run_ticks_lbr        = fromjrs.run_ticks_lbr
                  ,tojrs.run_ticks_mch        = fromjrs.run_ticks_mch
                  ,tojrs.sched_drv            = fromjrs.sched_drv
                  ,tojrs.sched_off            = fromjrs.sched_off
                  ,tojrs.sched_hrs            = fromjrs.sched_hrs
                  ,tojrs.schedsteprule        = fromjrs.schedsteprule
                  ,tojrs.sched_ticks          = fromjrs.sched_ticks
                  ,tojrs.setup_hrs            = fromjrs.setup_hrs
                  ,tojrs.setuprgid            = fromjrs.setuprgid
                  ,tojrs.setuprule            = fromjrs.setuprule
                  ,tojrs.setup_ticks          = fromjrs.setup_ticks
                  ,tojrs.splitgroup           = fromjrs.splitgroup
                  ,tojrs.splitrule            = fromjrs.splitrule
                  ,tojrs.splitsize            = fromjrs.splitsize
                  ,tojrs.start_date           = fromjrs.start_date
                  ,tojrs.start_tick           = fromjrs.start_tick
                  ,tojrs.tabid                = fromjrs.tabid
                  ,tojrs.whenrule             = fromjrs.whenrule
               FROM jrt_sch tojrs
               INNER JOIN jrt_sch fromjrs ON fromjrs.job = tojrs.job AND fromjrs.suffix = 0 AND fromjrs.oper_num = tojrs.oper_num
               INNER JOIN job ON tojrs.job = job.job AND tojrs.suffix = job.suffix AND job.MO_co_job = 1
               INNER JOIN jobroute ON fromjrs.job = jobroute.job AND fromjrs.suffix = jobroute.suffix AND fromjrs.oper_num = jobroute.oper_num
               WHERE tojrs.job = @InsertedJob AND tojrs.oper_num = @InsertedOperNum AND tojrs.suffix > 0
         END

         --If resource group has been updated(insert/delete) for suffix = 0, update other operations with suffix > 0
         DELETE jsg FROM jrtresourcegroup jsg
         INNER JOIN job ON jsg.job = job.job AND jsg.suffix = job.suffix AND job.MO_co_job = 1
         WHERE jsg.job = @InsertedJob
         AND jsg.oper_num = @InsertedOperNum
         AND jsg.suffix > 0

         ;WITH SharedOperations AS
            (
               SELECT DISTINCT jobroute.job AS Job
                     , jobroute.suffix AS Suffix
                     , jobroute.oper_num AS Operation_Number
               FROM jobroute
               INNER JOIN job ON jobroute.job = job.job AND jobroute.suffix = job.suffix AND job.MO_co_job = 1
               WHERE jobroute.job = @InsertedJob
               AND jobroute.oper_num = @InsertedOperNum
               AND jobroute.suffix > 0
            )
            , MainSharedOperationRG AS
            (
               SELECT jrtresourcegroup.job AS Job
                     , jrtresourcegroup.suffix AS Suffix
                     , jrtresourcegroup.oper_num AS Operation_Number
                     , jrtresourcegroup.rgid AS Resource_Group_ID
                     , jrtresourcegroup.qty_resources As Quantity_Resources
                     , jrtresourcegroup.resactn AS Resactn
                     , jrtresourcegroup.sequence AS Sequence
               FROM jrtresourcegroup
               WHERE jrtresourcegroup.job = @InsertedJob
               AND jrtresourcegroup.oper_num = @InsertedOperNum
               AND jrtresourcegroup.suffix = 0
            )
            , WaitingInsertedRG AS
            (
               SELECT MainSharedOperationRG.Job, SharedOperations.Suffix, MainSharedOperationRG.Operation_Number,
               MainSharedOperationRG.Resource_Group_ID, MainSharedOperationRG.Quantity_Resources, MainSharedOperationRG.Resactn, MainSharedOperationRG.Sequence
               FROM SharedOperations
               INNER JOIN MainSharedOperationRG ON SharedOperations.Job = MainSharedOperationRG.Job AND SharedOperations.Operation_Number = MainSharedOperationRG.Operation_Number
            )
            INSERT INTO jrtresourcegroup
            (job, suffix, oper_num, rgid, qty_resources, resactn, sequence)
            SELECT Job, Suffix, Operation_Number, Resource_Group_ID, Quantity_Resources, Resactn, Sequence
            FROM WaitingInsertedRG

      END


      END
      CLOSE insertedCoJob_crs
      DEALLOCATE insertedCoJob_crs
   END


END

RaiseError:
IF @Severity <> 0
BEGIN
   EXEC dbo.RaiseErrorSp  @Infobar, @Severity, 10
   exec @Severity = dbo.RollbackTransactionSp
     @Severity
   if @Severity != 0
   begin
      rollback transaction
      return
   end
end



GO
EXEC sp_settriggerorder @triggername=N'[dbo].[jobroute_mstIup]', @order=N'First', @stmttype=N'INSERT'
GO
EXEC sp_settriggerorder @triggername=N'[dbo].[jobroute_mstIup]', @order=N'First', @stmttype=N'UPDATE'