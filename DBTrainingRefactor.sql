CREATE TABLE #BatchStatus
(
	BatchID	INT,
	NRF		INT,
	RF		INT,
	F		INT,
	A		INT
)


CREATE TABLE #CompanyStatus
(
	BatchId			INT,
	CompanyID		INT,
	ReviewStatus	NVARCHAR(3)
)

CREATE TABLE #OpenBatches
(
	BatchID	INT
)


INSERT #BatchStatus
(
    BatchID,
    NRF,
    RF,
    F,
    A
)
SELECT	OB.BatchID,
		ISNULL(NRF.ct, 0),
		ISNULL(RF.ct, 0),
		ISNULL(F.ct, 0),
		ISNULL(A.ct, 0)
FROM	#OpenBatches OB
LEFT JOIN	
(
	SELECT	CS.BatchId,
            ct=COUNT(CS.CompanyID)
	FROM	#CompanyStatus CS
	WHERE	CS.ReviewStatus = 'NRF'
	GROUP BY CS.BatchId
) NRF
ON	OB.BatchID = NRF.BatchId
LEFT JOIN	
(
	SELECT	CS.BatchId,
            ct=COUNT(CS.CompanyID)
	FROM	#CompanyStatus CS
	WHERE	CS.ReviewStatus = 'RF'
	GROUP BY CS.BatchId
) RF
ON	OB.BatchID = RF.BatchId
LEFT JOIN	
(
	SELECT	CS.BatchId,
            ct=COUNT(CS.CompanyID)
	FROM	#CompanyStatus CS
	WHERE	CS.ReviewStatus = 'F'
	GROUP BY CS.BatchId
) F
ON	OB.BatchID = F.BatchId
LEFT JOIN	
(
	SELECT	CS.BatchId,
            ct=COUNT(CS.CompanyID)
	FROM	#CompanyStatus CS
	WHERE	CS.ReviewStatus = 'A'
	GROUP BY CS.BatchId
) A
ON	OB.BatchID = A.BatchId

CREATE TABLE #CompanyStatus
(
	BatchId			INT,
	CompanyID		INT,
	ReviewStatus	NVARCHAR(3)
)

INSERT INTO #CompanyStatus (
	BatchID,
	CompanyID, 
	ReviewStatus
)
VALUES ( 1, 1, 'NRF' ),
		( 1, 2, 'NRF' ),
		( 1, 3, 'NRF' ),
		( 2, 1, 'NRF' ),
		( 3, 1, 'NRF' ),
		( 1, 1, 'F' )

/* Solution */
;WITH ReviewStatusCount AS (
	SELECT CS.BatchId
			, CS.ReviewStatus
			, ct = COUNT(CS.CompanyID) OVER(PARTITION BY CS.BatchId)
	FROM #CompanyStatus CS
	WHERE CS.ReviewStatus IN ('NRF', 'RF', 'F', 'A')
	GROUP BY CS.ReviewStatus
)
SELECT BatchId,
		CASE WHEN ReviewStatus = 'NRF' THEN ISNULL(ct, 0) ELSE 0 END,
		CASE WHEN ReviewStatus = 'RF' THEN ISNULL(ct, 0) ELSE 0 END,
		CASE WHEN ReviewStatus = 'F' THEN ISNULL(ct, 0) ELSE 0 END,
		CASE WHEN ReviewStatus = 'A' THEN ISNULL(ct, 0) ELSE 0 END
FROM ReviewStatusCount
