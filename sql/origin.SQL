
SELECT DISTINCT
    VENDOR_NAME,
    ITEM_CODE,
    SUM(CASE WHEN PERIOD_DATE < 0 THEN PO_PRICE * RP_QTY ELSE 0 END) 당일입고,
    SUM(CASE WHEN PERIOD_DATE >= 0 AND PERIOD_DATE <= 30 THEN PO_PRICE * RP_QTY  ELSE 0 END)  D30,
    SUM(CASE WHEN PERIOD_DATE > 30 AND PERIOD_DATE <= 45 THEN PO_PRICE * RP_QTY ELSE 0  END)  D45,
    SUM(CASE WHEN PERIOD_DATE > 45 AND PERIOD_DATE <= 60 THEN PO_PRICE * RP_QTY ELSE 0  END)  D60,
    SUM(CASE WHEN PERIOD_DATE > 60 AND PERIOD_DATE <= 90 THEN PO_PRICE * RP_QTY ELSE 0  END)  D90,
    SUM(CASE WHEN PERIOD_DATE > 90 AND PERIOD_DATE <= 120 THEN PO_PRICE * RP_QTY ELSE 0 END ) D120,
    SUM(CASE WHEN PERIOD_DATE > 120 THEN PO_PRICE * RP_QTY ELSE 0 END ) D120_OVER,
    SUM( PO_PRICE * RM_QTY ) 미입고,
    SUM(PO_PRICE * RP_QTY ) 합계,
    SUM(CASE WHEN RP_QTY = 0 THEN 0 ELSE PO_PRICE * B.PO_QTY END ) 발주금액
FROM              (
    SELECT
        A.LINE_LOCATION_ID,
        VENDOR_NAME,
        ITEM_CODE,
        PERIOD_DATE,
        PO_PRICE,
        CASE WHEN A.CANCEL_FLAG = 'Y' AND RP_QTY = 0 THEN 0 WHEN A.CANCEL_FLAG= 'Y' AND RP_QTY > 0 THEN  RP_QTY ELSE PO_QTY END PO_QTY,
        CASE WHEN A.CANCEL_FLAG = 'Y' THEN 0 ELSE RM_QTY END RM_QTY,
        RP_QTY RP_QTY
    FROM (
        SELECT DISTINCT PLLA.LINE_LOCATION_ID,
                        PVSA.VENDOR_SITE_CODE                                                    VENDOR_NAME,
                        MSIB.SEGMENT1                                                            ITEM_CODE,
                        TRUNC(PLLA.APPROVED_DATE)                                                APPROVED_DATE,
                        PLLA.NEED_BY_DATE                                                        NEED_BY_DATE,
                        PLLA.CANCEL_FLAG,
                        PLA.UNIT_PRICE                                                           PO_PRICE,
                        PLLA.QUANTITY                                                            PO_QTY,
                        NVL(DECODE(RT.TRANSACTION_TYPE,
                                   'RECEIVE', RT.PRIMARY_QUANTITY,
                                   'RETURN TO VENDOR', -RT.PRIMARY_QUANTITY), 0)                 RP_QTY,
                        PLLA.QUANTITY - NVL(DECODE(RT.TRANSACTION_TYPE,
                                                   'RECEIVE', RT.PRIMARY_QUANTITY,
                                                   'RETURN TO VENDOR', -RT.PRIMARY_QUANTITY), 0) RM_QTY,
                        NVL(TO_CHAR(RT.TRANSACTION_DATE), '미입고')                                 RP_DATE,
                        NVL(TRUNC(RT.TRANSACTION_DATE - PLLA.APPROVED_DATE),0)                                 PERIOD_DATE
        FROM PO_LINE_LOCATIONS_ALL PLLA,
             PO_HEADERS_ALL PHA,
             PO_VENDOR_SITES_ALL PVSA,
             PO_LINES_ALL PLA,
             PO_RELEASES_ALL PRA,
             MTL_SYSTEM_ITEMS_B MSIB,
             RCV_TRANSACTIONS RT
        WHERE 1 = 1
          AND PLLA.PO_HEADER_ID = PHA.PO_HEADER_ID
          AND PHA.VENDOR_SITE_ID = PVSA.VENDOR_SITE_ID
          AND PHA.PO_HEADER_ID = PLA.PO_HEADER_ID
          AND PLLA.PO_HEADER_ID = PLA.PO_HEADER_ID
          AND PLLA.PO_LINE_ID = PLA.PO_LINE_ID
          AND NVL(PLLA.PO_RELEASE_ID, -99999) = PRA.PO_RELEASE_ID(+)
          AND RT.PO_LINE_LOCATION_ID(+) = PLLA.LINE_LOCATION_ID
          AND PLA.ITEM_ID = MSIB.INVENTORY_ITEM_ID
          AND MSIB.ORGANIZATION_ID = 83
          AND PLLA.APPROVED_DATE BETWEEN :시작일자 AND :종료일자
          AND PHA.SHIP_TO_LOCATION_ID = 167068
          AND RT.TRANSACTION_TYPE(+) = 'RECEIVE'
    ) A
) A
INNER JOIN (
                      SELECT PO_HEADER_ID,
                             PO_LINE_ID,
                          CASE WHEN CANCEL_FLAG = 'N' THEN QUANTITY ELSE 0 END  PO_QTY
                      FROM PO_LINE_LOCATIONS_ALL PLLA
                      WHERE  PLLA.APPROVED_DATE BETWEEN :시작일자 AND :종료일자
                       AND CANCEL_FLAG = 'N'
                  ) PLLAQTY ON PLLA.PO_HEADER_ID = PLLAQTY.PO_HEADER_ID AND PLLA.PO_LINE_ID = PLLAQTY.PO_LINE_ID
GROUP BY
    VENDOR_NAME,
    ITEM_CODE
ORDER BY ITEM_CODE
