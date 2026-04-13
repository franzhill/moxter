package dev.moxter;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestInstance;
import dev.moxter.infra.MoxterTestApp;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import lombok.extern.slf4j.Slf4j;


@SpringBootTest(classes = MoxterTestApp.class, webEnvironment = SpringBootTest.WebEnvironment.MOCK)
@AutoConfigureMockMvc
@ActiveProfiles({"test"})
@TestInstance(TestInstance.Lifecycle.PER_CLASS) // Tells JUnit to create one single instance of 
    // the test class for the entire test run of that class => allows non-static @BeforeAll/@AfterAll
@Slf4j

class MoxterTest {

    @Autowired
    private MockMvc mockMvc;

    protected Moxter mx;

    @Test
    void shouldVerifySimpleGet() 
    {
        mx = Moxter.forTestClass(getClass())
                   .mockMvc(mockMvc)
                   .build();


        mx .caller()
           .call("BeforeAll");
    }
}