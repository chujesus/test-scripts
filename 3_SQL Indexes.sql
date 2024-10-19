/***********************************************************************************************************************/
--F42119
/***********************************************************************************************************************/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F42119]') AND name = N'SC_F42119_01')
DROP INDEX [SC_F42119_01] ON [SCDATA].[F42119]

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F42119]') AND name = N'SC_F42119_01')
CREATE NONCLUSTERED INDEX [SC_F42119_01] ON [SCDATA].[F42119]
(
	[SDLNTY] ASC
)
INCLUDE ( 	[SDKCOO],
	[SDDOCO],
	[SDDCTO],
	[SDLNID],
	[SDSHAN],
	[SDITM],
	[SDNXTR],
	[SDLTTR]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
-----------------------------------------------------------------------------------------------------------------------------------

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F42119]') AND name = N'SC_F42119_02')
DROP INDEX [SC_F42119_02] ON [SCDATA].[F42119]

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F42119]') AND name = N'SC_F42119_02')
CREATE NONCLUSTERED INDEX [SC_F42119_02] ON [SCDATA].[F42119]
(
	[SDLNTY] ASC,
	[SDLTTR] ASC
)
INCLUDE ( 	[SDKCOO],
	[SDDOCO],
	[SDDCTO]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

-----------------------------------------------------------------------------------------------------------------------------------
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F42119]') AND name = N'SC_F42119_03')
DROP INDEX [SC_F42119_03] ON [SCDATA].[F42119]

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F42119]') AND name = N'SC_F42119_03')
CREATE NONCLUSTERED INDEX [SC_F42119_03] ON [SCDATA].[F42119]
(
	[SDAN8] ASC,
	[SDLNTY] ASC
)
INCLUDE ( 	[SDKCOO],
	[SDDOCO],
	[SDDCTO],
	[SDLNID],
	[SDMCU],
	[SDSHAN],
	[SDTRDJ],
	[SDADDJ],
	[SDITM],
	[SDLITM],
	[SDAITM],
	[SDLOCN],
	[SDLOTN],
	[SDDSC1],
	[SDDSC2],
	[SDNXTR],
	[SDLTTR],
	[SDEMCU],
	[SDRLIT],
	[SDUOM],
	[SDUORG],
	[SDSOQS],
	[SDSOBK],
	[SDUPRC],
	[SDAEXP],
	[SDTAX1],
	[SDTXA1],
	[SDEXR1],
	[SDUOM4],
	[SDFUP],
	[SDFEA]
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
-----------------------------------------------------------------------------------------------------------------------------------

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F42119]') AND name = N'SC_F42119_04')
DROP INDEX [SC_F42119_04] ON [SCDATA].[F42119]

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F42119]') AND name = N'SC_F42119_04')
CREATE NONCLUSTERED INDEX [SC_F42119_04] ON [SCDATA].[F42119]
(
	[SDOKCO] ASC,
	[SDOCTO] ASC,
	[SDLTTR] ASC
)
INCLUDE ( 	[SDKCOO],
	[SDDOCO],
	[SDDCTO],
	[SDMCU],
	[SDOORN],
	[SDOGNO],
	[SDTRDJ],
	[SDITM],
	[SDUOM],
	[SDSOQS]
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
-----------------------------------------------------------------------------------------------------------------------------------

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F42119]') AND name = N'SC_F42119_05')
DROP INDEX [SC_F42119_05] ON [SCDATA].[F42119]

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F42119]') AND name = N'SC_F42119_05')
CREATE NONCLUSTERED INDEX [SC_F42119_05] ON [SCDATA].[F42119]
(
	[SDLTTR] ASC
)
INCLUDE ( 	[SDDCTO],
	[SDLNID],
	[SDOKCO],
	[SDOORN],
	[SDOCTO],
	[SDOGNO],
	[SDSOQS]
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
-----------------------------------------------------------------------------------------------------------------------------------

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F42119]') AND name = N'SC_F42119_06')
DROP INDEX [SC_F42119_06] ON [SCDATA].[F42119]

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F4211]') AND name = N'SC_F42119_06')
CREATE NONCLUSTERED INDEX [SC_F42119_06] ON [SCDATA].[F42119]
(
	[SDSHAN] ASC,
	[SDRLIT] ASC
)
INCLUDE ( 	[SDKCOO],
	[SDDOCO],
	[SDDCTO],
	[SDNXTR],
	[SDLTTR]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
-----------------------------------------------------------------------------------------------------------------------------------

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F42119]') AND name = N'SC_F42119_07')
DROP INDEX [SC_F42119_07] ON [SCDATA].[F42119]

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F4211]') AND name = N'SC_F42119_07')
CREATE NONCLUSTERED INDEX [SC_F42119_07] ON [SCDATA].[F42119]
(
	[SDRLIT] ASC
)
INCLUDE ( 	[SDKCOO],
	[SDDOCO],
	[SDDCTO],
	[SDNXTR],
	[SDLTTR]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO

/***********************************************************************************************************************/
--F4211
/***********************************************************************************************************************/

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F4211]') AND name = N'SC_F4211_01')
DROP INDEX [SC_F4211_01] ON [SCDATA].[F4211]

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F4211]') AND name = N'SC_F4211_01')
CREATE NONCLUSTERED INDEX [SC_F4211_01] ON [SCDATA].[F4211]
(
	[SDLNTY] ASC
)
INCLUDE ( 	[SDKCOO],
	[SDDOCO],
	[SDDCTO],
	[SDLNID],
	[SDSHAN],
	[SDITM],
	[SDNXTR],
	[SDLTTR]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
-----------------------------------------------------------------------------------------------------------------------------------

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F4211]') AND name = N'SC_F4211_02')
DROP INDEX [SC_F4211_02] ON [SCDATA].[F4211]

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F4211]') AND name = N'SC_F4211_02')
CREATE NONCLUSTERED INDEX [SC_F4211_02] ON [SCDATA].[F4211]
(
	[SDKCOO] ASC,
	[SDDCTO] ASC,
	[SDLNTY] ASC
)
INCLUDE ( 	[SDDOCO],
	[SDLNID],
	[SDMCU],
	[SDAN8],
	[SDSHAN],
	[SDTRDJ],
	[SDADDJ],
	[SDITM],
	[SDLITM],
	[SDAITM],
	[SDLOCN],
	[SDLOTN],
	[SDDSC1],
	[SDDSC2],
	[SDNXTR],
	[SDLTTR],
	[SDUOM],
	[SDUORG],
	[SDSOQS],
	[SDUPRC],
	[SDAEXP],
	[SDTAX1],
	[SDFUP],
	[SDFEA]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
-----------------------------------------------------------------------------------------------------------------------------------

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F4211]') AND name = N'SC_F4211_03')
DROP INDEX [SC_F4211_03] ON [SCDATA].[F4211]

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F4211]') AND name = N'SC_F4211_03')
CREATE NONCLUSTERED INDEX [SC_F4211_03] ON [SCDATA].[F4211]
(
	[SDAN8] ASC
)
INCLUDE ([SDKCOO],
	[SDDOCO],
	[SDDCTO],
	[SDLNID],
	[SDMCU],
	[SDSHAN],
	[SDTRDJ],
	[SDADDJ],
	[SDITM],
	[SDLITM],
	[SDAITM],
	[SDLOCN],
	[SDLOTN],
	[SDDSC1],
	[SDDSC2],
	[SDLNTY],
	[SDNXTR],
	[SDLTTR],
	[SDEMCU],
	[SDRLIT],
	[SDUOM],
	[SDUORG],
	[SDSOQS],
	[SDSOBK],
	[SDUPRC],
	[SDAEXP],
	[SDTAX1],
	[SDTXA1],
	[SDEXR1],
	[SDUOM4],
	[SDFUP],
	[SDFEA]
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
-----------------------------------------------------------------------------------------------------------------------------------

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F4211]') AND name = N'SC_F4211_04')
DROP INDEX [SC_F4211_04] ON [SCDATA].[F4211]

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F4211]') AND name = N'SC_F4211_04')
CREATE NONCLUSTERED INDEX [SC_F4211_04] ON [SCDATA].[F4211]
(
	[SDOKCO] ASC,
	[SDOCTO] ASC,
	[SDLTTR] ASC
)
INCLUDE ([SDKCOO],
	[SDDOCO],
	[SDDCTO],
	[SDMCU],
	[SDOORN],
	[SDOGNO],
	[SDTRDJ],
	[SDITM],
	[SDUOM],
	[SDSOQS]
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
-----------------------------------------------------------------------------------------------------------------------------------

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F4211]') AND name = N'SC_F4211_05')
DROP INDEX [SC_F4211_05] ON [SCDATA].[F4211]

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F4211]') AND name = N'SC_F4211_05')
CREATE NONCLUSTERED INDEX [SC_F4211_05] ON [SCDATA].[F4211]
(
	[SDLTTR] ASC
)
INCLUDE ([SDDCTO],
	[SDLNID],
	[SDOKCO],
	[SDOORN],
	[SDOCTO],
	[SDOGNO],
	[SDSOQS]
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
-----------------------------------------------------------------------------------------------------------------------------------

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F4211]') AND name = N'SC_F4211_06')
DROP INDEX [SC_F4211_06] ON [SCDATA].[F4211]

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F4211]') AND name = N'SC_F4211_06')
CREATE NONCLUSTERED INDEX [SC_F4211_06] ON [SCDATA].[F4211]
(
	[SDSHAN] ASC,
	[SDRLIT] ASC
)
INCLUDE ( 	[SDKCOO],
	[SDDOCO],
	[SDDCTO],
	[SDNXTR],
	[SDLTTR]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
-----------------------------------------------------------------------------

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F4211]') AND name = N'SC_F4211_07')
DROP INDEX [SC_F4211_07] ON [SCDATA].[F4211]

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F4211]') AND name = N'SC_F4211_07')
CREATE NONCLUSTERED INDEX [SC_F4211_07] ON [SCDATA].[F4211]
(
	[SDRLIT] ASC
)
INCLUDE ( 	[SDKCOO],
	[SDDOCO],
	[SDDCTO],
	[SDNXTR],
	[SDLTTR]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO

/***********************************************************************************************************************/
--F4102 F4104
/***********************************************************************************************************************/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F4104]') AND name = N'SC_F4104_01')
DROP INDEX [SC_F4104_01] ON [SCDATA].[F4104]

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F4104]') AND name = N'SC_F4104_01')
CREATE NONCLUSTERED INDEX [SC_F4104_01] ON [SCDATA].[F4104]
(
	[IVXRT] ASC
)
INCLUDE ( 	[IVEFTJ],
	[IVEXDJ]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
/***********************************************************************************************************************/
--F4102 FQ67008
/***********************************************************************************************************************/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[FQ67008]') AND name = N'SC_FQ67008_01')
DROP INDEX [SC_FQ67008_01] ON [SCDATA].[FQ67008]

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[FQ67008]') AND name = N'SC_FQ67008_01')
CREATE NONCLUSTERED INDEX [SC_FQ67008_01] ON [SCDATA].[FQ67008]
(
	[DR$9INID] ASC,
	[DR$9CNST] ASC,
	[DRKY] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
/***********************************************************************************************************************/
--F4201
/***********************************************************************************************************************/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F4201]') AND name = N'SC_F4201_01')
DROP INDEX [SC_F4201_01] ON [SCDATA].[F4201]

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F4201]') AND name = N'SC_F4201_01')
CREATE NONCLUSTERED INDEX [SC_F4201_01] ON [SCDATA].[F4201]
(
	[SHDCTO] ASC
)
INCLUDE ( 	[SHKCOO],
	[SHDOCO],
	[SHCO],
	[SHRORN],
	[SHRCTO],
	[SHAN8],
	[SHSHAN],
	[SHDRQJ],
	[SHTRDJ],
	[SHVR01],
	[SHDEL1],
	[SHDEL2],
	[SHHOLD],
	[SHOTOT],
	[SHCRRM],
	[SHCRCD],
	[SHFAP]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
-----------------------------------------------------------------------------------------------------------------------------------

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F4201]') AND name = N'SC_F4201_02')
DROP INDEX [SC_F4201_02] ON [SCDATA].[F4201]

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F4201]') AND name = N'SC_F4201_02')
CREATE NONCLUSTERED INDEX [SC_F4201_02] ON [SCDATA].[F4201]
(
	[SHKCOO] ASC,
	[SHDCTO] ASC
)
INCLUDE ( 	[SHDOCO],
	[SHRYIN],
	[SHCRRM],
	[SHCRCD]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
-----------------------------------------------------------------------------------------------------------------------------------

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F4201]') AND name = N'SC_F4201_03')
DROP INDEX [SC_F4201_03] ON [SCDATA].[F4201]

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F4201]') AND name = N'SC_F4201_03')
CREATE NONCLUSTERED INDEX [SC_F4201_03] ON [SCDATA].[F4201]
(
	[SHAN8] ASC
)
INCLUDE ([SHKCOO],
	[SHDOCO],
	[SHDCTO],
	[SHCO],
	[SHTRDJ],
	[SHHOLD],
	[SHOTOT],
	[SHCRRM],
	[SHCRCD],
	[SHFAP]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
-----------------------------------------------------------------------------------------------------------------------------------

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F4201]') AND name = N'SC_F4201_04')
DROP INDEX [SC_F4201_04] ON [SCDATA].[F4201]

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F4201]') AND name = N'SC_F4201_04')
CREATE NONCLUSTERED INDEX [SC_F4201_04] ON [SCDATA].[F4201]
(
	[SHKCOO] ASC,
	[SHDOCO] ASC,
	[SHDCTO] ASC
)
INCLUDE ([SHRYIN],
	[SHHOLD],
	[SHCRRM],
	[SHCRCD]
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
-----------------------------------------------------------------------------------------------------------------------------------

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F4201]') AND name = N'SC_F4201_05')
DROP INDEX [SC_F4201_05] ON [SCDATA].[F4201]

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F4201]') AND name = N'SC_F4201_05')
CREATE NONCLUSTERED INDEX [SC_F4201_05] ON [SCDATA].[F4201]
(
	[SHDCTO] ASC
)
INCLUDE ([SHKCOO],
	[SHDOCO],
	[SHCO],
	[SHOKCO],
	[SHOORN],
	[SHOCTO],
	[SHRORN],
	[SHRCTO],
	[SHAN8],
	[SHSHAN],
	[SHDRQJ],
	[SHTRDJ],
	[SHVR01],
	[SHDEL1],
	[SHDEL2],
	[SHHOLD],
	[SHOTOT],
	[SHCRRM],
	[SHCRCD],
	[SHFAP]
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
-----------------------------------------------------------------------------------------------------------------------------------

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F4201]') AND name = N'SC_F4201_06')
DROP INDEX [SC_F4201_06] ON [SCDATA].[F4201]

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F4201]') AND name = N'SC_F4201_06')
CREATE NONCLUSTERED INDEX [SC_F4201_06] ON [SCDATA].[F4201]
(
	[SHAN8] ASC
)
INCLUDE ([SHKCOO],
	[SHDOCO],
	[SHDCTO],
	[SHCO],
	[SHTRDJ],
	[SHVR01]
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
-----------------------------------------------------------------------------------------------------------------------------------

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F4201]') AND name = N'SC_F4201_07')
DROP INDEX [SC_F4201_07] ON [SCDATA].[F4201]

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F4201]') AND name = N'SC_F4201_07')
CREATE NONCLUSTERED INDEX [SC_F4201_07] ON [SCDATA].[F4201]
(
	[SHAN8] ASC,
	[SHTRDJ] ASC
)
INCLUDE ( 	[SHKCOO],
	[SHDCTO],
	[SHCO],
	[SHOTOT],
	[SHCRRM],
	[SHCRCD],
	[SHFAP]
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO

/***********************************************************************************************************************/
--F42019
/***********************************************************************************************************************/

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F4201]') AND name = N'SC_F42019_01')
DROP INDEX [SC_F42019_01] ON [SCDATA].[F42019]

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F42019]') AND name = N'SC_F42019_01')
CREATE NONCLUSTERED INDEX [SC_F42019_01] ON [SCDATA].[F42019]
(
	[SHDCTO] ASC
)
INCLUDE ( 	[SHKCOO],
	[SHDOCO],
	[SHCO],
	[SHRORN],
	[SHRCTO],
	[SHAN8],
	[SHSHAN],
	[SHDRQJ],
	[SHTRDJ],
	[SHVR01],
	[SHDEL1],
	[SHDEL2],
	[SHHOLD],
	[SHOTOT],
	[SHCRRM],
	[SHCRCD],
	[SHFAP]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

-----------------------------------------------------------------------------------------------------------------------------------

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F42019]') AND name = N'SC_F42019_02')
DROP INDEX [SC_F42019_02] ON [SCDATA].[F42019]

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F42019]') AND name = N'SC_F42019_02')
CREATE NONCLUSTERED INDEX [SC_F42019_02] ON [SCDATA].[F42019]
(
	[SHDCTO] ASC
)
INCLUDE ( 	[SHKCOO],
	[SHDOCO],
	[SHCO],
	[SHOKCO],
	[SHOORN],
	[SHOCTO],
	[SHRORN],
	[SHRCTO],
	[SHAN8],
	[SHSHAN],
	[SHDRQJ],
	[SHTRDJ],
	[SHVR01],
	[SHDEL1],
	[SHDEL2],
	[SHHOLD],
	[SHOTOT],
	[SHCRRM],
	[SHCRCD],
	[SHFAP]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO

/***********************************************************************************************************************/
--FQ674201
/***********************************************************************************************************************/

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[FQ674201]') AND name = N'SC_FQ674201_01')
DROP INDEX [SC_FQ674201_01]  ON [SCDATA].[FQ674201]

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[FQ674201]') AND name = N'SC_FQ674201_01')
CREATE NONCLUSTERED INDEX [SC_FQ674201_01] ON [SCDATA].[FQ674201]
(
	[SHKCOO] ASC,
	[SHDOCO] ASC,
	[SHDCTO] ASC
)
INCLUDE ( 	[SHIDLN],
	[SH$9SHAN],
	[SHRCK7],
	[SH$9TYP],
	[SH$9AN8]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
-----------------------------------------------------------------------------------------------------------------------------------

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[FQ674201]') AND name = N'SC_FQ674201_02')
DROP INDEX [SC_FQ674201_02] ON [SCDATA].[FQ674201]

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[FQ674201]') AND name = N'SC_FQ674201_02')
CREATE NONCLUSTERED INDEX [SC_FQ674201_02] ON [SCDATA].[FQ674201]
(
	[SH$9AN8] ASC,
	[SH$9TYP] ASC
)
INCLUDE ( 	[SHKCOO],
	[SHDOCO],
	[SHDCTO]
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO

/***********************************************************************************************************************/
--FQ674211
/***********************************************************************************************************************/

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[FQ674211]') AND name = N'SC_FQ674211_02')
DROP INDEX [SC_FQ674211_02] ON [SCDATA].[FQ674211]

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[FQ674211]') AND name = N'SC_FQ674211_02')
CREATE NONCLUSTERED INDEX [SC_FQ674211_02] ON [SCDATA].[FQ674211]
(
	[SD$9TYP] ASC,
	[SD$9SHAN] ASC
)
INCLUDE ( 	[SDKCOO],
	[SDDOCO],
	[SDDCTO],
	[SDLNID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO

/***********************************************************************************************************************/
--F4102
/***********************************************************************************************************************/

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F4102]') AND name = N'SC_F4102_01')
DROP INDEX [SC_F4102_01] ON [SCDATA].[F4102]

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F4102]') AND name = N'SC_F4102_01')
CREATE NONCLUSTERED INDEX [SC_F4102_01] ON [SCDATA].[F4102]
(
	[IBMCU] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO

/***********************************************************************************************************************/
--FQ674213
/***********************************************************************************************************************/

/***********************************************************************************************************************/
--F4573
/***********************************************************************************************************************/

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F4573]') AND name = N'SC_F4573_01')
DROP INDEX [SC_F4573_01] ON [SCDATA].[F4573]

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F4573]') AND name = N'SC_F4573_01')
CREATE NONCLUSTERED INDEX [SC_F4573_01] ON [SCDATA].[F4573]
(
	[RFDOCO] ASC,
	[RFDCTO] ASC,
	[RFKCOO] ASC,
	[RFLNID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO

/***********************************************************************************************************************/
--F03B11
/***********************************************************************************************************************/

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F03B11]') AND name = N'SC_F03B11_01')
DROP INDEX [SC_F03B11_01] ON [SCDATA].[F03B11]

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F03B11]') AND name = N'SC_F03B11_01')
CREATE NONCLUSTERED INDEX [SC_F03B11_01] ON [SCDATA].[F03B11]
(
	[RPAN8] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
-----------------------------------------------------------------------------------------------------------------------------------

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F03B11]') AND name = N'SC_F03B11_02')
DROP INDEX [SC_F03B11_02] ON [SCDATA].[F03B11]

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F03B11]') AND name = N'SC_F03B11_02')
CREATE NONCLUSTERED INDEX [SC_F03B11_02] ON [SCDATA].[F03B11]
(
	[RPAN8] ASC,
	[RPCRCD] ASC,
	[RPAAP] ASC,
	[RPCO] ASC
)
INCLUDE ([RPDOC],
	[RPDCT],
	[RPKCO],
	[RPSFX],
	[RPDIVJ],
	[RPAG],
	[RPCRRM],
	[RPACR],
	[RPFAP],
	[RPDDJ],
	[RPSDOC],
	[RPSDCT],
	[RPVR01],
	[RPCTL]
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
-----------------------------------------------------------------------------------------------------------------------------------

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F03B11]') AND name = N'SC_F03B11_03')
DROP INDEX [SC_F03B11_03] ON [SCDATA].[F03B11]

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F03B11]') AND name = N'SC_F03B11_03')
CREATE NONCLUSTERED INDEX [SC_F03B11_03] ON [SCDATA].[F03B11]
(
	[RPCRCD] ASC,
	[RPSDCT] ASC
)
INCLUDE ( 	[RPDOC],
	[RPDCT],
	[RPKCO],
	[RPSFX],
	[RPAN8],
	[RPCO],
	[RPAAP],
	[RPSDOC]
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO

/***********************************************************************************************************************/
--F03B13
/***********************************************************************************************************************/

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F03B13]') AND name = N'SC_F03B13_01')
DROP INDEX [SC_F03B13_01] ON [SCDATA].[F03B13]

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F03B13]') AND name = N'SC_F03B13_01')
CREATE NONCLUSTERED INDEX [SC_F03B13_01] ON [SCDATA].[F03B13]
(
	[RYAN8] ASC
)
INCLUDE ([RYPYID],
	[RYCKNU],
	[RYDMTJ],
	[RYICU],
	[RYCKAM],
	[RYBCRC],
	[RYCRRM],
	[RYCRCD],
	[RYFCAM],
	[RYRYIN]
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO

/***********************************************************************************************************************/
--F03B13Z1
/***********************************************************************************************************************/

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F03B13Z1]') AND name = N'SC_F03B13Z1_01')
DROP INDEX [SC_F03B13Z1_01] ON [SCDATA].[F03B13Z1]

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F03B13Z1]') AND name = N'SC_F03B13Z1_01')
CREATE NONCLUSTERED INDEX [SC_F03B13Z1_01] ON [SCDATA].[F03B13Z1]
(
	[RUAN8] ASC,
	[RUEUPS] ASC
)
INCLUDE ([RUDOC],
	[RUDCT],
	[RUKCO],
	[RUSFX],
	[RUAG]
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
-----------------------------------------------------------------------------------------------------------------------------------

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F03B13Z1]') AND name = N'SC_F03B13Z1_02')
DROP INDEX [SC_F03B13Z1_02] ON [SCDATA].[F03B13Z1]

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F03B13Z1]') AND name = N'SC_F03B13Z1_02')
CREATE NONCLUSTERED INDEX [SC_F03B13Z1_02] ON [SCDATA].[F03B13Z1]
(
	[RUAN8] ASC,
	[RUEUPS] ASC
)
INCLUDE ([RUEDUS],
	[RUEDBT],
	[RUEDTN],
	[RUICU],
	[RUCKNU],
	[RUKCO],
	[RUPYID],
	[RUDMTJ],
	[RUAG],
	[RUFAP],
	[RUCO],
	[RUCRCD],
	[RUCRRM],
	[RUPYIN]
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
-----------------------------------------------------------------------------------------------------------------------------------

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F03B13Z1]') AND name = N'SC_F03B13Z1_03')
DROP INDEX [SC_F03B13Z1_03] ON [SCDATA].[F03B13Z1]

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F03B13Z1]') AND name = N'SC_F03B13Z1_03')
CREATE NONCLUSTERED INDEX [SC_F03B13Z1_03] ON [SCDATA].[F03B13Z1]
(
	[RUDOC] ASC,
	[RUEUPS] ASC
)
INCLUDE ( 	[RUGMFD],
	[RUCKAM]
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO

/***********************************************************************************************************************/
--F0111
/***********************************************************************************************************************/

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F0111]') AND name = N'SC_F0111_01')
DROP INDEX [SC_F0111_01] ON [SCDATA].[F0111]

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F0111]') AND name = N'SC_F0111_01')
CREATE NONCLUSTERED INDEX [SC_F0111_01] ON [SCDATA].[F0111]
(
	[WWAN8] ASC,
	[WWIDLN] ASC,
	[WWNICK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO

/***********************************************************************************************************************/
--F01151
/***********************************************************************************************************************/

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F01151]') AND name = N'SC_F01151_01')
DROP INDEX [SC_F01151_01] ON [SCDATA].[F01151]

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F01151]') AND name = N'SC_F01151_01')
CREATE NONCLUSTERED INDEX [SC_F01151_01] ON [SCDATA].[F01151]
(
	[EAAN8] ASC,
	[EAIDLN] ASC,
	[EAETP] ASC,
	[EAEHIER] ASC,
	[EARCK7] ASC
)
INCLUDE ([EAEMAL]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO

/***********************************************************************************************************************/
--F3201
/***********************************************************************************************************************/

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F3201]') AND name = N'SC_F3201_01')
DROP INDEX [SC_F3201_01] ON [SCDATA].[F3201]

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F3201]') AND name = N'SC_F3201_01')
CREATE NONCLUSTERED INDEX [SC_F3201_01] ON [SCDATA].[F3201]
(
	[CMCFGCID] ASC
)
INCLUDE ([CMCFGID],
	[CMKCOO],
	[CMDOCO],
	[CMDCTO],
	[CMLNID],
	[CMEMCU]
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO

/***********************************************************************************************************************/
--F32119
/***********************************************************************************************************************/

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F32119]') AND name = N'SC_F32119_01')
DROP INDEX [SC_F32119_01] ON [SCDATA].[F32119]

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F32119]') AND name = N'SC_F32119_01')
CREATE NONCLUSTERED INDEX [SC_F32119_01] ON [SCDATA].[F32119]
(
	[KSCFGID] ASC,
	[KSKIT] ASC,
	[KSCFGSID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO

/***********************************************************************************************************************/
--FQ67410
/***********************************************************************************************************************/

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[FQ67410]') AND name = N'SC_FQ67410_01')
DROP INDEX [SC_FQ67410_01] ON [SCDATA].[FQ67410]

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[FQ67410]') AND name = N'SC_FQ67410_01')
CREATE NONCLUSTERED INDEX [SC_FQ67410_01] ON [SCDATA].[FQ67410]
(
	[CHITM] ASC,
	[CH$9INID] ASC,
	[CH$9DS] ASC
)
INCLUDE ( 	[CHDSC1],
	[CHDSC2],
	[CHDSC3]
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
-----------------------------------------------------------------------------------------------------------------------------------

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[FQ67410]') AND name = N'SC_FQ67410_02')
DROP INDEX [SC_FQ67410_02] ON [SCDATA].[FQ67410]

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[FQ67410]') AND name = N'SC_FQ67410_02')
CREATE NONCLUSTERED INDEX [SC_FQ67410_02] ON [SCDATA].[FQ67410]
(
	[CH$9INID] ASC
)
INCLUDE ([CHITM]
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO

/***********************************************************************************************************************/
--FQ67410L
/***********************************************************************************************************************/

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[FQ67410L]') AND name = N'SC_FQ67410L_01')
DROP INDEX [SC_FQ67410L_01] ON [SCDATA].[FQ67410L]

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[FQ67410L]') AND name = N'SC_FQ67410L_01')
CREATE NONCLUSTERED INDEX [SC_FQ67410L_01] ON [SCDATA].[FQ67410L]
(
	[CLITM] ASC,
	[CL$9INID] ASC
)
INCLUDE ( 	[CLDSC1],
	[CLDSC2]
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO

/***********************************************************************************************************************/
--F41008
/***********************************************************************************************************************/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F41008]') AND name = N'SC_F41008_01')
DROP INDEX [SC_F41008_01] ON [SCDATA].[F41008]

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[SCDATA].[F41008]') AND name = N'SC_F41008_01')
CREATE NONCLUSTERED INDEX [SC_F41008_01] ON [SCDATA].[F41008]
(
	[S0TMPL] ASC
)
INCLUDE ( 	[S0SEG1],
	[S0SEG2],
	[S0SEG3],
	[S0SEG4],
	[S0SEG5],
	[S0SEG6],
	[S0SEG7],
	[S0SEG8],
	[S0SEG9],
	[S0SEG0],
	[S0SGD1],
	[S0SGD2],
	[S0SGD3],
	[S0SGD4],
	[S0SGD5],
	[S0SGD6],
	[S0SGD7],
	[S0SGD8],
	[S0SGD9],
	[S0SGD0]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO







