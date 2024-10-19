/***********************************************************************************************************************/
--F4201 Sales Order Header File
/***********************************************************************************************************************/
DECLARE
    i INTEGER;
BEGIN
	SELECT COUNT(*) INTO i FROM DBA_INDEXES WHERE index_name = 'SC_F4201_01' and owner = '[SCDATA]';
    IF i > 0 THEN
        EXECUTE IMMEDIATE 'DROP INDEX [SCDATA].SC_F4201_01';
    END IF;

    EXECUTE IMMEDIATE 'CREATE INDEX [SCDATA].SC_F4201_01 ON [SCDATA].F4201
        (
            SHAN8 ASC,
            SHCO ASC,
            SHDCTO ASC,
            SHKCOO ASC,
            SHDOCO ASC,
            SHTRDJ ASC,
            SHVR01 ASC,
            SHHOLD ASC,
            SHOTOT ASC,
            SHCRRM ASC,
            SHCRCD ASC,
            SHFAP ASC
        )';
END;
/

DECLARE
    i INTEGER;
BEGIN
    SELECT COUNT(*) INTO i FROM DBA_INDEXES WHERE index_name = 'SC_F4201_02' and owner = '[SCDATA]';
    IF i > 0 THEN
        EXECUTE IMMEDIATE 'DROP INDEX [SCDATA].SC_F4201_02';
    END IF;

    EXECUTE IMMEDIATE ' CREATE INDEX [SCDATA].SC_F4201_02 ON [SCDATA].F4201 
    (
		SHDOCO  ASC, 
		SHAN8  ASC, 
		SHVR01  ASC, 
		SHDCTO  ASC, 
		SHKCOO  ASC
	 )' ;
 END;
/

DECLARE
    i INTEGER;
BEGIN

    SELECT COUNT(*) INTO i FROM DBA_INDEXES WHERE index_name = 'SC_F4201_03' and owner = '[SCDATA]';
    IF i > 0 THEN
        EXECUTE IMMEDIATE 'DROP INDEX [SCDATA].SC_F4201_03';
    END IF;

    EXECUTE IMMEDIATE ' CREATE INDEX [SCDATA].SC_F4201_03 ON [SCDATA].F4201 
    (
		SHAN8  ASC,
		SHTRDJ  ASC,
		SHCO ASC
	)' ;
END;
/

DECLARE
    i INTEGER;
BEGIN
    SELECT COUNT(*) INTO i FROM DBA_INDEXES WHERE index_name = 'SC_F4201_04' and owner = '[SCDATA]';
    IF i > 0 THEN
        EXECUTE IMMEDIATE 'DROP INDEX [SCDATA].SC_F4201_04';
    END IF;

    EXECUTE IMMEDIATE ' CREATE INDEX [SCDATA].SC_F4201_04 ON [SCDATA].F4201 
    (
		SHAN8  ASC,
		SHDCTO  ASC,
		SHCO ASC
	)' ;
END;
/
/***********************************************************************************************************************/
--F42019 Sales Order Header History File         
/***********************************************************************************************************************/

DECLARE
    i INTEGER;
BEGIN
	SELECT COUNT(*) INTO i FROM DBA_INDEXES WHERE index_name = 'SC_F42019_01' and owner = '[SCDATA]';
    IF i > 0 THEN
        EXECUTE IMMEDIATE 'DROP INDEX [SCDATA].SC_F42019_01';
    END IF;

    EXECUTE IMMEDIATE 'CREATE INDEX [SCDATA].SC_F42019_01 ON [SCDATA].F42019
        (
            SHAN8 ASC,
            SHCO ASC,
            SHDCTO ASC,
            SHKCOO ASC,
            SHDOCO ASC,
            SHTRDJ ASC,
            SHVR01 ASC,
            SHHOLD ASC,
            SHOTOT ASC,
            SHCRRM ASC,
            SHCRCD ASC,
            SHFAP ASC
        )';
END;
/


DECLARE
    i INTEGER;
BEGIN
    SELECT COUNT(*) INTO i FROM DBA_INDEXES WHERE index_name = 'SC_F42019_02' and owner = '[SCDATA]';
    IF i > 0 THEN
        EXECUTE IMMEDIATE 'DROP INDEX [SCDATA].SC_F42019_02';
    END IF;

    EXECUTE IMMEDIATE ' CREATE INDEX [SCDATA].SC_F42019_02 ON [SCDATA].F42019 
    (
		SHDOCO  ASC, 
		SHAN8  ASC, 
		SHVR01  ASC, 
		SHDCTO  ASC, 
		SHKCOO  ASC
	 )' ;
END;
/


DECLARE
    i INTEGER;
BEGIN
    SELECT COUNT(*) INTO i FROM DBA_INDEXES WHERE index_name = 'SC_F42019_03' and owner = '[SCDATA]';
    IF i > 0 THEN
        EXECUTE IMMEDIATE 'DROP INDEX [SCDATA].SC_F42019_03';
    END IF;

    EXECUTE IMMEDIATE ' CREATE INDEX [SCDATA].SC_F42019_03 ON [SCDATA].F42019 
    (
		SHAN8  ASC,
		SHTRDJ  ASC,
		SHCO ASC
	)' ;
END;
/

DECLARE
    i INTEGER;
BEGIN
    SELECT COUNT(*) INTO i FROM DBA_INDEXES WHERE index_name = 'SC_F42019_04' and owner = '[SCDATA]';
    IF i > 0 THEN
        EXECUTE IMMEDIATE 'DROP INDEX [SCDATA].SC_F42019_04';
    END IF;

    EXECUTE IMMEDIATE ' CREATE INDEX [SCDATA].SC_F42019_04 ON [SCDATA].F42019 
    (
		SHAN8  ASC,
		SHDCTO  ASC,
		SHCO ASC
	)' ;
END;
/
/***********************************************************************************************************************/
--FQ674201 Sales Order Header Extended Info
/***********************************************************************************************************************/
DECLARE
    i INTEGER;
BEGIN
	SELECT COUNT(*) INTO i FROM DBA_INDEXES WHERE index_name = 'SC_FQ674201_01' and owner = '[SCDATA]';
    IF i > 0 THEN
        EXECUTE IMMEDIATE 'DROP INDEX [SCDATA].SC_FQ674201_01';
    END IF;
    EXECUTE IMMEDIATE 'CREATE INDEX [SCDATA].SC_FQ674201_01 ON [SCDATA].FQ674201
        (
            SHKCOO ASC, 
            SHDOCO ASC, 
            SHDCTO ASC, 
            SHIDLN ASC, 
            SH$9SHAN ASC, 
            SHRCK7 ASC, 
            SH$9TYP ASC, 
            SH$9AN8 ASC
        )';
END;
/

DECLARE
    i INTEGER;
BEGIN
    SELECT COUNT(*) INTO i FROM DBA_INDEXES WHERE index_name = 'SC_FQ674201_02' and owner = '[SCDATA]';
    IF i > 0 THEN
        EXECUTE IMMEDIATE 'DROP INDEX [SCDATA].SC_FQ674201_02';
    END IF;
    
    EXECUTE IMMEDIATE 'CREATE INDEX [SCDATA].SC_FQ674201_02 ON [SCDATA].FQ674201
		(
			SH$9TYP ASC, 
			SH$9AN8 ASC, 
			SHKCOO  ASC, 
			SHDCTO  ASC, 
			SHDOCO  ASC
		)';
END;
/

/***********************************************************************************************************************/
--FQ674211 Sales Order Detail Extended Info
/***********************************************************************************************************************/
DECLARE
    i INTEGER;
BEGIN
    SELECT COUNT(*) INTO i FROM DBA_INDEXES WHERE index_name = 'SC_FQ674211_01' and owner = '[SCDATA]';
    IF i > 0 THEN
		EXECUTE IMMEDIATE 'DROP INDEX [SCDATA].SC_FQ674211_01';
	END IF;
	EXECUTE IMMEDIATE 'CREATE INDEX [SCDATA].SC_FQ674211_01 ON [SCDATA].FQ674211
		(
			SDKCOO ASC,
			SDDOCO ASC,
			SDDCTO ASC,
			SDLNID ASC,
			SD$9SHAN ASC
		)';
END;
/

DECLARE
    i INTEGER;
BEGIN
	SELECT COUNT(*) INTO i FROM DBA_INDEXES WHERE index_name = 'SC_FQ674211_02' and owner = '[SCDATA]';
    IF i > 0 THEN
        EXECUTE IMMEDIATE 'DROP INDEX [SCDATA].SC_FQ674211_02 ';
    END IF;
    EXECUTE IMMEDIATE ' CREATE INDEX [SCDATA].SC_FQ674211_02 ON [SCDATA].FQ674211 
        (
           SD$9AN8 ASC,
           SD$9TYP ASC 
        )';
END;
/

DECLARE
    i INTEGER;
BEGIN
    SELECT COUNT(*) INTO i FROM DBA_INDEXES WHERE index_name = 'SC_FQ674211_03' and owner = '[SCDATA]';
    IF i > 0 THEN
        EXECUTE IMMEDIATE 'DROP INDEX [SCDATA].SC_FQ674211_03';
    END IF;
    EXECUTE IMMEDIATE 'CREATE INDEX [SCDATA].SC_FQ674211_03 ON [SCDATA].FQ674211
        (
            SD$9SHAN ASC,
            SD$9TYP ASC 
            
        )';
END;
/

/***********************************************************************************************************************/
--FQ67008 Document Restrictions
/***********************************************************************************************************************/
DECLARE
    i INTEGER;
BEGIN
    SELECT COUNT(*) INTO i FROM DBA_INDEXES WHERE index_name = 'SC_FQ67008_01' and owner = '[SCDATA]';
    IF i > 0 THEN
		EXECUTE IMMEDIATE 'DROP INDEX [SCDATA].SC_FQ67008_01';
	END IF;
	EXECUTE IMMEDIATE 'CREATE INDEX [SCDATA].SC_FQ67008_01 ON [SCDATA].FQ67008
		(
			DR$9INID ASC,
			DR$9CNST ASC,
			DRKY ASC
		)';
END;
/

/*********************************************************************************/
 --F03B11
/*********************************************************************************/

DECLARE
    i INTEGER;
BEGIN
    
	SELECT COUNT(*) INTO i FROM DBA_INDEXES WHERE index_name = 'SC_F03B11_01' and owner = '[SCDATA]';
    IF i > 0 THEN
        EXECUTE IMMEDIATE 'DROP INDEX [SCDATA].SC_F03B11_01';
    END IF;
    
    EXECUTE IMMEDIATE 'CREATE INDEX [SCDATA].SC_F03B11_01 ON [SCDATA].F03B11 
        (
        RPCRCD ASC, 
        RPCO   ASC, 
        RPAN8  ASC
    )';
END;
/

/*********************************************************************************/
 --F03B13Z1
/*********************************************************************************/
DECLARE
    i INTEGER;
BEGIN
    SELECT COUNT(*) INTO i FROM DBA_INDEXES WHERE index_name = 'SC_F03B13Z1_01' and owner = '[SCDATA]';
    IF i > 0 THEN
        EXECUTE IMMEDIATE 'DROP INDEX [SCDATA].SC_F03B13Z1_01';
    END IF;
    
    EXECUTE IMMEDIATE 'CREATE INDEX [SCDATA].SC_F03B13Z1_01 ON [SCDATA].F03B13Z1 
        (
            RUKCO ASC , 
            RUDCT ASC , 
            RUSFX ASC , 
            RUAN8 ASC , 
            RUDOC ASC 
        )';
END;
/

DECLARE
    i INTEGER;
BEGIN
    SELECT COUNT(*) INTO i FROM DBA_INDEXES WHERE index_name = 'SC_F03B13Z1_02' and owner = '[SCDATA]';
    IF i > 0 THEN
        EXECUTE IMMEDIATE 'DROP INDEX [SCDATA].SC_F03B13Z1_02';
    END IF;
    
    EXECUTE IMMEDIATE 'CREATE INDEX [SCDATA].SC_F03B13Z1_02 ON [SCDATA].F03B13Z1
        (
            RUAN8 ASC, 
            RUEUPS ASC
        )';
