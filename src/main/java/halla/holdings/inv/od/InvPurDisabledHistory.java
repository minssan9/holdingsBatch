package halla.holdings.inv.od;

import lombok.Data;

import java.sql.Time;

@Data
public class InvPurDisabledHistory {
    private String itemNumber;
    private String inventoryItemStatusCode;
    private String purchasingEnabledFlag;
    private Time disabledStartMm;
    private String purchasingEnabledStatus;
    private String badItemFlag;
    private String status;
    private String msg;
}
