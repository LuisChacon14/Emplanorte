package com.emplanorte.controller;

import com.emplanorte.model.Usuario;
import com.emplanorte.service.AuthService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.hamcrest.Matchers;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

import com.emplanorte.config.SecurityConfig;

/**
 * Pruebas de integración HTTP del endpoint POST /api/auth/login (RNF05 — Control de acceso).
 *
 * Organización:
 *   - Bloques "ComportamientoActual" : verifican lo que el código HACE hoy (deben PASAR).
 *   - Bloque  "ValidacionesEsperadas" : codifican lo que el Plan/usuario ESPERA pero que
 *                                        el código todavía NO implementa. Estas pruebas
 *                                        FALLAN intencionalmente y quedan como evidencia
 *                                        documentada del gap (mismo criterio que CP-44).
 *
 * Cada @DisplayName que empieza con [GAP] señala una prueba que se espera en ROJO.
 */
@WebMvcTest(AuthController.class)
@Import(SecurityConfig.class)
@DisplayName("AuthController — Integración HTTP /api/auth/login (RNF05)")
class AuthControllerTest {

    private static final String MSG_OBLIGATORIOS = "El correo y la contraseña son obligatorios";
    private static final String MSG_CREDENCIALES = "Credenciales incorrectas o usuario inactivo";
    private static final String CORREO_OK = "duvan@emplanorte.com";
    private static final String CLAVE_OK = "Admin2024*";

    @Autowired private MockMvc mockMvc;
    @Autowired private ObjectMapper objectMapper;
    @MockBean  private AuthService authService;

    private Usuario usuarioMock;

    @BeforeEach
    void setUp() {
        usuarioMock = new Usuario();
        usuarioMock.setId(1L);
        usuarioMock.setNombre("Duvan Alvarado");
        usuarioMock.setCorreo(CORREO_OK);
        usuarioMock.setRol("administrador");
        usuarioMock.setActivo(true);
    }

    private String json(Object body) throws Exception {
        return objectMapper.writeValueAsString(body);
    }

    // ════════════════════════════════════════════════════════════════════════
    //  CP-45 — Login exitoso (detallado): se valida CADA campo de la respuesta
    // ════════════════════════════════════════════════════════════════════════

    @Nested
    @DisplayName("CP-45 — Login exitoso (comportamiento actual, debe PASAR)")
    class LoginExitoso {

        @Test
        @DisplayName("CP-45a: credenciales válidas → 200 y la respuesta contiene TODOS los campos esperados")
        void login_valido_retornaTodosLosCampos() throws Exception {
            when(authService.login(CORREO_OK, CLAVE_OK)).thenReturn(Optional.of(usuarioMock));

            mockMvc.perform(post("/api/auth/login")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(json(Map.of("correo", CORREO_OK, "contrasena", CLAVE_OK))))
                    .andExpect(status().isOk())
                    .andExpect(content().contentTypeCompatibleWith(MediaType.APPLICATION_JSON))
                    .andExpect(jsonPath("$.mensaje").value("Inicio de sesión exitoso"))
                    .andExpect(jsonPath("$.id").value(1))
                    .andExpect(jsonPath("$.nombre").value("Duvan Alvarado"))
                    .andExpect(jsonPath("$.correo").value(CORREO_OK))
                    .andExpect(jsonPath("$.rol").value("administrador"))
                    .andExpect(jsonPath("$.token").value("dummy-jwt-token-for-1"));
        }

        @Test
        @DisplayName("CP-45b: la respuesta NUNCA expone el hash de la contraseña")
        void login_valido_noExponeHash() throws Exception {
            usuarioMock.setContrasenaHash("$2a$10$hashsecretobcrypt");
            when(authService.login(CORREO_OK, CLAVE_OK)).thenReturn(Optional.of(usuarioMock));

            mockMvc.perform(post("/api/auth/login")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(json(Map.of("correo", CORREO_OK, "contrasena", CLAVE_OK))))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.contrasenaHash").doesNotExist())
                    .andExpect(content().string(Matchers.not(Matchers.containsString("$2a$10$"))));
        }

        @Test
        @DisplayName("CP-45c: el controlador delega en AuthService.login con EXACTAMENTE las credenciales recibidas")
        void login_valido_delegaConCredencialesExactas() throws Exception {
            when(authService.login(CORREO_OK, CLAVE_OK)).thenReturn(Optional.of(usuarioMock));

            mockMvc.perform(post("/api/auth/login")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(json(Map.of("correo", CORREO_OK, "contrasena", CLAVE_OK))))
                    .andExpect(status().isOk());

            verify(authService, times(1)).login(CORREO_OK, CLAVE_OK);
            verifyNoMoreInteractions(authService);
        }

