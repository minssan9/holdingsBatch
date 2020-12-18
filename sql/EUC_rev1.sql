SELECT
    VENDOR_NAME,
    ITEM_CODE,
    SUM(D0) D0,
    SUM(D30) D30,
    SUM(D45) D45,
    SUM(D60) D60,
    SUM(D90) D90,
    SUM(D120) D120,
    SUM(D120_OVER) D120_OVER,
    SUM( RM_MONEY ) RM_MONEY_미입고,
    SUM( RP_MONEY ) RP_MONEY_입고,
    sum(PO_MONEY )  PO_MONEY_발주
FROM (
         SELECT  VENDOR_NAME,
                         ITEM_CODE,
                 PO_HEADER_ID,
                 PO_LINE_ID,
                 PO_RELEASE_ID,
                 RELEASE_NUM,
                         SUM(CASE WHEN PERIOD_DATE < 0 THEN PO_PRICE * RP_QTY ELSE 0 END)                         D0,
                         SUM(CASE WHEN PERIOD_DATE >= 0 AND PERIOD_DATE <= 30 THEN PO_PRICE * RP_QTY ELSE 0 END)  D30,
                         SUM(CASE WHEN PERIOD_DATE > 30 AND PERIOD_DATE <= 45 THEN PO_PRICE * RP_QTY ELSE 0 END)  D45,
                         SUM(CASE WHEN PERIOD_DATE > 45 AND PERIOD_DATE <= 60 THEN PO_PRICE * RP_QTY ELSE 0 END)  D60,
                         SUM(CASE WHEN PERIOD_DATE > 60 AND PERIOD_DATE <= 90 THEN PO_PRICE * RP_QTY ELSE 0 END)  D90,
                         SUM(CASE WHEN PERIOD_DATE > 90 AND PERIOD_DATE <= 120 THEN PO_PRICE * RP_QTY ELSE 0 END) D120,
                         SUM(CASE WHEN PERIOD_DATE > 120 THEN PO_PRICE * RP_QTY ELSE 0 END)                       D120_OVER,
                         SUM(PO_PRICE * RM_QTY)                                                                   RM_MONEY,
                         SUM(PO_PRICE * RP_QTY)                                                                   RP_MONEY,
                         CASE WHEN sum(RP_QTY) = 0 THEN 0 ELSE PO_PRICE * A.PO_QTY END                            PO_MONEY
         FROM (
                  SELECT   A.RELEASE_NUM, a.PO_HEADER_ID,
                                  a.PO_LINE_ID,
                          A.PO_RELEASE_ID,
                           VENDOR_NAME,
                                  ITEM_CODE,
                                  PERIOD_DATE,
                                  PO_PRICE,
                                  CASE
                                      WHEN A.CANCEL_FLAG = 'Y' AND RP_QTY = 0 THEN 0
                                      WHEN A.CANCEL_FLAG = 'Y' AND RP_QTY > 0 THEN RP_QTY
                                      ELSE PO_QTY END                                  PO_QTY,
                                  CASE WHEN A.CANCEL_FLAG = 'Y' THEN 0 ELSE RM_QTY END RM_QTY,
                                  RP_QTY                                               RP_QTY
                  FROM (
                           SELECT RELEASE_NUM, PLLA.PO_HEADER_ID,
                                           PLLA.PO_LINE_ID,
                                           PLLA.PO_RELEASE_ID,
                                           PLLA.LINE_LOCATION_ID,
                                           PVSA.VENDOR_SITE_CODE                                    VENDOR_NAME,
                                           MSIB.SEGMENT1                                            ITEM_CODE,
                                           TRUNC(PLLA.APPROVED_DATE)                                APPROVED_DATE,
                                           PLLA.NEED_BY_DATE                                        NEED_BY_DATE,
                                           PLLA.CANCEL_FLAG,
                                           PLA.UNIT_PRICE                                           PO_PRICE,
                                           --                           PLLA.QUANTITY                                                            PO_QTY,
                                           NVL(DECODE(RT.TRANSACTION_TYPE,
                                                      'RECEIVE', RT.PRIMARY_QUANTITY,
                                                      'RETURN TO VENDOR', -RT.PRIMARY_QUANTITY), 0) RP_QTY,
                                           PLLA.QUANTITY - NVL(DECODE(RT.TRANSACTION_TYPE,
                                                                      'RECEIVE', RT.PRIMARY_QUANTITY,
                                                                      'RETURN TO VENDOR', -RT.PRIMARY_QUANTITY),
                                                               0)                                   RM_QTY,
                                           NVL(TO_CHAR(RT.TRANSACTION_DATE), '미입고')                 RP_DATE,
                                           NVL(TRUNC(RT.TRANSACTION_DATE - PLLA.APPROVED_DATE), 0)  PERIOD_DATE
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
AND MSIB.SEGMENT1 =  'ECI00007U'
                       ) A
                       INNER JOIN (
                              SELECT DISTINCT PO_HEADER_ID,
                                     PO_LINE_ID,
                                              PO_RELEASE_ID,
                                     SUM(CASE WHEN CANCEL_FLAG = 'N' THEN QUANTITY ELSE 0 END) PO_QTY
                              FROM PO_LINE_LOCATIONS_ALL PLLA
                              WHERE PLLA.APPROVED_DATE BETWEEN :시작일자 AND :종료일자
                                AND CANCEL_FLAG = 'N'
        --         AND PO_HEADER_ID = 259435 AND PO_LINE_ID = 6274753
                              GROUP BY PO_HEADER_ID, PO_LINE_ID,PO_RELEASE_ID
                  ) PLLAQTY ON A.PO_HEADER_ID = PLLAQTY.PO_HEADER_ID AND A.PO_LINE_ID = PLLAQTY.PO_LINE_ID AND A.PO_RELEASE_ID=PLLAQTY.PO_RELEASE_ID
                  WHERE RP_QTY <> 0
) A
WHERE ITEM_CODE = 'ECI00007U'
         GROUP BY VENDOR_NAME,
                  ITEM_CODE,
                  PO_HEADER_ID,
                  PO_LINE_ID,
                PO_RELEASE_ID,
                  RELEASE_NUM,
                  PO_PRICE,
                  A.PO_QTY
     ) A
GROUP BY
    VENDOR_NAME,
    ITEM_CODE

