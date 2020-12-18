
SELECT
    VENDOR_NAME,
    A.ITEM_CODE,
    A.PO_HEADER_ID,
    SUM(CASE WHEN PERIOD_DATE < 0 THEN PO_PRICE * RP_QTY ELSE 0 END) 당일입고,
    SUM(CASE WHEN PERIOD_DATE >= 0 AND PERIOD_DATE <= 30 THEN PO_PRICE * RP_QTY  ELSE 0 END)  D30,
    SUM(CASE WHEN PERIOD_DATE > 30 AND PERIOD_DATE <= 45 THEN PO_PRICE * RP_QTY ELSE 0  END)  D45,
    SUM(CASE WHEN PERIOD_DATE > 45 AND PERIOD_DATE <= 60 THEN PO_PRICE * RP_QTY ELSE 0  END)  D60,
    SUM(CASE WHEN PERIOD_DATE > 60 AND PERIOD_DATE <= 90 THEN PO_PRICE * RP_QTY ELSE 0  END)  D90,
    SUM(CASE WHEN PERIOD_DATE > 90 AND PERIOD_DATE <= 120 THEN PO_PRICE * RP_QTY ELSE 0 END ) D120,
    SUM(CASE WHEN PERIOD_DATE > 120 THEN PO_PRICE * RP_QTY ELSE 0 END ) D120_OVER,
    SUM( PO_PRICE * RM_QTY ) 미입고,
    SUM(PO_PRICE * RP_QTY ) 합계,
    A.CANCEL_FLAG,
    SUM(DISTINCT CASE WHEN A.CANCEL_FLAG = 'Y' AND RP_QTY= 0 THEN 0 WHEN A.CANCEL_FLAG= 'Y' AND RP_QTY > 0 THEN RP_QTY ELSE PO_PRICE * A.PO_QTY END)  발주금액
FROM (
         SELECT
             A.PO_HEADER_ID,
             PO_LINE_ID,
             PO_RELEASE_ID,
             VENDOR_NAME,
             ITEM_CODE,
             PERIOD_DATE,
             PO_PRICE,
             A.CANCEL_FLAG,
             CASE WHEN A.CANCEL_FLAG = 'Y' AND RP_QTY = 0 THEN 0 WHEN A.CANCEL_FLAG= 'Y' AND RP_QTY > 0 THEN  RP_QTY ELSE PO_QTY END PO_QTY,
             CASE WHEN A.CANCEL_FLAG = 'Y' THEN 0 ELSE RM_QTY END RM_QTY,
             RP_QTY RP_QTY
         FROM (
                  SELECT DISTINCT PLLA.PO_HEADER_ID,
                                  PO_LINE_ID,
                                  PO_RELEASE_ID,
                                  LINE_LOCATION_ID,
                                  TRUNC(PLLA.APPROVED_DATE)                                                APPROVED_DATE,
                                  PLLA.NEED_BY_DATE                                                        NEED_BY_DATE,
                                  PLLA.CANCEL_FLAG,
                                  PLLAQTY.PO_QTY                                                            PO_QTY,
                                  PLA.UNIT_PRICE                                                           PO_PRICE,
                                  PVSA.VENDOR_SITE_CODE                                                    VENDOR_NAME,
                                  MSIB.SEGMENT1                                                            ITEM_CODE,
                                  NVL(RT_QTY, 0)                 RP_QTY,
                                  PLLAQTY.PO_QTY - NVL(RT_QTY, 0) RM_QTY,
                                  NVL(TO_CHAR(RT.TRANSACTION_DATE), '미입고')                                 RP_DATE,
                                  NVL(TRUNC(RT.TRANSACTION_DATE - PLLA.APPROVED_DATE),0)                                 PERIOD_DATE
                  FROM (
                           SELECT PO_HEADER_ID,
                                  PO_LINE_ID,
                                  PO_RELEASE_ID,
                                  LINE_LOCATION_ID,
                                  APPROVED_DATE,
                                  NEED_BY_DATE,
                                  CANCEL_FLAG,
                                  SUM(QUANTITY) PO_QTY
                           FROM PO_LINE_LOCATIONS_ALL PLLA
                           WHERE  PLLA.APPROVED_DATE BETWEEN :시작일자 AND :종료일자
                           GROUP BY
                               PO_HEADER_ID,
                               PO_LINE_ID,
                               PO_RELEASE_ID,
                               LINE_LOCATION_ID,
                               APPROVED_DATE,
                               NEED_BY_DATE,
                               CANCEL_FLAG
                       ) PLLA
                           INNER JOIN PO_HEADERS_ALL PHA ON PLLA.PO_HEADER_ID = PHA.PO_HEADER_ID
                           INNER JOIN PO_VENDOR_SITES_ALL PVSA ON PHA.VENDOR_SITE_ID = PVSA.VENDOR_SITE_ID
                           INNER JOIN     PO_LINES_ALL PLA ON PHA.PO_HEADER_ID = PLA.PO_HEADER_ID AND PLLA.PO_HEADER_ID = PLA.PO_HEADER_ID AND PLLA.PO_LINE_ID = PLA.PO_LINE_ID
                           LEFT OUTER JOIN PO_RELEASES_ALL PRA ON  NVL(PLLA.PO_RELEASE_ID, -99999) = PRA.PO_RELEASE_ID
                           INNER JOIN MTL_SYSTEM_ITEMS_B MSIB ON PLA.ITEM_ID = MSIB.INVENTORY_ITEM_ID AND MSIB.ORGANIZATION_ID = 83
                           LEFT OUTER JOIN (
                      SELECT PO_LINE_LOCATION_ID, TRANSACTION_DATE,
                             SUM(CASE
                                     WHEN RT.TRANSACTION_TYPE = 'RECEIVE' THEN QUANTITY
                                     WHEN TRANSACTION_TYPE = 'RETURN TO VENDOR' THEN -QUANTITY END) RT_QTY
                      FROM RCV_TRANSACTIONS RT
                      WHERE  RT.TRANSACTION_DATE BETWEEN add_months(:시작일자,-5) AND add_months(:종료일자,5)
                      GROUP BY PO_LINE_LOCATION_ID, TRANSACTION_DATE
                  ) RT ON PLLA.LINE_LOCATION_ID = RT.PO_LINE_LOCATION_ID
               INNER JOIN (
                      SELECT PO_HEADER_ID,
                             PO_LINE_ID,
                          CASE WHEN CANCEL_FLAG = 'N' THEN QUANTITY ELSE 0 END  PO_QTY
                      FROM PO_LINE_LOCATIONS_ALL PLLA
                      WHERE  PLLA.APPROVED_DATE BETWEEN :시작일자 AND :종료일자
                       AND CANCEL_FLAG = 'N'
--                       GROUP BY
--                           PO_HEADER_ID,
--                           PO_LINE_ID
                  ) PLLAQTY ON PLLA.PO_HEADER_ID = PLLAQTY.PO_HEADER_ID AND PLLA.PO_LINE_ID = PLLAQTY.PO_LINE_ID
                  WHERE  PLLA.APPROVED_DATE BETWEEN :시작일자 AND :종료일자
                    AND PHA.SHIP_TO_LOCATION_ID = 167068
              ) A
     ) A
GROUP BY
    VENDOR_NAME,
    A.ITEM_CODE,
    A.PO_HEADER_ID,
    A.CANCEL_FLAG,
    A.PO_QTY
HAVING SUM(PO_PRICE * RP_QTY ) <> 0
ORDER BY A.ITEM_CODE