        @Test
        @DisplayName("CP-45d: campos extra en el JSON se ignoran y el login válido sigue dando 200")
        void login_conCamposExtra_seIgnoran() throws Exception {
            when(authService.login(CORREO_OK, CLAVE_OK)).thenReturn(Optional.of(usuarioMock));
            String body = "{\"correo\":\"" + CORREO_OK + "\",\"contrasena\":\"" + CLAVE_OK
                    + "\",\"campoExtra\":\"hola\",\"rol\":\"superadmin\"}";

            mockMvc.perform(post("/api/auth/login")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(body))
                    .andExpect(status().isOk())
                    // el rol viene del usuario real, NO del campo inyectado en el request
                    .andExpect(jsonPath("$.rol").value("administrador"));
        }
    }

    // ════════════════════════════════════════════════════════════════════════
    //  CP-46 — Credenciales inválidas (mensaje genérico, sin fuga de info)
    // ════════════════════════════════════════════════════════════════════════

    @Nested
    @DisplayName("CP-46 — Credenciales inválidas (comportamiento actual, debe PASAR)")
    class CredencialesInvalidas {

        @Test
        @DisplayName("CP-46a: contraseña incorrecta → 401 con mensaje EXACTO genérico")
        void login_contrasenaIncorrecta_retorna401MensajeExacto() throws Exception {
            when(authService.login(eq(CORREO_OK), any())).thenReturn(Optional.empty());

            mockMvc.perform(post("/api/auth/login")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(json(Map.of("correo", CORREO_OK, "contrasena", "claveErrada"))))
                    .andExpect(status().isUnauthorized())
                    .andExpect(content().string(Matchers.containsString(MSG_CREDENCIALES)));
        }

        @Test
        @DisplayName("CP-46b: usuario inexistente → 401 con el MISMO mensaje (no revela si el usuario existe)")
        void login_usuarioInexistente_mismoMensajeQueClaveMala() throws Exception {
            when(authService.login(any(), any())).thenReturn(Optional.empty());

            String respUsuarioMalo = mockMvc.perform(post("/api/auth/login")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(json(Map.of("correo", "noexiste@test.com", "contrasena", "x"))))
                    .andExpect(status().isUnauthorized())
                    .andReturn().getResponse().getContentAsString();

            String respClaveMala = mockMvc.perform(post("/api/auth/login")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(json(Map.of("correo", CORREO_OK, "contrasena", "claveErrada"))))
                    .andExpect(status().isUnauthorized())
                    .andReturn().getResponse().getContentAsString();

            // Ambos errores son indistinguibles → no se filtra si el correo existe
            org.assertj.core.api.Assertions.assertThat(respUsuarioMalo).isEqualTo(respClaveMala);
        }

        @Test
        @DisplayName("CP-46c: usuario inactivo (service devuelve vacío) → 401, no 200")
        void login_usuarioInactivo_retorna401() throws Exception {
            when(authService.login(any(), any())).thenReturn(Optional.empty());

            mockMvc.perform(post("/api/auth/login")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(json(Map.of("correo", CORREO_OK, "contrasena", CLAVE_OK))))
                    .andExpect(status().isUnauthorized());
        }
    }

    // ════════════════════════════════════════════════════════════════════════
    //  CP-46 (cont.) — Campos faltantes (null): el código SÍ los valida → 400
    // ════════════════════════════════════════════════════════════════════════

    @Nested
    @DisplayName("CP-46 — Campos null/ausentes (comportamiento actual, debe PASAR)")
    class CamposFaltantes {

        @Test
        @DisplayName("CP-46d: sin correo → 400 con mensaje EXACTO de campos obligatorios")
        void login_sinCorreo_retorna400ConMensaje() throws Exception {
            mockMvc.perform(post("/api/auth/login")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(json(Map.of("contrasena", CLAVE_OK))))
                    .andExpect(status().isBadRequest())
                    .andExpect(content().string(Matchers.containsString(MSG_OBLIGATORIOS)));
            verifyNoInteractions(authService);
        }

        @Test
        @DisplayName("CP-46e: sin contraseña → 400 con mensaje EXACTO de campos obligatorios")
        void login_sinContrasena_retorna400ConMensaje() throws Exception {
            mockMvc.perform(post("/api/auth/login")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(json(Map.of("correo", CORREO_OK))))
                    .andExpect(status().isBadRequest())
                    .andExpect(content().string(Matchers.containsString(MSG_OBLIGATORIOS)));
            verifyNoInteractions(authService);
        }

