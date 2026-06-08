package com.emplanorte.service;

import java.time.LocalDate;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.emplanorte.model.CategoriaGasto;
import com.emplanorte.model.Gasto;
import com.emplanorte.repository.CategoriaGastoRepository;
import com.emplanorte.repository.GastoRepository;

@Service
public class GastoService {

    @Autowired
    private GastoRepository gastoRepository;

    @Autowired
    private CategoriaGastoRepository categoriaGastoRepository;

    // Métodos de Gastos (RF09)
    public List<Gasto> obtenerTodos() {
        return gastoRepository.findAll();
    }

    public List<Gasto> obtenerPorFechas(LocalDate desde, LocalDate hasta) {
        return gastoRepository.findByFechaGastoBetween(desde, hasta);
    }

    public Gasto guardar(Gasto gasto) {
        if (gasto.getFechaGasto() == null) {
            gasto.setFechaGasto(LocalDate.now());
        }
        return gastoRepository.save(gasto);
    }
    public Gasto actualizarGasto(Long id, Gasto gastoActualizado) {
    Gasto gasto = gastoRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Gasto no encontrado"));

    gasto.setCategoria(gastoActualizado.getCategoria());
    gasto.setDescripcion(gastoActualizado.getDescripcion());
    gasto.setValor(gastoActualizado.getValor());
    gasto.setFechaGasto(gastoActualizado.getFechaGasto());

    return gastoRepository.save(gasto);
}

    // Métodos de Categorías de Gasto (RF10)
    public List<CategoriaGasto> obtenerCategoriasActivas() {
        return categoriaGastoRepository.findByActivoTrue();
    }

    public CategoriaGasto guardarCategoria(CategoriaGasto categoria) {
        categoria.setActivo(true);
        return categoriaGastoRepository.save(categoria);
    }
}
