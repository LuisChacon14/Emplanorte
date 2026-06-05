package com.emplanorte.service;

import com.emplanorte.model.Producto;
import com.emplanorte.repository.ProductoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class ProductoService {

    @Autowired
    private ProductoRepository productoRepository;

    public List<Producto> obtenerTodosActivos() {
        return productoRepository.findByActivoTrue();
    }

    // RF04 - Ordenamiento de productos del inventario por diferentes criterios
    public List<Producto> obtenerTodosActivosOrdenados(String criterio) {
        Sort sort = Sort.by(Sort.Direction.ASC, "nombre"); // Criterio por defecto
        
        if (criterio != null) {
            switch (criterio.toLowerCase()) {
                case "nombre":
                    sort = Sort.by(Sort.Direction.ASC, "nombre");
                    break;
                case "tamano":
                case "capacidad":
                    sort = Sort.by(Sort.Direction.ASC, "capacidadMl");
                    break;
                case "categoria":
                    sort = Sort.by(Sort.Direction.ASC, "categoria.nombre");
                    break;
                case "cantidad":
                case "stock":
                    sort = Sort.by(Sort.Direction.ASC, "stockDisponible");
                    break;
            }
        }
        return productoRepository.findAll(sort).stream()
                .filter(Producto::getActivo)
                .toList();
    }

    public Optional<Producto> obtenerPorId(Long id) {
        return productoRepository.findById(id).filter(Producto::getActivo);
    }

    public Producto guardar(Producto producto) {
        producto.setActivo(true);
        return productoRepository.save(producto);
    }

    public Producto actualizar(Long id, Producto productoDetalles) {
        Producto producto = productoRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Producto no encontrado con el ID: " + id));

        producto.setCodigo(productoDetalles.getCodigo());
        producto.setNombre(productoDetalles.getNombre());
        producto.setDescripcion(productoDetalles.getDescripcion());
        producto.setCategoria(productoDetalles.getCategoria());
        producto.setCapacidadMl(productoDetalles.getCapacidadMl());
        producto.setCostoUnitario(productoDetalles.getCostoUnitario());
        producto.setPrecioVenta(productoDetalles.getPrecioVenta());
        producto.setStockDisponible(productoDetalles.getStockDisponible());
        producto.setStockMinimo(productoDetalles.getStockMinimo());
        producto.setUnidadMedida(productoDetalles.getUnidadMedida());

        return productoRepository.save(producto);
    }

    // RF02 - Eliminación lógica (desactivar) de productos para no romper históricos de ventas
    public void desactivar(Long id) {
        Producto producto = productoRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Producto no encontrado con el ID: " + id));
        producto.setActivo(false);
        productoRepository.save(producto);
    }
}
