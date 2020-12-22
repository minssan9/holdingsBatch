package halla.holdings.inv;

import com.fasterxml.jackson.databind.ObjectMapper;
import halla.holdings.inv.dto.InvSampleDto;
import halla.holdings.inv.mapper.InvMapper;
import org.junit.Test;
import org.mockito.Mockito;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.hateoas.MediaTypes;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;



import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest
public class InvTest {
    @Autowired
    MockMvc mockMvc;

    @MockBean
    InvMapper invMapper;

    @Autowired
    ObjectMapper objectMapper;



    @Test
    public void createEvent() throws Exception {
        InvSampleDto invSampleDto = InvSampleDto.builder()
                .name("Spring")
                .build();
        //eventRepository에 save가 호출되면 event를 리턴하라
//        Mockito.when(invMapper.insertSample(invSampleDto)).thenReturn(invSampleDto);

        mockMvc.perform(post("/api/events/")
                .contentType(MediaType.APPLICATION_JSON) //요청타입
                .accept(MediaTypes.HAL_JSON) //받고싶은 타입
                .content(objectMapper.writeValueAsString(invSampleDto))) //event를 json을 String으로 맵핑
                .andDo(print())
                .andExpect(status().isCreated()) // 201 상태인지 확인
                .andExpect(jsonPath("id").exists()) //ID가 있는지 확인
                .andExpect(header().exists(HttpHeaders.LOCATION)) // HEADER에 Location 있는지 확인
                .andExpect(header().string(HttpHeaders.CONTENT_TYPE, MediaTypes.HAL_JSON_VALUE)); //Content-Type 값 확인
    }
}
