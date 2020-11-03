package com.docker.example.hello.controller;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {
  private final Logger logger = LoggerFactory.getLogger(this.getClass());

  @RequestMapping("/")
  public String hello() {
    // logger.info("이거?");
    return "Hello, yusung yo!!!!!";
  }
}
