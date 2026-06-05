package com.emplanorte.service;

import com.emplanorte.model.Usuario;
import com.emplanorte.repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import java.util.Optional;

@Service
public class AuthService {

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    public Optional<Usuario> login(String correo, String contrasena) {
        Optional<Usuario> usuarioOpt = usuarioRepository.findByCorreo(correo);
        
        if (usuarioOpt.isPresent()) {
            Usuario usuario = usuarioOpt.get();
            // Compara la contraseña en texto plano con el hash guardado (BCrypt)
            if (usuario.getActivo() && passwordEncoder.matches(contrasena, usuario.getContrasenaHash())) {
                return Optional.of(usuario);
            }
        }
        return Optional.empty();
    }
}
