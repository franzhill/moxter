package dev.moxter.infra;

import org.springframework.web.bind.annotation.*;
import java.util.Map;

@RestController
@RequestMapping("/moxter-test")
public class TestController {

    @GetMapping("/simple")
    public Map<String, String> getSimple() {
        return Map.of("status", "ok", "message", "Moxter is alive");
    }

    @PostMapping("/echo")
    public Map<String, Object> echo(@RequestBody Map<String, Object> body, 
                                   @RequestHeader(value = "X-Mox-Header", required = false) String header) {
        body.put("receivedHeader", header);
        return body;
    }
}