        @Test
        @DisplayName("CP-46f: body vacío {} → 400")
        void login_bodyVacio_retorna400() throws Exception {
            mockMvc.perform(post("/api/auth/login")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content("{}"))
                    .andExpect(status().isBadRequest())
                    .andExpect(content().string(Matchers.containsString(MSG_OBLIGATORIOS)));
        }

        @Test
        @DisplayName("CP-46g: correo y contraseña explícitamente null en el JSON → 400")
        void login_camposNullExplicitos_retorna400() throws Exception {
            mockMvc.perform(post("/api/auth/login")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content("{\"correo\":null,\"contrasena\":null}"))
                    .andExpect(status().isBadRequest());
            verifyNoInteractions(authService);
        }
    }

    // ════════════════════════════════════════════════════════════════════════
    //  CP-48 — Seguridad: inyección SQL en la capa HTTP (comportamiento actual)
    // ════════════════════════════════════════════════════════════════════════

    @Nested
    @DisplayName("CP-48 — Inyección SQL (comportamiento actual, debe PASAR)")
    class InyeccionSql {

        @Test
        @DisplayName("CP-48a: usuario \"admin' OR '1'='1\" → se trata como credencial normal, 401 sin error 500")
        void login_inyeccionSqlEnCorreo_retorna401SinEjecutar() throws Exception {
            when(authService.login(any(), any())).thenReturn(Optional.empty());

            mockMvc.perform(post("/api/auth/login")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(json(Map.of("correo", "admin' OR '1'='1", "contrasena", "x"))))
                    .andExpect(status().isUnauthorized())
                    .andExpect(content().string(Matchers.not(Matchers.containsString("SQL"))));
        }

        @Test
        @DisplayName("CP-48b: payload con '; DROP TABLE en la contraseña → 401, nunca 200")
        void login_inyeccionSqlEnContrasena_noAutentica() throws Exception {
            when(authService.login(any(), any())).thenReturn(Optional.empty());

            mockMvc.perform(post("/api/auth/login")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(json(Map.of("correo", CORREO_OK, "contrasena", "'; DROP TABLE usuarios;--"))))
                    .andExpect(status().isUnauthorized());
        }
    }

    // ════════════════════════════════════════════════════════════════════════
    //  Robustez del endpoint (comportamiento actual)
    // ════════════════════════════════════════════════════════════════════════

    @Nested
    @DisplayName("Robustez HTTP (comportamiento actual, debe PASAR)")
    class RobustezHttp {

        @Test
        @DisplayName("ROB-1: JSON malformado → 400")
        void login_jsonMalformado_retorna400() throws Exception {
            mockMvc.perform(post("/api/auth/login")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content("{\"correo\": \"x\", "))
                    .andExpect(status().isBadRequest());
        }

        @Test
        @DisplayName("ROB-2: petición sin body → 400")
        void login_sinBody_retorna400() throws Exception {
            mockMvc.perform(post("/api/auth/login")
                            .contentType(MediaType.APPLICATION_JSON))
                    .andExpect(status().isBadRequest());
        }

        @Test
        @DisplayName("ROB-3: Content-Type text/plain en vez de JSON → 415 Unsupported Media Type")
        void login_contentTypeInvalido_retorna415() throws Exception {
            mockMvc.perform(post("/api/auth/login")
                            .contentType(MediaType.TEXT_PLAIN)
                            .content("correo=x&contrasena=y"))
                    .andExpect(status().isUnsupportedMediaType());
        }

        @Test
        @DisplayName("ROB-4: método GET sobre /api/auth/login → 405 Method Not Allowed")
        void login_metodoGet_retorna405() throws Exception {
            mockMvc.perform(get("/api/auth/login"))
                    .andExpect(status().isMethodNotAllowed());
        }
    }

    // ════════════════════════════════════════════════════════════════════════
    //  VALIDACIONES ESPERADAS NO IMPLEMENTADAS  →  ESTAS PRUEBAS FALLAN (ROJO)
    //  Quedan como evidencia documentada del gap, igual que CP-44.
    // ════════════════════════════════════════════════════════════════════════

    @Nested
    @DisplayName("[GAP] Validaciones esperadas aún NO implementadas (se esperan en ROJO)")
    class ValidacionesEsperadasNoImplementadas {

        // ── Valores vacíos / en blanco ─────────────────────────────────────────
        // El controlador solo verifica null, no cadenas vacías ni espacios:
        // hoy "" pasa al service y devuelve 401, cuando lo correcto sería 400.

