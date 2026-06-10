package com.emplanorte.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.emplanorte.dto.VentaRequest;
import com.emplanorte.model.Venta;
import com.emplanorte.service.VentaService;

@RestController
@RequestMapping("/api/ventas")
public class VentaController {

    @Autowired
    private VentaService ventaService;

    @GetMapping
    public ResponseEntity<List<Venta>> listarVentas() {
        return ResponseEntity.ok(ventaService.obtenerTodas());
    }

    // RF05, RF06, RF07, RF08 - Registrar Venta
    @PostMapping
    public ResponseEntity<?> registrarVenta(@RequestBody VentaRequest request) {
        try {
            Venta venta = ventaService.registrarVenta(request);
            return ResponseEntity.status(HttpStatus.CREATED).body(venta);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }
    @GetMapping("/{id}/detalles")
    public ResponseEntity<?> listarDetallesVenta(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(ventaService.obtenerDetalles(id));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }

    // Dentro de VentaController.java

    @GetMapping("/{id}")
    public ResponseEntity<?> obtenerVentaPorId(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(ventaService.obtenerPorId(id));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(e.getMessage());
        }
}

    @PutMapping("/{id}")
    public ResponseEntity<?> actualizarVenta(@PathVariable Long id, @RequestBody VentaRequest request) {
        try {
            return ResponseEntity.ok(ventaService.actualizarVenta(id, request));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }
    
}
