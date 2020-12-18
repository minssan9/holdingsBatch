package halla.holdings.inv.service;

import halla.holdings.inv.dto.InvSampleDto;
import halla.holdings.inv.mapper.InvMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class InvService {
    @Autowired
    private InvMapper invMapper;

    public InvSampleDto getInvSample (InvSampleDto invSampleDto)   {
        return new InvSampleDto();
    }
}