        @Test
        @DisplayName("[GAP] CP-VAL-1: correo vacío \"\" debería dar 400 con mensaje claro (hoy da 401)")
        void login_correoVacio_deberiaRetornar400() throws Exception {
            mockMvc.perform(post("/api/auth/login")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(json(Map.of("correo", "", "contrasena", CLAVE_OK))))
                    .andExpect(status().isBadRequest())
                    .andExpect(content().string(Matchers.containsString("correo")));
        }

        @Test
        @DisplayName("[GAP] CP-VAL-2: contraseña vacía \"\" debería dar 400 (al menos un caracter) (hoy da 401)")
        void login_contrasenaVacia_deberiaRetornar400() throws Exception {
            mockMvc.perform(post("/api/auth/login")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(json(Map.of("correo", CORREO_OK, "contrasena", ""))))
                    .andExpect(status().isBadRequest())
                    .andExpect(content().string(Matchers.containsString("contraseña")));
        }

        @Test
        @DisplayName("[GAP] CP-VAL-3: correo solo espacios \"   \" debería dar 400 tras trim (hoy da 401)")
        void login_correoSoloEspacios_deberiaRetornar400() throws Exception {
            mockMvc.perform(post("/api/auth/login")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(json(Map.of("correo", "   ", "contrasena", CLAVE_OK))))
                    .andExpect(status().isBadRequest());
        }

        @Test
        @DisplayName("[GAP] CP-VAL-4: contraseña solo espacios \"   \" debería dar 400 (hoy da 401)")
        void login_contrasenaSoloEspacios_deberiaRetornar400() throws Exception {
            mockMvc.perform(post("/api/auth/login")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(json(Map.of("correo", CORREO_OK, "contrasena", "   "))))
                    .andExpect(status().isBadRequest());
        }

        // ── Formato de correo ──────────────────────────────────────────────────

        @Test
        @DisplayName("[GAP] CP-VAL-5: correo sin formato válido \"noesuncorreo\" debería dar 400 (hoy da 401)")
        void login_correoFormatoInvalido_deberiaRetornar400() throws Exception {
            mockMvc.perform(post("/api/auth/login")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(json(Map.of("correo", "noesuncorreo", "contrasena", CLAVE_OK))))
                    .andExpect(status().isBadRequest())
                    .andExpect(content().string(Matchers.containsString("formato")));
        }

        @Test
        @DisplayName("[GAP] CP-VAL-6: correo con espacios internos \"a b@c.com\" debería dar 400 (hoy da 401)")
        void login_correoConEspacios_deberiaRetornar400() throws Exception {
            mockMvc.perform(post("/api/auth/login")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(json(Map.of("correo", "a b@c.com", "contrasena", CLAVE_OK))))
                    .andExpect(status().isBadRequest());
        }

        // ── Complejidad de contraseña: al menos un caracter + una mayúscula ─────

        @Test
        @DisplayName("[GAP] CP-VAL-7: contraseña sin ninguna mayúscula \"admin2024*\" debería dar 400 (hoy 401)")
        void login_contrasenaSinMayuscula_deberiaRetornar400() throws Exception {
            mockMvc.perform(post("/api/auth/login")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(json(Map.of("correo", CORREO_OK, "contrasena", "admin2024*"))))
                    .andExpect(status().isBadRequest())
                    .andExpect(content().string(Matchers.containsString("mayúscula")));
        }

        @Test
        @DisplayName("[GAP] CP-VAL-8: contraseña de un solo caracter en minúscula \"a\" debería dar 400 (hoy 401)")
        void login_contrasenaUnCaracterMinuscula_deberiaRetornar400() throws Exception {
            mockMvc.perform(post("/api/auth/login")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(json(Map.of("correo", CORREO_OK, "contrasena", "a"))))
                    .andExpect(status().isBadRequest());
        }

        // ── CP-47 del Plan: bloqueo tras intentos fallidos ─────────────────────

        @Test
        @DisplayName("[GAP] CP-47: tras 5 intentos fallidos debería bloquear (429), hoy siempre responde 401")
        void login_cincoIntentosFallidos_deberiaBloquear() throws Exception {
            when(authService.login(any(), any())).thenReturn(Optional.empty());

            Map<String, String> credsMalas = new HashMap<>();
            credsMalas.put("correo", CORREO_OK);
            credsMalas.put("contrasena", "claveErrada");

            for (int i = 0; i < 5; i++) {
                mockMvc.perform(post("/api/auth/login")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(json(credsMalas)))
                        .andExpect(status().isUnauthorized());
            }

            // El 6º intento debería estar bloqueado (no implementado → hoy sigue dando 401)
            mockMvc.perform(post("/api/auth/login")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(json(credsMalas)))
                    .andExpect(status().isTooManyRequests());
        }
    }
}
