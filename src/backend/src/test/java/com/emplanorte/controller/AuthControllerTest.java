package com.emplanorte.controller;

import com.emplanorte.model.Usuario;
import com.emplanorte.service.AuthService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Map;
import java.util.Optional;

import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;
import com.emplanorte.config.SecurityConfig;

@WebMvcTest(AuthController.class)
@Import(SecurityConfig.class)
@DisplayName("AuthController — Integración HTTP /api/auth")
class AuthControllerTest {

    @Autowired private MockMvc mockMvc;
    @Autowired private ObjectMapper objectMapper;
    @MockBean  private AuthService authService;

    private Usuario usuarioMock;

    @BeforeEach
    void setUp() {
        usuarioMock = new Usuario();
        usuarioMock.setId(1L);
        usuarioMock.setNombre("Duvan Alvarado");
        usuarioMock.setCorreo("duvan@emplanorte.com");
        usuarioMock.setRol("administrador");
        usuarioMock.setActivo(true);
    }

    // ─── CP-45  Login exitoso ─────────────────────────────────────────────────

    @Test
    @DisplayName("CP-45: POST /api/auth/login con credenciales válidas — HTTP 200 con datos del usuario")
    void login_credencialesValidas_retorna200ConUsuario() throws Exception {
        when(authService.login("duvan@emplanorte.com", "Admin2024*"))
                .thenReturn(Optional.of(usuarioMock));

        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(
                                Map.of("correo", "duvan@emplanorte.com", "contrasena", "Admin2024*"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.nombre").value("Duvan Alvarado"))
                .andExpect(jsonPath("$.rol").value("administrador"))
                .andExpect(jsonPath("$.token").exists());
    }

    // ─── CP-46  Credenciales inválidas ────────────────────────────────────────

    @Test
    @DisplayName("CP-46: POST /api/auth/login con credenciales incorrectas — HTTP 401")
    void login_credencialesInvalidas_retorna401() throws Exception {
        when(authService.login(any(), any())).thenReturn(Optional.empty());

        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(
                                Map.of("correo", "duvan@emplanorte.com", "contrasena", "claveErrada"))))
                .andExpect(status().isUnauthorized());
    }

    @Test
    @DisplayName("CP-46b: POST /api/auth/login sin correo — HTTP 400")
    void login_sinCorreo_retorna400() throws Exception {
        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(
                                Map.of("contrasena", "Admin2024*"))))
                .andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("CP-46c: POST /api/auth/login sin contraseña — HTTP 400")
    void login_sinContrasena_retorna400() throws Exception {
        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(
                                Map.of("correo", "duvan@emplanorte.com"))))
                .andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("CP-46d: POST /api/auth/login con body vacío — HTTP 400")
    void login_bodyVacio_retorna400() throws Exception {
        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{}"))
                .andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("CP-46e: Mensaje de error genérico — no revela si el usuario existe")
    void login_fallido_mensajeGenerico() throws Exception {
        when(authService.login(any(), any())).thenReturn(Optional.empty());

        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(
                                Map.of("correo", "noexiste@test.com", "contrasena", "cualquier"))))
                .andExpect(status().isUnauthorized())
                .andExpect(content().string(org.hamcrest.Matchers.containsString("Credenciales incorrectas")));
    }
}
