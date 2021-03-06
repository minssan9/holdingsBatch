package halla.holdings.inv.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class InvSampleDto {
    private String num;
    private String name;
    private String title;
    private String content;
    private String readCount;
    private String writeDate;
}