END;
/

DECLARE
    i INTEGER;
BEGIN
        
    SELECT COUNT(*) INTO i FROM DBA_INDEXES WHERE index_name = 'SC_F03B13Z1_03' and owner = '[SCDATA]';
    IF i > 0 THEN
        EXECUTE IMMEDIATE 'DROP INDEX [SCDATA].SC_F03B13Z1_03';
    END IF;
    
    EXECUTE IMMEDIATE '  CREATE INDEX [SCDATA].SC_F03B13Z1_03 ON [SCDATA].F03B13Z1
        (
            RUDOC ASC,
            RUEUPS ASC
        )';
END;
/

/*********************************************************************************/
 --F4211
/*********************************************************************************/
DECLARE
    i INTEGER;
BEGIN
    SELECT COUNT(*) INTO i FROM DBA_INDEXES WHERE index_name = 'SC_F4211_01' and owner = '[SCDATA]';
    IF i > 0 THEN
        EXECUTE IMMEDIATE 'DROP INDEX [SCDATA].SC_F4211_01';
    END IF;
    
    EXECUTE IMMEDIATE 'CREATE INDEX [SCDATA].SC_F4211_01 ON [SCDATA].F4211 
        (
            SDLNTY ASC, 
            SDDOCO ASC, 
            SDDCTO ASC, 
            SDLNID ASC, 
            SDSHAN ASC, 
            SDITM ASC, 
            SDNXTR ASC, 
            SDLTTR ASC
        ) ';
END;
/

DECLARE
    i INTEGER;
BEGIN
    SELECT COUNT(*) INTO i FROM DBA_INDEXES WHERE index_name = 'SC_F4211_02' and owner = '[SCDATA]';
    IF i > 0 THEN
        EXECUTE IMMEDIATE 'DROP INDEX [SCDATA].SC_F4211_02';
    END IF;
 
    EXECUTE IMMEDIATE 'CREATE INDEX [SCDATA].SC_F4211_02  ON [SCDATA].F4211 
		(
			SDSHAN ASC, 
			SDLNTY ASC
		)';
END;
/

DECLARE
    i INTEGER;
BEGIN
    SELECT COUNT(*) INTO i FROM DBA_INDEXES WHERE index_name = 'SC_F4211_03' and owner = '[SCDATA]';
    IF i > 0 THEN
        EXECUTE IMMEDIATE 'DROP INDEX [SCDATA].SC_F4211_03';
    END IF;
    EXECUTE IMMEDIATE 'CREATE INDEX [SCDATA].SC_F4211_03 ON [SCDATA].F4211 
        (
            SDOKCO ASC, 
            SDOCTO ASC, 
            SDOGNO ASC, 
            SDOORN ASC, 
            SDDCTO ASC
        ) ';
END;
/

DECLARE
    i INTEGER;
BEGIN
    SELECT COUNT(*) INTO i FROM DBA_INDEXES WHERE index_name = 'SC_F4211_04' and owner = '[SCDATA]';
    IF i > 0 THEN
        EXECUTE IMMEDIATE 'DROP INDEX [SCDATA].SC_F4211_04';
    END IF;
    
    EXECUTE IMMEDIATE 'CREATE INDEX [SCDATA].SC_F4211_04 ON [SCDATA].F4211
		(
			SDRLIT ASC
		)';
END;
/

/*********************************************************************************/
 --F42119
/*********************************************************************************/
DECLARE
    i INTEGER;
BEGIN
    SELECT COUNT(*) INTO i FROM DBA_INDEXES WHERE index_name = 'SC_F42119_01' and owner = '[SCDATA]';
    IF i > 0 THEN
        EXECUTE IMMEDIATE 'DROP INDEX [SCDATA].SC_F42119_01';
    END IF;
    
    EXECUTE IMMEDIATE 'CREATE INDEX [SCDATA].SC_F42119_01 ON [SCDATA].F42119 
        (
            SDLNTY ASC, 
            SDDOCO ASC, 
            SDDCTO ASC, 
            SDLNID ASC, 
            SDSHAN ASC, 
            SDITM ASC, 
            SDNXTR ASC, 
            SDLTTR ASC
        ) ';
END;
/

DECLARE
    i INTEGER;
BEGIN
    SELECT COUNT(*) INTO i FROM DBA_INDEXES WHERE index_name = 'SC_F42119_02' and owner = '[SCDATA]';
    IF i > 0 THEN
        EXECUTE IMMEDIATE 'DROP INDEX [SCDATA].SC_F42119_02';
    END IF;
    
    EXECUTE IMMEDIATE 'CREATE INDEX [SCDATA].SC_F42119_02 ON [SCDATA].F42119 
        (
            SDLNTY ASC, 
            SDLTTR ASC, 
            SDKCOO ASC, 
            SDDOCO ASC, 
            SDDCTO ASC 
        ) ';
END;
/

DECLARE
    i INTEGER;
BEGIN
    SELECT COUNT(*) INTO i FROM DBA_INDEXES WHERE index_name = 'SC_F42119_03' and owner = '[SCDATA]';
    IF i > 0 THEN
        EXECUTE IMMEDIATE 'DROP INDEX [SCDATA].SC_F42119_03';
    END IF;
 
    EXECUTE IMMEDIATE 'CREATE INDEX [SCDATA].SC_F42119_03  ON [SCDATA].F42119 
        (
            SDSHAN ASC, 
            SDLNTY ASC
		)';
END;
/

DECLARE
    i INTEGER;
BEGIN
    SELECT COUNT(*) INTO i FROM DBA_INDEXES WHERE index_name = 'SC_F42119_04' and owner = '[SCDATA]';
    IF i > 0 THEN
        EXECUTE IMMEDIATE 'DROP INDEX [SCDATA].SC_F42119_04';
    END IF;
    
    EXECUTE IMMEDIATE 'CREATE INDEX [SCDATA].SC_F42119_04 ON [SCDATA].F42119
		(
			SDRLIT ASC
		)';
END;
/

DECLARE
    i INTEGER;
BEGIN
    SELECT COUNT(*) INTO i FROM DBA_INDEXES WHERE index_name = 'SC_F42119_05' and owner = '[SCDATA]';
    IF i > 0 THEN
        EXECUTE IMMEDIATE 'DROP INDEX [SCDATA].SC_F42119_05';
    END IF;
    
    EXECUTE IMMEDIATE ' CREATE INDEX [SCDATA].SC_F42119_05 ON [SCDATA].F42119 
        (
            SDOKCO ASC, 
            SDOCTO ASC, 
            SDOGNO ASC, 
            SDOORN ASC, 
            SDDCTO ASC
        ) ';
END;
/

DECLARE
    i INTEGER;
BEGIN
    SELECT COUNT(*) INTO i FROM DBA_INDEXES WHERE index_name = 'SC_F42119_06' and owner = '[SCDATA]';
    IF i > 0 THEN
        EXECUTE IMMEDIATE 'DROP INDEX [SCDATA].SC_F42119_06';
    END IF;
    EXECUTE IMMEDIATE 'CREATE INDEX [SCDATA].SC_F42119_06 ON [SCDATA].F42119 
        (
            SDDOC ASC, 
            SDDCT ASC, 
            SDKCO ASC
        )';
END;
/

/*********************************************************************************/
 --FQ67410
/*********************************************************************************/

DECLARE
    i INTEGER;
BEGIN
    SELECT COUNT(*) INTO i FROM DBA_INDEXES WHERE index_name = 'SC_FQ67410_01' and owner = '[SCDATA]';
    IF i > 0 THEN
        EXECUTE IMMEDIATE 'DROP INDEX [SCDATA].SC_FQ67410_01 ';
    END IF;
	EXECUTE IMMEDIATE 'CREATE INDEX [SCDATA].SC_FQ67410_01 ON [SCDATA].FQ67410 
		(
			CH$9DS ASC, 
			CH$9INID ASC
		)';
END;
/

